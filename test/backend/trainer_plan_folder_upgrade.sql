-- Loaded only before the plan-folder migration to exercise a real upgrade.
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES('30000000-0000-4000-8000-000000000001','upgrade-coach@test.invalid'),('30000000-0000-4000-8000-000000000002','upgrade-client@test.invalid');
SELECT public.trainer_execute('30000000-0000-4000-8000-000000000001','activate','{"display_name":"Upgrade coach"}');
SELECT public.mcp_store_billing('30000000-0000-4000-8000-000000000002',true,NULL,'PRODUCTION',clock_timestamp());
DO $$
DECLARE invitation jsonb; relationship jsonb; draft jsonb; revision jsonb; doc jsonb; first_folder uuid:=gen_random_uuid(); second_folder uuid:=gen_random_uuid();
BEGIN
 invitation:=public.trainer_execute('30000000-0000-4000-8000-000000000001','invite_create');
 relationship:=public.trainer_execute('30000000-0000-4000-8000-000000000002','invite_accept',jsonb_build_object('token',invitation->>'token'));
 doc:=jsonb_build_object('custom_exercises','[]'::jsonb,'folders',jsonb_build_array(jsonb_build_object('id',first_folder,'name','Old A'),jsonb_build_object('id',second_folder,'name','Old B')),
 'routines',jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'name','Upgrade day A','weight_unit','kg','distance_unit','km','folder_id',first_folder,'exercises','[]'::jsonb),jsonb_build_object('id',gen_random_uuid(),'name','Upgrade day B','weight_unit','kg','distance_unit','km','folder_id',second_folder,'exercises','[]'::jsonb)));
 draft:=public.trainer_execute('30000000-0000-4000-8000-000000000001','plan_save',jsonb_build_object('id',gen_random_uuid(),'link_id',relationship->>'id','name','Upgrade plan','document',doc));
 revision:=public.trainer_execute('30000000-0000-4000-8000-000000000001','publish',jsonb_build_object('plan_id',draft->>'id','link_id',relationship->>'id','version',draft->>'version'));
 PERFORM public.trainer_execute('30000000-0000-4000-8000-000000000002','accept',jsonb_build_object('plan_id',draft->>'id','link_id',relationship->>'id','revision_id',revision->>'id'));
END $$;
COMMIT;
