
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('vancouver-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021]::int[],
  array[2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021]::int[],
  array[149,912,293,1549,512,539,219,211,353,144,296,172,1472,1365,1462,776,792,5543,480,201,143,914]::int[],
  array[14,258,52,703,104,133,19,17,49,10,54,21,273,152,436,160,93,1779,78,34,24,122]::int[],
  array[5,57,37,76,39,56,11,10,29,12,31,7,57,73,46,61,43,112,41,11,8,34]::int[],
  array[49,213,78,220,71,136,107,60,142,69,60,72,289,128,212,152,196,755,154,77,54,210]::int[],
  array[3,25,7,63,17,15,2,3,7,2,11,1,31,27,44,35,12,236,4,3,2,18]::int[],
  array[78,359,119,487,281,199,80,121,126,51,140,71,822,985,724,368,448,2661,203,76,55,530]::int[],
  array[72,339,129,305,252,366,124,74,220,77,164,106,383,346,729,379,338,1886,230,89,79,356]::int[]
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
