\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000081','mcp-free@unit.test','{"username":"mcpfree"}'),
 ('00000000-0000-0000-0000-000000000082','mcp-other@unit.test','{"username":"mcpother"}');
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000081',false,NULL,now(),'PRODUCTION');
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000081","session_id":"00000000-0000-0000-0000-000000000081","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_account_limits'); RAISE EXCEPTION 'Missing OAuth grant accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.mcp_preferences('Europe/Rome'); RAISE EXCEPTION 'MCP preferences write accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.mcp_store_billing('00000000-0000-0000-0000-000000000081',true,NULL,'PRODUCTION',now()); RAISE EXCEPTION 'MCP self-upgrade accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
SELECT public.test_mcp_oauth(id) FROM auth.users;
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000081","session_id":"00000000-0000-0000-0000-000000000081","role":"authenticated"}';
SELECT public.mcp_preferences('Europe/Rome');
RESET ROLE;
-- Array storage and date-effective fallback match the app's DateSequence.
INSERT INTO public.nutrition_categories(id,user_id,reference_date,json_data) VALUES('categories','00000000-0000-0000-0000-000000000081',now() AT TIME ZONE 'UTC','[{"name":"Lunch","dailyPercentage":40,"icon":"fork_and_spoon"}]');
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000081","session_id":"00000000-0000-0000-0000-000000000081","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE result jsonb; routine jsonb; request jsonb; again jsonb; food jsonb; day text:=(now() AT TIME ZONE 'Europe/Rome')::date::text; i int; BEGIN
 result:=public.mcp_execute('get_account_limits');
 IF result->>'plan'<>'free' OR result->>'routineLimit'<>'4' THEN RAISE EXCEPTION 'Wrong free limits'; END IF;
 result:=public.mcp_execute('create_custom_exercises','{"exercises":[{"name":"Custom lift","parameters":"repsWeight","primaryMuscleGroup":"chest","equipment":"barbell"}]}','00000000-0000-0000-0000-000000000083');
 request:=jsonb_build_object('name','Home program','routines',jsonb_build_array(jsonb_build_object('name','Superset day','exercises',jsonb_build_array(jsonb_build_object('type','superset','restSeconds',120,'exercises',jsonb_build_array(
 jsonb_build_object('exerciseRef',(result->'items'->0)-'name','rpe',8,'sets','[{"reps":8,"rpe":8.5},{"reps":8}]'::jsonb,'progression','{"mode":"doubleProgression","minReps":8,"maxReps":12,"repsPerStep":1,"startingWeight":0,"weightPerStep":2.5,"weightPerCycle":0}'::jsonb),
 '{"exerciseRef":{"source":"standard","id":"library.abs.exercises.bicycleCrunches"},"sets":[{"reps":12}]}'::jsonb))))));
 result:=public.mcp_create_program(request,'00000000-0000-0000-0000-000000000084');
 IF result->'folderId'<>'null' OR result->>'placement'<>'root' THEN RAISE EXCEPTION 'Free program created folder'; END IF;
 routine:=public.mcp_get_routine(result->'routines'->0->>'id');
 IF jsonb_array_length(routine->'exercises')<>3 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(routine->'exercises') e WHERE (e->>'is_superset')::boolean) THEN RAISE EXCEPTION 'Superset did not persist'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(routine->'exercises') e WHERE (e->>'progression')::jsonb->>'setCount'='2' AND e->>'rpe'='8') THEN RAISE EXCEPTION 'Progression/RPE missing'; END IF;
 PERFORM set_config('gymbro.test.advanced_routine',routine::text,true);
 again:=public.mcp_create_program(request,'00000000-0000-0000-0000-000000000084'); IF result<>again THEN RAISE EXCEPTION 'Retry changed placement'; END IF;
 BEGIN PERFORM public.mcp_execute('create_routine_folders','{"folders":[{"name":"Pro"}]}',gen_random_uuid()); RAISE EXCEPTION 'Free folder accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 FOR i IN 1..3 LOOP PERFORM public.mcp_create_program(request,gen_random_uuid()); END LOOP;
 BEGIN PERFORM public.mcp_create_program(request,gen_random_uuid()); RAISE EXCEPTION 'Free quota bypass' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1004' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('create_custom_exercises','{"exercises":[{"name":"Fake","parameters":"bogus","primaryMuscleGroup":"chest"}]}',gen_random_uuid()); RAISE EXCEPTION 'Forged metadata' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;

 BEGIN
  PERFORM public.mcp_execute('create_custom_exercises',jsonb_build_object('exercises',(SELECT jsonb_agg('{"name":"Too many","parameters":"time","primaryMuscleGroup":"abs"}'::jsonb) FROM generate_series(1,10))),gen_random_uuid());
  RAISE EXCEPTION 'Custom exercise bulk quota bypass' USING ERRCODE='XX000';
 EXCEPTION WHEN SQLSTATE 'P1004' THEN NULL; END;
 food:=jsonb_build_object('date',day,'amount',50,'pieces',2,'category','Lunch','food','{"name":"Manual food","unit":"g","nutritionalValuesPer100g":{"calories":200,"fat":5,"saturatedFat":1,"carbs":20,"sugar":2,"protein":10}}'::jsonb);
 request:=jsonb_build_object('entries',jsonb_build_array(food));
 PERFORM set_config('gymbro.test.food_request',request::text,true);
 result:=public.mcp_execute('log_foods',request,'00000000-0000-0000-0000-000000000085');
 again:=public.mcp_execute('log_foods',request,'00000000-0000-0000-0000-000000000085'); IF result<>again THEN RAISE EXCEPTION 'Food retry duplicated'; END IF;
 PERFORM set_config('gymbro.test.food_id',result->'items'->0->>'id',true);
 result:=public.mcp_execute('get_nutrition_summary',jsonb_build_object('from',day,'to',day));
 IF jsonb_array_length(result->'entries')<>1 OR result->'settings'->0->'categories'->'Lunch' IS NULL OR result->'settings'->0->>'goalIsDefault'<>'true' THEN RAISE EXCEPTION 'Nutrition settings mismatch'; END IF;
 FOR i IN -7..7 BY 14 LOOP
  PERFORM public.mcp_execute('get_nutrition_settings',jsonb_build_object('from',((day::date)+i)::text,'to',((day::date)+i)::text));
 END LOOP;
 BEGIN
  PERFORM public.mcp_execute('log_foods',jsonb_build_object('entries',jsonb_build_array(food,jsonb_set(food,'{date}',to_jsonb(((day::date)-8)::text)))),gen_random_uuid());
  RAISE EXCEPTION 'Mixed dates accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('get_nutrition_settings',jsonb_build_object('from',((day::date)-8)::text,'to',day)); RAISE EXCEPTION 'Free read outside window' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('get_routines','{"ids":[]}'); RAISE EXCEPTION 'Empty bulk accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.foods WHERE user_id='00000000-0000-0000-0000-000000000081')<>1 THEN RAISE EXCEPTION 'Partial food bulk committed'; END IF;
 IF EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id='00000000-0000-0000-0000-000000000081') THEN RAISE EXCEPTION 'Free folder exists'; END IF;
