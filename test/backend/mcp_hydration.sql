\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000301','mcp-water-a@unit.test','{"username":"mcpwatera"}'),
 ('00000000-0000-0000-0000-000000000302','mcp-water-b@unit.test','{"username":"mcpwaterb"}');
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000301',false,NULL,now(),'PRODUCTION');
INSERT INTO gymbro_mcp.preferences VALUES('00000000-0000-0000-0000-000000000301','Europe/Rome');
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000301","session_id":"00000000-0000-0000-0000-000000000301","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE r jsonb; again jsonb; bad jsonb; today date:=(now() AT TIME ZONE 'Europe/Rome')::date; i int; BEGIN
 r:=public.mcp_execute('log_water','{"entries":[{"milliliters":500.25}]}','00000000-0000-0000-0000-000000000303');
 again:=public.mcp_execute('log_water','{"entries":[{"milliliters":500.25}]}','00000000-0000-0000-0000-000000000303');
 IF r<>again OR r->'items'->0->>'milliliters'<>'500.25' OR (r->'items'->0->>'date')::date<>today THEN RAISE EXCEPTION 'Water retry/mapping failed'; END IF;
 PERFORM set_config('gymbro.test.water_id',r->'items'->0->>'id',true);
 BEGIN PERFORM public.mcp_execute('log_water','{"entries":[{"milliliters":250}]}','00000000-0000-0000-0000-000000000303'); RAISE EXCEPTION 'Water key conflict accepted' USING ERRCODE='XX000'; EXCEPTION WHEN unique_violation THEN NULL; END;
 FOR i IN 1..7 LOOP
  bad:=CASE i WHEN 1 THEN '{"milliliters":0}'::jsonb WHEN 2 THEN '{"milliliters":-1}'::jsonb WHEN 3 THEN jsonb_build_object('milliliters',100,'time',now()+interval '1 hour') WHEN 4 THEN '{"milliliters":100,"user_id":"forged"}'::jsonb WHEN 6 THEN '{"milliliters":100,"time":"1999-12-31T12:00:00Z"}'::jsonb WHEN 7 THEN '{"milliliters":1e309}'::jsonb ELSE '{"milliliters":100,"time":null}'::jsonb END;
  BEGIN
   PERFORM public.mcp_execute('log_water',jsonb_build_object('entries',jsonb_build_array('{"milliliters":200}'::jsonb,bad)),gen_random_uuid());
   RAISE EXCEPTION 'Invalid water bulk accepted' USING ERRCODE='XX000';
  EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'entries[1]: Invalid water entry' THEN RAISE; END IF; END;
 END LOOP;
 BEGIN PERFORM public.mcp_execute('log_water',jsonb_build_object('entries',jsonb_build_array('{"milliliters":200}'::jsonb,jsonb_build_object('milliliters',100,'time',(today-8)::text))),gen_random_uuid()); RAISE EXCEPTION 'Mixed Free water dates accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 r:=public.mcp_execute('get_water_entries',jsonb_build_object('ids',jsonb_build_array(current_setting('gymbro.test.water_id'),'missing')));
 IF jsonb_array_length(r->'items')<>1 OR r->'unavailable'->>0<>'missing' THEN RAISE EXCEPTION 'Water ID lookup failed'; END IF;
 r:=public.mcp_execute('get_hydration_summary',jsonb_build_object('from',today-1,'to',today));
 IF jsonb_array_length(r->'settings')<>2 OR r->'settings'->0->'goal'->'dailyWater'<>'null'::jsonb OR jsonb_array_length(r->'waterEntries')<>1 THEN RAISE EXCEPTION 'Empty day/default goal summary failed'; END IF;
 IF r IS DISTINCT FROM public.mcp_execute('get_nutrition_summary',jsonb_build_object('from',today-1,'to',today)) THEN RAISE EXCEPTION 'Nutrition/hydration raw data diverged'; END IF;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.water_logs WHERE user_id='00000000-0000-0000-0000-000000000301')<>1 THEN RAISE EXCEPTION 'Partial water bulk committed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.water_logs WHERE id=current_setting('gymbro.test.water_id') AND revision>0 AND date_added=(json_data::jsonb->>'time')::timestamptz AND reference_date=((date_added AT TIME ZONE 'Europe/Rome')::date)::timestamp AT TIME ZONE 'UTC') THEN RAISE EXCEPTION 'Water sync/storage mismatch'; END IF;
