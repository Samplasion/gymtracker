\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000021','social-a@test.local','{"username":"social_a"}'),
 ('00000000-0000-0000-0000-000000000022','social-b@test.local','{"username":"social_b"}'),
 ('00000000-0000-0000-0000-000000000023','social-c@test.local','{"username":"social_c"}');
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES
 ('00000000-0000-0000-0000-000000000021','00000000-0000-0000-0000-000000000022','accepted'),
 ('00000000-0000-0000-0000-000000000023','00000000-0000-0000-0000-000000000022','accepted');
INSERT INTO public.achievements_v2(id,user_id,achievement_id,level,completed_at) VALUES('social_1','00000000-0000-0000-0000-000000000022','social',1,now());
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000023',true);
INSERT INTO public.comments(post_id,body) SELECT id,'Hello Bob' FROM public.public_posts WHERE source_id='social_1';
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000021',true);
DO $$ DECLARE p uuid; BEGIN
 SELECT id INTO p FROM public.public_posts WHERE source_id='social_1';
 IF (public.get_post_social(p)->>'comments')::int<>1 THEN RAISE EXCEPTION 'Third-party comment hidden'; END IF;
 INSERT INTO public.likes(post_id) VALUES(p);
 BEGIN INSERT INTO public.likes(post_id) VALUES(p); RAISE EXCEPTION 'Duplicate like accepted'; EXCEPTION WHEN unique_violation THEN NULL; END;
 PERFORM public.submit_report('00000000-0000-0000-0000-000000000023','Test report');
 PERFORM public.set_user_block('00000000-0000-0000-0000-000000000023',true);
 IF (public.get_post_social(p)->>'comments')::int<>0 THEN RAISE EXCEPTION 'Blocked comment visible'; END IF;
 IF EXISTS(SELECT 1 FROM public.profiles WHERE id='00000000-0000-0000-0000-000000000023') THEN RAISE EXCEPTION 'Blocked profile visible'; END IF;
 PERFORM public.set_user_block('00000000-0000-0000-0000-000000000022',true);
 IF public.can_read_post(p) THEN RAISE EXCEPTION 'Blocked post visible'; END IF;
 IF EXISTS(SELECT 1 FROM public.friends WHERE sender_id=auth.uid() OR receiver_id=auth.uid()) THEN RAISE EXCEPTION 'Friendship survived block'; END IF;
 PERFORM public.set_user_block('00000000-0000-0000-0000-000000000022',false);
 IF public.can_read_post(p) THEN RAISE EXCEPTION 'Unblock restored friendship'; END IF;
END; $$;
RESET ROLE;
ROLLBACK;

BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000031','compat-a@test.local','{"username":"compat_a"}'),
 ('00000000-0000-0000-0000-000000000032','compat-b@test.local','{"username":"compat_b"}');
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES('00000000-0000-0000-0000-000000000031','00000000-0000-0000-0000-000000000032','accepted');
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000031',true);
DO $$
DECLARE payload jsonb; op jsonb; result jsonb; revision bigint; pid uuid; nid bigint; lease uuid; claimed jsonb;
BEGIN
 payload:=jsonb_build_object('id','compat-workout','user_id',auth.uid(),'name','Legacy','duration',1800,'starting_date',now(),'weight_unit','kg','distance_unit','km','deleted',false);
 op:=jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workouts','record_id','compat-workout','base_revision',0,'payload',payload);
 result:=public.sync_push_v2(jsonb_build_array(op))->0;
 IF result->>'status'<>'applied' OR (result->'payload')->>'visibility'<>'friends' THEN RAISE EXCEPTION 'Legacy insert failed: %',result; END IF;
 SELECT id INTO pid FROM public.public_posts WHERE source_id='compat-workout';
 IF pid IS NULL THEN RAISE EXCEPTION 'Legacy post missing'; END IF;
 IF public.sync_push_v2(jsonb_build_array(op))->0<>result THEN RAISE EXCEPTION 'Receipt replay changed'; END IF;
 revision:=(result->>'revision')::bigint;
 payload:=(result->'payload')-'revision';
 payload:=payload||jsonb_build_object('visibility','private');
 result:=public.sync_push_v2(jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workouts','record_id','compat-workout','base_revision',revision,'payload',payload)))->0;
 IF result->>'status'<>'applied' THEN RAISE EXCEPTION 'Private edit failed: %',result; END IF;
 IF (SELECT active FROM public.public_posts WHERE id=pid) THEN RAISE EXCEPTION 'Private post remained active'; END IF;
 -- A client that omits the field must preserve private visibility.
 revision:=(result->>'revision')::bigint;
 payload:=((result->'payload')-'revision'-'visibility'-'publication_manifest')||'{"name":"Legacy edit"}'::jsonb;
 result:=public.sync_push_v2(jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workouts','record_id','compat-workout','base_revision',revision,'payload',payload)))->0;
 IF (result->'payload')->>'visibility'<>'private' THEN RAISE EXCEPTION 'Legacy edit republished private workout'; END IF;
 revision:=(result->>'revision')::bigint;
 payload:=((result->'payload')-'revision')||'{"visibility":null}'::jsonb;
 result:=public.sync_push_v2(jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workouts','record_id','compat-workout','base_revision',revision,'payload',payload)))->0;
 IF (result->'payload')->>'visibility'<>'private' THEN RAISE EXCEPTION 'NULL visibility was not preserved'; END IF;
 -- Publish a new revision in separate batches: header alone is insufficient.
 revision:=(result->>'revision')::bigint;
 payload:=((result->'payload')-'revision')||jsonb_build_object('visibility','friends','publication_manifest','{"version":"revision-1","ids":["exercise-1"]}');
 result:=public.sync_push_v2(jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workouts','record_id','compat-workout','base_revision',revision,'payload',payload)))->0;
 IF result->>'status'<>'applied' OR (SELECT active FROM public.public_posts WHERE id=pid) THEN RAISE EXCEPTION 'Partial post published: %',result; END IF;
 payload:=jsonb_build_object('id','exercise-1','user_id',auth.uid(),'routine_id','compat-workout','name','Exercise','deleted',false,'is_custom',false,'is_superset',false,'is_in_superset',false,'sort_order',0,'equipment','none','publication_version','revision-1');
 result:=public.sync_push_v2(jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','history_workout_exercises','record_id','exercise-1','base_revision',0,'payload',payload)))->0;
 IF result->>'status'<>'applied' OR NOT (SELECT active FROM public.public_posts WHERE id=pid) THEN RAISE EXCEPTION 'Complete post not published: %',result; END IF;
 IF (SELECT count(*) FROM public.public_posts WHERE source_id='compat-workout')<>1 THEN RAISE EXCEPTION 'Post ID changed'; END IF;
 PERFORM public.register_push_device('00000000-0000-0000-0000-000000000039','test-token-long-enough','android','it');
 BEGIN PERFORM public.claim_push_deliveries(); RAISE EXCEPTION 'Client claimed push jobs'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
RESET ROLE;
-- Exercise notification watermark and durable per-device delivery leases.
INSERT INTO public.notifications(user_id,kind,actor_id,event_key) VALUES('00000000-0000-0000-0000-000000000031','friend_accepted','00000000-0000-0000-0000-000000000032','watermark-first');
SET LOCAL ROLE authenticated;
DO $$ DECLARE watermark bigint; BEGIN
 watermark:=(public.notification_summary()->>'through_id')::bigint;
 PERFORM public.read_notifications(watermark);
 IF (public.notification_summary()->>'unread')::int<>0 THEN RAISE EXCEPTION 'Read watermark failed'; END IF;
END; $$;
RESET ROLE;
SELECT public.enqueue_notification('00000000-0000-0000-0000-000000000031','friend_accepted','00000000-0000-0000-0000-000000000032',NULL,NULL,NULL,'{}','watermark-second');
DO $$ DECLARE jobs jsonb; job jsonb; BEGIN
 jobs:=public.claim_push_deliveries();
 IF jsonb_array_length(jobs)<>1 THEN RAISE EXCEPTION 'Push fanout missing: %',jobs; END IF;
 job:=jobs->0;
 IF NOT public.authorize_push_delivery((job->>'id')::bigint,(job->>'lease_id')::uuid) THEN RAISE EXCEPTION 'Valid delivery rejected'; END IF;
 IF jsonb_array_length(public.claim_push_deliveries())<>0 THEN RAISE EXCEPTION 'Leased delivery claimed twice'; END IF;
 PERFORM public.set_user_block('00000000-0000-0000-0000-000000000032',true);
 IF public.authorize_push_delivery((job->>'id')::bigint,(job->>'lease_id')::uuid) THEN RAISE EXCEPTION 'Blocked delivery remained authorized'; END IF;
END; $$;
DELETE FROM auth.users WHERE id='00000000-0000-0000-0000-000000000031';
ROLLBACK;
