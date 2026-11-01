BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES('50000000-0000-4000-8000-000000000001','coach@limit.invalid'),('50000000-0000-4000-8000-000000000002','client@limit.invalid');
SELECT public.trainer_execute('50000000-0000-4000-8000-000000000001','activate','{"display_name":"Coach"}');
DO $$
DECLARE invitation jsonb; relationship jsonb; draft jsonb; pid uuid:=gen_random_uuid(); doc jsonb; rows jsonb; oversized jsonb; second_day jsonb; custom text:=gen_random_uuid()::text; group_id text:=gen_random_uuid()::text;
BEGIN
 SELECT jsonb_agg(jsonb_build_object('id',gen_random_uuid(),'name','Exercise','parameters','setless','primary_muscle_group','chest','is_custom',true,'custom_exercise_id',custom,'is_in_superset',true,'superset_id',group_id,'sort_order',n,'sets','[]'::jsonb) ORDER BY n) INTO rows FROM generate_series(1,50) n;
 rows:=jsonb_build_array(jsonb_build_object('id',group_id,'name','Superset','is_superset',true,'sort_order',0))||rows;
 doc:=jsonb_build_object('folders','[]'::jsonb,'custom_exercises',jsonb_build_array(jsonb_build_object('id',custom,'name','Exercise','parameters','setless','primary_muscle_group','chest')),
 'routines',jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'name','Day A','weight_unit','kg','distance_unit','km','exercises',rows)));
 PERFORM gymbro_trainer.validate_document(doc); -- 51 rows, 50 actual exercises.
 SELECT jsonb_agg((e - 'superset_id' - 'is_in_superset')||jsonb_build_object('id',gen_random_uuid(),'sort_order',position)) INTO rows FROM jsonb_array_elements(rows) WITH ORDINALITY x(e,position) WHERE e->>'is_superset' IS DISTINCT FROM 'true';
 second_day:=(doc->'routines'->0)||jsonb_build_object('id',gen_random_uuid(),'name','Day B','exercises',rows);
 doc:=jsonb_set(doc,'{routines}',(doc->'routines')||jsonb_build_array(second_day));
 PERFORM gymbro_trainer.validate_document(doc); -- 100 total exercises across two allowed days.
 PERFORM public.trainer_execute('50000000-0000-4000-8000-000000000001','template_save',jsonb_build_object('id',gen_random_uuid(),'name','Valid','document',doc));
 oversized:=jsonb_set(doc,'{routines,0,exercises}',(doc#>'{routines,0,exercises}')||jsonb_build_array((doc#>'{routines,0,exercises,1}')||jsonb_build_object('id',gen_random_uuid(),'sort_order',51)));
 BEGIN PERFORM gymbro_trainer.validate_document(oversized); RAISE EXCEPTION '51 exercises accepted'; EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'routine_exercise_limit' THEN RAISE; END IF; END;
 BEGIN PERFORM public.trainer_execute('50000000-0000-4000-8000-000000000001','template_save',jsonb_build_object('id',gen_random_uuid(),'name','Invalid','document',oversized)); RAISE EXCEPTION 'oversized template saved'; EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'routine_exercise_limit' THEN RAISE; END IF; END;
 invitation:=public.trainer_execute('50000000-0000-4000-8000-000000000001','invite_create');
 relationship:=public.trainer_execute('50000000-0000-4000-8000-000000000002','invite_accept',jsonb_build_object('token',invitation->>'token'));
 BEGIN PERFORM public.trainer_execute('50000000-0000-4000-8000-000000000001','plan_save',jsonb_build_object('id',pid,'link_id',relationship->>'id','name','Invalid','document',oversized)); RAISE EXCEPTION 'oversized plan saved'; EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'routine_exercise_limit' THEN RAISE; END IF; END;
 draft:=public.trainer_execute('50000000-0000-4000-8000-000000000001','plan_save',jsonb_build_object('id',pid,'link_id',relationship->>'id','name','Valid','document',doc));
 UPDATE gymbro_trainer.plans SET draft=oversized WHERE id=pid;
 BEGIN PERFORM public.trainer_execute('50000000-0000-4000-8000-000000000001','publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version')); RAISE EXCEPTION 'legacy oversized plan published'; EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'routine_exercise_limit' THEN RAISE; END IF; END;

END $$;
ROLLBACK;
