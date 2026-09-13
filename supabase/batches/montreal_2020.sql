
insert into public.crime_stats_indicator
  ("Id", "Year", "Total MCI", "Assault", "Auto Theft", "Break & Enter", "Robbery", "Theft Over", "Theft From MV", hood_id)
select
  uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8'::uuid, format('montreal-crime-%s-%s', t.hood_code, t.y)),
  t.y, t.total, t.assault, t.auto, t.bne, t.robbery, t.theft, t.tfmv, n.id
from unnest(
  array[1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033]::int[],
  array[2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020,2020]::int[],
  array[1381,401,226,3370,3395,47,4,2862,45,51,2656,138,117,1182,1088,1801,3547,171,972,1563,2146,374,265,452,402,755,1838,2188,1552,5226,134,50,305]::int[],
  array[458,106,81,1152,1031,15,1,749,16,20,900,50,31,361,412,512,1138,57,371,540,972,123,84,108,90,282,629,653,399,1223,40,14,78]::int[],
  array[97,86,28,332,287,7,null,157,3,3,229,13,23,174,55,70,361,28,85,242,229,33,28,54,68,71,277,341,304,202,18,7,12]::int[],
  array[130,46,27,483,526,8,2,675,5,6,330,26,23,83,154,394,465,23,129,159,232,46,31,69,59,119,177,274,208,729,25,11,59]::int[],
  array[32,13,2,85,97,null,null,66,1,null,93,2,1,25,19,61,110,1,16,47,52,8,9,5,6,20,43,60,44,208,1,1,1]::int[],
  array[664,150,88,1318,1454,17,1,1215,20,22,1104,47,39,539,448,764,1473,62,371,575,661,164,113,216,179,263,712,860,597,2864,50,17,155]::int[],
  array[218,83,18,418,382,4,null,282,15,14,278,12,14,296,130,228,487,25,126,265,233,41,37,136,103,103,329,347,285,701,31,7,35]::int[]
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
