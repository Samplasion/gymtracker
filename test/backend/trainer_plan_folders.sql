BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES('20000000-0000-4000-8000-000000000001','coach@folders.invalid'),('20000000-0000-4000-8000-000000000002','client@folders.invalid');
SELECT public.trainer_execute('20000000-0000-4000-8000-000000000001','activate','{"display_name":"Coach"}');
SELECT public.mcp_store_billing('20000000-0000-4000-8000-000000000002',true,NULL,'PRODUCTION',clock_timestamp());
DO $$
DECLARE coach uuid:='20000000-0000-4000-8000-000000000001'; client uuid:='20000000-0000-4000-8000-000000000002'; invitation jsonb; relationship jsonb; doc jsonb; draft jsonb; published jsonb; second_plan jsonb; first_folder text; other_folder text; pid uuid:=gen_random_uuid(); first_day text:=gen_random_uuid()::text; second_day text:=gen_random_uuid()::text; supplied_folder uuid:=gen_random_uuid(); personal_folder uuid:=gen_random_uuid();
BEGIN
 invitation:=public.trainer_execute(coach,'invite_create');
 relationship:=public.trainer_execute(client,'invite_accept',jsonb_build_object('token',invitation->>'token'));
 PERFORM set_config('gymtracker.sync_v2','on',true);
 INSERT INTO public.routine_folders(id,user_id,name,sort_order) VALUES(personal_folder,client,'Personal folder',0);
 doc:=jsonb_build_object('custom_exercises','[]'::jsonb,'folders',jsonb_build_array(jsonb_build_object('id',personal_folder,'name','Do not overwrite'),jsonb_build_object('id',supplied_folder,'name','Arbitrary folder')),
 'routines',jsonb_build_array(jsonb_build_object('id',first_day,'name','Day A','weight_unit','kg','distance_unit','km','folder_id',personal_folder,'exercises','[]'::jsonb),jsonb_build_object('id',second_day,'name','Day B','weight_unit','kg','distance_unit','km','folder_id',supplied_folder,'exercises','[]'::jsonb)));
 draft:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'name','Strength plan','link_id',relationship->>'id','document',doc));
 first_folder:=draft->>'folder_id';
 IF jsonb_array_length(draft->'draft'->'folders')<>1 OR draft->'draft'->'folders'->0->>'name'<>'Strength plan' OR first_folder IN (personal_folder::text,supplied_folder::text) OR EXISTS(SELECT 1 FROM jsonb_array_elements(draft->'draft'->'routines') r WHERE r->>'folder_id'<>first_folder) THEN RAISE EXCEPTION 'server did not enforce one owned plan folder'; END IF;
 published:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version'));
 PERFORM public.trainer_execute(client,'accept',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','revision_id',published->>'id'));
 IF (SELECT count(*) FROM public.routine_folders WHERE user_id=client AND NOT deleted)<>2 OR (SELECT name FROM public.routine_folders WHERE user_id=client AND id=personal_folder)<>'Personal folder' OR EXISTS(SELECT 1 FROM public.routines WHERE user_id=client AND folder_id::text<>first_folder) THEN RAISE EXCEPTION 'acceptance created arbitrary folders or misplaced days'; END IF;
 -- A rename/revision reuses the folder and cannot move days to supplied folders.
 draft:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',pid,'name','Strength revised','link_id',relationship->>'id','document',doc,'version',(SELECT version FROM gymbro_trainer.plans WHERE id=pid)));
 IF draft->>'folder_id'<>first_folder THEN RAISE EXCEPTION 'revision changed folder identity'; END IF;
 published:=public.trainer_execute(coach,'publish',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','version',draft->>'version'));
 PERFORM public.trainer_execute(client,'accept',jsonb_build_object('plan_id',pid,'link_id',relationship->>'id','revision_id',published->>'id'));
 IF (SELECT count(*) FROM public.routine_folders WHERE user_id=client AND NOT deleted)<>2 OR (SELECT name FROM public.routine_folders WHERE user_id=client AND id::text=first_folder)<>'Strength revised' THEN RAISE EXCEPTION 'revision duplicated or did not rename folder'; END IF;
 -- Another plan receives a different server-owned folder even with the same payload.
 second_plan:=public.trainer_execute(coach,'plan_save',jsonb_build_object('id',gen_random_uuid(),'name','Another plan','link_id',relationship->>'id','document',doc));
 other_folder:=second_plan->>'folder_id';
 IF other_folder=first_folder THEN RAISE EXCEPTION 'different plans share a folder identity'; END IF;
 draft:=public.trainer_execute(coach,'template_save',jsonb_build_object('id',gen_random_uuid(),'name','Template','document',doc));
 IF jsonb_array_length(draft->'document'->'folders')<>1 THEN RAISE EXCEPTION 'template retained arbitrary folders'; END IF;
 PERFORM public.trainer_execute(coach,'disconnect',jsonb_build_object('link_id',relationship->>'id'));
 IF NOT EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id=client AND id::text=first_folder AND NOT deleted) THEN RAISE EXCEPTION 'disconnect removed plan folder'; END IF;
END $$;
ROLLBACK;
