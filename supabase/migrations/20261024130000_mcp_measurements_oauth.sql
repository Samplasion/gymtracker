-- OAuth is the only authorization; preferences carry no permission state.
BEGIN;
CREATE TABLE gymbro_mcp.preferences (
 user_id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
 time_zone text NOT NULL DEFAULT 'UTC'
);
INSERT INTO gymbro_mcp.preferences SELECT user_id,CASE WHEN EXISTS(SELECT 1 FROM pg_timezone_names z WHERE z.name=c.time_zone) THEN time_zone ELSE 'UTC' END FROM gymbro_mcp.consents c;
REVOKE ALL ON gymbro_mcp.preferences FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE FUNCTION public.mcp_preferences(time_zone text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); zone text; BEGIN
 IF owner IS NULL OR auth.jwt()->>'role' IS DISTINCT FROM 'authenticated' OR NULLIF(auth.jwt()->>'client_id','') IS NOT NULL THEN RAISE EXCEPTION 'Ordinary account session required' USING ERRCODE='42501'; END IF;
 IF time_zone IS NOT NULL THEN
  zone:=CASE WHEN EXISTS(SELECT 1 FROM pg_timezone_names z WHERE z.name=time_zone) THEN time_zone ELSE 'UTC' END;
  INSERT INTO gymbro_mcp.preferences VALUES(owner,zone) ON CONFLICT(user_id) DO UPDATE SET time_zone=excluded.time_zone;
 END IF;
 RETURN jsonb_build_object('timeZone',COALESCE((SELECT p.time_zone FROM gymbro_mcp.preferences p WHERE p.user_id=owner),'UTC'),'isDefault',NOT EXISTS(SELECT 1 FROM gymbro_mcp.preferences p WHERE p.user_id=owner));
END $$;
REVOKE ALL ON FUNCTION public.mcp_preferences(text) FROM PUBLIC,anon,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.mcp_preferences(text) TO authenticated;
CREATE OR REPLACE FUNCTION gymbro_mcp.owner() RETURNS uuid LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE config gymbro_mcp.settings; claims jsonb:=auth.jwt(); BEGIN
 SELECT * INTO config FROM gymbro_mcp.settings WHERE singleton;
 IF auth.uid() IS NULL OR config.client_id IS NULL OR claims->>'role' IS DISTINCT FROM 'gymbro_mcp_user'
 OR claims->>'client_id' IS DISTINCT FROM config.client_id OR NOT COALESCE((claims->'aud') ? config.resource,false)
 OR NOT EXISTS(SELECT 1 FROM auth.sessions s JOIN auth.oauth_consents c ON c.user_id=s.user_id AND c.client_id=s.oauth_client_id
 WHERE s.id::text=claims->>'session_id' AND s.user_id=auth.uid() AND s.oauth_client_id::text=config.client_id
 AND c.revoked_at IS NULL AND (s.not_after IS NULL OR s.not_after>now()))
 THEN RAISE EXCEPTION 'MCP authentication required' USING ERRCODE='42501'; END IF;
 RETURN auth.uid();
END $$;
CREATE FUNCTION gymbro_mcp.time_zone(owner uuid) RETURNS text LANGUAGE sql STABLE SET search_path='' AS $$
 SELECT COALESCE((SELECT p.time_zone FROM gymbro_mcp.preferences p JOIN pg_timezone_names z ON z.name=p.time_zone WHERE p.user_id=owner),'UTC');
$$;
CREATE OR REPLACE FUNCTION gymbro_mcp.check_days(owner uuid, first_day date, last_day date) RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE today date; BEGIN
 IF first_day IS NULL OR last_day IS NULL OR first_day>last_day OR last_day-first_day>366 THEN RAISE EXCEPTION 'Invalid date range (maximum 367 days)' USING ERRCODE='22023'; END IF;
 today:=(now() AT TIME ZONE gymbro_mcp.time_zone(owner))::date;
 IF NOT gymbro_mcp.pro(owner) AND (first_day<today-7 OR last_day>today+7) THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
END $$;

