
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('montreal-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033]::int[],
  array[2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023,2023]::int[],
  array[1844,657,329,3931,3744,146,10,4732,75,91,4272,255,180,1184,1579,2949,4837,211,1492,1845,2880,458,362,1059,1146,1024,1952,3020,2482,11175,244,40,541]::int[],
  array[568,161,116,1337,1104,46,3,1239,23,32,1431,101,48,332,584,822,1515,69,562,598,1298,142,108,214,222,384,630,856,594,2588,65,11,133]::int[],
  array[262,175,50,599,476,30,1,748,11,16,576,33,43,262,180,379,635,33,194,403,326,63,55,343,416,172,403,630,694,1276,53,7,79]::int[],
  array[135,81,33,352,475,19,2,616,11,8,394,23,25,71,149,432,586,30,139,136,281,54,39,64,49,88,164,308,244,935,37,9,59]::int[],
  array[56,11,3,113,132,null,null,120,1,null,115,4,4,24,31,88,141,3,36,71,93,9,15,12,17,22,42,98,60,315,7,null,6]::int[],
  array[823,229,127,1530,1557,51,4,2009,29,35,1756,94,60,495,635,1228,1960,76,561,637,882,190,145,426,442,358,713,1128,890,6061,82,13,264]::int[],
  array[138,80,22,466,301,8,4,467,11,13,394,46,21,174,148,311,532,28,170,180,296,22,26,102,100,144,218,304,255,1368,25,4,38]::int[]
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