END $$;
-- Native/imported records may contain stale date metadata. Actual time must govern access.
INSERT INTO public.water_logs(user_id,id,date_added,reference_date,json_data)
 SELECT '00000000-0000-0000-0000-000000000301','window_'||i,now(),date_trunc('day',now()),jsonb_build_object('milliliters',10,'time',(((now() AT TIME ZONE 'Europe/Rome')::date+i)::timestamp AT TIME ZONE 'Europe/Rome'))::text FROM unnest(ARRAY[-8,-7,7]) i;
INSERT INTO public.water_logs(user_id,id,date_added,reference_date,json_data)
 VALUES('00000000-0000-0000-0000-000000000302','foreign',now(),date_trunc('day',now()),jsonb_build_object('milliliters',10,'time',now())::text);
INSERT INTO public.water_logs(user_id,id,date_added,reference_date,json_data,deleted)
 VALUES('00000000-0000-0000-0000-000000000301','tombstone',now(),date_trunc('day',now()),jsonb_build_object('milliliters',10,'time',now())::text,true);
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE r jsonb; today date:=(now() AT TIME ZONE 'Europe/Rome')::date; i int; BEGIN
 r:=public.mcp_execute('get_water_entries','{"ids":["foreign","tombstone","missing"]}');
 IF r->'items'<>'[]'::jsonb OR jsonb_array_length(r->'unavailable')<>3 THEN RAISE EXCEPTION 'Water isolation/tombstone failed'; END IF;
 FOR i IN -7..7 BY 14 LOOP
  r:=public.mcp_execute('list_water_entries',jsonb_build_object('from',today+i,'to',today+i));
  IF jsonb_array_length(r->'items')<>1 THEN RAISE EXCEPTION 'Inclusive Free endpoint failed'; END IF;
 END LOOP;
 BEGIN PERFORM public.mcp_execute('get_water_entries','{"ids":["window_-8"]}'); RAISE EXCEPTION 'ID window bypass accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('list_water_entries',jsonb_build_object('from',today-8,'to',today)); RAISE EXCEPTION 'Mixed read interval accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('get_hydration_summary',jsonb_build_object('from',today-8,'to',today)); RAISE EXCEPTION 'Summary window bypass accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
END $$;
RESET ROLE;
UPDATE gymbro_mcp.billing SET checked_at=now()-interval '6 minutes';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_water_entries',jsonb_build_object('ids',jsonb_build_array(current_setting('gymbro.test.water_id')))); RAISE EXCEPTION 'Stale billing accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1002' THEN NULL; END;
 BEGIN PERFORM public.mcp_execute('log_water','{"entries":[{"milliliters":10}]}',gen_random_uuid()); RAISE EXCEPTION 'Stale billing write accepted' USING ERRCODE='XX000'; EXCEPTION WHEN SQLSTATE 'P1002' THEN NULL; END;
 PERFORM public.mcp_execute('log_water','{"entries":[{"milliliters":500.25}]}','00000000-0000-0000-0000-000000000303');
END $$;
RESET ROLE;
UPDATE gymbro_mcp.billing SET checked_at=now(),is_pro=true;
INSERT INTO public.nutrition_goals(id,user_id,reference_date,calories,fat,carbs,protein,water) VALUES
 ('water-goal-old','00000000-0000-0000-0000-000000000301',((now() AT TIME ZONE 'Europe/Rome')::date-4)::timestamp AT TIME ZONE 'UTC',2000,60,250,100,2000),
 ('water-goal-none','00000000-0000-0000-0000-000000000301',((now() AT TIME ZONE 'Europe/Rome')::date)::timestamp AT TIME ZONE 'UTC',2000,60,250,100,NULL);
