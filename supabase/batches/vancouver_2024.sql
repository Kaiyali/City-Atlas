
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('vancouver-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021]::int[],
  array[2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024]::int[],
  array[141,874,274,1503,915,481,190,223,281,131,308,128,1274,1718,1617,808,790,7572,496,184,129,980]::int[],
  array[12,266,65,600,87,121,23,26,44,14,48,25,219,146,353,160,68,1969,69,22,19,121]::int[],
  array[10,55,27,56,65,30,9,2,17,5,30,10,34,57,36,50,18,92,23,3,4,28]::int[],
  array[19,125,46,179,51,95,63,48,55,58,41,24,143,142,148,119,75,465,108,67,27,124]::int[],
  array[3,47,1,83,7,7,2,7,4,2,4,1,40,24,39,24,10,300,10,3,2,13]::int[],
  array[97,381,135,585,705,228,93,140,161,52,185,68,838,1349,1041,455,619,4746,286,89,77,694]::int[],
  array[64,228,115,290,165,190,76,43,118,82,152,71,264,214,501,271,221,2122,135,54,86,235]::int[]
) as t(hood_code, y, total, assault, auto, bne, robbery, theft, tfmv)
join public.neighbourhoods n on n.city = 'vancouver' and n."hood id" = t.hood_code
on conflict (hood_id, "Year") do update set
  "Total MCI" = excluded."Total MCI",
  "Assault" = excluded."Assault",
  "Auto Theft" = excluded."Auto Theft",
  "Break & Enter" = excluded."Break & Enter",
  "Robbery" = excluded."Robbery",
  "Theft Over" = excluded."Theft Over",
  "Theft From MV" = excluded."Theft From MV";
