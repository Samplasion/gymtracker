-- Only loaded by the disposable backend harness; never a production migration.
CREATE TABLE IF NOT EXISTS auth.sessions (
 id uuid PRIMARY KEY,user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 not_after timestamptz,oauth_client_id uuid
);
ALTER TABLE auth.sessions ADD COLUMN IF NOT EXISTS oauth_client_id uuid;
CREATE TABLE IF NOT EXISTS auth.oauth_consents (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL,
 client_id uuid NOT NULL,scopes text NOT NULL DEFAULT 'openid',
 granted_at timestamptz NOT NULL DEFAULT now(),revoked_at timestamptz
);
CREATE FUNCTION public.test_mcp_oauth(owner uuid) RETURNS void LANGUAGE plpgsql AS $$ BEGIN
 INSERT INTO auth.sessions(id,user_id,oauth_client_id) VALUES(owner,owner,'00000000-0000-0000-0000-000000000090') ON CONFLICT(id) DO UPDATE SET oauth_client_id=excluded.oauth_client_id;
 INSERT INTO auth.oauth_consents(user_id,client_id,scopes,granted_at) SELECT owner,'00000000-0000-0000-0000-000000000090','openid',now() WHERE NOT EXISTS(SELECT 1 FROM auth.oauth_consents c WHERE c.user_id=owner AND c.client_id='00000000-0000-0000-0000-000000000090');
END $$;

REVOKE ALL ON FUNCTION public.test_mcp_oauth(uuid) FROM PUBLIC;
