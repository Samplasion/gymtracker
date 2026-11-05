-- First-party personal dashboard. Only the verified Edge handler can select an actor.
CREATE TABLE public.shared_programs (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 token text NOT NULL UNIQUE DEFAULT encode(extensions.gen_random_bytes(24), 'hex'),
 document jsonb NOT NULL CHECK (document->>'version' = '1' AND jsonb_typeof(document->'routines') = 'array'),
 created_at timestamptz NOT NULL DEFAULT now(),
 revoked_at timestamptz
);
ALTER TABLE public.shared_programs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.shared_programs FROM anon, authenticated;
-- Owner-only SELECT also lets the existing RLS-scoped data export include snapshots.
GRANT SELECT ON public.shared_programs TO authenticated;
CREATE POLICY shared_program_owner_read ON public.shared_programs FOR SELECT TO authenticated
 USING (owner_id=(SELECT auth.uid()) AND (SELECT auth.jwt()->>'client_id') IS NULL);
CREATE INDEX shared_programs_owner ON public.shared_programs(owner_id, created_at DESC);

-- Logical sessions include their nondeleted continuations, never orphaned continuations.
CREATE FUNCTION public.personal_history_parts(actor uuid, root text DEFAULT NULL)
RETURNS TABLE(root_id text,id text,starting_date timestamptz,weight_unit text,distance_unit text,duration bigint,depth integer)
LANGUAGE sql STABLE SET search_path = '' AS $$
 WITH RECURSIVE parts AS (
  SELECT w.id root_id,w.id,w.starting_date,w.weight_unit,w.distance_unit,w.duration,0 depth,ARRAY[w.id] path
  FROM public.history_workouts w WHERE w.user_id=actor AND NOT w.deleted AND w.completes IS NULL AND (root IS NULL OR w.id=root)
  UNION ALL
  SELECT p.root_id,w.id,p.starting_date,w.weight_unit,w.distance_unit,w.duration,p.depth+1,p.path||w.id
  FROM parts p JOIN public.history_workouts w ON w.completes::text=p.id AND w.user_id=actor
  WHERE NOT w.deleted AND NOT w.id=ANY(p.path)
 ) SELECT root_id,id,starting_date,weight_unit,distance_unit,duration,depth FROM parts
$$;
REVOKE ALL ON FUNCTION public.personal_history_parts(uuid,text) FROM PUBLIC,anon,authenticated;

CREATE FUNCTION public.personal_workout(actor uuid, workout_id text, is_history boolean)
RETURNS jsonb LANGUAGE sql STABLE SET search_path = '' AS $$
 SELECT CASE WHEN is_history THEN
 (SELECT (to_jsonb(w)-'user_id'-'updated_at'-'deleted'-'completed_by') || jsonb_build_object('duration',(SELECT sum(p.duration) FROM public.personal_history_parts(actor,w.id) p),'exercises',
   COALESCE((SELECT jsonb_agg((to_jsonb(e)-'user_id'-'updated_at'-'deleted') || jsonb_build_object('sets',
      (SELECT COALESCE(jsonb_agg(s || jsonb_build_object(
        'weight',COALESCE((s->>'weight')::numeric,0) * CASE WHEN p.weight_unit=w.weight_unit THEN 1 WHEN p.weight_unit='lb' THEN 0.45359237 ELSE 1/0.45359237 END,
        'distance',COALESCE((s->>'distance')::numeric,0) * CASE WHEN p.distance_unit=w.distance_unit THEN 1 WHEN p.distance_unit='mi' THEN 1.609344 ELSE 1/1.609344 END)), '[]') FROM jsonb_array_elements(COALESCE(e.sets,'[]')) s)) ORDER BY p.depth,e.sort_order,e.id)
    FROM public.personal_history_parts(actor,w.id) p JOIN public.history_workout_exercises e ON e.routine_id=p.id AND e.user_id=actor WHERE NOT e.deleted),'[]'::jsonb))
 FROM public.history_workouts w WHERE w.user_id=actor AND w.id=workout_id AND NOT w.deleted AND w.completes IS NULL)
 ELSE
 (SELECT (to_jsonb(w)-'user_id'-'updated_at'-'deleted') || jsonb_build_object('exercises',
   COALESCE((SELECT jsonb_agg(to_jsonb(e)-'user_id'-'updated_at'-'deleted' ORDER BY e.sort_order,e.id)
    FROM public.routine_exercises e WHERE e.user_id=actor AND e.routine_id=w.id AND NOT e.deleted),'[]'::jsonb))
 FROM public.routines w WHERE w.user_id=actor AND w.id=workout_id AND NOT w.deleted) END
