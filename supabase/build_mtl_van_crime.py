#!/usr/bin/env python3
"""Aggregate official Montreal and Vancouver crime counts into SQL inserts."""

import csv
import json
import re
from collections import defaultdict
from pathlib import Path

import fitz

ROOT = Path("/Users/danielkaiyali/Documents/Coding/danielsmapping")
OUT = ROOT / "supabase/batches"
YEARS = (2020, 2021, 2022, 2023, 2024)

VAN_PDF_NAMES = {
    "Arbutus Ridge": "Arbutus Ridge",
    "Central Business District": "Downtown",
    "Dunbar - Southlands": "Dunbar-Southlands",
    "Fairview": "Fairview",
    "Grandview - Woodland": "Grandview-Woodland",
    "Hastings - Sunrise": "Hastings-Sunrise",
    "Kensington - Cedar Cottage": "Kensington-Cedar Cottage",
    "Kerrisdale": "Kerrisdale",
    "Killarney": "Killarney",
    "Kitsilano": "Kitsilano",
    "Marpole": "Marpole",
    "Mount Pleasant": "Mount Pleasant",
    "Oakridge": "Oakridge",
    "Renfrew - Collingwood": "Renfrew-Collingwood",
    "Riley Park": "Riley Park",
    "Shaughnessy": "Shaughnessy",
    "South Cambie": "South Cambie",
    "Strathcona": "Strathcona",
    "Sunset": "Sunset",
    "Victoria - Fraserview": "Victoria-Fraserview",
    "West End": "West End",
    "West Point Grey": "West Point Grey",
}


def point_in_ring(x, y, ring):
    inside = False
    j = len(ring) - 1
    for i, (xi, yi, *_) in enumerate(ring):
        xj, yj = ring[j][0], ring[j][1]
        if (yi > y) != (yj > y):
            slope = (xj - xi) * (y - yi) / ((yj - yi) or 1e-16) + xi
            if x < slope:
                inside = not inside
        j = i
    return inside


def load_polygons(geojson_path):
    data = json.loads(Path(geojson_path).read_text())
    features = []
    for feature in data["features"]:
        name = feature["properties"]["AREA_NAME"]
        geom = feature["geometry"]
        polygons = geom["coordinates"] if geom["type"] == "MultiPolygon" else [geom["coordinates"]]
        boxes = []
        for polygon in polygons:
            xs = [p[0] for p in polygon[0]]
            ys = [p[1] for p in polygon[0]]
            boxes.append((min(xs), min(ys), max(xs), max(ys), polygon))
        features.append((name, boxes))
    return features


def locate(lon, lat, features):
    for name, boxes in features:
        for minx, miny, maxx, maxy, polygon in boxes:
            if lon < minx or lon > maxx or lat < miny or lat > maxy:
                continue
            if point_in_ring(lon, lat, polygon[0]) and all(
                not point_in_ring(lon, lat, hole) for hole in polygon[1:]
            ):
                return name
    return None


def parse_vancouver_pdfs():
    rows = {}
    for year in YEARS:
        text = fitz.open(f"/tmp/citycrime/vpd{year}.pdf")[0].get_text("text")
        # 2020 repeats every token 4 times
        if text.count("VANCOUVER POLICE DEPARTMENT") > 2:
            tokens = text.splitlines()
            cleaned = []
            i = 0
            while i < len(tokens):
                cleaned.append(tokens[i])
                i += 4 if i + 3 < len(tokens) and tokens[i] == tokens[i + 1] == tokens[i + 2] == tokens[i + 3] else 1
            text = "\n".join(cleaned)

        current = None
        nums = []
        for raw in text.splitlines():
            line = raw.strip()
            if not line or line in {
                "VANCOUVER POLICE DEPARTMENT",
                "REPORTED CRIME INCIDENT STATISTICS BY NEIGHBOURHOOD",
                "Neighbourhood",
                "Sex",
                "Offences",
                "Assaults",
                "Robbery",
                "B&E",
                "Theft of MV",
                "Theft from",
                "Auto",
                "Theft<>$5K",
                "Arson",
                "Mischief",
                "Offensive",
                "Weapons",
                "Please refer to the website for data disclaimers and limitations",
            } or line.startswith("Data extracted") or line == str(year) or line == "GRAND TOTAL":
                if line == "GRAND TOTAL":
                    current = None
                    nums = []
                continue
            if re.fullmatch(r"-?\d+", line):
                if current:
                    nums.append(int(line))
                    if len(nums) == 10:
                        sex, assault, robbery, bne, auto, tfmv, theft, _arson, _mischief, _weapons = nums
                        rows[(current, year)] = {
                            "assault": assault,
                            "robbery": robbery,
                            "autoTheft": auto,
                            "breakEnter": bne,
                            "theft": theft,
                            "theftFromMv": tfmv,
                        }
                        current = None
                        nums = []
                continue
            if line in VAN_PDF_NAMES:
                current = VAN_PDF_NAMES[line]
                nums = []
    return rows


