\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000031','mcp-a@unit.test','{"username":"mcpalpha"}'),
 ('00000000-0000-0000-0000-000000000032','mcp-b@unit.test','{"username":"mcpbeta"}');
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group,secondary_muscle_groups,equipment) VALUES
 ('custom-a','00000000-0000-0000-0000-000000000031','Custom timer','time','abs','{}','none'),
 ('custom-b','00000000-0000-0000-0000-000000000032','Private exercise','freeBodyReps','chest','{}','none');
DO $$ DECLARE claims jsonb; BEGIN
 claims:=public.gymbro_mcp_access_token_hook('{"claims":{"role":"authenticated","aud":"authenticated","client_id":"00000000-0000-0000-0000-000000000090"}}')->'claims';
 IF claims->>'role'<>'gymbro_mcp_user' OR NOT (claims->'aud' ? 'https://gym-bro.test/mcp') THEN RAISE EXCEPTION 'OAuth claims missing'; END IF;
 IF public.gymbro_mcp_access_token_hook('{"claims":{"role":"authenticated","aud":"authenticated"}}')->'claims'<>'{"role":"authenticated","aud":"authenticated"}' THEN RAISE EXCEPTION 'Ordinary claims changed'; END IF;
 IF public.gymbro_mcp_access_token_hook('{"claims":{"role":"authenticated","client_id":"unknown"}}')->'claims'->>'role'<>'gymbro_mcp_user' THEN RAISE EXCEPTION 'Unknown client was not isolated'; END IF;
END $$;
INSERT INTO gymbro_mcp.billing SELECT id,true,NULL,now(),'PRODUCTION' FROM auth.users ON CONFLICT(user_id) DO NOTHING;
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.preferences SELECT id,'Europe/Rome' FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE gymbro_mcp_user;
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000031","session_id":"00000000-0000-0000-0000-000000000031","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["authenticated","https://gym-bro.test/mcp"]}',true);
DO $$ DECLARE request jsonb; first_result jsonb; repeated jsonb; routine jsonb; changed jsonb; definitions jsonb; BEGIN
 definitions:=public.mcp_custom_exercises();
 IF jsonb_array_length(definitions)<>1 OR definitions->0->>'id'<>'custom-a' THEN RAISE EXCEPTION 'Custom catalog isolation failed'; END IF;
 request:='{"name":"Three days","routines":[{"name":"Day one","exercises":[{"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"restSeconds":120,"sets":[{"reps":8}]}]},{"name":"Day two","exercises":[{"exerciseRef":{"source":"custom","id":"custom-a"},"sets":[{"timeSeconds":30.5}]}]}]}';
 first_result:=public.mcp_create_program(request,'00000000-0000-0000-0000-000000000041');
 repeated:=public.mcp_create_program(request,'00000000-0000-0000-0000-000000000041');
 IF first_result<>repeated OR jsonb_array_length(first_result->'routines')<>2 THEN RAISE EXCEPTION 'Idempotency failed'; END IF;
 PERFORM set_config('gymbro.test.result',first_result::text,true);
 routine:=public.mcp_get_routine(first_result->'routines'->0->>'id');
 IF routine->'exercises'->0->>'rest_time'<>'120' OR routine->'exercises'->0->'sets'->0->>'weight'<>'0' OR (routine->'exercises'->0->'sets'->0->>'done')::boolean THEN RAISE EXCEPTION 'Set mapping failed'; END IF;
 routine:=public.mcp_get_routine(first_result->'routines'->1->>'id');
 IF routine->'exercises'->0->'sets'->0->>'time'<>'30500000' THEN RAISE EXCEPTION 'Duration conversion failed'; END IF;
 IF jsonb_array_length(public.mcp_list_routines(0,1))<>2 OR jsonb_array_length(public.mcp_list_routines(1,1))<>1 THEN RAISE EXCEPTION 'Pagination failed'; END IF;
 BEGIN
  PERFORM public.mcp_create_program(jsonb_set(request,'{name}','"Changed"'),'00000000-0000-0000-0000-000000000041');
  RAISE EXCEPTION 'Reused key accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN unique_violation THEN NULL; END;
 -- The last invalid exercise must roll back already inserted folder/routine/sets.
 changed:=jsonb_set(request,'{routines,1,exercises,0,exerciseRef,id}','"custom-b"');
 BEGIN
  PERFORM public.mcp_create_program(changed,'00000000-0000-0000-0000-000000000042');
  RAISE EXCEPTION 'Cross-user reference accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN no_data_found THEN NULL; END;
 FOREACH changed IN ARRAY ARRAY[
  jsonb_set(request,'{routines,0,exercises,0,sets,0,timeSeconds}','30'),
  jsonb_set(request,'{routines,0,exercises,0,sets,0,reps}','-1'),
  jsonb_set(request,'{routines,0,exercises,0,sets,0,reps}','1.5'),
  jsonb_set(request,'{routines,0,exercises,0,sets,0,reps}','"8"'),
  jsonb_set(request,'{routines,0,exercises,0,sets,0,done}','true'),
  jsonb_set(request,'{routines,0,exercises,0,sets,0,parameters}','"time"'),
  jsonb_set(request,'{routines,0,exercises,0,restSeconds}','null'),
  jsonb_set(request,'{routines,0,exercises,0,exerciseRef,source}','"forged"')
 ] LOOP
  BEGIN
   PERFORM public.mcp_create_program(changed,gen_random_uuid());
   RAISE EXCEPTION 'Invalid payload accepted: %',changed USING ERRCODE='XX000';
  EXCEPTION WHEN invalid_parameter_value OR no_data_found THEN NULL; END;
 END LOOP;
 BEGIN PERFORM public.sync_pull_v2(); RAISE EXCEPTION 'Sync RPC exposed' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.get_public_profile_v2('00000000-0000-0000-0000-000000000032'); RAISE EXCEPTION 'Social RPC exposed' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM 1 FROM public.routines; RAISE EXCEPTION 'Direct table access' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.gymbro_mcp_access_token_hook('{}'); RAISE EXCEPTION 'Auth hook exposed' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000032","session_id":"00000000-0000-0000-0000-000000000032","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["authenticated","https://gym-bro.test/mcp"]}',true);
