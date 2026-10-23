-- Private ChatGPT integration. This does not enable OAuth or activate sync v2.
BEGIN;
CREATE SCHEMA gymbro_mcp;
REVOKE ALL ON SCHEMA gymbro_mcp FROM PUBLIC, anon, authenticated;
CREATE ROLE gymbro_mcp_user NOLOGIN NOINHERIT;
GRANT gymbro_mcp_user TO authenticator;
GRANT USAGE ON SCHEMA public, auth TO gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION auth.uid(), auth.jwt() TO gymbro_mcp_user;

-- PUBLIC is inherited even by NOINHERIT roles. Preserve existing API callers,
-- then remove implicit access to all existing public functions.
DO $$ DECLARE f record; r text; BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature, p.oid FROM pg_proc p
 JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f'
 AND EXISTS(SELECT 1 FROM aclexplode(COALESCE(p.proacl,acldefault('f',p.proowner))) a WHERE a.grantee=0 AND a.privilege_type='EXECUTE')
 LOOP
  FOREACH r IN ARRAY ARRAY['anon','authenticated','service_role'] LOOP
   IF has_function_privilege(r,f.oid,'EXECUTE') THEN
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO %I',f.signature,r);
   END IF;
  END LOOP;
  EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC',f.signature);
 END LOOP;
END $$;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

CREATE TABLE gymbro_mcp.settings(singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), client_id text NOT NULL, resource text NOT NULL CHECK(resource LIKE 'https://%'));
CREATE TABLE gymbro_mcp.catalog(singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), version text NOT NULL, exercises jsonb NOT NULL);
CREATE TABLE gymbro_mcp.receipts(user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, idempotency_key uuid NOT NULL, request jsonb NOT NULL, result jsonb NOT NULL, PRIMARY KEY(user_id,idempotency_key));
REVOKE ALL ON ALL TABLES IN SCHEMA gymbro_mcp FROM PUBLIC, anon, authenticated, gymbro_mcp_user;

-- Only Auth may call this hook. Unknown OAuth clients are isolated too, but
-- cannot pass the MCP client check. Ordinary login/refresh claims are unchanged.
CREATE FUNCTION public.gymbro_mcp_access_token_hook(event jsonb) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE claims jsonb:=event->'claims'; config gymbro_mcp.settings;
BEGIN
 IF NULLIF(claims->>'client_id','') IS NOT NULL THEN
  claims:=jsonb_set(claims,'{role}','"gymbro_mcp_user"');
  SELECT * INTO config FROM gymbro_mcp.settings WHERE singleton;
  IF claims->>'client_id'=config.client_id THEN
   claims:=jsonb_set(claims,'{aud}',jsonb_build_array('authenticated',config.resource));
  END IF;
 END IF;
 RETURN jsonb_build_object('claims',claims);
END $$;
REVOKE ALL ON FUNCTION public.gymbro_mcp_access_token_hook(jsonb) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.gymbro_mcp_access_token_hook(jsonb) TO supabase_auth_admin;

CREATE FUNCTION gymbro_mcp.owner() RETURNS uuid LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE config gymbro_mcp.settings; claims jsonb:=auth.jwt();
BEGIN
 SELECT * INTO config FROM gymbro_mcp.settings WHERE singleton;
 IF auth.uid() IS NULL OR config.client_id IS NULL OR claims->>'role' IS DISTINCT FROM 'gymbro_mcp_user'
 OR claims->>'client_id' IS DISTINCT FROM config.client_id OR NOT COALESCE((claims->'aud') ? config.resource,false)
 THEN RAISE EXCEPTION 'MCP authentication required' USING ERRCODE='42501'; END IF;
 RETURN auth.uid();
END $$;
REVOKE ALL ON FUNCTION gymbro_mcp.owner() FROM PUBLIC,anon,authenticated,gymbro_mcp_user;

-- One bounded snapshot provides a consistent merged catalog, also after the
-- optional sync-v2 gate has revoked direct table access.
CREATE FUNCTION public.mcp_custom_exercises() RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); result jsonb;
BEGIN
 SELECT COALESCE(jsonb_agg(jsonb_build_object('source','custom','id',id,'name',name,'category','custom','parameters',parameters,
 'primaryMuscleGroup',primary_muscle_group,'secondaryMuscleGroups',secondary_muscle_groups,'equipment',COALESCE(equipment,'none')) ORDER BY id),'[]')
 INTO result FROM public.custom_exercises WHERE user_id=owner AND NOT deleted;
 RETURN result;