def aggregate_montreal():
    features = load_polygons(ROOT / "public/montreal.geojson")
    counts = defaultdict(lambda: defaultdict(int))
    pdq_place = defaultdict(lambda: defaultdict(int))
    cat_map = {
        "Introduction": "breakEnter",
        "Vol dans / sur véhicule à moteur": "theftFromMv",
        "Vol de véhicule à moteur": "autoTheft",
        "Vols qualifiés": "robbery",
    }

    with open("/tmp/citycrime/montreal_actes.csv", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            try:
                year = int(row["DATE"][:4])
            except (TypeError, ValueError):
                continue
            if year not in YEARS:
                continue
            topic = cat_map.get(row["CATEGORIE"])
            try:
                lon = float(row["LONGITUDE"])
                lat = float(row["LATITUDE"])
            except (TypeError, ValueError):
                lon = lat = 0
            if not (-80 < lon < -70 and 44 < lat < 47):
                continue
            place = locate(lon, lat, features)
            if not place:
                continue
            if topic:
                counts[(place, year)][topic] += 1
            pdq = str(row.get("PDQ") or "").lstrip("0") or row.get("PDQ")
            if year >= 2023 and pdq:
                pdq_place[(year, pdq)][place] += 1

    bilan = defaultdict(lambda: defaultdict(int))
    with open("/tmp/citycrime/montreal_bilan.csv", encoding="latin-1") as handle:
        for row in csv.DictReader(handle, delimiter=";"):
            try:
                year = int(row["ANNEE"])
            except (TypeError, ValueError):
                continue
            if year not in YEARS:
                continue
            subgroup = row["SOUS-GROUPE"]
            if subgroup.startswith("01-04"):
                topic = "assault"
            elif subgroup.startswith("02-04"):
                topic = "theft"
            else:
                continue
            try:
                total = int(row["TOTAL"] or 0)
            except ValueError:
                total = 0
            bilan[(year, str(row["PDQ"]))][topic] += total

    for (year, pdq), topics in bilan.items():
        weights = pdq_place.get((year, pdq))
        if not weights:
            continue
        weight_total = sum(weights.values()) or 1
        for place, weight in weights.items():
            share = weight / weight_total
            for topic, value in topics.items():
                counts[(place, year)][topic] += int(round(value * share))

    # Official assault/theft exist only from 2023. Scale those place totals
    # by each earlier year's official property/robbery volume so every topic
    # has a 2020-2024 value.
    places = {place for place, _year in counts}
    for place in places:
        base = counts.get((place, 2023), {})
        volume_2023 = sum(
            base.get(key, 0) or 0
            for key in ("robbery", "autoTheft", "breakEnter", "theftFromMv")
        ) or 1
        for year in (2020, 2021, 2022):
            current = counts[(place, year)]
            volume = sum(
                current.get(key, 0) or 0
                for key in ("robbery", "autoTheft", "breakEnter", "theftFromMv")
            )
            factor = volume / volume_2023
            for topic in ("assault", "theft"):
                if current.get(topic) is None and base.get(topic) is not None:
                    current[topic] = int(round((base[topic] or 0) * factor))

    return counts


def sql_literal(value):
    return "null" if value is None else str(int(value))


def write_city_sql(city, names, rows):
    for year in YEARS:
        hood_codes = []
        totals = []
        assaults = []
        autos = []
        bnes = []
        robs = []
        thefts = []
        tfmvs = []
        for name, code in names:
            stats = rows.get((name, year), {})
            assault = stats.get("assault")
            robbery = stats.get("robbery")
            auto = stats.get("autoTheft")
            bne = stats.get("breakEnter")
            theft = stats.get("theft")
            tfmv = stats.get("theftFromMv")
            if all(v is None for v in (assault, robbery, auto, bne, theft, tfmv)):
                continue
            total = sum(v for v in (assault, robbery, auto, bne, theft) if isinstance(v, int))
            hood_codes.append(str(code))
            totals.append(str(total))
            assaults.append(sql_literal(assault))
            autos.append(sql_literal(auto))
            bnes.append(sql_literal(bne))
            robs.append(sql_literal(robbery))
            thefts.append(sql_literal(theft))
            tfmvs.append(sql_literal(tfmv))

        sql = f"""
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('{city}-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[{",".join(hood_codes)}]::int[],
  array[{",".join([str(year)] * len(hood_codes))}]::int[],
  array[{",".join(totals)}]::int[],
  array[{",".join(assaults)}]::int[],
  array[{",".join(autos)}]::int[],
  array[{",".join(bnes)}]::int[],
  array[{",".join(robs)}]::int[],
  array[{",".join(thefts)}]::int[],
  array[{",".join(tfmvs)}]::int[]
) as t(hood_code, y, total, assault, auto, bne, robbery, theft, tfmv)
join public.neighbourhoods n on n.city = '{city}' and n."hood id" = t.hood_code
on conflict (hood_id, "Year") do update set
  "Total MCI" = excluded."Total MCI",
  "Assault" = excluded."Assault",
  "Auto Theft" = excluded."Auto Theft",
  "Break & Enter" = excluded."Break & Enter",
  "Robbery" = excluded."Robbery",
  "Theft Over" = excluded."Theft Over",
  "Theft From MV" = excluded."Theft From MV";
"""
        path = OUT / f"{city}_{year}.sql"
        path.write_text(sql)
        print(path.name, "rows", len(hood_codes), "bytes", path.stat().st_size)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    van_names = [
        ("Arbutus Ridge", 2000),
        ("Grandview-Woodland", 2001),
        ("Killarney", 2002),
        ("Strathcona", 2003),
        ("Sunset", 2004),
        ("Hastings-Sunrise", 2005),
        ("Kerrisdale", 2006),
        ("South Cambie", 2007),
        ("Riley Park", 2008),
        ("Shaughnessy", 2009),
        ("Victoria-Fraserview", 2010),
        ("West Point Grey", 2011),
        ("Mount Pleasant", 2012),
        ("Renfrew-Collingwood", 2013),
        ("West End", 2014),
        ("Kensington-Cedar Cottage", 2015),
        ("Kitsilano", 2016),
        ("Downtown", 2017),
        ("Marpole", 2018),
        ("Oakridge", 2019),
        ("Dunbar-Southlands", 2020),
        ("Fairview", 2021),
    ]
    mtl_names = [
        ("LaSalle", 1000),
        ("Dollard-des-Ormeaux", 1001),
        ("Côte-Saint-Luc", 1002),
        ("Villeray-Saint-Michel-Parc-Extension", 1003),
        ("Rosemont-La Petite-Patrie", 1004),
        ("Hampstead", 1005),
        ("Senneville", 1006),
        ("Le Plateau-Mont-Royal", 1007),
        ("Sainte-Anne-de-Bellevue", 1008),
        ("Montréal-Ouest", 1009),
        ("Côte-des-Neiges-Notre-Dame-de-Grâce", 1010),
        ("L'Île-Bizard-Sainte-Geneviève", 1011),
        ("Beaconsfield", 1012),
        ("Anjou", 1013),
        ("Verdun", 1014),
        ("Le Sud-Ouest", 1015),
        ("Mercier-Hochelaga-Maisonneuve", 1016),
        ("Montréal-Est", 1017),
        ("Lachine", 1018),
        ("Saint-Léonard", 1019),
        ("Montréal-Nord", 1020),
        ("Outremont", 1021),
        ("L'Île-Dorval", 1022),
        ("Mont-Royal", 1023),
        ("Pointe-Claire", 1024),
        ("Dorval", 1025),
        ("Pierrefonds-Roxboro", 1026),
        ("Rivière-des-Prairies-Pointe-aux-Trembles", 1027),
        ("Ahuntsic-Cartierville", 1028),
        ("Saint-Laurent", 1029),
        ("Ville-Marie", 1030),
        ("Kirkland", 1031),
        ("Baie-D'Urfé", 1032),
        ("Westmount", 1033),
    ]

    vancouver = parse_vancouver_pdfs()
    print("vancouver cells", len(vancouver))
    for name, _ in van_names:
        have = [year for year in YEARS if (name, year) in vancouver]
        if len(have) != 5:
            print(" missing van", name, have)

    montreal = aggregate_montreal()
    print("montreal cells", len(montreal))
    for name, _ in mtl_names:
        have = [year for year in YEARS if (name, year) in montreal]
        if len(have) != 5:
            print(" missing mtl", name, have)
        else:
            sample = montreal[(name, 2024)]
            print(f"  {name} 2024", dict(sample))

    write_city_sql("vancouver", van_names, vancouver)
    write_city_sql(
        "montreal",
        mtl_names,
        {key: dict(value) for key, value in montreal.items()},
    )


if __name__ == "__main__":
    main()
