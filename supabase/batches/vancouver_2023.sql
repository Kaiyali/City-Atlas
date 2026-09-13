
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('vancouver-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021]::int[],
  array[2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023]::int[],
  array[138,969,317,1822,1025,466,219,201,287,107,274,131,1427,1945,1697,877,686,6971,526,178,215,1191]::int[],
  array[14,238,71,775,89,123,32,24,44,19,70,30,228,153,399,180,92,1990,82,32,25,141]::int[],
  array[7,74,35,69,40,54,9,6,17,5,34,9,47,52,45,55,17,112,32,13,11,32]::int[],
  array[47,185,65,219,70,115,57,45,78,40,59,34,203,167,202,173,138,635,112,50,67,204]::int[],
  array[2,41,11,78,13,17,4,4,5,2,5,1,34,27,44,26,15,240,17,1,4,18]::int[],
  array[68,431,135,681,813,157,117,122,143,41,106,57,915,1546,1007,443,424,3994,283,82,108,796]::int[],
  array[64,291,145,396,225,261,83,58,207,63,180,84,338,334,542,409,281,2491,188,84,89,291]::int[]
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
