
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('montreal-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033]::int[],
  array[2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022,2022]::int[],
  array[1709,608,504,3990,4144,108,6,4020,84,136,3922,294,132,1300,1718,2232,4915,183,1260,1709,2830,443,391,1006,711,1053,2278,2793,2349,8466,235,39,396]::int[],
  array[541,158,176,1366,1264,33,1,1050,26,47,1326,116,37,361,659,636,1554,61,483,583,1299,142,121,207,149,397,740,829,585,2003,67,13,101]::int[],
  array[213,133,60,543,519,29,2,466,11,25,494,36,38,294,132,255,575,26,147,364,366,68,60,321,204,141,474,516,612,660,65,5,46]::int[],
  array[124,83,70,400,458,9,1,687,13,13,379,32,9,82,177,323,614,27,128,102,229,41,38,54,51,127,190,272,222,833,17,6,43]::int[],
  array[47,9,5,118,120,null,null,115,1,null,96,2,2,24,34,68,161,2,20,39,53,2,10,13,11,18,36,83,53,279,2,null,6]::int[],
  array[784,225,193,1563,1783,37,2,1702,33,51,1627,108,46,539,716,950,2011,67,482,621,883,190,162,411,296,370,838,1093,877,4691,84,15,200]::int[],
  array[179,116,29,502,488,3,null,385,14,16,401,52,22,178,230,290,593,28,168,265,349,37,43,115,124,154,272,427,348,1242,41,12,43]::int[]
) as t(hood_code, y, total, assault, auto, bne, robbery, theft, tfmv)
join public.neighbourhoods n on n.city = 'montreal' and n."hood id" = t.hood_code
on conflict (hood_id, "Year") do update set
  "Total MCI" = excluded."Total MCI",
  "Assault" = excluded."Assault",
  "Auto Theft" = excluded."Auto Theft",
  "Break & Enter" = excluded."Break & Enter",
  "Robbery" = excluded."Robbery",
  "Theft Over" = excluded."Theft Over",
  "Theft From MV" = excluded."Theft From MV";