CREATE OR REPLACE FUNCTION gymbro_mcp.create(operation text, request jsonb, idempotency_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); receipt gymbro_mcp.operations; old gymbro_mcp.receipts; pro boolean; result jsonb:='{}'; items jsonb:='[]'; item jsonb; r jsonb; normalized jsonb; saved jsonb; uid text; destination uuid; make_folder boolean; count_new int; i int:=0; BEGIN
 IF idempotency_key IS NULL OR request IS NULL OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 PERFORM gymbro_mcp.lock_account(owner);
 SELECT * INTO receipt FROM gymbro_mcp.operations WHERE user_id=owner AND operations.idempotency_key=$3;
 IF FOUND THEN
  IF receipt.operation<>operation OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN receipt.result;
 END IF;
 SELECT * INTO old FROM gymbro_mcp.receipts WHERE user_id=owner AND receipts.idempotency_key=$3;
 IF FOUND THEN
  IF operation<>'create_program' OR old.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN old.result;
 END IF;
 pro:=gymbro_mcp.pro(owner);
 IF operation IN ('create_program','create_routines') THEN
  IF operation='create_program' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['name','notes','routines']);
  ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['routines']); END IF;
  IF jsonb_typeof(request->'routines') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'routines') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid routines' USING ERRCODE='22023'; END IF;
  count_new:=jsonb_array_length(request->'routines');
  IF NOT pro AND (SELECT count(*) FROM public.routines WHERE user_id=owner AND NOT deleted)+count_new>4 THEN RAISE EXCEPTION 'plan_limit_exceeded' USING ERRCODE='P1004'; END IF;
  IF operation='create_program' THEN
   IF EXISTS(SELECT 1 FROM jsonb_array_elements(request->'routines') rr WHERE rr ? 'folderId') THEN RAISE EXCEPTION 'Program owns destination' USING ERRCODE='22023'; END IF;
   SELECT jsonb_agg(gymbro_mcp.normalize_routine(value)) INTO normalized FROM jsonb_array_elements(request->'routines');
   saved:=gymbro_mcp.insert_program(jsonb_set(request,'{routines}',normalized),pro);
   FOR r IN SELECT value FROM jsonb_array_elements(request->'routines') LOOP
    PERFORM gymbro_mcp.decorate_routine(saved->'routines'->i->>'id',r); i:=i+1;
   END LOOP;
   result:=saved||jsonb_build_object('placement',CASE WHEN pro THEN 'folder' ELSE 'root' END,'warnings',CASE WHEN pro THEN '[]'::jsonb ELSE '["Program folder name and notes were not persisted; routines were saved in the home."]'::jsonb END);
  ELSE
   FOR r IN SELECT value FROM jsonb_array_elements(request->'routines') LOOP
    normalized:=gymbro_mcp.normalize_routine(r); destination:=(r->>'folderId')::uuid;
    IF destination IS NOT NULL THEN
     IF NOT pro THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
     IF NOT EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id=owner AND id=destination AND NOT deleted) THEN RAISE EXCEPTION 'Folder unavailable' USING ERRCODE='P0002'; END IF;
    END IF;
    saved:=gymbro_mcp.insert_program(jsonb_build_object('name','Routines','routines',jsonb_build_array(normalized)),false,destination);
    PERFORM gymbro_mcp.decorate_routine(saved->'routines'->0->>'id',r);
    items:=items||(saved->'routines');
   END LOOP; result:=jsonb_build_object('items',items);
  END IF;
 ELSIF operation='create_custom_exercises' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['exercises']);
  IF jsonb_typeof(request->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'exercises') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid exercises' USING ERRCODE='22023'; END IF;
  IF NOT pro AND (SELECT count(*) FROM public.custom_exercises WHERE user_id=owner AND NOT deleted)+jsonb_array_length(request->'exercises')>10 THEN RAISE EXCEPTION 'plan_limit_exceeded' USING ERRCODE='P1004'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'exercises') LOOP
   PERFORM gymbro_mcp.object_keys(item,ARRAY['name','parameters','primaryMuscleGroup','secondaryMuscleGroups','equipment']);
   PERFORM gymbro_mcp.text_value(item->'name',200,true);
   IF NOT COALESCE(gymbro_mcp.muscle(item->>'primaryMuscleGroup'),false) OR NOT COALESCE(gymbro_mcp.equipment(COALESCE(item->>'equipment','none')),false)
   OR COALESCE(item->>'parameters','') NOT IN ('repsWeight','timeWeight','freeBodyReps','time','distance','setless')
   OR jsonb_typeof(COALESCE(item->'secondaryMuscleGroups','[]'))<>'array' THEN RAISE EXCEPTION 'Invalid exercise metadata' USING ERRCODE='22023'; END IF;
   IF EXISTS(SELECT 1 FROM jsonb_array_elements_text(COALESCE(item->'secondaryMuscleGroups','[]')) m WHERE NOT COALESCE(gymbro_mcp.muscle(m),false)) THEN RAISE EXCEPTION 'Invalid muscle' USING ERRCODE='22023'; END IF;
   uid:=gen_random_uuid()::text;
   INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group,secondary_muscle_groups,equipment)
   VALUES(uid,owner,btrim(item->>'name'),item->>'parameters',item->>'primaryMuscleGroup',ARRAY(SELECT DISTINCT jsonb_array_elements_text(COALESCE(item->'secondaryMuscleGroups','[]'))),COALESCE(item->>'equipment','none'));
   items:=items||jsonb_build_array(jsonb_build_object('source','custom','id',uid,'name',btrim(item->>'name')));
  END LOOP; result:=jsonb_build_object('items',items);
 ELSIF operation='create_routine_folders' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['folders']);
  IF NOT pro THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
  IF jsonb_typeof(request->'folders') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'folders') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid folders' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'folders') LOOP
   PERFORM gymbro_mcp.object_keys(item,ARRAY['name','notes']);
   uid:=gen_random_uuid()::text;
   INSERT INTO public.routine_folders(id,user_id,name,notes,sort_order) SELECT uid::uuid,owner,gymbro_mcp.text_value(item->'name',200,true),gymbro_mcp.text_value(item->'notes',10000),COALESCE(max(sort_order)+1,0) FROM public.routine_folders WHERE user_id=owner AND NOT deleted;
   items:=items||jsonb_build_array(jsonb_build_object('id',uid,'name',item->>'name'));
  END LOOP; result:=jsonb_build_object('items',items);
 ELSE RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023'; END IF;
 IF operation='create_program' THEN INSERT INTO gymbro_mcp.receipts VALUES(owner,idempotency_key,request,result);
 ELSE INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,operation,request,result); END IF;
 RETURN result;
