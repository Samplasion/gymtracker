begin;

drop publication if exists supabase_realtime;
create publication supabase_realtime;

create or replace function discard_older_updates()
returns trigger as $$
begin
  if new.updated_at <= old.updated_at then
    return null;
  end if;

  return new;
end;
$$ language plpgsql;

create table if not exists public.routine_folders (
  id uuid not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  name text not null,
  sort_order integer not null,
  primary key (id, user_id)
);

create table if not exists public.routines (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  name text not null,
  infobox text not null default '',
  weight_unit text not null,
  distance_unit text not null,
  sort_order integer not null,
  folder_id uuid,
  primary key (id, user_id),
  constraint routines_folder_fk
    foreign key (folder_id, user_id)
    references public.routine_folders (id, user_id)
    on delete set null
);

create table if not exists public.custom_exercises (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  name text not null,
  parameters text not null,
  primary_muscle_group text not null,
  secondary_muscle_groups text[] not null default '{}',
  equipment text not null default 'none',
  primary key (id, user_id)
);

create table if not exists public.routine_exercises (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  routine_id text not null,
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
  primary key (id, user_id)
);

create table if not exists public.history_workouts (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  name text not null,
  infobox text,
  duration bigint not null,
  starting_date timestamptz not null,
  parent_id text,
  completed_by uuid,
  completes uuid,
  weight_unit text not null,
  distance_unit text not null,
  primary key (id, user_id)
);

create table if not exists public.history_workout_exercises (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  routine_id text not null,
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
  primary key (id, user_id)
);

create table if not exists public.weight_measurements (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  weight real not null,
  time timestamptz not null,
  weight_unit text not null,
  primary key (id, user_id)
);

create table if not exists public.body_measurements (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  value real not null,
  time timestamptz not null,
  type text not null,
  primary key (id, user_id)
);

create table if not exists public.foods (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  date_added timestamptz not null,
  reference_date timestamptz not null,
  json_data jsonb not null,
  primary key (id, user_id)
);

create table if not exists public.custom_barcode_foods (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  json_data jsonb not null,
  primary key (id, user_id)
);

create table if not exists public.favorite_foods (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  primary key (id, user_id),
  constraint favorite_foods_food_fk
    foreign key (id, user_id)
    references public.foods (id, user_id)
    on delete cascade
);

create table if not exists public.nutrition_goals (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  reference_date timestamptz not null,
  calories real not null,
  fat real not null,
  carbs real not null,
  protein real not null,
  primary key (id, user_id)
);

create table if not exists public.nutrition_categories (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  reference_date timestamptz not null,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  json_data jsonb not null,
  primary key (id, user_id)
);

create table if not exists public.achievements_v2 (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  achievement_id text not null,
  level integer not null,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  completed_at timestamptz not null,
  primary key (id, user_id)
);

drop trigger if exists handle_conflicts_routine_folders on public.routine_folders;
create trigger handle_conflicts_routine_folders
before update on public.routine_folders
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_routines on public.routines;
create trigger handle_conflicts_routines
before update on public.routines
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_custom_exercises on public.custom_exercises;
create trigger handle_conflicts_custom_exercises
before update on public.custom_exercises
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_routine_exercises on public.routine_exercises;
create trigger handle_conflicts_routine_exercises
before update on public.routine_exercises
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_history_workouts on public.history_workouts;
create trigger handle_conflicts_history_workouts
before update on public.history_workouts
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_history_workout_exercises on public.history_workout_exercises;
create trigger handle_conflicts_history_workout_exercises
before update on public.history_workout_exercises
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_weight_measurements on public.weight_measurements;
create trigger handle_conflicts_weight_measurements
before update on public.weight_measurements
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_body_measurements on public.body_measurements;
create trigger handle_conflicts_body_measurements
before update on public.body_measurements
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_foods on public.foods;
create trigger handle_conflicts_foods
before update on public.foods
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_custom_barcode_foods on public.custom_barcode_foods;
create trigger handle_conflicts_custom_barcode_foods
before update on public.custom_barcode_foods
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_favorite_foods on public.favorite_foods;
create trigger handle_conflicts_favorite_foods
before update on public.favorite_foods
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_nutrition_goals on public.nutrition_goals;
create trigger handle_conflicts_nutrition_goals
before update on public.nutrition_goals
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_nutrition_categories on public.nutrition_categories;
create trigger handle_conflicts_nutrition_categories
before update on public.nutrition_categories
for each row
execute function discard_older_updates();

drop trigger if exists handle_conflicts_achievements on public.achievements;
create trigger handle_conflicts_achievements
before update on public.achievements
for each row
execute function discard_older_updates();

alter publication supabase_realtime add table public.routine_folders;
alter publication supabase_realtime add table public.routines;
alter publication supabase_realtime add table public.custom_exercises;
alter publication supabase_realtime add table public.routine_exercises;
alter publication supabase_realtime add table public.history_workouts;
alter publication supabase_realtime add table public.history_workout_exercises;
alter publication supabase_realtime add table public.weight_measurements;
alter publication supabase_realtime add table public.body_measurements;
alter publication supabase_realtime add table public.foods;
alter publication supabase_realtime add table public.custom_barcode_foods;
alter publication supabase_realtime add table public.favorite_foods;
alter publication supabase_realtime add table public.nutrition_goals;
alter publication supabase_realtime add table public.nutrition_categories;
alter publication supabase_realtime add table public.achievements;