END $$;
CREATE FUNCTION public.mcp_list_routines(page_offset integer DEFAULT 0, page_limit integer DEFAULT 20) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); result jsonb;
BEGIN
 IF page_offset<0 OR page_limit NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid pagination' USING ERRCODE='22023'; END IF;
 SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO result FROM (
 SELECT r.id,r.name,r.weight_unit AS "weightUnit",r.distance_unit AS "distanceUnit",r.folder_id AS "folderId",f.name AS "folderName"
 FROM public.routines r LEFT JOIN public.routine_folders f ON f.id=r.folder_id AND f.user_id=owner AND NOT f.deleted
 WHERE r.user_id=owner AND NOT r.deleted ORDER BY r.sort_order,r.id OFFSET page_offset LIMIT page_limit+1) t;
 RETURN result;
END $$;
CREATE FUNCTION public.mcp_get_routine(routine_id text) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); result jsonb;
BEGIN
 SELECT to_jsonb(r)||jsonb_build_object('exercises',COALESCE((SELECT jsonb_agg(to_jsonb(e) ORDER BY e.sort_order,e.id) FROM public.routine_exercises e WHERE e.user_id=owner AND e.routine_id=r.id AND NOT e.deleted),'[]'))
 INTO result FROM public.routines r WHERE r.user_id=owner AND r.id=routine_id AND NOT r.deleted;
 IF result IS NULL THEN RAISE EXCEPTION 'Routine unavailable' USING ERRCODE='P0002'; END IF;
 RETURN result-'user_id';
END $$;

-- Shared strict validators also protect direct RPC calls from forged metadata.
CREATE FUNCTION gymbro_mcp.object_keys(value jsonb, allowed text[]) RETURNS void LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
BEGIN
 IF jsonb_typeof(value) IS DISTINCT FROM 'object' OR EXISTS(SELECT 1 FROM jsonb_object_keys(value) k WHERE NOT k=ANY(allowed))
 THEN RAISE EXCEPTION 'Invalid object fields' USING ERRCODE='22023'; END IF;