END $$;

CREATE OR REPLACE FUNCTION gymbro_mcp.log_foods(request jsonb, idempotency_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); receipt gymbro_mcp.operations; item jsonb; f jsonb; day date; settings jsonb; uid text; amount numeric; pieces int; items jsonb:='[]'; result jsonb; BEGIN
 PERFORM gymbro_mcp.lock_account(owner);
 IF idempotency_key IS NULL OR request IS NULL OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid food request' USING ERRCODE='22023'; END IF;
 SELECT * INTO receipt FROM gymbro_mcp.operations o WHERE user_id=owner AND o.idempotency_key=log_foods.idempotency_key;
 IF FOUND THEN IF receipt.operation<>'log_foods' OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN receipt.result; END IF;
 IF EXISTS(SELECT 1 FROM gymbro_mcp.receipts r WHERE user_id=owner AND r.idempotency_key=log_foods.idempotency_key) THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
 PERFORM gymbro_mcp.pro(owner);
 PERFORM gymbro_mcp.object_keys(request,ARRAY['entries']);
 IF jsonb_typeof(request->'entries') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'entries') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid entries' USING ERRCODE='22023'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(request->'entries') LOOP
  PERFORM gymbro_mcp.object_keys(item,ARRAY['date','category','amount','pieces','food','foodRef']);
  day:=gymbro_mcp.day(item->>'date'); PERFORM gymbro_mcp.check_days(owner,day,day);
  IF (item ? 'food')=(item ? 'foodRef') THEN RAISE EXCEPTION 'Supply food or foodRef exclusively' USING ERRCODE='22023'; END IF;
  f:=CASE WHEN item ? 'food' THEN item->'food' ELSE gymbro_mcp.food(owner,item->'foodRef') END;
  IF f IS NULL THEN RAISE EXCEPTION 'Food unavailable' USING ERRCODE='P0002'; END IF;
  -- Only the server-resolved definition can carry catalog provenance.
  IF item ? 'food' AND (f ? 'barcode' OR f ? 'isDownloaded') THEN RAISE EXCEPTION 'Forged provenance' USING ERRCODE='22023'; END IF;
  f:=f-ARRAY['id','amount','pieces','category']; PERFORM gymbro_mcp.validate_food(f);
  amount:=gymbro_mcp.number_value(item->'amount',1e6); pieces:=COALESCE(gymbro_mcp.number_value(item->'pieces',10000,true),1);
  IF amount IS NULL OR amount<=0 OR pieces<=0 THEN RAISE EXCEPTION 'Invalid quantity' USING ERRCODE='22023'; END IF;
  settings:=gymbro_mcp.settings_for(owner,day);
  IF item ? 'category' THEN
   PERFORM gymbro_mcp.text_value(item->'category',200,true);
   IF NOT (settings->'categories' ? (item->>'category')) THEN RAISE EXCEPTION 'Category unavailable' USING ERRCODE='P0002'; END IF;
  END IF;
  uid:=gen_random_uuid()::text;
  f:=f||jsonb_build_object('id',uid,'amount',amount,'pieces',pieces,'category',item->'category','servingSizes',COALESCE(f->'servingSizes','[]'),'isDownloaded',COALESCE(f->'isDownloaded','false'));
  INSERT INTO public.foods(id,user_id,date_added,reference_date,json_data) VALUES(uid,owner,clock_timestamp(),day::timestamp AT TIME ZONE 'UTC',f);
  items:=items||jsonb_build_array(jsonb_build_object('id',uid,'date',day,'food',f));
 END LOOP;
 result:=jsonb_build_object('items',items);
 INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,'log_foods',request,result);
 RETURN result;
