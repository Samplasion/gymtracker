CREATE TABLE public.admin_user_audit (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 target_id uuid NOT NULL,
 actor uuid NOT NULL,
 note text NOT NULL,
 before_profile jsonb NOT NULL,
 after_profile jsonb NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.admin_user_audit ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.admin_user_audit FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.admin_user_audit TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.admin_user_audit_id_seq TO service_role;
CREATE FUNCTION public.admin_update_public_profile(target_id uuid, expected_updated_at timestamptz,
 new_username text, new_full_name text, operator_id uuid, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE old_profile public.profiles; new_profile public.profiles;
BEGIN
 IF new_username IS NULL OR new_username !~ '^[a-zA-Z0-9_]{3,30}$' OR new_full_name IS NULL OR length(new_full_name)>100
 OR note IS NULL OR length(btrim(note)) NOT BETWEEN 1 AND 2000 THEN
 RAISE EXCEPTION 'Invalid profile' USING ERRCODE='22023'; END IF;
 SELECT * INTO old_profile FROM public.profiles WHERE id=target_id FOR UPDATE;
 IF NOT FOUND OR old_profile.updated_at IS DISTINCT FROM expected_updated_at THEN
 RAISE EXCEPTION 'Profile changed' USING ERRCODE='40001'; END IF;
 UPDATE public.profiles SET username=new_username,full_name=new_full_name WHERE id=target_id RETURNING * INTO new_profile;
 INSERT INTO public.admin_user_audit(target_id,actor,note,before_profile,after_profile)
 VALUES(target_id,operator_id,note,jsonb_build_object('username',old_profile.username,'full_name',old_profile.full_name),
 jsonb_build_object('username',new_profile.username,'full_name',new_profile.full_name));
END $$;
REVOKE ALL ON FUNCTION public.admin_update_public_profile(uuid,timestamptz,text,text,uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_public_profile(uuid,timestamptz,text,text,uuid,text) TO service_role;
