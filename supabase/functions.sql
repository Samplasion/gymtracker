CREATE OR REPLACE FUNCTION public.handle_new_user() -- Replace with your actual function name
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER -- Keep any existing security settings you had
AS $$
DECLARE
  new_username TEXT;
  base_username TEXT;
  counter INT := 1;
BEGIN
  -- Determine the starting username (custom or derived from email)
  IF NEW.raw_user_meta_data->>'username' IS NOT NULL THEN
    base_username := NEW.raw_user_meta_data->>'username';
  ELSE
    base_username := split_part(NEW.email, '@', 1);
  END IF;

  new_username := base_username;

  -- Ensure the username is truly unique by appending a counter if necessary
  WHILE EXISTS (SELECT 1 FROM public.profiles WHERE username = new_username) LOOP
    new_username := base_username || '_' || counter;
    counter := counter + 1;
  END LOOP;

  -- Insert the new profile
  INSERT INTO public.profiles (id, email, full_name, username, updated_at)
  VALUES (
    NEW.id, 
    NEW.email, 
    NEW.raw_user_meta_data->>'full_name', 
    new_username,
    NOW()
  );

  RETURN NEW;
END;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function search_users_weighted(search_query text)
returns table (
    id uuid,
    email text,
    full_name text,
    username text,
    rank real
) 
language plpgsql
security definer
set search_path = ''
as $$
declare
  formatted_query text;
begin
  -- Don't run search if the query is empty or only whitespace
  if trim(search_query) = '' then
    return;
  end if;

  -- Formats each word in the input to support prefix partial matching (e.g. "John Do" -> "John:* & Do:*")
  select string_agg(lexeme || ':*', ' & ')
  into formatted_query
  from unnest(regexp_split_to_array(trim(search_query), '\s+')) as lexeme;

  return query
  select
    profiles.id,
    profiles.email,
    profiles.full_name,
    profiles.username,
    ts_rank(profiles.fts_weighted, to_tsquery('english', formatted_query)) as rank
  from public.profiles
  where profiles.fts_weighted @@ to_tsquery('english', formatted_query)
  order by rank desc;
end;
$$;

create or replace function delete_user_complete(target_user_id uuid)
returns void
security definer
set search_path = public, auth, storage
language plpgsql
as $$
declare
  requesting_user_id uuid;
  is_admin boolean;
begin
  -- 1. Get the ID of the user making the request
  requesting_user_id := auth.uid();

  if requesting_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- 2. Check if the requesting user is an admin 
  is_admin := coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, 
    false
  );

  -- 3. Enforce authorization: Must be admin OR the user themselves
  if not is_admin and requesting_user_id <> target_user_id then
    raise exception 'Access denied: You can only delete your own account or must be an admin.';
  end if;

  -- 4. Delete the profile picture from the 'profile_pictures' storage bucket
  delete from storage.objects
  where bucket_id = 'profile_pictures' 
    and name = target_user_id::text;

  -- 5. Delete data from all associated tables where column 'userId' matches
  -- Replace 'your_table_name' with your actual table(s)
  delete from public.your_table_name where "userId" = target_user_id;

  -- 6. Finally, delete the user from Supabase Auth
  delete from auth.users where id = target_user_id;

end;
$$;

create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.friends
    where status = 'accepted'
      and (
        (sender_id = user_a and receiver_id = user_b)
        or
        (sender_id = user_b and receiver_id = user_a)
      )
  );
$$;