END $$;

CREATE OR REPLACE FUNCTION public.mcp_execute(operation text, request jsonb DEFAULT '{}', idempotency_key uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); result jsonb; items jsonb:='[]'; unavailable jsonb:='[]'; item jsonb; raw jsonb; first_day date; last_day date; offset_value int:=0; page_limit int:=20; cursor_data jsonb; fingerprint text; target text; d date; pro boolean; BEGIN
 IF request IS NULL OR jsonb_typeof(request)<>'object' OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 IF operation IN ('create_routines','create_custom_exercises','create_routine_folders') THEN RETURN gymbro_mcp.create(operation,request,idempotency_key); END IF;
 IF operation='log_foods' THEN RETURN gymbro_mcp.log_foods(request,idempotency_key); END IF;
 IF operation IN ('list_measurements','get_measurements','create_measurements') THEN RETURN gymbro_mcp.measurements(operation,request,idempotency_key); END IF;
 -- Every direct caller is validated before executing even read-only operations.
 IF operation IN ('get_routines','get_workouts','get_food_entries') THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['ids','language']);
  IF jsonb_typeof(request->'ids') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'ids') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid IDs' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'ids') LOOP
   target:=gymbro_mcp.text_value(item,300,true); raw:=NULL;
   IF operation='get_routines' THEN
    IF EXISTS(SELECT 1 FROM public.routines WHERE user_id=owner AND id=target AND NOT deleted) THEN raw:=public.mcp_get_routine(target); END IF;
   ELSIF operation='get_workouts' THEN raw:=gymbro_mcp.workout(owner,target);
   ELSE
    SELECT jsonb_build_object('id',id,'date',(reference_date AT TIME ZONE 'UTC')::date,'food',gymbro_mcp.decode_json(json_data)) INTO raw FROM public.foods WHERE user_id=owner AND id=target AND NOT deleted;
    IF raw IS NOT NULL THEN d:=gymbro_mcp.day(raw->>'date'); PERFORM gymbro_mcp.check_days(owner,d,d); END IF;
   END IF;
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(target); ELSE items:=items||jsonb_build_array(raw); END IF;
  END LOOP; RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 END IF;
 IF operation='external_access' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY[]::text[]); RETURN '{"allowed":true}'::jsonb; END IF;
 IF operation='get_foods' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['references']);
  IF jsonb_typeof(request->'references') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'references') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid references' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'references') LOOP
   raw:=gymbro_mcp.food(owner,item);
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(item); ELSE items:=items||jsonb_build_array(jsonb_build_object('reference',item,'food',raw)); END IF;
  END LOOP; RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 END IF;
 IF operation='get_account_limits' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY[]::text[]); pro:=gymbro_mcp.pro(owner);
  d:=(now() AT TIME ZONE gymbro_mcp.time_zone(owner))::date;
  RETURN jsonb_build_object('plan',CASE WHEN pro THEN 'pro' ELSE 'free' END,'routineLimit',CASE WHEN pro THEN NULL ELSE 4 END,'customExerciseLimit',CASE WHEN pro THEN NULL ELSE 10 END,
   'routinesUsed',(SELECT count(*) FROM public.routines WHERE user_id=owner AND NOT deleted),'customExercisesUsed',(SELECT count(*) FROM public.custom_exercises WHERE user_id=owner AND NOT deleted),
   'canCreateFolders',pro,'nutritionFrom',CASE WHEN pro THEN '2000-01-01'::date ELSE d-7 END,'nutritionTo',CASE WHEN pro THEN '2099-12-31'::date ELSE d+7 END);
 END IF;
 IF operation IN ('get_nutrition_summary','get_nutrition_settings','list_food_entries') THEN
  IF operation='list_food_entries' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to','category','cursor','limit']);
  ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to']); END IF;
  first_day:=gymbro_mcp.day(request->>'from'); last_day:=gymbro_mcp.day(request->>'to');
  PERFORM gymbro_mcp.check_days(owner,first_day,last_day);
  IF operation IN ('get_nutrition_summary','get_nutrition_settings') THEN
   SELECT jsonb_agg(gymbro_mcp.settings_for(owner,day::date) ORDER BY day) INTO items FROM generate_series(first_day::timestamp,last_day::timestamp,interval '1 day') day;
   IF operation='get_nutrition_settings' THEN RETURN jsonb_build_object('items',items); END IF;
   SELECT COALESCE(jsonb_agg(jsonb_build_object('id',id,'date',(reference_date AT TIME ZONE 'UTC')::date,'food',gymbro_mcp.decode_json(json_data)) ORDER BY reference_date,date_added,id),'[]') INTO raw FROM (SELECT id,reference_date,date_added,json_data FROM public.foods WHERE user_id=owner AND NOT deleted AND reference_date>=first_day::timestamp AT TIME ZONE 'UTC' AND reference_date<(last_day+1)::timestamp AT TIME ZONE 'UTC' ORDER BY reference_date,date_added,id LIMIT 10001) f;
   IF jsonb_array_length(raw)>10000 THEN RAISE EXCEPTION 'Nutrition interval too large; narrow dates' USING ERRCODE='22023'; END IF;
   RETURN jsonb_build_object('settings',items,'entries',raw);
  END IF;
 END IF;
 IF operation IN ('list_routine_folders','list_workouts','get_exercise_history','list_food_entries','search_foods','get_training_stats') THEN
  IF operation='list_routine_folders' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['cursor','limit']); END IF;
  IF operation IN ('list_workouts','get_training_stats','get_exercise_history') THEN
   IF operation='get_exercise_history' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['references','from','to','routineId','cursor','limit','language']);
   ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to','routineId','cursor','limit','language','weightUnit','distanceUnit']); END IF;
   first_day:=gymbro_mcp.day(request->>'from'); last_day:=gymbro_mcp.day(request->>'to');
   IF first_day>last_day OR last_day-first_day>366 THEN RAISE EXCEPTION 'Invalid training range' USING ERRCODE='22023'; END IF;
   IF operation='get_exercise_history' THEN
    IF jsonb_typeof(request->'references') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'references') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid references' USING ERRCODE='22023'; END IF;
    FOR item IN SELECT value FROM jsonb_array_elements(request->'references') LOOP
     PERFORM gymbro_mcp.object_keys(item,ARRAY['source','id']); PERFORM gymbro_mcp.text_value(item->'id',300,true);
     IF COALESCE(item->>'source','') NOT IN ('standard','custom') THEN RAISE EXCEPTION 'Invalid reference source' USING ERRCODE='22023'; END IF;
    END LOOP;
   END IF;
  END IF;
  IF operation='search_foods' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['query','source','cursor','limit','language','country']);
   PERFORM gymbro_mcp.text_value(request->'query',200,true);
   IF COALESCE(request->>'source','all') NOT IN ('all','favorite','customBarcode') THEN RAISE EXCEPTION 'Invalid private food source' USING ERRCODE='22023'; END IF;
  END IF;
  IF request ? 'limit' THEN page_limit:=gymbro_mcp.number_value(request->'limit',100,true); END IF;
  IF page_limit IS NULL OR page_limit<1 THEN RAISE EXCEPTION 'Invalid limit' USING ERRCODE='22023'; END IF;
  fingerprint:=md5(operation||(request-ARRAY['cursor','limit'])::text);
  IF request ? 'cursor' THEN
   BEGIN cursor_data:=convert_from(decode(request->>'cursor','base64'),'UTF8')::jsonb;
    offset_value:=(cursor_data->>'offset')::int;
    IF cursor_data->>'filter' IS DISTINCT FROM fingerprint OR offset_value IS NULL OR offset_value NOT BETWEEN 0 AND 1000000 THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
   EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Invalid cursor' USING ERRCODE='22023'; END;
  END IF;
  IF operation='list_routine_folders' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (SELECT f.id,f.name,f.notes,f.sort_order AS "sortOrder",(SELECT count(*) FROM public.routines r WHERE r.user_id=owner AND r.folder_id=f.id AND NOT r.deleted) AS "routineCount" FROM public.routine_folders f WHERE f.user_id=owner AND NOT f.deleted ORDER BY f.sort_order,f.id OFFSET offset_value LIMIT page_limit+1) t;
  ELSIF operation='list_food_entries' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (SELECT id,(reference_date AT TIME ZONE 'UTC')::date AS date,gymbro_mcp.decode_json(json_data) AS food FROM public.foods WHERE user_id=owner AND NOT deleted AND reference_date>=first_day::timestamp AT TIME ZONE 'UTC' AND reference_date<(last_day+1)::timestamp AT TIME ZONE 'UTC' AND (NOT request ? 'category' OR gymbro_mcp.decode_json(json_data)->>'category'=request->>'category') ORDER BY reference_date DESC,date_added DESC,id OFFSET offset_value LIMIT page_limit+1) t;
  ELSIF operation='search_foods' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (
    SELECT jsonb_build_object('source',source,'id',id) AS reference,food FROM (
     SELECT 'favorite' AS source,f.id,gymbro_mcp.decode_json(f.json_data) AS food FROM public.favorite_foods fav JOIN public.foods f ON f.user_id=owner AND f.id=fav.id AND NOT f.deleted WHERE fav.user_id=owner AND NOT fav.deleted AND COALESCE(request->>'source','all') IN ('all','favorite')
     UNION ALL SELECT 'customBarcode',id,gymbro_mcp.decode_json(json_data) FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND COALESCE(request->>'source','all') IN ('all','customBarcode')
    ) foods WHERE position(lower(request->>'query') IN lower(COALESCE(food->>'name','')||' '||COALESCE(food->>'brand','')))>0 ORDER BY source,id OFFSET offset_value LIMIT page_limit+1) t;
  ELSE
   SELECT COALESCE(jsonb_agg(gymbro_mcp.workout(owner,t.id)),'[]') INTO items FROM (
    SELECT w.id FROM public.history_workouts w WHERE w.user_id=owner AND NOT w.deleted
    AND (w.completes IS NULL OR NOT EXISTS(SELECT 1 FROM public.history_workouts original WHERE original.user_id=owner AND original.id=w.completes::text AND NOT original.deleted))
    AND w.starting_date>=first_day::timestamp AT TIME ZONE 'UTC' AND w.starting_date<(last_day+1)::timestamp AT TIME ZONE 'UTC'
    AND (NOT request ? 'routineId' OR w.parent_id=request->>'routineId')
    AND (operation<>'get_exercise_history' OR EXISTS(SELECT 1 FROM public.history_workout_exercises e JOIN public.history_workouts component ON component.id=e.routine_id AND component.user_id=owner CROSS JOIN LATERAL jsonb_array_elements(request->'references') ref WHERE e.user_id=owner AND NOT e.deleted AND NOT component.deleted AND (component.id=w.id OR component.completes::text=w.id) AND ((ref->>'source'='standard' AND e.library_exercise_id=ref->>'id' AND NOT e.is_custom) OR (ref->>'source'='custom' AND e.custom_exercise_id=ref->>'id' AND e.is_custom))))
    ORDER BY w.starting_date DESC,w.id OFFSET CASE WHEN operation='get_training_stats' THEN 0 ELSE offset_value END LIMIT CASE WHEN operation='get_training_stats' THEN 1001 ELSE page_limit+1 END
   ) t;
   -- Never silently truncate aggregation input.
   IF operation='get_training_stats' THEN
    IF jsonb_array_length(items)>1000 THEN RAISE EXCEPTION 'Training interval too large' USING ERRCODE='22023'; END IF;
    RETURN jsonb_build_object('items',items);
   END IF;
  END IF;
  RETURN jsonb_build_object('items',(SELECT COALESCE(jsonb_agg(value),'[]') FROM jsonb_array_elements(items) WITH ORDINALITY t(value,n) WHERE n<=page_limit),
   'nextCursor',CASE WHEN jsonb_array_length(items)>page_limit THEN encode(convert_to(jsonb_build_object('offset',offset_value+page_limit,'filter',fingerprint)::text,'UTF8'),'base64') ELSE NULL END);
 END IF;
 RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023';
