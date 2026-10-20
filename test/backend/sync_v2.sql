-- Run only against a disposable database after the three migrations.
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000001','a@unit.test','{"username":"alpha","full_name":"Alpha Trainer"}'),
 ('00000000-0000-0000-0000-000000000002','b@unit.test','{"username":"beta"}');
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
DO $$
DECLARE op jsonb; first_result jsonb; repeated jsonb; conflict jsonb; batch jsonb; page jsonb; h bigint; c bigint:=0; total integer:=0; i integer; j integer;
BEGIN
 op:=jsonb_build_object('operation_id','10000000000000000000000000000001','entity','nutrition_goals','record_id','day','base_revision',0,'payload',jsonb_build_object('id','day','user_id',auth.uid(),'reference_date','2026-10-20T00:00:00Z','updated_at','9999-01-01T00:00:00Z','deleted',false,'calories',1800,'fat',50,'carbs',200,'protein',100));
 first_result:=public.sync_push_v2(jsonb_build_array(op));
 repeated:=public.sync_push_v2(jsonb_build_array(op));
 IF first_result<>repeated OR first_result->0->>'status'<>'applied' THEN RAISE EXCEPTION 'Idempotence failed'; END IF;
 IF (first_result->0->'payload'->>'updated_at')::timestamptz>clock_timestamp() THEN RAISE EXCEPTION 'Client clock determined revision'; END IF;
 conflict:=public.sync_push_v2(jsonb_build_array(op||jsonb_build_object('operation_id','10000000000000000000000000000002')));
 IF conflict->0->>'status'<>'conflict' OR conflict->0->'payload'->>'calories'<>'1800' THEN RAISE EXCEPTION 'CAS conflict lost'; END IF;
 BEGIN
   PERFORM public.sync_push_v2(jsonb_build_array(jsonb_set(op,'{payload,calories}','2200')));
   RAISE EXCEPTION 'UUID reuse accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN raise_exception THEN NULL; END;
 FOR i IN 0..10 LOOP
   batch:='[]';
   FOR j IN 1..100 LOOP
     batch:=batch||jsonb_build_array(op||jsonb_build_object('operation_id',gen_random_uuid(),'record_id','row-'||(i*100+j),'payload',(op->'payload')||jsonb_build_object('id','row-'||(i*100+j))));
   END LOOP;
   PERFORM public.sync_push_v2(batch);
 END LOOP;
 page:=public.sync_pull_v2(0,NULL,500);h:=(page->>'horizon')::bigint;
 -- A concurrent later write must not move the already selected horizon.
 PERFORM public.sync_push_v2(jsonb_build_array(op||jsonb_build_object('operation_id',gen_random_uuid(),'record_id','later','payload',(op->'payload')||'{"id":"later"}'::jsonb)));
 LOOP
   total:=total+jsonb_array_length(page->'changes');c:=(page->>'cursor')::bigint;
   EXIT WHEN NOT (page->>'has_more')::boolean;
   page:=public.sync_pull_v2(c,h,500);
 END LOOP;
 IF total<>1101 OR c<>h THEN RAISE EXCEPTION 'Pagination skipped changes: % / %',total,c; END IF;
 page:=public.sync_pull_v2(c,NULL,500);
 IF jsonb_array_length(page->'changes')<>1 THEN RAISE EXCEPTION 'Later commit was lost'; END IF;
 batch:=jsonb_build_array(
   op||jsonb_build_object('operation_id',gen_random_uuid(),'record_id','valid-after-error','payload',(op->'payload')||'{"id":"valid-after-error"}'::jsonb),
   op||jsonb_build_object('operation_id',gen_random_uuid(),'record_id','invalid','payload',((op->'payload')-'calories')||'{"id":"invalid"}'::jsonb));
 repeated:=public.sync_push_v2(batch);
 IF repeated->0->>'status'<>'applied' OR repeated->1->>'status'<>'error' THEN RAISE EXCEPTION 'Record validation blocked the batch'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.search_users_weighted('Alpha Tra!')) THEN RAISE EXCEPTION 'Search failed'; END IF;
 IF EXISTS(SELECT 1 FROM public.search_users_weighted('!!!')) THEN RAISE EXCEPTION 'Empty token search failed'; END IF;
END; $$;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
DO $$ BEGIN
 IF jsonb_array_length(public.sync_pull_v2()->'changes')<>0 THEN RAISE EXCEPTION 'Cross-account download'; END IF;
 IF jsonb_array_length(public.get_public_profile_v2('00000000-0000-0000-0000-000000000001')->'workouts')<>0 THEN RAISE EXCEPTION 'Stranger data exposed'; END IF;
 BEGIN
   PERFORM public.sync_push_v2('[{"operation_id":"20000000000000000000000000000001","entity":"nutrition_goals","record_id":"bad","base_revision":0,"payload":{"id":"bad","user_id":"00000000-0000-0000-0000-000000000001"}}]');
   RAISE EXCEPTION 'Cross-account write accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
RESET ROLE;
SELECT public.activate_sync_v2();
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 BEGIN PERFORM 1 FROM public.nutrition_goals; RAISE EXCEPTION 'Legacy reads still allowed' USING ERRCODE='XX000'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 IF jsonb_array_length(public.get_friends_feed('2026-01-01','2027-01-01')->'workouts')<>0 THEN RAISE EXCEPTION 'Unexpected social results'; END IF;
 PERFORM public.sync_pull_v2();
END; $$;
ROLLBACK;