alter table public.routine_folders enable row level security;
alter table public.routines enable row level security;
alter table public.custom_exercises enable row level security;
alter table public.routine_exercises enable row level security;
alter table public.history_workouts enable row level security;
alter table public.history_workout_exercises enable row level security;
alter table public.weight_measurements enable row level security;
alter table public.body_measurements enable row level security;
alter table public.foods enable row level security;
alter table public.custom_barcode_foods enable row level security;
alter table public.favorite_foods enable row level security;
alter table public.nutrition_goals enable row level security;
alter table public.nutrition_categories enable row level security;
alter table public.achievements enable row level security;

drop policy if exists "Users can work with own data" on public.routine_folders;
create policy "Users can work with own data" on public.routine_folders
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.routines;
create policy "Users can work with own data" on public.routines
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.custom_exercises;
create policy "Users can work with own data" on public.custom_exercises
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.routine_exercises;
create policy "Users can work with own data" on public.routine_exercises
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.history_workouts;
create policy "Users can work with own data" on public.history_workouts
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.history_workout_exercises;
create policy "Users can work with own data" on public.history_workout_exercises
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.weight_measurements;
create policy "Users can work with own data" on public.weight_measurements
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.body_measurements;
create policy "Users can work with own data" on public.body_measurements
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.foods;
create policy "Users can work with own data" on public.foods
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.custom_barcode_foods;
create policy "Users can work with own data" on public.custom_barcode_foods
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.favorite_foods;
create policy "Users can work with own data" on public.favorite_foods
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.nutrition_goals;
create policy "Users can work with own data" on public.nutrition_goals
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.nutrition_categories;
create policy "Users can work with own data" on public.nutrition_categories
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can work with own data" on public.achievements;
create policy "Users can work with own data" on public.achievements
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

alter table public.routine_exercises drop constraint if exists routine_exercises_routine_fk;
alter table public.routine_exercises drop constraint if exists routine_exercises_custom_exercise_fk;
alter table public.routine_exercises drop constraint if exists routine_exercises_superset_fk;
alter table public.routine_exercises drop constraint if exists routine_exercises_supersedes_fk;

alter table public.history_workouts drop constraint if exists history_workouts_parent_fk;
alter table public.history_workouts drop constraint if exists history_workouts_completion_fk;
alter table public.history_workouts drop constraint if exists history_workouts_completes_fk;

alter table public.history_workout_exercises drop constraint if exists history_workout_exercises_history_workout_fk;
alter table public.history_workout_exercises drop constraint if exists history_workout_exercises_custom_exercise_fk;
alter table public.history_workout_exercises drop constraint if exists history_workout_exercises_superset_fk;
alter table public.history_workout_exercises drop constraint if exists history_workout_exercises_supersedes_fk;

-- Friends table & relationships
create table if not exists public.friends (
  sender_id uuid not null references auth.users (id) on delete cascade,
  receiver_id uuid not null references auth.users (id) on delete cascade,
  status text not null check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (sender_id, receiver_id)
);

-- Enable Row Level Security
alter table public.friends enable row level security;

-- Policies for friends table
drop policy if exists "Users can view own relationships" on public.friends;
create policy "Users can view own relationships" on public.friends
for select
using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "Users can insert own relationships" on public.friends;
create policy "Users can insert own relationships" on public.friends
for insert
with check (auth.uid() = sender_id);

drop policy if exists "Users can update own received relationships" on public.friends;
create policy "Users can update own received relationships" on public.friends
for update
using (auth.uid() = receiver_id)
with check (auth.uid() = receiver_id);

drop policy if exists "Users can delete own relationships" on public.friends;
create policy "Users can delete own relationships" on public.friends
for delete
using (auth.uid() = sender_id or auth.uid() = receiver_id);

-- Enable read-only for friends for history_workouts, history_workout_exercises, and achievements
create policy "Users can view own posts and accepted friends' history"
on public.history_workouts
for select
to authenticated
using (
  public.are_friends(auth.uid(), user_id)
);

create policy "Users can view own posts and accepted friends' history"
on public.history_workout_exercises
for select
to authenticated
using (
  public.are_friends(auth.uid(), user_id)
);

create policy "Users can view own posts and accepted friends' history"
on public.achievements_v2
for select
to authenticated
using (
  public.are_friends(auth.uid(), user_id)
);

-- Profiles table
create table if not exists public.profiles (
  id uuid not null,
  email text null,
  full_name text null,
  updated_at timestamp with time zone null,
  username text not null,
  constraint profiles_pkey primary key (id),
  constraint profiles_username_key unique (username),
  constraint profiles_id_fkey foreign key (id) references auth.users (id) on delete cascade
);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- Policies for profiles
drop policy if exists "Profiles are publicly viewable" on public.profiles;
create policy "Profiles are publicly viewable" on public.profiles
for select
using (true);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

commit;