BEGIN;
ALTER TABLE public.profiles ADD COLUMN fts_weighted tsvector GENERATED ALWAYS AS (
  setweight(to_tsvector('english'::regconfig,coalesce(username,'')),'A') ||
  setweight(to_tsvector('english'::regconfig,coalesce(full_name,'')),'B')) STORED;
CREATE INDEX profiles_fts_weighted_idx ON public.profiles USING gin(fts_weighted);
CREATE FUNCTION public.touch_profile_version() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
BEGIN NEW.updated_at=clock_timestamp(); RETURN NEW; END; $$;
CREATE TRIGGER profile_version BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.touch_profile_version();
DROP FUNCTION public.search_users_weighted(text);
CREATE FUNCTION public.search_users_weighted(search_query text)
RETURNS TABLE(id uuid,email text,full_name text,username text,rank real,updated_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path='' AS $$
DECLARE terms text; q tsquery;
BEGIN
 SELECT string_agg(quote_literal(t)||':*',' & ') INTO terms FROM unnest(tsvector_to_array(to_tsvector('english',trim(search_query)))) t;
 IF terms IS NULL THEN RETURN; END IF;
 q:=to_tsquery('english',terms);
 RETURN QUERY SELECT p.id,p.email,p.full_name,p.username,ts_rank(p.fts_weighted,q),p.updated_at FROM public.profiles p WHERE p.fts_weighted@@q ORDER BY ts_rank(p.fts_weighted,q) DESC,p.id LIMIT 15;
END; $$;

CREATE INDEX friends_receiver_status_idx ON public.friends(receiver_id,status,sender_id);
CREATE INDEX friends_sender_status_idx ON public.friends(sender_id,status,receiver_id);
CREATE INDEX history_feed_idx ON public.history_workouts(user_id,starting_date DESC,id) WHERE NOT deleted;
CREATE INDEX achievements_feed_idx ON public.achievements_v2(user_id,completed_at DESC,id) WHERE NOT deleted;
CREATE INDEX history_exercises_workout_idx ON public.history_workout_exercises(user_id,routine_id) WHERE NOT deleted;
CREATE INDEX boutique_packages_category_idx ON public.boutique_packages(category_id);
CREATE INDEX boutique_routines_package_idx ON public.boutique_routines(package_id);
CREATE INDEX boutique_exercises_routine_idx ON public.boutique_routine_exercises(routine_id);

-- Privileged reads are necessary after the legacy table-access gate is enabled.
-- All ownership/friendship checks are explicit; no caller-supplied account.
CREATE FUNCTION public.get_friends_feed(start_at timestamptz,end_at timestamptz)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 IF start_at>=end_at THEN RAISE EXCEPTION 'Invalid interval'; END IF;
 WITH friends AS (
   SELECT DISTINCT CASE WHEN sender_id=auth.uid() THEN receiver_id ELSE sender_id END AS id
   FROM public.friends WHERE status='accepted' AND (sender_id=auth.uid() OR receiver_id=auth.uid())
 ), workouts AS (
   SELECT w.* FROM public.history_workouts w JOIN friends f ON w.user_id=f.id
   WHERE NOT w.deleted AND w.starting_date>=start_at AND w.starting_date<end_at
 ), achievements AS (
   SELECT a.* FROM public.achievements_v2 a JOIN friends f ON a.user_id=f.id
   WHERE NOT a.deleted AND a.completed_at>=start_at AND a.completed_at<end_at
 ), authors AS (SELECT user_id FROM workouts UNION SELECT user_id FROM achievements), older AS (
   SELECT max(w.starting_date) AS at FROM public.history_workouts w JOIN friends f ON w.user_id=f.id WHERE NOT w.deleted AND w.starting_date<start_at
   UNION ALL SELECT max(a.completed_at) FROM public.achievements_v2 a JOIN friends f ON a.user_id=f.id WHERE NOT a.deleted AND a.completed_at<start_at
 )
 SELECT jsonb_build_object(
   'workouts',coalesce((SELECT jsonb_agg(to_jsonb(w)) FROM workouts w),'[]'),
   'achievements',coalesce((SELECT jsonb_agg(to_jsonb(a)) FROM achievements a),'[]'),
   'exercises',coalesce((SELECT jsonb_agg(to_jsonb(e)) FROM public.history_workout_exercises e JOIN workouts w ON e.user_id=w.user_id AND e.routine_id=w.id WHERE NOT e.deleted),'[]'),
   'profiles',coalesce((SELECT jsonb_agg(jsonb_build_object('id',p.id,'username',p.username,'full_name',p.full_name,'updated_at',p.updated_at)) FROM public.profiles p JOIN authors a ON p.id=a.user_id),'[]'),
   'previous_at',(SELECT max(at) FROM older)) INTO result;
 RETURN result;
END; $$;

CREATE FUNCTION public.get_public_profile_v2(profile_id uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 IF profile_id<>auth.uid() AND NOT public.are_friends(auth.uid(),profile_id) THEN
   RETURN jsonb_build_object('workouts','[]'::jsonb,'exercises','[]'::jsonb,'achievements','[]'::jsonb,'friend_count',0);
 END IF;
 WITH workouts AS (SELECT * FROM public.history_workouts WHERE user_id=profile_id AND NOT deleted AND completes IS NULL ORDER BY starting_date DESC,id LIMIT 25), achievements AS (SELECT * FROM public.achievements_v2 WHERE user_id=profile_id AND NOT deleted ORDER BY completed_at DESC,id LIMIT 100)
 SELECT jsonb_build_object(
   'workouts',coalesce((SELECT jsonb_agg(to_jsonb(w)) FROM workouts w),'[]'),
   'achievements',coalesce((SELECT jsonb_agg(to_jsonb(a)) FROM achievements a),'[]'),
   'exercises',coalesce((SELECT jsonb_agg(to_jsonb(e)) FROM public.history_workout_exercises e JOIN workouts w ON e.user_id=w.user_id AND e.routine_id=w.id WHERE NOT e.deleted),'[]'),
   -- Preserve the existing relationship visibility: caller must participate.
   'friend_count',(SELECT count(*) FROM public.friends WHERE status='accepted' AND (sender_id=profile_id OR receiver_id=profile_id) AND (sender_id=auth.uid() OR receiver_id=auth.uid()))) INTO result;
 RETURN result;
END; $$;
REVOKE ALL ON FUNCTION public.get_friends_feed(timestamptz,timestamptz),public.get_public_profile_v2(uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.get_friends_feed(timestamptz,timestamptz),public.get_public_profile_v2(uuid) TO authenticated;
REVOKE ALL ON FUNCTION public.search_users_weighted(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.search_users_weighted(text) TO authenticated;
COMMIT;