END $$;

DROP FUNCTION public.mcp_manage_consent(boolean,text);
DROP FUNCTION gymbro_mcp.require_consent();
DROP TABLE gymbro_mcp.consents;

CREATE FUNCTION gymbro_mcp.measurement_time(value jsonb, owner uuid) RETURNS timestamptz
LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE input text; day date; BEGIN
 IF value IS NULL THEN RETURN now(); END IF;
 IF jsonb_typeof(value) IS DISTINCT FROM 'string' THEN RAISE EXCEPTION 'Invalid measurement time' USING ERRCODE='22023'; END IF;
 input:=value#>>'{}';
 IF input ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
  day:=input::date;
  IF to_char(day,'YYYY-MM-DD')<>input THEN RAISE EXCEPTION 'Invalid date' USING ERRCODE='22023'; END IF;
  RETURN day::timestamp AT TIME ZONE gymbro_mcp.time_zone(owner);
 END IF;
 IF input !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})$' THEN RAISE EXCEPTION 'Offset required' USING ERRCODE='22023'; END IF;
 RETURN input::timestamptz;
EXCEPTION WHEN datetime_field_overflow OR invalid_datetime_format THEN RAISE EXCEPTION 'Invalid measurement time' USING ERRCODE='22023';
END $$;
CREATE FUNCTION gymbro_mcp.measurements(operation text, request jsonb, idempotency_key uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); receipt gymbro_mcp.operations; item jsonb; items jsonb:='[]'; unavailable jsonb:='[]'; raw jsonb; result jsonb;
 kind text; part text; unit text; uid text; value numeric; measured timestamptz; i int:=0; lim int:=20; first_time timestamptz; end_time timestamptz;
 cursor_data jsonb; cursor_time timestamptz; cursor_kind text; cursor_id text; fingerprint text; more boolean; last_row jsonb;
 body_types text[]:=ARRAY['waist','bodyFat','neck','shoulder','chest','leftBicep','rightBicep','leftForearm','rightForearm','abdomen','hips','leftThigh','rightThigh','leftCalf','rightCalf'];
