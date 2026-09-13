import { useEffect, useMemo, useState } from 'react';
import { MapContainer, GeoJSON, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { loadMapData } from './loadMapData';
import { getCity } from './cities';
import { combinedValue } from './crimeSeries';
import { TOPICS } from './topics';
import SearchBar from './SearchBar';

const CHORO = ['#F8E2C4', '#F4C48A', '#F25A24', '#C43A16', '#9C2E11'];
const FALLBACK = ['#F7C48A', '#F25A24', '#C43A16', '#9C2E11', '#E8A05A', '#D9783A'];
const NODATA = '#E8C9A0';

function displayName(name = '') {
  return name.replace(/\s*\(\d+\)\s*$/, '').trim();
}

function featureName(feature) {
  return feature.properties.AREA_NAME || feature.properties.name || 'Unknown';
}

function metricValue(feature, topics, year) {
  return combinedValue(feature.properties?.byYear?.[year], topics);
}

function choroplethColor(value, values) {
  if (value == null || !values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  if (sorted[0] === sorted[sorted.length - 1]) return CHORO[0];
  const rank = sorted.filter((item) => item <= value).length / sorted.length;
  const index = Math.min(CHORO.length - 1, Math.max(0, Math.ceil(rank * CHORO.length) - 1));
  return CHORO[index];
}

function collectRings(geometry) {
  if (geometry.type === 'Polygon') return geometry.coordinates;
  if (geometry.type === 'MultiPolygon') return geometry.coordinates.flat();
  return [];
}

function adjacentColors(features) {
  const vertexToIds = new Map();

  features.forEach((feature, index) => {
    const seen = new Set();
    collectRings(feature.geometry).forEach((ring) => {
      ring.forEach(([x, y]) => {
        const key = `${x.toFixed(4)}|${y.toFixed(4)}`;
        if (seen.has(key)) return;
        seen.add(key);
        const ids = vertexToIds.get(key);
        if (ids) ids.push(index);
        else vertexToIds.set(key, [index]);
      });
    });
  });

  const neighbors = features.map(() => new Set());
  vertexToIds.forEach((ids) => {
    const unique = [...new Set(ids)];
    for (let i = 0; i < unique.length; i += 1) {
      for (let j = i + 1; j < unique.length; j += 1) {
        neighbors[unique[i]].add(unique[j]);
        neighbors[unique[j]].add(unique[i]);
      }
    }
  });

  const colorIndex = new Array(features.length).fill(-1);
  features.forEach((_, index) => {
    const used = new Set(
      [...neighbors[index]].map((n) => colorIndex[n]).filter((c) => c >= 0)
    );
    let next = 0;
    while (used.has(next)) next += 1;
    colorIndex[index] = next;
  });

  const colors = new Map();
  features.forEach((feature, index) => {
    colors.set(featureName(feature), colorIndex[index]);
  });
  return colors;
}

function FitCity({ geoData, selectedHood }) {
  const map = useMap();

  useEffect(() => {
    if (!geoData) return;
    let cancelled = false;

    const apply = (animate) => {
      if (cancelled) return;
      map.invalidateSize();
      const cityBounds = L.geoJSON(geoData).getBounds();
      map.setMaxBounds(cityBounds.pad(0.14));

      if (!selectedHood) {
        map.setMinZoom(7);
        map.fitBounds(cityBounds, {
          padding: [10, 10],
          maxZoom: 14,
          animate,
        });
        map.setMinZoom(Math.max(8, map.getZoom() - 0.55));
        return;
      }

      const feature = geoData.features.find((f) => featureName(f) === selectedHood);
      if (!feature) return;
      map.fitBounds(L.geoJSON(feature).getBounds(), {
        padding: [48, 48],
        maxZoom: 14,
        animate,
      });
    };

    apply(false);
    const later = setTimeout(() => apply(false), 160);

    const container = map.getContainer();
    let resizeTimer;
    const observer = new ResizeObserver(() => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => apply(true), 180);
    });
    observer.observe(container);

    return () => {
      cancelled = true;
      clearTimeout(later);
      clearTimeout(resizeTimer);
      observer.disconnect();
    };
  }, [geoData, selectedHood, map]);

  return null;
}

