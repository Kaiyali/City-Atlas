
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('montreal-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033]::int[],
  array[2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021,2021]::int[],
  array[1750,468,311,3079,2923,67,5,2444,58,51,3282,206,123,1329,1331,1824,4114,168,931,1887,2573,307,247,665,341,641,2056,2525,1746,5628,205,53,325]::int[],
  array[561,121,114,1083,912,21,1,657,20,19,1120,76,35,381,506,522,1313,57,357,642,1191,103,78,140,74,241,689,753,442,1342,56,17,84]::int[],
  array[224,110,40,394,325,17,2,168,7,7,402,33,21,271,77,168,445,28,98,355,308,33,39,167,71,69,357,450,436,257,46,4,22]::int[],
  array[127,56,25,276,335,6,null,478,6,3,285,21,22,73,166,301,535,19,93,164,213,31,13,66,45,93,176,273,158,659,31,11,49]::int[],
  array[25,9,7,87,65,null,null,76,null,1,100,5,2,35,32,53,123,2,27,42,52,3,12,12,4,14,55,57,48,227,1,1,3]::int[],
  array[813,172,125,1239,1286,23,2,1065,25,21,1375,71,43,569,550,780,1698,62,356,684,809,137,105,280,147,224,779,992,662,3143,71,20,167]::int[],
  array[208,85,34,482,418,3,1,312,16,11,371,21,22,231,165,247,538,28,124,287,341,40,34,97,74,91,316,398,290,876,27,15,41]::int[]
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
