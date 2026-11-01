BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES('40000000-0000-4000-8000-000000000001','coach@superset.invalid'),('40000000-0000-4000-8000-000000000002','client@superset.invalid');
SELECT public.trainer_execute('40000000-0000-4000-8000-000000000001','activate','{"display_name":"Coach"}');
SELECT public.mcp_store_billing('40000000-0000-4000-8000-000000000002',true,NULL,'PRODUCTION',clock_timestamp());
DO $$
DECLARE coach uuid:='40000000-0000-4000-8000-000000000001'; client uuid:='40000000-0000-4000-8000-000000000002'; invitation jsonb; relationship jsonb; doc jsonb; invalid_doc jsonb; draft jsonb; revision jsonb; parent jsonb; a jsonb; b jsonb; c jsonb; pid uuid:=gen_random_uuid(); custom text:=gen_random_uuid()::text; rid text:=gen_random_uuid()::text; gid text:=gen_random_uuid()::text;
BEGIN
 invitation:=public.trainer_execute(coach,'invite_create');
 relationship:=public.trainer_execute(client,'invite_accept',jsonb_build_object('token',invitation->>'token'));
 parent:=jsonb_build_object('id',gid,'name','Superset','is_superset',true,'is_in_superset',false,'sort_order',0,'sets','[]'::jsonb);
 a:=jsonb_build_object('id',gen_random_uuid(),'name','A','is_custom',true,'parameters','repsWeight','primary_muscle_group','chest','custom_exercise_id',custom,'is_in_superset',true,'superset_id',gid,'sort_order',1,'sets','[]'::jsonb);
 b:=jsonb_set(jsonb_set(jsonb_set(a,'{id}',to_jsonb(gen_random_uuid()::text)),'{name}','"B"'),'{sort_order}','3')||'{"is_in_superset":false,"superset_id":null}'::jsonb;
 c:=jsonb_set(jsonb_set(jsonb_set(a,'{id}',to_jsonb(gen_random_uuid()::text)),'{name}','"C"'),'{sort_order}','2');
 doc:=jsonb_build_object('folders','[]'::jsonb,'custom_exercises',jsonb_build_array(jsonb_build_object('id',custom,'name','Custom','parameters','repsWeight','primary_muscle_group','chest')),
 'routines',jsonb_build_array(jsonb_build_object('id',rid,'name','Day A','weight_unit','kg','distance_unit','km','exercises',jsonb_build_array(parent,a,c,b))));
 PERFORM gymbro_trainer.validate_document(doc);
 -- A and C cannot be grouped across the independent B, in either representation.
 invalid_doc:=jsonb_set(doc,'{routines,0,exercises}',jsonb_build_array(parent,a,jsonb_set(b,'{sort_order}','2'),jsonb_set(c,'{sort_order}','3')));
 BEGIN PERFORM gymbro_trainer.validate_document(invalid_doc); RAISE EXCEPTION 'non-consecutive array accepted'; EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'noncontiguous_superset' THEN RAISE; END IF; END;
 BEGIN PERFORM gymbro_trainer.validate_document(jsonb_set(doc,'{routines,0,exercises}',jsonb_build_array(parent,a,jsonb_set(c,'{sort_order}','3'),jsonb_set(b,'{sort_order}','2')))); RAISE EXCEPTION 'non-consecutive persisted sort accepted'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM gymbro_trainer.validate_document(jsonb_set(doc,'{routines,0,exercises,2,sort_order}','1')); RAISE EXCEPTION 'ambiguous sort accepted'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM public.trainer_execute(coach,'template_save',jsonb_build_object('id',gen_random_uuid(),'name','Invalid','document',invalid_doc)); RAISE EXCEPTION 'invalid template saved'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'link_id',relationship->>'id','name','Invalid','document',invalid_doc)); RAISE EXCEPTION 'invalid plan saved'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 draft:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'link_id',relationship->>'id','name','Valid plan','document',doc));
 revision:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version'));
 -- A legacy draft cannot bypass checks by publishing directly without the editor.
 UPDATE gymbro_trainer.plans SET draft=invalid_doc WHERE id=pid;
 BEGIN PERFORM public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',(SELECT version FROM gymbro_trainer.plans WHERE id=pid))); RAISE EXCEPTION 'invalid legacy draft published'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 -- Simulate a previously published legacy document. Import must still be atomic.
 UPDATE gymbro_trainer.revisions SET document=invalid_doc WHERE id=(revision->>'id')::uuid;
 BEGIN PERFORM public.trainer_execute(client,'accept',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','revision_id',revision->>'id')); RAISE EXCEPTION 'invalid legacy proposal imported'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 IF EXISTS(SELECT 1 FROM public.routines WHERE user_id=client) OR EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id=client) OR EXISTS(SELECT 1 FROM gymbro_trainer.acceptances WHERE link_id=(relationship->>'id')::uuid) THEN RAISE EXCEPTION 'invalid superset partially imported'; END IF;
 draft:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'link_id',relationship->>'id','name','Valid plan','document',doc,'version',(SELECT version FROM gymbro_trainer.plans WHERE id=pid)));
 revision:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version'));
 PERFORM public.trainer_execute(client,'accept',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','revision_id',revision->>'id'));
 IF (SELECT count(*) FROM public.routine_exercises WHERE user_id=client AND is_in_superset AND superset_id=gid)<>2 THEN RAISE EXCEPTION 'valid contiguous members lost'; END IF;
END $$;
ROLLBACK;