DO $$ BEGIN
 IF public.mcp_list_routines()<>'[]' THEN RAISE EXCEPTION 'Cross-user routines'; END IF;
 BEGIN PERFORM public.mcp_get_routine(current_setting('gymbro.test.result')::jsonb->'routines'->0->>'id'); RAISE EXCEPTION 'Cross-user routine' USING ERRCODE='XX000'; EXCEPTION WHEN no_data_found THEN NULL; END;
END $$;
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000031","session_id":"00000000-0000-0000-0000-000000000031","role":"gymbro_mcp_user","client_id":"unknown","aud":["https://gym-bro.test/mcp"]}',true);
DO $$ BEGIN
 BEGIN PERFORM public.mcp_list_routines(); RAISE EXCEPTION 'Unknown client' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF (SELECT count(*) FROM gymbro_mcp.receipts)<>1 OR (SELECT count(*) FROM public.routine_folders WHERE user_id='00000000-0000-0000-0000-000000000031')<>1 OR (SELECT count(*) FROM public.routines WHERE user_id='00000000-0000-0000-0000-000000000031')<>2 THEN RAISE EXCEPTION 'Partial program committed'; END IF;
 IF EXISTS(SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND p.proname NOT LIKE 'mcp_%' AND has_function_privilege('gymbro_mcp_user',p.oid,'EXECUTE')) THEN RAISE EXCEPTION 'Unexpected public RPC grants'; END IF;
 IF EXISTS(SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN ('public','storage') AND c.relkind IN ('r','v','m') AND (has_table_privilege('gymbro_mcp_user',c.oid,'SELECT') OR has_table_privilege('gymbro_mcp_user',c.oid,'INSERT') OR has_table_privilege('gymbro_mcp_user',c.oid,'UPDATE') OR has_table_privilege('gymbro_mcp_user',c.oid,'DELETE'))) THEN RAISE EXCEPTION 'Unexpected table grants'; END IF;
END $$;
SELECT public.activate_sync_v2();
INSERT INTO gymbro_mcp.billing SELECT id,true,NULL,now(),'PRODUCTION' FROM auth.users ON CONFLICT(user_id) DO NOTHING;
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.preferences SELECT id,'Europe/Rome' FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE gymbro_mcp_user;
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000031","session_id":"00000000-0000-0000-0000-000000000031","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["authenticated","https://gym-bro.test/mcp"]}',true);
DO $$ DECLARE p jsonb; BEGIN
 p:='{"name":"After activation","routines":[{"name":"After gate","exercises":[{"exerciseRef":{"source":"custom","id":"custom-a"},"sets":[{"timeSeconds":15}]}]}]}';
 PERFORM public.mcp_create_program(p,'00000000-0000-0000-0000-000000000043');
 IF jsonb_array_length(public.mcp_list_routines())<>3 THEN RAISE EXCEPTION 'MCP failed after sync gate'; END IF;
