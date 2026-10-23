BEGIN;
CREATE FUNCTION public.get_achievement_history(
  profile_id uuid,
  before_completed_at timestamptz DEFAULT NULL,
  before_id text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
  IF auth.uid() IS NULL OR profile_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;
  IF profile_id <> auth.uid() AND NOT public.are_friends(auth.uid(),profile_id) THEN
    RAISE EXCEPTION 'Friendship required' USING ERRCODE='42501';
  END IF;
  IF (before_completed_at IS NULL) <> (before_id IS NULL) THEN
    RAISE EXCEPTION 'Incomplete cursor' USING ERRCODE='22023';
  END IF;
  WITH candidates AS (
    SELECT a.* FROM public.achievements_v2 a
    WHERE a.user_id=profile_id AND NOT a.deleted
      AND (before_completed_at IS NULL OR (a.completed_at,a.id)<(before_completed_at,before_id))
    ORDER BY a.completed_at DESC,a.id DESC LIMIT 51
  ), page AS (
    SELECT * FROM candidates ORDER BY completed_at DESC,id DESC LIMIT 50
  ), last_item AS (
    SELECT completed_at,id FROM page ORDER BY completed_at ASC,id ASC LIMIT 1
  )
  SELECT jsonb_build_object(
    'items',coalesce((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.completed_at DESC,p.id DESC) FROM page p),'[]'::jsonb),
    'next_cursor',CASE WHEN (SELECT count(*) FROM candidates)>50
      THEN (SELECT jsonb_build_object('completed_at',completed_at,'id',id) FROM last_item)
      ELSE NULL END
  ) INTO result;
  RETURN result;
END; $$;
REVOKE ALL ON FUNCTION public.get_achievement_history(uuid,timestamptz,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.get_achievement_history(uuid,timestamptz,text) TO authenticated;
COMMIT;
