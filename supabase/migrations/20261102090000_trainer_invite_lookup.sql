BEGIN;

-- Public invitation landing pages need only availability, never invite records
-- or access to the private trainer schema. Acceptance rechecks all constraints.
CREATE FUNCTION public.trainer_invite_available(p_token uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM gymbro_trainer.invites AS invitation
    WHERE invitation.token = p_token
      AND NOT invitation.revoked
      AND invitation.link_id IS NULL
      AND invitation.expires_at > now()
  );
$$;

REVOKE ALL ON FUNCTION public.trainer_invite_available(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.trainer_invite_available(uuid) TO anon, authenticated, service_role;

COMMIT;