END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-0000-0000-000000000031","session_id":"00000000-0000-0000-0000-000000000031","role":"authenticated"}',true);
DO $$ DECLARE page jsonb; cursor bigint:=0; horizon bigint; total integer:=0; BEGIN
 page:=public.sync_pull_v2(0,NULL,2); horizon:=(page->>'horizon')::bigint;
 LOOP
  total:=total+jsonb_array_length(page->'changes'); cursor:=(page->>'cursor')::bigint;
  EXIT WHEN NOT (page->>'has_more')::boolean;
  page:=public.sync_pull_v2(cursor,horizon,2);
 END LOOP;
 IF total<>9 THEN RAISE EXCEPTION 'MCP changes not in sync stream: %',total; END IF;
 BEGIN PERFORM public.mcp_list_routines(); RAISE EXCEPTION 'Regular token accepted by MCP' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
ROLLBACK;

-- All parameter kinds, tombstones and retries after a reference is deleted.
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES('00000000-0000-0000-0000-000000000061','mcp-types@unit.test','{"username":"mcptypes"}');
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group,secondary_muscle_groups,equipment) VALUES('custom-later-deleted','00000000-0000-0000-0000-000000000061','Timer','time','abs','{}','none');
INSERT INTO gymbro_mcp.billing SELECT id,true,NULL,now(),'PRODUCTION' FROM auth.users ON CONFLICT(user_id) DO NOTHING;
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.preferences SELECT id,'Europe/Rome' FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000061","session_id":"00000000-0000-0000-0000-000000000061","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE request jsonb; saved jsonb; routine jsonb; BEGIN
 request:='{"name":"All parameters","routines":[{"name":"All types","weightUnit":"lb","distanceUnit":"mi","exercises":[{"exerciseRef":{"source":"standard","id":"library.forearms.exercises.farmerWalk"},"sets":[{"timeSeconds":30,"weight":15}]},{"exerciseRef":{"source":"standard","id":"library.cardio.exercises.biking"},"sets":[{"distance":2.5}]},{"exerciseRef":{"source":"standard","id":"library.abs.exercises.bicycleCrunches"},"sets":[{"reps":12}]},{"exerciseRef":{"source":"standard","id":"library.other.exercises.stretching"},"sets":[]},{"exerciseRef":{"source":"custom","id":"custom-later-deleted"},"sets":[{"timeSeconds":30}]}]}]}';
 saved:=public.mcp_create_program(request,'00000000-0000-0000-0000-000000000062');
 PERFORM set_config('gymbro.test.request',request::text,true);
 PERFORM set_config('gymbro.test.result',saved::text,true);
 routine:=public.mcp_get_routine(saved->'routines'->0->>'id');
 IF routine->>'weight_unit'<>'lb' OR routine->>'distance_unit'<>'mi'
 OR routine->'exercises'->0->'sets'->0->>'weight'<>'15' OR routine->'exercises'->0->'sets'->0->>'time'<>'30000000'
 OR routine->'exercises'->1->'sets'->0->>'distance'<>'2.5' OR routine->'exercises'->2->'sets'->0->>'reps'<>'12'
 OR routine->'exercises'->3->'sets'<>'[]' THEN RAISE EXCEPTION 'Parameter/unit mapping failed'; END IF;
 BEGIN PERFORM public.mcp_list_routines(NULL,20); RAISE EXCEPTION 'NULL pagination accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
RESET ROLE;
UPDATE public.custom_exercises SET deleted=true,updated_at=clock_timestamp() WHERE id='custom-later-deleted';
INSERT INTO gymbro_mcp.billing SELECT id,true,NULL,now(),'PRODUCTION' FROM auth.users ON CONFLICT(user_id) DO NOTHING;
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.preferences SELECT id,'Europe/Rome' FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 IF public.mcp_custom_exercises()<>'[]' THEN RAISE EXCEPTION 'Deleted exercise exposed'; END IF;
 IF public.mcp_create_program(current_setting('gymbro.test.request')::jsonb,'00000000-0000-0000-0000-000000000062')<>current_setting('gymbro.test.result')::jsonb THEN RAISE EXCEPTION 'Retry after reference deletion failed'; END IF;
 BEGIN
  PERFORM public.mcp_create_program(current_setting('gymbro.test.request')::jsonb,'00000000-0000-0000-0000-000000000063');
  RAISE EXCEPTION 'Deleted exercise accepted for new program' USING ERRCODE='XX000';
 EXCEPTION WHEN no_data_found THEN NULL; END;
END $$;
ROLLBACK;