$$;
REVOKE ALL ON FUNCTION public.personal_workout(uuid,text,boolean) FROM PUBLIC,anon,authenticated;

CREATE FUNCTION public.personal_execute(actor uuid, operation text, payload jsonb DEFAULT '{}')
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE result jsonb; take integer := least(100,greatest(1,COALESCE((payload->>'limit')::integer,20)));
 skip integer := greatest(0,COALESCE((payload->>'offset')::integer,0));
 since_date timestamptz := COALESCE((payload->>'since')::timestamptz,'-infinity');
BEGIN
 IF operation='read' THEN
  SELECT document INTO result FROM public.shared_programs WHERE token=payload->>'token' AND revoked_at IS NULL;
  IF result IS NULL THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
  RETURN result;
 END IF;
 IF operation='catalog' THEN
  RETURN COALESCE((SELECT jsonb_agg(x.value) FROM (SELECT value FROM gymbro_mcp.catalog c,jsonb_array_elements(c.exercises)
   ORDER BY value->>'id' LIMIT take OFFSET skip) x),'[]');
 END IF;
 IF actor IS NULL THEN RAISE EXCEPTION 'unauthorized' USING ERRCODE='42501'; END IF;
 IF operation='overview' THEN
  RETURN jsonb_build_object('workouts',(SELECT count(*) FROM public.history_workouts WHERE user_id=actor AND NOT deleted AND completes IS NULL),
   'foods',(SELECT count(*) FROM public.foods WHERE user_id=actor AND NOT deleted),
   'recent',COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT id,name,starting_date,(SELECT sum(p.duration) FROM public.personal_history_parts(actor,history_workouts.id) p) duration FROM public.history_workouts
    WHERE user_id=actor AND NOT deleted AND completes IS NULL ORDER BY starting_date DESC,id LIMIT 5) x),'[]'));
 ELSIF operation='history' THEN
  SELECT jsonb_build_object('total',count(*)) INTO result FROM public.history_workouts
   WHERE user_id=actor AND NOT deleted AND completes IS NULL AND starting_date>=since_date
   AND (COALESCE(payload->>'search','')='' OR strpos(lower(name),lower(payload->>'search'))>0);
  RETURN result || jsonb_build_object('items',COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM
   (SELECT id,name,starting_date,(SELECT sum(p.duration) FROM public.personal_history_parts(actor,history_workouts.id) p) duration,weight_unit,distance_unit FROM public.history_workouts
    WHERE user_id=actor AND NOT deleted AND completes IS NULL AND starting_date>=since_date
    AND (COALESCE(payload->>'search','')='' OR strpos(lower(name),lower(payload->>'search'))>0)
    ORDER BY starting_date DESC,id LIMIT take OFFSET skip) x),'[]'));
 ELSIF operation='detail' THEN
  result := public.personal_workout(actor,payload->>'id',true);
  IF result IS NULL THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
  RETURN result;
 ELSIF operation='routines' THEN
  RETURN jsonb_build_object('routines',COALESCE((SELECT jsonb_agg(public.personal_workout(actor,id,false) ORDER BY sort_order,id)
    FROM public.routines WHERE user_id=actor AND NOT deleted),'[]'),
   'folders',COALESCE((SELECT jsonb_agg(to_jsonb(f)-'user_id'-'updated_at'-'deleted' ORDER BY sort_order,id)
    FROM public.routine_folders f WHERE user_id=actor AND NOT deleted),'[]'));
 ELSIF operation='progress' THEN
  -- Aggregate every completed set, independently of the history page or chart period.
  WITH raw AS (
   SELECT w.root_id id,w.starting_date,e.name,COALESCE(e.library_exercise_id,e.custom_exercise_id,e.name) exercise_id,
    COALESCE(s->>'parameters',e.parameters) metric,s,w.weight_unit,w.distance_unit
   FROM public.personal_history_parts(actor) w JOIN public.history_workout_exercises e ON e.routine_id=w.id AND e.user_id=actor
   CROSS JOIN LATERAL jsonb_array_elements(COALESCE(e.sets,'[]')) s
   WHERE NOT e.deleted AND NOT e.is_superset AND s->>'done'='true'
  ), measured AS (
   SELECT id,starting_date,name,exercise_id,metric,
    CASE metric WHEN 'repsWeight' THEN (s->>'weight')::numeric * CASE weight_unit WHEN 'lb' THEN 0.45359237 ELSE 1 END
     WHEN 'timeWeight' THEN (s->>'weight')::numeric * CASE weight_unit WHEN 'lb' THEN 0.45359237 ELSE 1 END
     WHEN 'repsNegWeight' THEN abs((s->>'weight')::numeric) * CASE weight_unit WHEN 'lb' THEN 0.45359237 ELSE 1 END
     WHEN 'freeBodyReps' THEN (s->>'reps')::numeric WHEN 'time' THEN (s->>'time')::numeric/1000000
     WHEN 'distance' THEN (s->>'distance')::numeric * CASE distance_unit WHEN 'mi' THEN 1.609344 ELSE 1 END END value,
    CASE metric WHEN 'freeBodyReps' THEN 'reps' WHEN 'time' THEN 's' WHEN 'distance' THEN 'km' ELSE 'kg' END unit
   FROM raw
  ), points AS (
   SELECT id,starting_date,exercise_id,metric,unit,max(name) name,
    CASE WHEN metric='repsNegWeight' THEN min(value) ELSE max(value) END value
   FROM measured WHERE value>=0 AND value::text NOT IN ('NaN','Infinity') GROUP BY id,starting_date,exercise_id,metric,unit
  ), grouped AS (
   SELECT exercise_id,metric,unit,max(name) name,
    (jsonb_agg(jsonb_build_object('value',value,'date',starting_date) ORDER BY
      CASE WHEN metric='repsNegWeight' THEN -value ELSE value END DESC, starting_date DESC)->0) record,
    COALESCE(jsonb_agg(jsonb_build_object('id',id,'date',starting_date,'value',value) ORDER BY starting_date,id)
      FILTER (WHERE starting_date>=since_date),'[]') points
   FROM points GROUP BY exercise_id,metric,unit
  ) SELECT COALESCE(jsonb_agg(to_jsonb(grouped) ORDER BY name,metric),'[]') INTO result FROM grouped;
  RETURN result;
 ELSIF operation='share_create' THEN
  INSERT INTO public.shared_programs(owner_id,document) VALUES(actor,payload->'document')
   RETURNING jsonb_build_object('id',id,'token',token,'created_at',created_at) INTO result;
  RETURN result;
 ELSIF operation='shares' THEN
  RETURN COALESCE((SELECT jsonb_agg(jsonb_build_object('id',id,'token',token,'title',document->>'title','created_at',created_at,'revoked_at',revoked_at) ORDER BY created_at DESC)
   FROM public.shared_programs WHERE owner_id=actor),'[]');
 ELSIF operation='share_revoke' THEN
  UPDATE public.shared_programs SET revoked_at=COALESCE(revoked_at,now()) WHERE id=(payload->>'id')::uuid AND owner_id=actor;
  IF NOT FOUND THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
  RETURN '{}'::jsonb;
 END IF;
 RAISE EXCEPTION 'invalid_request' USING ERRCODE='22023';
END $$;
REVOKE ALL ON FUNCTION public.personal_execute(uuid,text,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.personal_execute(uuid,text,jsonb) TO service_role;
