\set ON_ERROR_STOP on
BEGIN;
INSERT INTO gymbro_mcp.settings VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
INSERT INTO gymbro_mcp.oauth_clients VALUES
 ('00000000-0000-0000-0000-000000000090'),('00000000-0000-0000-0000-000000000091') ON CONFLICT DO NOTHING;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000911','multi-client@unit.test','{"username":"multiclient"}');
INSERT INTO auth.sessions(id,user_id,oauth_client_id) VALUES
 ('00000000-0000-0000-0000-000000000912','00000000-0000-0000-0000-000000000911','00000000-0000-0000-0000-000000000091');
INSERT INTO auth.oauth_consents(user_id,client_id) VALUES
 ('00000000-0000-0000-0000-000000000911','00000000-0000-0000-0000-000000000091');
DO $$
DECLARE claims jsonb; client text;
BEGIN
 FOREACH client IN ARRAY ARRAY['00000000-0000-0000-0000-000000000090','00000000-0000-0000-0000-000000000091'] LOOP
  claims:=public.gymbro_mcp_access_token_hook(jsonb_build_object('claims',jsonb_build_object('client_id',client,'role','authenticated','aud','authenticated')))->'claims';
  IF claims->>'role'<>'gymbro_mcp_user' OR NOT (claims->'aud') ? 'https://gym-bro.test/mcp' THEN RAISE EXCEPTION 'Registered client rejected'; END IF;
 END LOOP;
 claims:=public.gymbro_mcp_access_token_hook('{"claims":{"role":"authenticated","aud":"authenticated"}}')->'claims';
 IF claims->>'role'<>'authenticated' THEN RAISE EXCEPTION 'Ordinary login changed'; END IF;
 claims:=public.gymbro_mcp_access_token_hook('{"claims":{"client_id":"unknown","role":"authenticated","aud":"authenticated"}}')->'claims';
 IF claims->>'role'<>'gymbro_mcp_user' OR claims->>'aud'<>'authenticated' THEN RAISE EXCEPTION 'Unknown client gained access'; END IF;
END $$;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000911","session_id":"00000000-0000-0000-0000-000000000912","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000091","aud":["https://gym-bro.test/mcp"]}';
SET LOCAL ROLE gymbro_mcp_user;
SELECT public.mcp_custom_exercises();
DO $$ BEGIN
 BEGIN PERFORM 1 FROM gymbro_mcp.oauth_clients; RAISE EXCEPTION 'Registry exposed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
-- A token cannot borrow the session of a different allowed client.
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000911","session_id":"00000000-0000-0000-0000-000000000912","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_custom_exercises(); RAISE EXCEPTION 'Cross-client session accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
SET LOCAL request.jwt.claims='{"sub":"00000000-0000-0000-0000-000000000911","session_id":"00000000-0000-0000-0000-000000000912","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000091","aud":["https://gym-bro.test/mcp"]}';
UPDATE auth.oauth_consents SET revoked_at=now() WHERE user_id='00000000-0000-0000-0000-000000000911';
SET LOCAL ROLE gymbro_mcp_user;
DO $$ BEGIN
 BEGIN PERFORM public.mcp_custom_exercises(); RAISE EXCEPTION 'Revoked consent accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
ROLLBACK;
