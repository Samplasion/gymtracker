BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES ('11111111-1111-4111-8111-111111111111','trainer@test.invalid'),('22222222-2222-4222-8222-222222222222','client@test.invalid'),('33333333-3333-4333-8333-333333333333','other@test.invalid');
SELECT public.trainer_execute('11111111-1111-4111-8111-111111111111','activate','{"display_name":"Coach"}');
DO $$ DECLARE invite jsonb; link jsonb; result jsonb; BEGIN
 invite:=public.trainer_execute('11111111-1111-4111-8111-111111111111','invite_create');
 BEGIN PERFORM public.trainer_execute('11111111-1111-4111-8111-111111111111','invite_accept',jsonb_build_object('token',invite->>'token')); RAISE EXCEPTION 'self-link allowed'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 link:=public.trainer_execute('22222222-2222-4222-8222-222222222222','invite_accept',jsonb_build_object('token',invite->>'token'));
 result:=public.trainer_execute('22222222-2222-4222-8222-222222222222','invite_accept',jsonb_build_object('token',invite->>'token'));
 IF link->>'id'<>result->>'id' THEN RAISE EXCEPTION 'non-idempotent acceptance'; END IF;
 BEGIN PERFORM public.trainer_execute('33333333-3333-4333-8333-333333333333','client',jsonb_build_object('link_id',link->>'id')); RAISE EXCEPTION 'other account access'; EXCEPTION WHEN no_data_found THEN NULL; END;
 PERFORM public.trainer_execute('11111111-1111-4111-8111-111111111111','disconnect',jsonb_build_object('link_id',link->>'id'));
 result:=public.trainer_execute('22222222-2222-4222-8222-222222222222','session');
 IF result->'profile'<>'null'::jsonb THEN RAISE EXCEPTION 'ordinary user treated as trainer'; END IF;
 IF result->'link'<>'null'::jsonb OR result->'controls'<>'[]'::jsonb THEN RAISE EXCEPTION 'stale link'; END IF;
END $$;
ROLLBACK;

BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES ('11111111-1111-4111-8111-111111111111','trainer@test.invalid'),('22222222-2222-4222-8222-222222222222','client@test.invalid'),('33333333-3333-4333-8333-333333333333','stranger@test.invalid');
SELECT public.trainer_execute('11111111-1111-4111-8111-111111111111','activate','{"display_name":"Coach"}');
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
SELECT public.mcp_store_billing('22222222-2222-4222-8222-222222222222',false,NULL,'PRODUCTION',clock_timestamp());
DO $$ DECLARE invitation jsonb; relationship jsonb; doc jsonb; response jsonb; published jsonb; plan_id uuid:=gen_random_uuid(); rid text:=gen_random_uuid()::text; cid text:=gen_random_uuid()::text; eid text:=gen_random_uuid()::text; n int; BEGIN
 invitation:=public.trainer_execute('11111111-1111-4111-8111-111111111111','invite_create');
 relationship:=public.trainer_execute('22222222-2222-4222-8222-222222222222','invite_accept',jsonb_build_object('token',invitation->>'token'));
 PERFORM set_config('gymtracker.sync_v2','on',true);
 FOR n IN 1..3 LOOP INSERT INTO public.routines(id,user_id,name,weight_unit,distance_unit,sort_order) VALUES(gen_random_uuid()::text,'22222222-2222-4222-8222-222222222222','Personal','kg','km',n); END LOOP;
 FOR n IN 1..9 LOOP INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group) VALUES(gen_random_uuid()::text,'22222222-2222-4222-8222-222222222222','Personal','repsWeight','chest'); END LOOP;
 doc:=jsonb_build_object('folders','[]'::jsonb,'custom_exercises',jsonb_build_array(jsonb_build_object('id',cid,'name','Custom 1','parameters','repsWeight','primary_muscle_group','chest'),jsonb_build_object('id',gen_random_uuid(),'name','Custom 2','parameters','repsWeight','primary_muscle_group','chest')),'routines',jsonb_build_array(jsonb_build_object('id',rid,'name','Day A','weight_unit','kg','distance_unit','km','exercises',jsonb_build_array(jsonb_build_object('id',eid,'name','Custom 1','parameters','repsWeight','primary_muscle_group','chest','is_custom',true,'custom_exercise_id',cid,'sets',jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'kind','normal','parameters','repsWeight','done',false,'reps',10,'weight',20,'time',0,'distance',0))))),jsonb_build_object('id',gen_random_uuid(),'name','Day B','weight_unit','kg','distance_unit','km','exercises','[]'::jsonb)));
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','plan_save',jsonb_build_object('id',plan_id,'name','Program','link_id',relationship->>'id','document',doc));
 published:=public.trainer_execute('11111111-1111-4111-8111-111111111111','publish',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','version',response->>'version'));
 PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','accept',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','revision_id',published->>'id'));
 IF (SELECT count(*) FROM public.routines WHERE user_id='22222222-2222-4222-8222-222222222222' AND NOT deleted)<>5 OR (SELECT count(*) FROM public.custom_exercises WHERE user_id='22222222-2222-4222-8222-222222222222' AND NOT deleted)<>11 THEN RAISE EXCEPTION 'soft limit not respected'; END IF;
 PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','accept',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','revision_id',published->>'id'));
 -- Serialize real rows rather than the null r/e PL/pgSQL loop variables.
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','client',jsonb_build_object('link_id',relationship->>'id'));
 IF jsonb_array_length(response->'routines')<>2 OR EXISTS(SELECT 1 FROM jsonb_array_elements(response->'routines') item WHERE jsonb_typeof(item) IS DISTINCT FROM 'object') THEN RAISE EXCEPTION 'client routine serialization returned null'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(response->'routines') item WHERE item->>'id'=rid AND item->>'name'='Day A' AND item->'exercises'->0->>'id'=eid AND item->'exercises'->0->>'name'='Custom 1') THEN RAISE EXCEPTION 'client exercise serialization lost contents'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(response->'routines') item WHERE item->>'name'='Day B' AND item->'exercises'='[]'::jsonb) THEN RAISE EXCEPTION 'empty routine exercises must be an array'; END IF;
 BEGIN UPDATE public.routines SET name='Tampered' WHERE id=rid; RAISE EXCEPTION 'controlled routine changed'; EXCEPTION WHEN check_violation THEN NULL; END;
 BEGIN DELETE FROM public.custom_exercises WHERE id=cid; RAISE EXCEPTION 'protected exercise deleted'; EXCEPTION WHEN check_violation THEN NULL; END;
 -- Unshared routines never leak with the client's general last-activity marker.
 INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,parent_id,weight_unit,distance_unit) VALUES(gen_random_uuid()::text,'22222222-2222-4222-8222-222222222222','Private',60,clock_timestamp(),NULL,'kg','km');
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','history',jsonb_build_object('link_id',relationship->>'id'));
 IF response<>'[]'::jsonb THEN RAISE EXCEPTION 'private workout leaked'; END IF;
 INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,parent_id,weight_unit,distance_unit) VALUES(gen_random_uuid()::text,'22222222-2222-4222-8222-222222222222','Assigned',60,clock_timestamp(),rid,'kg','km');
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','history',jsonb_build_object('link_id',relationship->>'id'));
 IF response->0->>'name' IS DISTINCT FROM 'Assigned' OR response->0->'exercises' IS DISTINCT FROM '[]'::jsonb THEN RAISE EXCEPTION 'empty history exercises must be an array'; END IF;
 IF jsonb_array_length(response)<>1 OR response->0->'prescription' IS NULL THEN RAISE EXCEPTION 'history unavailable'; END IF;
 -- Nested history rows must also serialize actual exercises, not the e loop variable.
 INSERT INTO public.history_workout_exercises
 SELECT converted.* FROM public.routine_exercises source_exercise
 CROSS JOIN LATERAL jsonb_populate_record(NULL::public.history_workout_exercises,
   to_jsonb(source_exercise)||jsonb_build_object('id',gen_random_uuid()::text,'routine_id',
     (SELECT id FROM public.history_workouts WHERE user_id='22222222-2222-4222-8222-222222222222' AND name='Assigned'))) converted
 WHERE source_exercise.id=eid;
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','history',jsonb_build_object('link_id',relationship->>'id'));
 IF jsonb_array_length(response->0->'exercises')<>1 OR response->0->'exercises'->0->>'name' IS DISTINCT FROM 'Custom 1' OR response->0->'exercises'->0->>'id' IS NULL THEN RAISE EXCEPTION 'history exercise serialization returned null'; END IF;
 -- Existing-content revisions remain acceptable when both free categories are saturated.
 doc:=jsonb_set(doc,'{routines,0,name}','"Day A revised"');
 SELECT p.version INTO n FROM gymbro_trainer.plans p WHERE p.id=plan_id;
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','plan_save',jsonb_build_object('id',plan_id,'name','Program','link_id',relationship->>'id','document',doc,'version',n));
 published:=public.trainer_execute('11111111-1111-4111-8111-111111111111','publish',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','version',response->>'version'));
 PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','accept',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','revision_id',published->>'id'));
 IF (SELECT name FROM public.routines WHERE id=rid)<>'Day A revised' THEN RAISE EXCEPTION 'revision did not update stable routine'; END IF;
 -- A new routine while saturated is rejected without modifying existing content.
 doc:=jsonb_set(doc,'{routines}',doc->'routines'||jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'name','Blocked','weight_unit','kg','distance_unit','km','exercises','[]'::jsonb)));
 SELECT p.version INTO n FROM gymbro_trainer.plans p WHERE p.id=plan_id;
 response:=public.trainer_execute('11111111-1111-4111-8111-111111111111','plan_save',jsonb_build_object('id',plan_id,'name','Program','link_id',relationship->>'id','document',doc,'version',n));
 published:=public.trainer_execute('11111111-1111-4111-8111-111111111111','publish',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','version',response->>'version'));
 BEGIN PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','accept',jsonb_build_object('plan_id',plan_id,'link_id',relationship->>'id','revision_id',published->>'id')); RAISE EXCEPTION 'saturated account imported'; EXCEPTION WHEN SQLSTATE 'P1003' THEN NULL; END;
 IF EXISTS(SELECT 1 FROM public.routines WHERE name='Blocked') THEN RAISE EXCEPTION 'partial import'; END IF;
 -- Share/revoke controls detail access without hiding the general activity date.
 PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','share',jsonb_build_object('link_id',relationship->>'id','routine_id',(SELECT id FROM public.routines WHERE user_id='22222222-2222-4222-8222-222222222222' AND name='Personal' LIMIT 1),'include_previous',true));
 PERFORM public.trainer_execute('22222222-2222-4222-8222-222222222222','unshare',jsonb_build_object('link_id',relationship->>'id','routine_id',(SELECT id FROM public.routines WHERE user_id='22222222-2222-4222-8222-222222222222' AND name='Personal' LIMIT 1)));
 PERFORM public.trainer_execute('11111111-1111-4111-8111-111111111111','overview');
 PERFORM public.trainer_execute('11111111-1111-4111-8111-111111111111','catalog');
 PERFORM public.trainer_execute('11111111-1111-4111-8111-111111111111','disconnect',jsonb_build_object('link_id',relationship->>'id'));
 UPDATE public.routines SET name='Now personal' WHERE id=rid;
 DELETE FROM public.custom_exercises WHERE id=cid;
 IF EXISTS(SELECT 1 FROM gymbro_trainer.acceptances WHERE link_id=(relationship->>'id')::uuid) OR EXISTS(SELECT 1 FROM gymbro_trainer.imports WHERE link_id=(relationship->>'id')::uuid) THEN RAISE EXCEPTION 'relationship artifacts remain'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.history_workouts WHERE parent_id=rid) THEN RAISE EXCEPTION 'personal history association lost'; END IF;
END $$;
ROLLBACK;