BEGIN
 IF operation='create_measurements' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['entries']);
  IF idempotency_key IS NULL THEN RAISE EXCEPTION 'Idempotency key required' USING ERRCODE='22023'; END IF;
  PERFORM gymbro_mcp.lock_account(owner);
  SELECT * INTO receipt FROM gymbro_mcp.operations WHERE user_id=owner AND operations.idempotency_key=$3;
  IF FOUND THEN
   IF receipt.operation<>operation OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN receipt.result;
  END IF;
  IF EXISTS(SELECT 1 FROM gymbro_mcp.receipts WHERE user_id=owner AND receipts.idempotency_key=$3) THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
  IF jsonb_typeof(request->'entries') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'entries') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid entries' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT v FROM jsonb_array_elements(request->'entries') v LOOP
   BEGIN
    kind:=item->>'kind'; part:=NULL;
    IF kind='weight' THEN
     PERFORM gymbro_mcp.object_keys(item,ARRAY['kind','value','unit','time']); unit:=COALESCE(item->>'unit','kg');
     IF unit NOT IN ('kg','lb') OR item->'unit'='null'::jsonb THEN RAISE EXCEPTION 'Invalid unit' USING ERRCODE='22023'; END IF;
    ELSIF kind='body' THEN
     PERFORM gymbro_mcp.object_keys(item,ARRAY['kind','value','type','time']); part:=item->>'type';
     IF part IS NULL OR NOT part=ANY(body_types) THEN RAISE EXCEPTION 'Invalid type' USING ERRCODE='22023'; END IF;
     unit:=CASE WHEN part='bodyFat' THEN '%' ELSE 'cm' END;
    ELSE RAISE EXCEPTION 'Invalid kind' USING ERRCODE='22023'; END IF;
    value:=gymbro_mcp.number_value(item->'value',3.4028234e38,false);
    IF value IS NULL OR (part='bodyFat' AND value>100) THEN RAISE EXCEPTION 'Invalid value' USING ERRCODE='22023'; END IF;
    measured:=gymbro_mcp.measurement_time(item->'time',owner); uid:=gen_random_uuid()::text;
    IF kind='weight' THEN INSERT INTO public.weight_measurements(id,user_id,weight,time,weight_unit) VALUES(uid,owner,value,measured,unit) RETURNING weight INTO value;
    ELSE INSERT INTO public.body_measurements(id,user_id,value,time,type) VALUES(uid,owner,value,measured,part) RETURNING body_measurements.value INTO value; END IF;
    items:=items||jsonb_build_array(jsonb_build_object('reference',jsonb_build_object('kind',kind,'id',uid),'value',value,'unit',unit,'time',measured)||CASE WHEN part IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('type',part) END);
   EXCEPTION WHEN invalid_parameter_value OR invalid_text_representation OR numeric_value_out_of_range THEN RAISE EXCEPTION 'entries[%]: Invalid measurement',i USING ERRCODE='22023'; END;
   i:=i+1;
  END LOOP;
  result:=jsonb_build_object('items',items);
  INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,operation,request,result);
  RETURN result;
 ELSIF operation='get_measurements' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['references']);
  IF jsonb_typeof(request->'references') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'references') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid references' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT v FROM jsonb_array_elements(request->'references') v LOOP
   PERFORM gymbro_mcp.object_keys(item,ARRAY['kind','id']); uid:=gymbro_mcp.text_value(item->'id',300,true); kind:=item->>'kind'; raw:=NULL;
   IF kind='weight' THEN SELECT jsonb_build_object('reference',item,'value',weight,'unit',weight_unit,'time',time) INTO raw FROM public.weight_measurements WHERE user_id=owner AND id=uid AND NOT deleted;
   ELSIF kind='body' THEN SELECT jsonb_build_object('reference',item,'value',b.value,'unit',CASE WHEN b.type='bodyFat' THEN '%' ELSE 'cm' END,'type',b.type,'time',b.time) INTO raw FROM public.body_measurements b WHERE b.user_id=owner AND b.id=uid AND NOT b.deleted;
   ELSE RAISE EXCEPTION 'Invalid kind' USING ERRCODE='22023'; END IF;
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(item); ELSE items:=items||jsonb_build_array(raw); END IF;
  END LOOP;
  RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 ELSIF operation='list_measurements' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['kind','types','from','to','cursor','limit']);
  kind:=COALESCE(request->>'kind','all');
  IF kind NOT IN ('weight','body','all') OR (request ? 'types' AND kind='weight') THEN RAISE EXCEPTION 'Invalid kind filter' USING ERRCODE='22023'; END IF;
  IF request ? 'types' THEN
   IF jsonb_typeof(request->'types') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'types') NOT BETWEEN 1 AND 15 THEN RAISE EXCEPTION 'Invalid types' USING ERRCODE='22023'; END IF;
   FOR item IN SELECT v FROM jsonb_array_elements(request->'types') v LOOP
    IF jsonb_typeof(item)<>'string' OR NOT (item#>>'{}')=ANY(body_types) THEN RAISE EXCEPTION 'Invalid type filter' USING ERRCODE='22023'; END IF;
   END LOOP;
  END IF;
  IF request ? 'from' THEN
   IF jsonb_typeof(request->'from') IS DISTINCT FROM 'string' OR request->>'from' !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN RAISE EXCEPTION 'Invalid from date' USING ERRCODE='22023'; END IF;
   first_time:=gymbro_mcp.measurement_time(request->'from',owner);
  END IF;
  IF request ? 'to' THEN
   IF jsonb_typeof(request->'to') IS DISTINCT FROM 'string' OR request->>'to' !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN RAISE EXCEPTION 'Invalid to date' USING ERRCODE='22023'; END IF;
   PERFORM gymbro_mcp.measurement_time(request->'to',owner);
   end_time:=((request->>'to')::date+1)::timestamp AT TIME ZONE gymbro_mcp.time_zone(owner);
  END IF;
  IF first_time>=end_time THEN RAISE EXCEPTION 'Invalid interval' USING ERRCODE='22023'; END IF;
  IF request ? 'limit' THEN lim:=gymbro_mcp.number_value(request->'limit',100,true); END IF;
  IF lim IS NULL OR lim<1 THEN RAISE EXCEPTION 'Invalid limit' USING ERRCODE='22023'; END IF;
  fingerprint:=md5((request-ARRAY['cursor','limit'])::text||gymbro_mcp.time_zone(owner));
  IF request ? 'cursor' THEN
   BEGIN
    cursor_data:=convert_from(decode(request->>'cursor','base64'),'UTF8')::jsonb;
    cursor_time:=(cursor_data->>'time')::timestamptz; cursor_kind:=cursor_data->>'kind'; cursor_id:=cursor_data->>'id';
    IF cursor_data->>'filter' IS DISTINCT FROM fingerprint OR cursor_time IS NULL OR cursor_kind IS NULL OR cursor_id IS NULL THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
   EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Invalid cursor' USING ERRCODE='22023'; END;
  END IF;
  SELECT COALESCE(jsonb_agg(jsonb_build_object('reference',jsonb_build_object('kind',t.kind,'id',t.id),'value',t.value,'unit',t.unit,'time',t.time)||CASE WHEN t.type IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('type',t.type) END ORDER BY t.time DESC,t.kind DESC,t.id DESC),'[]') INTO items FROM (
   SELECT * FROM (
    SELECT 'weight' AS kind,w.id,w.weight AS value,w.weight_unit AS unit,w.time,NULL::text AS type FROM public.weight_measurements w WHERE w.user_id=owner AND NOT w.deleted AND kind IN ('all','weight') AND NOT request ? 'types'
    UNION ALL SELECT 'body',b.id,b.value,CASE WHEN b.type='bodyFat' THEN '%' ELSE 'cm' END,b.time,b.type FROM public.body_measurements b WHERE b.user_id=owner AND NOT b.deleted AND kind IN ('all','body') AND (NOT request ? 'types' OR request->'types' ? b.type)
   ) x WHERE (first_time IS NULL OR x.time>=first_time) AND (end_time IS NULL OR x.time<end_time)
   AND (cursor_time IS NULL OR (x.time,x.kind,x.id)<(cursor_time,cursor_kind,cursor_id)) ORDER BY x.time DESC,x.kind DESC,x.id DESC LIMIT lim+1
  ) t;
  more:=jsonb_array_length(items)>lim;
  SELECT COALESCE(jsonb_agg(v),'[]') INTO items FROM jsonb_array_elements(items) WITH ORDINALITY t(v,n) WHERE n<=lim;
  last_row:=items->(jsonb_array_length(items)-1);
  RETURN jsonb_build_object('items',items,'nextCursor',CASE WHEN more THEN encode(convert_to(jsonb_build_object('time',last_row->>'time','kind',last_row->'reference'->>'kind','id',last_row->'reference'->>'id','filter',fingerprint)::text,'UTF8'),'base64') ELSE NULL END);
 END IF;
 RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023';
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_mcp FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE INDEX weight_measurements_mcp_time ON public.weight_measurements(user_id,time DESC,id) WHERE NOT deleted;
CREATE INDEX body_measurements_mcp_time ON public.body_measurements(user_id,time DESC,id) WHERE NOT deleted;
COMMIT;
