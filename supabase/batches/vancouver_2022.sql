
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('vancouver-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021]::int[],
  array[2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022]::int[],
  array[200,913,305,1608,1119,501,212,237,347,150,277,125,1386,1679,1605,817,713,6359,513,210,166,1074]::int[],
  array[20,268,65,732,92,140,22,19,43,7,56,16,233,147,387,181,81,1964,91,27,20,134]::int[],
  array[17,70,43,82,54,49,6,16,38,22,36,7,68,76,54,72,44,90,36,18,13,44]::int[],
  array[53,188,55,201,96,122,73,76,87,72,50,56,263,116,237,141,151,700,123,74,48,196]::int[],
  array[5,31,7,91,19,15,7,2,5,5,9,0,32,13,48,38,9,290,18,1,2,24]::int[],
  array[105,356,135,502,858,175,104,124,174,44,126,46,790,1327,879,385,428,3315,245,90,83,676]::int[],
  array[69,292,162,392,235,259,54,56,179,75,206,53,399,390,624,327,250,2274,226,82,88,288]::int[]
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
