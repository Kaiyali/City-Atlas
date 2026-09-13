
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('vancouver-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021]::int[],
  array[2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020]::int[],
  array[198,1059,290,1830,489,577,242,291,465,213,292,232,1517,1224,1531,935,969,5669,501,247,262,1172]::int[],
  array[18,286,50,758,91,131,27,41,41,7,51,17,237,138,369,149,102,1746,70,30,24,103]::int[],
  array[9,87,20,95,35,55,10,8,27,10,27,8,73,61,66,55,52,90,34,11,14,39]::int[],
  array[105,249,78,304,98,166,106,84,196,136,60,119,393,173,335,201,312,966,159,88,101,352]::int[],
  array[5,30,2,96,13,19,4,5,5,4,5,3,40,24,35,32,5,226,16,3,1,22]::int[],
  array[61,407,140,577,252,206,95,153,196,56,149,85,774,828,726,498,498,2641,222,115,122,656]::int[],
  array[103,436,176,464,312,431,132,122,240,124,195,160,517,554,832,425,517,2893,249,101,155,578]::int[]
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
