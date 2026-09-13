
create table if not exists public.cities (
  id text primary key,
  name text not null,
  province text not null,
  country text not null default 'Canada'
);

alter table public.cities enable row level security;

drop policy if exists cities_public_read on public.cities;
create policy cities_public_read on public.cities for select to anon, authenticated using (true);

insert into public.cities (id, name, province, country) values
  ('toronto', 'Toronto', 'Ontario', 'Canada'),
  ('montreal', 'Montreal', 'Quebec', 'Canada'),
  ('vancouver', 'Vancouver', 'British Columbia', 'Canada')
on conflict (id) do update set name = excluded.name, province = excluded.province, country = excluded.country;

create table if not exists public.crime_topics (
  id text primary key,
  label text not null,
  official_name text not null,
  source text not null
);

alter table public.crime_topics enable row level security;
drop policy if exists crime_topics_public_read on public.crime_topics;
create policy crime_topics_public_read on public.crime_topics for select to anon, authenticated using (true);

insert into public.crime_topics (id, label, official_name, source) values
  ('assault', 'Assault', 'Assault', 'Toronto Police Service Neighbourhood Crime Rates'),
  ('robbery', 'Robbery', 'Robbery', 'Toronto Police Service Neighbourhood Crime Rates'),
  ('autoTheft', 'Auto Theft', 'Auto Theft', 'Toronto Police Service Neighbourhood Crime Rates'),
  ('breakEnter', 'Break & Enter', 'Break & Enter', 'Toronto Police Service Neighbourhood Crime Rates'),
  ('theft', 'Theft Over', 'Theft Over', 'Toronto Police Service Neighbourhood Crime Rates'),
  ('theftFromMv', 'Theft From Vehicle', 'Theft From Motor Vehicle', 'Toronto Police Service Neighbourhood Crime Rates')
on conflict (id) do update set label = excluded.label, official_name = excluded.official_name, source = excluded.source;

delete from public.crime_stats_indicator;
delete from public.neighbourhoods;

alter table public.neighbourhoods drop constraint if exists neighbourhoods_city_fkey;
alter table public.neighbourhoods
  add constraint neighbourhoods_city_fkey foreign key (city) references public.cities(id);

alter table public.neighbourhoods drop constraint if exists neighbourhoods_city_hood_key;
alter table public.neighbourhoods
  add constraint neighbourhoods_city_hood_key unique (city, "hood id");