INSERT INTO public.foods(id,user_id,date_added,reference_date,json_data) VALUES
 ('water-food-known','00000000-0000-0000-0000-000000000301',now(),((now() AT TIME ZONE 'Europe/Rome')::date)::timestamp AT TIME ZONE 'UTC',to_jsonb('{"name":"Hydration fixture","amount":10,"pieces":3,"unit":"g","nutritionalValuesPer100g":{"calories":0,"fat":0,"saturatedFat":0,"carbs":0,"sugar":0,"protein":0,"water":90}}'::text)),
 ('water-food-unknown','00000000-0000-0000-0000-000000000301',now(),((now() AT TIME ZONE 'Europe/Rome')::date)::timestamp AT TIME ZONE 'UTC','{"name":"Unknown water","amount":100,"pieces":1,"unit":"g","nutritionalValuesPer100g":{"calories":0,"fat":0,"saturatedFat":0,"carbs":0,"sugar":0,"protein":0}}');
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE r jsonb; page jsonb; cur text; today date:=(now() AT TIME ZONE 'Europe/Rome')::date; BEGIN
 r:=public.mcp_execute('get_hydration_summary',jsonb_build_object('from',today-5,'to',today));
 IF r->'settings'->0->'goal'->>'dailyWater'<>'2000' OR r->'settings'->5->'goal'->'dailyWater'<>'null'::jsonb OR jsonb_array_length(r->'entries')<>2 THEN RAISE EXCEPTION 'Goal DateSequence/food snapshot failed'; END IF;
 r:=public.mcp_execute('log_water','{"entries":[{"milliliters":100,"time":"2025-10-26T02:30:00+02:00"},{"milliliters":200,"time":"2025-10-26T02:30:00+01:00"},{"milliliters":50,"time":"2025-10-26"},{"milliliters":25,"time":"2025-03-31"}]}',gen_random_uuid());
 IF (r->'items'->2->>'time')::timestamptz<>'2025-10-25T22:00:00Z'::timestamptz OR (r->'items'->3->>'time')::timestamptz<>'2025-03-30T22:00:00Z'::timestamptz THEN RAISE EXCEPTION 'DST date-only write failed'; END IF;
 page:=public.mcp_execute('list_water_entries','{"from":"2025-10-26","to":"2025-10-26","limit":1}'); cur:=page->>'nextCursor';
 IF page->'items'->0->>'milliliters'<>'200' OR cur IS NULL THEN RAISE EXCEPTION 'DST order/cursor start failed'; END IF;
 page:=public.mcp_execute('list_water_entries',jsonb_build_object('from','2025-10-26','to','2025-10-26','limit',2,'cursor',cur));
 IF jsonb_array_length(page->'items')<>2 OR page->>'nextCursor' IS NOT NULL THEN RAISE EXCEPTION 'Water pagination failed'; END IF;
 BEGIN PERFORM public.mcp_execute('list_water_entries',jsonb_build_object('from','2025-10-25','to','2025-10-26','cursor',cur)); RAISE EXCEPTION 'Cursor filter changed' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 r:=public.mcp_execute('get_water_entries','{"ids":["window_-8"]}');
 IF jsonb_array_length(r->'items')<>1 THEN RAISE EXCEPTION 'Pro historical ID denied'; END IF;
 r:=public.mcp_execute('log_water','{"entries":[{"milliliters":10,"time":"2025-10-27T12:00:00Z"},{"milliliters":20,"time":"2025-10-27T12:00:00Z"}]}',gen_random_uuid());
 page:=public.mcp_execute('list_water_entries','{"from":"2025-10-27","to":"2025-10-27","limit":1}');
 r:=public.mcp_execute('list_water_entries',jsonb_build_object('from','2025-10-27','to','2025-10-27','limit',1,'cursor',page->>'nextCursor'));
 IF page->'items'->0->>'id'=r->'items'->0->>'id' OR r->>'nextCursor' IS NOT NULL THEN RAISE EXCEPTION 'Equal-time cursor lost an entry'; END IF;
 -- Pro removes the commercial date restriction, never the actual-future guard.
 BEGIN PERFORM public.mcp_execute('log_water',jsonb_build_object('entries',jsonb_build_array(jsonb_build_object('milliliters',100,'time',now()+interval '1 hour'))),gen_random_uuid()); RAISE EXCEPTION 'Pro future write accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
RESET ROLE;
-- Verify pull-v2 contains the text JSON payload consumable by Flutter.
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000301","role":"authenticated"}';
DO $$ DECLARE pull jsonb; BEGIN
 pull:=public.sync_pull_v2();
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(pull->'changes') c WHERE c->>'entity'='water_logs' AND c->>'record_id'=current_setting('gymbro.test.water_id')) THEN RAISE EXCEPTION 'MCP water missing in pull v2'; END IF;
END $$;
RESET ROLE;
-- Never silently truncate summary inputs, including histories created in-app.
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000302',true,NULL,now(),'PRODUCTION');
INSERT INTO public.water_logs(user_id,id,date_added,reference_date,json_data)
 SELECT '00000000-0000-0000-0000-000000000302','large-'||n,'2025-01-01T12:00:00Z','2025-01-01T00:00:00Z','{"milliliters":1,"time":"2025-01-01T12:00:00Z"}' FROM generate_series(1,10001) n;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000302","session_id":"00000000-0000-0000-0000-000000000302","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('get_hydration_summary','{"from":"2025-01-01","to":"2025-01-01"}'); RAISE EXCEPTION 'Summary silently truncated' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
RESET ROLE;
ROLLBACK;