END $$;
CREATE FUNCTION gymbro_mcp.text_value(value jsonb, max_length integer, required boolean DEFAULT false) RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
DECLARE result text:=COALESCE(value#>>'{}','');
BEGIN
 IF (value IS NOT NULL AND jsonb_typeof(value)<>'string') OR length(result)>max_length OR (required AND length(btrim(result))=0)
 THEN RAISE EXCEPTION 'Invalid text' USING ERRCODE='22023'; END IF;
 RETURN result;
END $$;
CREATE FUNCTION gymbro_mcp.number_value(value jsonb, max_value numeric, integral boolean DEFAULT false) RETURNS numeric LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
DECLARE result numeric;
BEGIN
 IF value IS NULL THEN RETURN NULL; END IF;
 IF jsonb_typeof(value)<>'number' THEN RAISE EXCEPTION 'Invalid number' USING ERRCODE='22023'; END IF;
 result:=(value#>>'{}')::numeric;
 IF result<0 OR result>max_value OR (integral AND result<>trunc(result)) THEN RAISE EXCEPTION 'Number out of range' USING ERRCODE='22023'; END IF;
 RETURN result;
END $$;

CREATE FUNCTION public.mcp_create_program(program jsonb, idempotency_key uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); previous gymbro_mcp.receipts; folder_id uuid:=gen_random_uuid(); routine_id text; exercise_id text;
 routine jsonb; exercise jsonb; reference jsonb; definition jsonb; item jsonb; normalized_sets jsonb; routines_result jsonb:='[]'; result jsonb;
 folder_name text; routine_name text; notes text; exercise_notes text; info text; weight_unit text; distance_unit text; parameters text; kind text;
 repetitions numeric; weight numeric; duration numeric; distance numeric; perceived numeric; rest numeric; routine_order integer:=0; exercise_order integer; folder_order integer; catalog jsonb;
BEGIN
 IF idempotency_key IS NULL OR octet_length(program::text)>1048576 THEN RAISE EXCEPTION 'Invalid program' USING ERRCODE='22023'; END IF;
 -- Serialize writes and retries with the same lock used by sync_push_v2.
 INSERT INTO public.sync_accounts_v2(user_id) VALUES(owner) ON CONFLICT DO NOTHING;
 PERFORM 1 FROM public.sync_accounts_v2 WHERE user_id=owner FOR UPDATE;
 SELECT * INTO previous FROM gymbro_mcp.receipts r WHERE r.user_id=owner AND r.idempotency_key=mcp_create_program.idempotency_key;
 IF FOUND THEN
  IF previous.request<>program THEN RAISE EXCEPTION 'Idempotency key reused' USING ERRCODE='23505'; END IF;
  RETURN previous.result;
 END IF;
 PERFORM gymbro_mcp.object_keys(program,ARRAY['name','notes','routines']);
 folder_name:=gymbro_mcp.text_value(program->'name',200,true);
 notes:=gymbro_mcp.text_value(program->'notes',10000);
 IF jsonb_typeof(program->'routines') IS DISTINCT FROM 'array' OR jsonb_array_length(program->'routines') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid routines' USING ERRCODE='22023'; END IF;
 SELECT exercises INTO catalog FROM gymbro_mcp.catalog WHERE singleton;
 IF catalog IS NULL THEN RAISE EXCEPTION 'Catalog not configured'; END IF;
 PERFORM set_config('gymtracker.sync_v2','on',true);
 SELECT COALESCE(max(sort_order)+1,0) INTO folder_order FROM public.routine_folders WHERE user_id=owner AND NOT deleted;
 INSERT INTO public.routine_folders(id,user_id,name,notes,sort_order) VALUES(folder_id,owner,folder_name,notes,folder_order);
 FOR routine IN SELECT value FROM jsonb_array_elements(program->'routines') LOOP
  PERFORM gymbro_mcp.object_keys(routine,ARRAY['name','notes','weightUnit','distanceUnit','exercises']);
  routine_name:=gymbro_mcp.text_value(routine->'name',200,true);
  info:=gymbro_mcp.text_value(routine->'notes',10000);
  weight_unit:=COALESCE(routine->>'weightUnit','kg'); distance_unit:=COALESCE(routine->>'distanceUnit','km');
  IF weight_unit NOT IN ('kg','lb') OR distance_unit NOT IN ('km','mi') OR jsonb_typeof(routine->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(routine->'exercises') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid routine' USING ERRCODE='22023'; END IF;
  routine_id:=gen_random_uuid()::text;
  INSERT INTO public.routines(id,user_id,name,infobox,weight_unit,distance_unit,folder_id,sort_order)
  VALUES(routine_id,owner,routine_name,info,weight_unit,distance_unit,folder_id,routine_order);
  exercise_order:=0;
  FOR exercise IN SELECT value FROM jsonb_array_elements(routine->'exercises') LOOP
   PERFORM gymbro_mcp.object_keys(exercise,ARRAY['exerciseRef','notes','restSeconds','sets']);
   reference:=exercise->'exerciseRef';
   PERFORM gymbro_mcp.object_keys(reference,ARRAY['source','id']);
   PERFORM gymbro_mcp.text_value(reference->'id',300,true);
   definition:=NULL;
   IF reference->>'source'='standard' THEN
    SELECT value INTO definition FROM jsonb_array_elements(catalog) WHERE value->>'id'=reference->>'id';
   ELSIF reference->>'source'='custom' THEN
    SELECT jsonb_build_object('names',jsonb_build_object('it',name),'parameters',c.parameters,'primaryMuscleGroup',primary_muscle_group,'secondaryMuscleGroups',secondary_muscle_groups,'equipment',COALESCE(equipment,'none'))
    INTO definition FROM public.custom_exercises c WHERE c.user_id=owner AND c.id=reference->>'id' AND NOT c.deleted FOR SHARE;
   END IF;
   IF definition IS NULL THEN RAISE EXCEPTION 'Exercise unavailable' USING ERRCODE='P0002'; END IF;
   parameters:=definition->>'parameters';
   rest:=COALESCE(gymbro_mcp.number_value(exercise->'restSeconds',86400,true),0);
   exercise_notes:=gymbro_mcp.text_value(exercise->'notes',10000);
   IF jsonb_typeof(exercise->'sets') IS DISTINCT FROM 'array' OR jsonb_array_length(exercise->'sets')>100 OR (parameters<>'setless' AND jsonb_array_length(exercise->'sets')=0) OR (parameters='setless' AND jsonb_array_length(exercise->'sets')<>0) THEN RAISE EXCEPTION 'Invalid sets' USING ERRCODE='22023'; END IF;
   normalized_sets:='[]';
   FOR item IN SELECT value FROM jsonb_array_elements(exercise->'sets') LOOP
    PERFORM gymbro_mcp.object_keys(item,ARRAY['kind','reps','weight','timeSeconds','distance','rpe']);
    kind:=COALESCE(item->>'kind','normal');
    IF kind NOT IN ('warmUp','normal','drop','failure','failureStripping') THEN RAISE EXCEPTION 'Invalid set kind' USING ERRCODE='22023'; END IF;
    repetitions:=gymbro_mcp.number_value(item->'reps',100000,true);
    weight:=gymbro_mcp.number_value(item->'weight',100000);
    duration:=gymbro_mcp.number_value(item->'timeSeconds',604800);
    distance:=gymbro_mcp.number_value(item->'distance',100000);
    perceived:=gymbro_mcp.number_value(item->'rpe',10);
    IF (perceived IS NOT NULL AND perceived<1)
     OR (parameters IN ('repsWeight','freeBodyReps') AND repetitions IS NULL)
     OR (parameters NOT IN ('repsWeight','freeBodyReps') AND repetitions IS NOT NULL)
     OR (parameters NOT IN ('repsWeight','timeWeight') AND weight IS NOT NULL)
     OR (parameters IN ('time','timeWeight') AND duration IS NULL)
     OR (parameters NOT IN ('time','timeWeight') AND duration IS NOT NULL)
     OR (parameters='distance' AND distance IS NULL) OR (parameters<>'distance' AND distance IS NOT NULL)
    THEN RAISE EXCEPTION 'Set parameters do not match exercise' USING ERRCODE='22023'; END IF;
    normalized_sets:=normalized_sets||jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'kind',kind,'parameters',parameters,'reps',COALESCE(repetitions,0),'weight',COALESCE(weight,0),'time',COALESCE(round(duration*1000000),0),'distance',COALESCE(distance,0),'rpe',perceived,'done',false));
   END LOOP;
   exercise_id:=gen_random_uuid()::text;
   INSERT INTO public.routine_exercises(id,user_id,routine_id,name,parameters,sets,primary_muscle_group,secondary_muscle_groups,rest_time,is_custom,library_exercise_id,custom_exercise_id,notes,is_superset,is_in_superset,sort_order,equipment)
   VALUES(exercise_id,owner,routine_id,definition->'names'->>'it',parameters,normalized_sets,definition->>'primaryMuscleGroup',ARRAY(SELECT jsonb_array_elements_text(definition->'secondaryMuscleGroups')),rest::bigint,reference->>'source'='custom',CASE WHEN reference->>'source'='standard' THEN reference->>'id' END,CASE WHEN reference->>'source'='custom' THEN reference->>'id' END,exercise_notes,false,false,exercise_order,definition->>'equipment');
   exercise_order:=exercise_order+1;
  END LOOP;
  routines_result:=routines_result||jsonb_build_array(jsonb_build_object('id',routine_id,'name',routine_name,'exerciseCount',exercise_order));
  routine_order:=routine_order+1;
 END LOOP;
 result:=jsonb_build_object('folderId',folder_id,'name',folder_name,'routines',routines_result);
 INSERT INTO gymbro_mcp.receipts VALUES(owner,idempotency_key,program,result);
 RETURN result;
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_mcp FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
REVOKE ALL ON FUNCTION public.mcp_custom_exercises(),public.mcp_list_routines(integer,integer),public.mcp_get_routine(text),public.mcp_create_program(jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mcp_custom_exercises(),public.mcp_list_routines(integer,integer),public.mcp_get_routine(text),public.mcp_create_program(jsonb,uuid) TO gymbro_mcp_user;
COMMIT;
