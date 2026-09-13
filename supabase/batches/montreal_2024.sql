
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('montreal-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033]::int[],
  array[2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024,2024]::int[],
  array[1852,550,323,3922,4190,94,15,4400,78,108,4240,197,147,1051,1658,3291,5076,182,1275,1956,2691,466,343,1280,960,886,1940,3064,2264,11701,196,61,566]::int[],
  array[609,182,121,1421,1290,33,4,1173,24,39,1488,91,42,360,554,947,1654,64,501,615,1280,157,113,271,205,394,684,990,648,2976,57,18,147]::int[],
  array[247,103,32,455,454,17,4,584,12,10,470,13,27,162,131,359,545,19,131,259,280,38,29,396,305,90,296,489,547,674,35,11,63]::int[],
  array[98,58,41,388,442,11,1,486,11,18,388,26,23,62,170,416,613,30,122,128,182,62,47,79,43,107,145,340,249,966,27,7,58]::int[],
  array[58,16,6,110,121,null,null,88,1,1,142,2,2,27,47,87,119,2,45,73,87,7,8,21,19,14,40,72,37,312,4,1,7]::int[],
  array[840,191,123,1548,1883,33,6,2069,30,40,1752,65,53,440,756,1482,2145,67,476,881,862,202,146,513,388,281,775,1173,783,6773,73,24,291]::int[],
  array[155,63,28,441,445,4,2,491,10,10,291,18,13,132,153,317,603,23,99,247,285,37,26,109,90,106,260,339,204,1555,19,7,31]::int[]
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
