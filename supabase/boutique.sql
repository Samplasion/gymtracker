create table if not exists public.boutique_categories (
  id uuid not null,
  name json not null,
  icon text not null,
  color integer not null,
  is_hidden boolean not null default false,
  "order" bigint not null default '0'::bigint,
  primary key (id)
);

create table if not exists public.boutique_packages (
  id uuid not null,
  name json not null,
  description json not null,
  category_id uuid not null references public.boutique_categories(id) on delete cascade,
  primary key (id)
);

create table if not exists boutique_routines (
  id text not null,
  name text not null,
  infobox text not null default '',
  weight_unit text not null,
  distance_unit text not null,
  sort_order integer not null,
  package_id uuid not null references public.boutique_packages(id) on delete cascade,
  primary key (id)
);

create table if not exists public.boutique_routine_exercises (
  id text not null,
  routine_id text not null references public.boutique_routines(id) on delete cascade,
  name text not null,
  parameters text,
  sets jsonb,
  primary_muscle_group text,
  secondary_muscle_groups text[] default '{}',
  rest_time bigint,
  is_custom boolean not null,
  library_exercise_id text,
  custom_exercise_id text,
  notes text,
  is_superset boolean not null,
  is_in_superset boolean not null,
  superset_id text,
  sort_order integer not null,
  supersedes_id text,
  rpe integer,
  equipment text not null default 'none',
  primary key (id)
);

drop policy if exists "Users can view boutique data" on public.boutique_categories;
create policy "Users can view boutique datata" on public.boutique_categories
for select
using (true);

drop policy if exists "Users can view boutique data" on public.boutique_packages;
create policy "Users can view boutique datata" on public.boutique_packages
for select
using (true);

drop policy if exists "Users can view boutique data" on public.boutique_routines;
create policy "Users can view boutique datata" on public.boutique_routines
for select
using (true);

drop policy if exists "Users can view boutique data" on public.boutique_routine_exercises;
create policy "Users can view boutique datata" on public.boutique_routine_exercises
for select
using (true);