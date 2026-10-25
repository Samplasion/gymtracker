\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000201','measure-a@unit.test','{"username":"measurea"}'),
 ('00000000-0000-0000-0000-000000000202','measure-b@unit.test','{"username":"measureb"}');
SELECT public.test_mcp_oauth(id) FROM auth.users;
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
-- No billing state: basic measurements must remain available.
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000201","role":"authenticated"}';
DO $$ BEGIN
 IF public.mcp_preferences()->>'timeZone'<>'UTC' THEN RAISE EXCEPTION 'Missing preferences not UTC'; END IF;
 IF public.mcp_preferences('invalid/zone')->>'timeZone'<>'UTC' OR public.mcp_preferences('')->>'timeZone'<>'UTC' THEN RAISE EXCEPTION 'Invalid zone not UTC'; END IF;
 PERFORM public.mcp_preferences('Europe/Rome');
END $$;
RESET ROLE;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000201","session_id":"00000000-0000-0000-0000-000000000201","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE r jsonb; again jsonb; req jsonb; cur text; i int; BEGIN
 req:='{"entries":[{"kind":"weight","value":154,"unit":"lb","time":"2026-10-24"},{"kind":"body","type":"waist","value":85,"time":"2026-10-24"},{"kind":"body","type":"bodyFat","value":15.5,"time":"2026-10-24T15:00:00+02:00"}]}';
 r:=public.mcp_execute('create_measurements',req,'00000000-0000-0000-0000-000000000203');
 again:=public.mcp_execute('create_measurements',req,'00000000-0000-0000-0000-000000000203');
 IF r<>again OR jsonb_array_length(r->'items')<>3 THEN RAISE EXCEPTION 'Measurement retry failed'; END IF;
 IF (r->'items'->0->>'time')::timestamptz<>'2026-10-23T22:00:00Z'::timestamptz OR r->'items'->0->>'unit'<>'lb' OR r->'items'->2->>'unit'<>'%' THEN RAISE EXCEPTION 'Measurement mapping failed'; END IF;
 PERFORM set_config('gymbro.test.measure_weight',r->'items'->0->'reference'->>'id',true);
 PERFORM set_config('gymbro.test.measure_body',r->'items'->1->'reference'->>'id',true);
 BEGIN PERFORM public.mcp_execute('create_measurements','{"entries":[{"kind":"weight","value":70}]}','00000000-0000-0000-0000-000000000203'); RAISE EXCEPTION 'Key conflict accepted' USING ERRCODE='XX000'; EXCEPTION WHEN unique_violation THEN NULL; END;
 FOR i IN 1..4 LOOP
  BEGIN
   PERFORM public.mcp_execute('create_measurements',jsonb_build_object('entries',jsonb_build_array('{"kind":"weight","value":60}'::jsonb,CASE i WHEN 1 THEN '{"kind":"body","type":"bodyFat","value":101}'::jsonb WHEN 2 THEN '{"kind":"body","type":"unknown","value":2}'::jsonb WHEN 3 THEN '{"kind":"weight","value":-1}'::jsonb ELSE '{"kind":"weight","value":60,"time":"2026-10-24T12:00:00"}'::jsonb END)),gen_random_uuid());
   RAISE EXCEPTION 'Invalid bulk accepted' USING ERRCODE='XX000';
  EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'entries[1]: Invalid measurement' THEN RAISE; END IF; END;
 END LOOP;
 r:=public.mcp_execute('list_measurements','{"from":"2026-10-24","to":"2026-10-24","limit":1}');cur:=r->>'nextCursor';
 IF r->'items'->0->>'type'<>'bodyFat' OR cur IS NULL THEN RAISE EXCEPTION 'Pagination start failed'; END IF;
 r:=public.mcp_execute('list_measurements',jsonb_build_object('from','2026-10-24','to','2026-10-24','limit',2,'cursor',cur));
 IF jsonb_array_length(r->'items')<>2 OR r->>'nextCursor' IS NOT NULL THEN RAISE EXCEPTION 'Pagination tie failed'; END IF;
 BEGIN PERFORM public.mcp_execute('list_measurements',jsonb_build_object('kind','body','cursor',cur)); RAISE EXCEPTION 'Cursor filter bypass' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 r:=public.mcp_execute('list_measurements','{"types":["waist"]}');
 IF jsonb_array_length(r->'items')<>1 THEN RAISE EXCEPTION 'Body filter failed'; END IF;
 r:=public.mcp_execute('get_measurements',jsonb_build_object('references',jsonb_build_array(jsonb_build_object('kind','weight','id',current_setting('gymbro.test.measure_weight')),'{"kind":"body","id":"missing"}'::jsonb)));
 IF jsonb_array_length(r->'items')<>1 OR jsonb_array_length(r->'unavailable')<>1 THEN RAISE EXCEPTION 'Bulk lookup failed'; END IF;
 -- Date-only writes use the actual IANA offset on the day, not today's offset.
 r:=public.mcp_execute('create_measurements','{"entries":[{"kind":"weight","value":71,"time":"2026-10-26"},{"kind":"weight","value":72,"time":"2026-03-30"}]}',gen_random_uuid());
 IF (r->'items'->0->>'time')::timestamptz<>'2026-10-25T23:00:00Z'::timestamptz OR (r->'items'->1->>'time')::timestamptz<>'2026-03-29T22:00:00Z'::timestamptz THEN RAISE EXCEPTION 'DST conversion failed'; END IF;
 r:=public.mcp_execute('create_measurements','{"entries":[{"kind":"weight","value":65,"time":"1980-10-24"}]}',gen_random_uuid());
 r:=public.mcp_execute('list_measurements','{"from":"1980-10-24","to":"1980-10-24"}');
 IF jsonb_array_length(r->'items')<>1 OR r->'items'->0->>'value'<>'65' THEN RAISE EXCEPTION 'Historical measurement dates restricted'; END IF;
 BEGIN PERFORM public.mcp_preferences('UTC'); RAISE EXCEPTION 'OAuth preference write accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.weight_measurements WHERE user_id='00000000-0000-0000-0000-000000000201')<>4 THEN RAISE EXCEPTION 'Partial bulk committed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.body_measurements WHERE revision>0 AND user_id='00000000-0000-0000-0000-000000000201') THEN RAISE EXCEPTION 'Sync trigger missing'; END IF;