END $$;
\pset format unaligned
\pset tuples_only on
SELECT 'MCP_EXPANDED_FIXTURE:'||jsonb_build_object('routine',current_setting('gymbro.test.advanced_routine')::jsonb-'exercises','exercises',current_setting('gymbro.test.advanced_routine')::jsonb->'exercises','food',(SELECT to_jsonb(f) FROM public.foods f WHERE id=current_setting('gymbro.test.food_id')))::text;
\pset tuples_only off
\pset format aligned
UPDATE public.foods SET reference_date=reference_date-interval '9 days' WHERE id=current_setting('gymbro.test.food_id');
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_food_entries',jsonb_build_object('ids',jsonb_build_array(current_setting('gymbro.test.food_id')))); RAISE EXCEPTION 'ID date bypass' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
END $$;
RESET ROLE;
INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit,completed_by) VALUES('00000000-0000-0000-0000-000000000101','00000000-0000-0000-0000-000000000081','Session',60,now(),'kg','km',NULL);
INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit,completes) VALUES('00000000-0000-0000-0000-000000000102','00000000-0000-0000-0000-000000000081','Session',30,now(),'lb','mi','00000000-0000-0000-0000-000000000101');
UPDATE public.history_workouts SET completed_by='00000000-0000-0000-0000-000000000102' WHERE id='00000000-0000-0000-0000-000000000101' AND user_id='00000000-0000-0000-0000-000000000081';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE result jsonb; day text:=(now() AT TIME ZONE 'UTC')::date::text; BEGIN
 result:=public.mcp_execute('list_workouts',jsonb_build_object('from',day,'to',day,'limit',1));
 IF jsonb_array_length(result->'items')<>1 OR jsonb_array_length(result->'items'->0->'components')<>2 OR result->'nextCursor'<>'null' THEN RAISE EXCEPTION 'Logical history pagination mismatch'; END IF;
 result:=public.mcp_execute('get_workouts','{"ids":["00000000-0000-0000-0000-000000000102","missing"]}');
 IF result->'items'->0->>'id'<>'00000000-0000-0000-0000-000000000101' OR result->'unavailable'->>0<>'missing' THEN RAISE EXCEPTION 'History ID resolution mismatch'; END IF;
 result:=public.mcp_execute('get_training_stats',jsonb_build_object('from',day,'to',day));
 IF jsonb_array_length(result->'items')<>1 THEN RAISE EXCEPTION 'History stats double count'; END IF;
 result:=public.mcp_execute('get_exercise_history',jsonb_build_object('from',day,'to',day,'references','[{"source":"standard","id":"missing"}]'::jsonb));
 IF result->'items'<>'[]' THEN RAISE EXCEPTION 'History reference filter failed'; END IF;
 result:=public.mcp_execute('list_food_entries',jsonb_build_object('from',(now() AT TIME ZONE 'Europe/Rome')::date::text,'to',(now() AT TIME ZONE 'Europe/Rome')::date::text));
 IF result->'items'<>'[]' THEN RAISE EXCEPTION 'Food range leaked old entries'; END IF;
