-- Explicit private registry; OAuth registration alone never grants MCP access.
BEGIN;
CREATE TABLE gymbro_mcp.oauth_clients (
 client_id text PRIMARY KEY CHECK (length(btrim(client_id)) > 0)
);
REVOKE ALL ON gymbro_mcp.oauth_clients FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
INSERT INTO gymbro_mcp.oauth_clients(client_id)
 SELECT client_id FROM gymbro_mcp.settings WHERE singleton ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION public.gymbro_mcp_access_token_hook(event jsonb) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE claims jsonb:=event->'claims'; resource text;
BEGIN
 IF NULLIF(claims->>'client_id','') IS NOT NULL THEN
  claims:=jsonb_set(claims,'{role}','"gymbro_mcp_user"');
  SELECT s.resource INTO resource FROM gymbro_mcp.settings s WHERE singleton;
  IF resource IS NOT NULL AND EXISTS(SELECT 1 FROM gymbro_mcp.oauth_clients c WHERE c.client_id=claims->>'client_id') THEN
   claims:=jsonb_set(claims,'{aud}',jsonb_build_array('authenticated',resource));
  END IF;
 END IF;
 RETURN jsonb_build_object('claims',claims);
END $$;

CREATE OR REPLACE FUNCTION gymbro_mcp.owner() RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE config gymbro_mcp.settings; claims jsonb:=auth.jwt();
BEGIN
 SELECT * INTO config FROM gymbro_mcp.settings WHERE singleton;
 IF auth.uid() IS NULL OR config.resource IS NULL OR claims->>'role' IS DISTINCT FROM 'gymbro_mcp_user'
 OR NOT EXISTS(SELECT 1 FROM gymbro_mcp.oauth_clients c WHERE c.client_id=claims->>'client_id')
 OR NOT COALESCE((claims->'aud') ? config.resource,false)
 OR NOT EXISTS(SELECT 1 FROM auth.sessions s JOIN auth.oauth_consents c ON c.user_id=s.user_id AND c.client_id=s.oauth_client_id
 WHERE s.id::text=claims->>'session_id' AND s.user_id=auth.uid() AND s.oauth_client_id::text=claims->>'client_id'
 AND c.revoked_at IS NULL AND (s.not_after IS NULL OR s.not_after>now()))
 THEN RAISE EXCEPTION 'MCP authentication required' USING ERRCODE='42501'; END IF;
 RETURN auth.uid();
END $$;
COMMIT;
