import { supabase } from './supabaseClient';
import { seedFallback } from './seedFallback';
import { getCity } from './cities';
import { addYearStats, yearStatsFromRow } from './crimeSeries';

const NAME_ALIASES = {
  'weston pellam park': 'weston pelham park',
  'central business district': 'downtown',
};

// Older 140-neighbourhood polygons that Toronto later split in HOOD_158.
const SPLIT_PLACES = {
  'islington city centre west': ['islington', 'etobicoke city centre'],
  'dovercourt wallace emerson junction': ['dovercourt village', 'junction wallace emerson'],
  niagara: ['fort york liberty village', 'wellington place'],
  lamoreaux: ['east lamoreaux', 'lamoreaux west'],
  bendale: ['bendale south', 'bendale glen andrew'],
  'downsview roding cfb': ['downsview', 'oakdale beverley heights'],
  'willowdale east': ['east willowdale', 'yonge doris'],
  rouge: ['west rouge', 'morningside heights'],
  'mount pleasant west': ['north toronto', 'south eglinton davisville'],
  'parkwoods donalda': ['fenside parkwoods', 'parkwoods oconnor hills'],
  woburn: ['woburn north', 'golfdale cedarbrae woburn'],
  malvern: ['malvern east', 'malvern west'],
  'mimico includes humber bay shores': ['mimico queensway', 'humber bay shores'],
};

export function normalizeName(name = '') {
  return name
    .replace(/\s*\(\d+\)\s*$/, '')
    .toLowerCase()
    .replace(/[.’']/g, '')
    .replace(/[-.]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function canonicalName(name = '') {
  const normalized = normalizeName(name);
  return NAME_ALIASES[normalized] ?? normalized;
}

function featureDisplayName(feature) {
  return (
    feature.properties.AREA_NAME ||
    feature.properties.name ||
    feature.properties.NOM ||
    'Unknown'
  );
}

function featureHoodCode(feature) {
  const raw = feature.properties.AREA_S_CD ?? feature.properties.HOOD_ID ?? feature.properties['hood id'];
  const code = parseInt(String(raw ?? ''), 10);
  return Number.isFinite(code) ? code : null;
}

function buildByYear(stats) {
  const byYear = {};
  const rows = Array.isArray(stats) ? stats : stats ? [stats] : [];
  rows.forEach((row) => {
    const year = row.Year;
    const values = yearStatsFromRow(row);
    if (year == null || !values) return;
    byYear[year] = values;
  });
  return Object.keys(byYear).length ? byYear : null;
}

function mergeByYear(parts) {
  const byYear = {};
  parts.forEach((part) => {
    if (!part) return;
    Object.entries(part).forEach(([year, stats]) => {
      byYear[year] = addYearStats(byYear[year], stats);
    });
  });
  return Object.keys(byYear).length ? byYear : null;
}

function fallbackByYear(row) {
  if (row.assault == null && row.robbery == null) return null;
  return {
    [row.year ?? 2024]: {
      assault: row.assault ?? null,
      robbery: row.robbery ?? null,
      autoTheft: null,
      breakEnter: null,
      theft: null,
      theftFromMv: null,
    },
  };
}

export async function loadMapData(cityId = 'toronto') {
  const city = getCity(cityId);
  const geoRes = await fetch(city.geojson);
  const geoData = await geoRes.json();

  const features = geoData.features.map((feature) => ({
    ...feature,
    properties: {
      ...feature.properties,
      AREA_NAME: featureDisplayName(feature),
    },
  }));

  if (!city.hasCrime) {
    return {
      geoData: { type: 'FeatureCollection', features },
      source: 'geojson',
      hasCrime: false,
    };
  }

  const { data: rows, error } = await supabase
    .from('neighbourhoods')
    .select(
      'id, neighbourhood, "hood id", city, crime_stats_indicator("Year", "Assault", "Robbery", "Auto Theft", "Break & Enter", "Theft Over", "Theft From MV")'
    )
    .eq('city', cityId);

  if (error) {
    console.error('Supabase neighbourhoods error:', error);
  }

  const supabaseRows = error ? [] : rows ?? [];

  const byName = new Map();
  const byHood = new Map();

  const attributeRows = supabaseRows.length
    ? supabaseRows.map((row) => ({
        neighbourhood: row.neighbourhood,
        hoodId: row['hood id'],
        byYear: buildByYear(row.crime_stats_indicator),
      }))
    : cityId === 'toronto'
      ? seedFallback.map((row) => ({
          neighbourhood: row.neighbourhood,
          hoodId: null,
          byYear: fallbackByYear(row),
        }))
      : [];

  for (const row of attributeRows) {
    const key = canonicalName(row.neighbourhood);
    byName.set(key, row);
    if (row.hoodId != null) byHood.set(Number(row.hoodId), row);
  }

  const joined = features.map((feature) => {
    const nameKey = canonicalName(feature.properties.AREA_NAME);
    const hoodCode = featureHoodCode(feature);
    const exact = byName.get(nameKey) || (hoodCode != null ? byHood.get(hoodCode) : null);
    const splitNames = SPLIT_PLACES[nameKey];
    const extra = exact
      ? exact
      : splitNames
        ? {
            neighbourhood: feature.properties.AREA_NAME,
            byYear: mergeByYear(splitNames.map((name) => byName.get(name)?.byYear)),
          }
        : {};

    return {
      ...feature,
      properties: {
        ...feature.properties,
        ...extra,
      },
    };
  });

  return {
    geoData: { type: 'FeatureCollection', features: joined },
    source: supabaseRows.length ? 'supabase' : 'seed',
    hasCrime: true,
    error: error?.message,
  };
}