END $$;
RESET ROLE;
UPDATE gymbro_mcp.billing SET environment='SANDBOX';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_account_limits'); RAISE EXCEPTION 'Sandbox mirror granted production access' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1002' THEN NULL; END;
END $$;
RESET ROLE;
UPDATE gymbro_mcp.billing SET environment='PRODUCTION',checked_at=now()-interval '6 minutes';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_account_limits'); RAISE EXCEPTION 'Stale billing accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1002' THEN NULL; END;
 -- Completed writes remain retryable after billing cache expiry.
 PERFORM public.mcp_execute('log_foods',current_setting('gymbro.test.food_request')::jsonb,'00000000-0000-0000-0000-000000000085');
END $$;
RESET ROLE;
UPDATE gymbro_mcp.billing SET checked_at=now(),is_pro=true,expires_at=NULL;
INSERT INTO public.custom_barcode_foods(id,user_id,json_data) VALUES('12345678','00000000-0000-0000-0000-000000000081','{"name":"Personal food","unit":"ml","servingSizes":[],"nutritionalValuesPer100g":{"calories":100,"fat":1,"saturatedFat":0,"carbs":10,"sugar":2,"protein":5}}');
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE result jsonb; saved jsonb; folder text; next_cursor text; BEGIN
 result:=public.mcp_execute('create_routine_folders','{"folders":[{"name":"A"},{"name":"B"}]}',gen_random_uuid());
 folder:=result->'items'->0->>'id';
 result:=public.mcp_execute('list_routine_folders','{"limit":1}'); next_cursor:=result->>'nextCursor';
 IF next_cursor IS NULL OR jsonb_array_length(result->'items')<>1 THEN RAISE EXCEPTION 'Folder cursor missing'; END IF;
 result:=public.mcp_execute('list_routine_folders',jsonb_build_object('limit',1,'cursor',next_cursor));
 IF result->'items'->0->>'name'<>'B' OR result->'nextCursor'<>'null' THEN RAISE EXCEPTION 'Folder cursor failed'; END IF;
 saved:=public.mcp_execute('create_routines',jsonb_build_object('routines',jsonb_build_array(jsonb_build_object('name','Cyclic day','folderId',folder,'exercises','[{"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"sets":[{"reps":10}],"progression":{"mode":"cyclicLinear","minReps":6,"maxReps":10,"repsPerStep":2,"startingWeight":20,"weightPerStep":2.5,"weightPerCycle":5,"cycle":1,"step":1}}]'::jsonb))),gen_random_uuid());
 result:=public.mcp_execute('get_routines',jsonb_build_object('ids',jsonb_build_array(saved->'items'->0->>'id','other-user-id')));
 IF result->'items'->0->>'folder_id'<>folder OR (result->'items'->0->'exercises'->0->>'progression')::jsonb->>'mode'<>'cyclicLinear' OR result->'unavailable'->>0<>'other-user-id' THEN RAISE EXCEPTION 'Bulk routine folder/progression mismatch'; END IF;
 result:=public.mcp_execute('search_foods','{"source":"customBarcode","query":"Personal","limit":1}');
 IF result->'items'->0->'reference'->>'id'<>'12345678' THEN RAISE EXCEPTION 'Personal food search failed'; END IF;
 result:=public.mcp_execute('get_foods','{"references":[{"source":"customBarcode","id":"12345678"},{"source":"favorite","id":"not-owned"}]}');
 IF result->'items'->0->'food'->>'unit'<>'ml' OR jsonb_array_length(result->'unavailable')<>1 THEN RAISE EXCEPTION 'Food reference resolution failed'; END IF;
 -- A Pro user can read beyond the Free window without changing or deleting data.
 result:=public.mcp_execute('get_food_entries',jsonb_build_object('ids',jsonb_build_array(current_setting('gymbro.test.food_id'))));
 IF jsonb_array_length(result->'items')<>1 THEN RAISE EXCEPTION 'Pro date access denied'; END IF;
 BEGIN PERFORM public.mcp_execute('list_routine_folders',jsonb_build_object('cursor',next_cursor||'invalid')); RAISE EXCEPTION 'Forged cursor accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
