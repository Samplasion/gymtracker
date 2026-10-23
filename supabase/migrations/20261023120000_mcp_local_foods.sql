-- Existing Flutter sync stores JSON documents as JSONB strings. Support both
-- that representation and native JSON from MCP without rewriting user data.
CREATE FUNCTION gymbro_mcp.decode_json(value jsonb) RETURNS jsonb
LANGUAGE sql IMMUTABLE SET search_path='' AS $$
 SELECT CASE WHEN jsonb_typeof(value)='string' THEN (value #>> '{}')::jsonb ELSE value END;
$$;
REVOKE ALL ON FUNCTION gymbro_mcp.decode_json(jsonb) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;

CREATE OR REPLACE FUNCTION gymbro_mcp.settings_for(owner uuid, day date) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE goal public.nutrition_goals; categories public.nutrition_categories; BEGIN
 SELECT * INTO goal FROM public.nutrition_goals WHERE user_id=owner AND NOT deleted
 ORDER BY (reference_date <= day::timestamp AT TIME ZONE 'UTC') DESC,
 CASE WHEN reference_date<=day::timestamp AT TIME ZONE 'UTC' THEN reference_date END DESC,reference_date ASC LIMIT 1;
 SELECT * INTO categories FROM public.nutrition_categories WHERE user_id=owner AND NOT deleted
 ORDER BY (reference_date <= day::timestamp AT TIME ZONE 'UTC') DESC,
 CASE WHEN reference_date<=day::timestamp AT TIME ZONE 'UTC' THEN reference_date END DESC,reference_date ASC LIMIT 1;
 RETURN jsonb_build_object('date',day,'goal',CASE WHEN goal.id IS NULL THEN jsonb_build_object('dailyCalories',2000,'dailyFat',2000.0/30,'dailyCarbs',250,'dailyProtein',100)
 ELSE jsonb_build_object('dailyCalories',goal.calories,'dailyFat',goal.fat,'dailyCarbs',goal.carbs,'dailyProtein',goal.protein) END,
 'goalIsDefault',goal.id IS NULL,'goalEffectiveFrom',goal.reference_date::date,
 'categories',COALESCE((SELECT jsonb_object_agg(c->>'name',c) FROM jsonb_array_elements(COALESCE(gymbro_mcp.decode_json(categories.json_data),'[]')) c),'{}'),'categoriesEffectiveFrom',categories.reference_date::date);
END $$;

CREATE OR REPLACE FUNCTION gymbro_mcp.food(owner uuid, ref jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE result jsonb; BEGIN
 PERFORM gymbro_mcp.object_keys(ref,ARRAY['source','id']); PERFORM gymbro_mcp.text_value(ref->'id',300,true);
 CASE ref->>'source'
 WHEN 'openfoodfacts' THEN SELECT definition INTO result FROM gymbro_mcp.food_cache WHERE key='product:'||(ref->>'id') AND cached_at>now()-interval '24 hours';
 WHEN 'favorite' THEN SELECT f.json_data INTO result FROM public.favorite_foods fav JOIN public.foods f ON f.id=fav.id AND f.user_id=owner WHERE fav.user_id=owner AND NOT fav.deleted AND NOT f.deleted AND f.id=ref->>'id';
 WHEN 'customBarcode' THEN SELECT json_data INTO result FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND id=ref->>'id';
 ELSE RAISE EXCEPTION 'Invalid food reference' USING ERRCODE='22023'; END CASE;
 RETURN gymbro_mcp.decode_json(result);
END $$;

CREATE OR REPLACE FUNCTION public.mcp_execute(operation text, request jsonb DEFAULT '{}', idempotency_key uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.require_consent(); result jsonb; items jsonb:='[]'; unavailable jsonb:='[]'; item jsonb; raw jsonb; first_day date; last_day date; offset_value int:=0; page_limit int:=20; cursor_data jsonb; fingerprint text; target text; d date; pro boolean; BEGIN
 IF request IS NULL OR jsonb_typeof(request)<>'object' OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 IF operation IN ('create_routines','create_custom_exercises','create_routine_folders') THEN RETURN gymbro_mcp.create(operation,request,idempotency_key); END IF;
 IF operation='log_foods' THEN RETURN gymbro_mcp.log_foods(request,idempotency_key); END IF;
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
  SELECT (now() AT TIME ZONE time_zone)::date INTO d FROM gymbro_mcp.consents WHERE user_id=owner;
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