END $$;
UPDATE public.body_measurements SET deleted=true WHERE id=current_setting('gymbro.test.measure_body');
SET LOCAL ROLE gymbro_mcp_user;
DO $$ DECLARE r jsonb; BEGIN
 r:=public.mcp_execute('get_measurements',jsonb_build_object('references',jsonb_build_array(jsonb_build_object('kind','body','id',current_setting('gymbro.test.measure_body')))));
 IF jsonb_array_length(r->'items')<>0 THEN RAISE EXCEPTION 'Tombstone leaked'; END IF;
END $$;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000202","session_id":"00000000-0000-0000-0000-000000000202","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE r jsonb; BEGIN
 r:=public.mcp_execute('get_measurements',jsonb_build_object('references',jsonb_build_array(jsonb_build_object('kind','weight','id',current_setting('gymbro.test.measure_weight')))));
 IF r->'items'<>'[]'::jsonb OR jsonb_array_length(r->'unavailable')<>1 THEN RAISE EXCEPTION 'Other user leaked'; END IF;
END $$;
RESET ROLE;
-- Revocation blocks every RPC entrypoint even while JWT claims remain unchanged.
UPDATE auth.oauth_consents SET revoked_at=now() WHERE user_id='00000000-0000-0000-0000-000000000202';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('list_measurements','{}'); RAISE EXCEPTION 'Revoked grant accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.mcp_list_routines(); RAISE EXCEPTION 'Legacy RPC revocation bypass' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
UPDATE auth.oauth_consents SET revoked_at=NULL WHERE user_id='00000000-0000-0000-0000-000000000202';
UPDATE auth.sessions SET not_after=now()-interval '1 minute' WHERE user_id='00000000-0000-0000-0000-000000000202';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('list_measurements','{}'); RAISE EXCEPTION 'Expired session accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
DELETE FROM auth.sessions WHERE user_id='00000000-0000-0000-0000-000000000202';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_execute('list_measurements','{}'); RAISE EXCEPTION 'Deleted session accepted' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
ROLLBACK;