RESET ROLE;
-- Real Flutter records contain a JSON string inside the JSONB column.
-- Keep native JSON coverage above and exercise mixed-format reads/writes here.
UPDATE public.nutrition_categories SET json_data=to_jsonb(json_data::text);
UPDATE public.foods SET json_data=to_jsonb(json_data::text);
UPDATE public.custom_barcode_foods SET json_data=to_jsonb(json_data::text);
INSERT INTO public.favorite_foods(id,user_id) VALUES(current_setting('gymbro.test.food_id'),'00000000-0000-0000-0000-000000000081');
INSERT INTO public.custom_barcode_foods(id,user_id,json_data,deleted) VALUES
 ('other-local','00000000-0000-0000-0000-000000000082','{"name":"Personal foreign"}',false),
 ('deleted-local','00000000-0000-0000-0000-000000000081','{"name":"Personal deleted"}',true);
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE r jsonb; cursor_value text; day text:=(now() AT TIME ZONE 'Europe/Rome')::date::text; BEGIN
 r:=public.mcp_execute('get_nutrition_settings',jsonb_build_object('from',day,'to',day));
 IF r->'items'->0->'categories'->'Lunch'->>'dailyPercentage' IS DISTINCT FROM '40' THEN RAISE EXCEPTION 'Encoded categories not decoded'; END IF;
 r:=public.mcp_execute('search_foods','{"query":"food","limit":1}');
 cursor_value:=r->>'nextCursor';
 IF r->'items'->0->'reference'->>'source' IS DISTINCT FROM 'customBarcode' OR r->'items'->0->'food'->>'name' IS DISTINCT FROM 'Personal food' OR cursor_value IS NULL THEN RAISE EXCEPTION 'Combined local search failed'; END IF;
 r:=public.mcp_execute('search_foods',jsonb_build_object('query','food','limit',1,'cursor',cursor_value));
 IF r->'items'->0->'reference'->>'source' IS DISTINCT FROM 'favorite' OR r->>'nextCursor' IS NOT NULL THEN RAISE EXCEPTION 'Combined local cursor failed'; END IF;
 r:=public.mcp_execute('search_foods','{"query":"Personal","source":"customBarcode"}');
 IF jsonb_array_length(r->'items')<>1 THEN RAISE EXCEPTION 'Local search leaked foreign or deleted foods'; END IF;
 BEGIN PERFORM public.mcp_execute('search_foods','{"query":"food","source":"openfoodfacts"}'); RAISE EXCEPTION 'External search accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 r:=public.mcp_execute('get_foods',jsonb_build_object('references',jsonb_build_array(jsonb_build_object('source','favorite','id',current_setting('gymbro.test.food_id')),'{"source":"customBarcode","id":"12345678"}'::jsonb)));
 IF jsonb_typeof(r->'items'->0->'food') IS DISTINCT FROM 'object' OR r->'items'->1->'food'->>'unit' IS DISTINCT FROM 'ml' THEN RAISE EXCEPTION 'Encoded references not decoded'; END IF;
 r:=public.mcp_execute('get_food_entries',jsonb_build_object('ids',jsonb_build_array(current_setting('gymbro.test.food_id'))));
 IF jsonb_typeof(r->'items'->0->'food') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Encoded ID read not decoded'; END IF;
 r:=public.mcp_execute('list_food_entries',jsonb_build_object('from',((day::date)-10)::text,'to',day,'category','Lunch'));
 IF jsonb_array_length(r->'items')<>1 OR jsonb_typeof(r->'items'->0->'food') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Encoded category filter failed'; END IF;
 r:=public.mcp_execute('get_nutrition_summary',jsonb_build_object('from',((day::date)-10)::text,'to',day));
 IF jsonb_typeof(r->'entries'->0->'food') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Encoded summary not decoded'; END IF;
 r:=public.mcp_execute('log_foods',jsonb_build_object('entries',jsonb_build_array(jsonb_build_object('date',day,'amount',100,'pieces',1,'category','Lunch','foodRef',jsonb_build_object('source','favorite','id',current_setting('gymbro.test.food_id'))))),gen_random_uuid());
 IF jsonb_array_length(r->'items')<>1 THEN RAISE EXCEPTION 'Encoded reference log failed'; END IF;
END $$;
RESET ROLE;
ROLLBACK;
