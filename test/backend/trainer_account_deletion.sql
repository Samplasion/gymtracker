BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES
 ('10000000-0000-4000-8000-000000000001','parent-coach@delete.invalid'),
 ('10000000-0000-4000-8000-000000000002','deleting-coach@delete.invalid'),
 ('10000000-0000-4000-8000-000000000003','client-one@delete.invalid'),
 ('10000000-0000-4000-8000-000000000004','client-two@delete.invalid');
SELECT public.trainer_execute('10000000-0000-4000-8000-000000000001','activate','{"display_name":"Parent coach"}');
SELECT public.trainer_execute('10000000-0000-4000-8000-000000000002','activate','{"display_name":"Deleting coach"}');
CREATE TEMP TABLE deletion_expectations(client uuid, routine_id text, exercise_id text, workout_id text, link_id uuid);
DO $$
DECLARE coach uuid; client uuid; invitation jsonb; relationship jsonb; draft jsonb; published jsonb; document jsonb; rid text; cid text; wid text; pid uuid;
BEGIN
 FOR coach,client IN SELECT * FROM (VALUES
 ('10000000-0000-4000-8000-000000000001'::uuid,'10000000-0000-4000-8000-000000000002'::uuid),
 ('10000000-0000-4000-8000-000000000002'::uuid,'10000000-0000-4000-8000-000000000003'::uuid),
 ('10000000-0000-4000-8000-000000000002'::uuid,'10000000-0000-4000-8000-000000000004'::uuid)) pair(coach,client)
 LOOP
  invitation:=public.trainer_execute(coach,'invite_create');
  relationship:=public.trainer_execute(client,'invite_accept',jsonb_build_object('token',invitation->>'token'));
  rid:=gen_random_uuid()::text; cid:=gen_random_uuid()::text; wid:=gen_random_uuid()::text; pid:=gen_random_uuid();
  document:=jsonb_build_object('folders','[]'::jsonb,'custom_exercises',jsonb_build_array(jsonb_build_object('id',cid,'name','Trainer custom','parameters','repsWeight','primary_muscle_group','chest')),
   'routines',jsonb_build_array(jsonb_build_object('id',rid,'name','Assigned day','weight_unit','kg','distance_unit','km','exercises',jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'name','Trainer custom','parameters','repsWeight','primary_muscle_group','chest','is_custom',true,'custom_exercise_id',cid,'sets','[]'::jsonb)))));
  PERFORM public.mcp_store_billing(client,false,NULL,'PRODUCTION',clock_timestamp());
  draft:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'name','Assigned plan','link_id',relationship->>'id','document',document));
  published:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version'));
  PERFORM public.trainer_execute(client,'accept',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','revision_id',published->>'id'));
  PERFORM set_config('gymtracker.sync_v2','on',true);
  INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,parent_id,weight_unit,distance_unit) VALUES(wid,client,'History',60,clock_timestamp(),rid,'kg','km');
  INSERT INTO deletion_expectations VALUES(client,rid,cid,wid,(relationship->>'id')::uuid);
  -- Leave another proposal and a personal share pending at account deletion.
  published:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',(SELECT version FROM gymbro_trainer.plans WHERE id=pid)));
  INSERT INTO public.routines(id,user_id,name,weight_unit,distance_unit,sort_order) VALUES(gen_random_uuid()::text,client,'Personal shared','kg','km',10);
  PERFORM public.trainer_execute(client,'share',jsonb_build_object('link_id',relationship->>'id','routine_id',(SELECT id FROM public.routines WHERE user_id=client AND name='Personal shared'),'include_previous',true));
 END LOOP;
END $$;
-- This is the same hard Auth deletion used by delete-user-complete.
DELETE FROM auth.users WHERE id='10000000-0000-4000-8000-000000000002';
DO $$
DECLARE expected record; snapshot jsonb;
BEGIN
 IF EXISTS(SELECT 1 FROM gymbro_trainer.links WHERE trainer_id='10000000-0000-4000-8000-000000000002' OR client_id='10000000-0000-4000-8000-000000000002') THEN RAISE EXCEPTION 'deleted account still linked'; END IF;
 IF EXISTS(SELECT 1 FROM gymbro_trainer.controls) OR EXISTS(SELECT 1 FROM gymbro_trainer.shares) OR EXISTS(SELECT 1 FROM gymbro_trainer.acceptances) OR EXISTS(SELECT 1 FROM gymbro_trainer.imports) OR EXISTS(SELECT 1 FROM gymbro_trainer.plans) THEN RAISE EXCEPTION 'professional constraints survived account deletion'; END IF;
 IF EXISTS(SELECT 1 FROM public.notifications WHERE kind='trainer_plan' AND params->>'link_id' IN (SELECT link_id::text FROM deletion_expectations)) THEN RAISE EXCEPTION 'stale invitation notification'; END IF;
 IF EXISTS(SELECT 1 FROM gymbro_trainer.invites WHERE trainer_id='10000000-0000-4000-8000-000000000001' AND (NOT revoked OR link_id IS NOT NULL)) THEN RAISE EXCEPTION 'consumed invite can be reused after client deletion'; END IF;
 FOR expected IN SELECT * FROM deletion_expectations WHERE client<>'10000000-0000-4000-8000-000000000002' LOOP
  snapshot:=public.trainer_execute(expected.client,'session');
  IF snapshot->'link'<>'null'::jsonb OR snapshot->'controls'<>'[]'::jsonb OR snapshot->'offers'<>'[]'::jsonb OR snapshot->'protected_exercises'<>'[]'::jsonb THEN RAISE EXCEPTION 'stale client session after trainer deletion'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.routines WHERE id=expected.routine_id AND user_id=expected.client AND NOT deleted) OR NOT EXISTS(SELECT 1 FROM public.custom_exercises WHERE id=expected.exercise_id AND user_id=expected.client AND NOT deleted) OR NOT EXISTS(SELECT 1 FROM public.history_workouts WHERE id=expected.workout_id AND user_id=expected.client AND parent_id=expected.routine_id) THEN RAISE EXCEPTION 'client content or history association lost'; END IF;
  UPDATE public.routines SET name='Freely editable' WHERE id=expected.routine_id AND user_id=expected.client;
  UPDATE public.custom_exercises SET name='Personal custom' WHERE id=expected.exercise_id AND user_id=expected.client;
  UPDATE public.history_workouts SET starting_date=starting_date-interval '1 day' WHERE id=expected.workout_id AND user_id=expected.client;
  IF NOT EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id=expected.client AND NOT deleted) THEN RAISE EXCEPTION 'client plan folder lost'; END IF;
  DELETE FROM public.routine_folders WHERE user_id=expected.client;
 END LOOP;
END $$;
ROLLBACK;
