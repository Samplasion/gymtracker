BEGIN;
INSERT INTO auth.users(id,email) VALUES
 ('60000000-0000-4000-8000-000000000001','lookup-coach@example.invalid'),
 ('60000000-0000-4000-8000-000000000002','lookup-client@example.invalid');
INSERT INTO gymbro_trainer.profiles(user_id,display_name)
 VALUES('60000000-0000-4000-8000-000000000001','Coach');
INSERT INTO gymbro_trainer.links(id,trainer_id,client_id)
 VALUES('60000000-0000-4000-8000-000000000003','60000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000002');
INSERT INTO gymbro_trainer.invites(trainer_id,token,revoked,expires_at,link_id) VALUES
 ('60000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000010',false,now()+interval '1 day',NULL),
 ('60000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000011',true,now()+interval '1 day',NULL),
 ('60000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000012',false,now()-interval '1 second',NULL),
 ('60000000-0000-4000-8000-000000000001','60000000-0000-4000-8000-000000000013',false,now()+interval '1 day','60000000-0000-4000-8000-000000000003');
SET LOCAL ROLE anon;
DO $$
BEGIN
 IF NOT public.trainer_invite_available('60000000-0000-4000-8000-000000000010') THEN RAISE EXCEPTION 'valid invitation rejected'; END IF;
 IF public.trainer_invite_available('60000000-0000-4000-8000-000000000099') OR public.trainer_invite_available(NULL) THEN RAISE EXCEPTION 'missing invitation accepted'; END IF;
 IF public.trainer_invite_available('60000000-0000-4000-8000-000000000011') THEN RAISE EXCEPTION 'revoked invitation accepted'; END IF;
 IF public.trainer_invite_available('60000000-0000-4000-8000-000000000012') THEN RAISE EXCEPTION 'expired invitation accepted'; END IF;
 IF public.trainer_invite_available('60000000-0000-4000-8000-000000000013') THEN RAISE EXCEPTION 'used invitation accepted'; END IF;
 BEGIN PERFORM * FROM gymbro_trainer.invites; RAISE EXCEPTION 'anonymous invite table access'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
UPDATE gymbro_trainer.invites SET revoked=true WHERE token='60000000-0000-4000-8000-000000000010';
SET LOCAL ROLE authenticated;
DO $$ BEGIN IF public.trainer_invite_available('60000000-0000-4000-8000-000000000010') THEN RAISE EXCEPTION 'revocation was not observed'; END IF; END $$;
RESET ROLE;
DELETE FROM auth.users WHERE id='60000000-0000-4000-8000-000000000001';
SET LOCAL ROLE anon;
DO $$ BEGIN IF public.trainer_invite_available('60000000-0000-4000-8000-000000000010') THEN RAISE EXCEPTION 'deleted trainer invitation accepted'; END IF; END $$;
RESET ROLE;
ROLLBACK;
