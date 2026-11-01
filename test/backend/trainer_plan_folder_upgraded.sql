DO $$
DECLARE folder uuid;
BEGIN
 SELECT folder_id INTO STRICT folder FROM gymbro_trainer.plans WHERE name='Upgrade plan';
 IF (SELECT count(*) FROM public.routines WHERE user_id='30000000-0000-4000-8000-000000000002' AND folder_id=folder)<>2 THEN RAISE EXCEPTION 'upgrade did not group existing assigned days'; END IF;
 IF (SELECT count(*) FROM public.routine_folders WHERE user_id='30000000-0000-4000-8000-000000000002')<>3 THEN RAISE EXCEPTION 'upgrade deleted old user folders'; END IF;
 IF (SELECT jsonb_array_length(document->'folders') FROM gymbro_trainer.revisions WHERE plan_id=(SELECT id FROM gymbro_trainer.plans WHERE name='Upgrade plan'))<>2 THEN RAISE EXCEPTION 'upgrade changed immutable revision'; END IF;
 IF NOT EXISTS(SELECT 1 FROM gymbro_trainer.imports WHERE client_id='30000000-0000-4000-8000-000000000002' AND record_id=folder::text) THEN RAISE EXCEPTION 'upgrade did not register owned folder'; END IF;
END $$;
DELETE FROM auth.users WHERE id IN ('30000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000002');