function InvalidateSize() {
  const map = useMap();
  useEffect(() => {
    const id = requestAnimationFrame(() => map.invalidateSize());
    return () => cancelAnimationFrame(id);
  }, [map]);
  return null;
}

const MapComponent = ({ cityId, isDarkMode, topics, year }) => {
  const city = getCity(cityId);
  const [geoData, setGeoData] = useState(null);
  const [hoodNames, setHoodNames] = useState([]);
  const [selectedHood, setSelectedHood] = useState('');
  const topicKey = Object.entries(topics)
    .filter(([, on]) => on)
    .map(([id]) => id)
    .join('-');

  useEffect(() => {
    setSelectedHood('');
    setGeoData(null);
    loadMapData(city.id)
      .then((result) => {
        setGeoData(result.geoData);
        const names = [
          ...new Set(result.geoData.features.map(featureName).filter(Boolean)),
        ].sort();
        setHoodNames(names);
      })
      .catch((err) => console.error('Map data load error:', err));
  }, [city.id]);

  const colorIndexByName = useMemo(
    () => (geoData ? adjacentColors(geoData.features) : new Map()),
    [geoData]
  );

  const metricValues = useMemo(() => {
    if (!geoData) return [];
    return geoData.features
      .map((feature) => metricValue(feature, topics, year))
      .filter((value) => value != null);
  }, [geoData, topics, year]);

  const style = (feature) => {
    const name = featureName(feature);
    const active = name === selectedHood;
    const value = metricValue(feature, topics, year);
    const scaled = choroplethColor(value, metricValues);
    const color = scaled
      ?? (metricValues.length ? NODATA : FALLBACK[(colorIndexByName.get(name) ?? 0) % FALLBACK.length]);

    return {
      fillColor: color,
      fillOpacity: 1,
      color: '#FFFFFF',
      weight: active ? 2.2 : 1,
      opacity: 1,
      lineJoin: 'round',
      lineCap: 'round',
      smoothFactor: 1.15,
    };
  };

  const onEachFeature = (feature, layer) => {
    const name = featureName(feature);
    if (!name) return;

    const statsForYear = feature.properties.byYear?.[year];
    const activeTopics = TOPICS.filter((topic) => topics[topic.id] && statsForYear);
    const stats = activeTopics.length
      ? `${displayName(name)} — ${year}  ${activeTopics
          .map((topic) => `${topic.label} ${statsForYear[topic.id] ?? '—'}`)
          .join('  ·  ')}`
      : displayName(name);

    layer.bindTooltip(stats, {
      sticky: true,
      direction: 'top',
      className: 'atlas-tooltip',
      offset: [0, -8],
    });

    layer.on({
      mouseover: (e) => {
        const target = e.target;
        target.setStyle({
          weight: 2.2,
          fillOpacity: 1,
          color: '#FFFFFF',
        });
        target.bringToFront();
      },
      mouseout: (e) => {
        e.target.setStyle(style(feature));
      },
      click: () => setSelectedHood(name),
    });
  };

  return (
    <div className="map-block">
      <SearchBar
        city={city}
        hoodNames={hoodNames}
        selectedHood={selectedHood}
        onSelect={setSelectedHood}
      />

      <div className="map-stage">
        <MapContainer
          center={city.center}
          zoom={11}
          scrollWheelZoom
          style={{ height: '100%', width: '100%' }}
          zoomControl={false}
          attributionControl={false}
          maxBoundsViscosity={0.85}
        >
          <FitCity geoData={geoData} selectedHood={selectedHood} />
          <InvalidateSize />
          {geoData && (
            <GeoJSON
              key={`${city.id}-${year}-${topicKey}-${isDarkMode}`}
              data={geoData}
              style={style}
              onEachFeature={onEachFeature}
            />
          )}
        </MapContainer>
        <div className="map-legend">
          <span>High</span>
          <span className="map-legend-bar" />
          <span>Low</span>
        </div>
      </div>
    </div>
  );
};

export default MapComponent;
