-- Run against a disposable Supabase database after all migrations.
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000011','history-a@unit.test','{"username":"history_alpha"}'),
 ('00000000-0000-0000-0000-000000000012','history-b@unit.test','{"username":"history_beta"}');
INSERT INTO public.achievements_v2(id,user_id,achievement_id,level,completed_at,deleted)
SELECT lpad(i::text,3,'0'),'00000000-0000-0000-0000-000000000011','test',1,'2026-10-22T12:00:00.123456Z',i=126
FROM generate_series(1,126) i;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000011',true);
DO $$
DECLARE page jsonb; cursor jsonb; ids text[]:='{}'; i jsonb;
BEGIN
 page:=public.get_achievement_history(auth.uid());
 IF jsonb_array_length(page->'items')<>50 THEN RAISE EXCEPTION 'Wrong page size'; END IF;
 LOOP
   FOR i IN SELECT * FROM jsonb_array_elements(page->'items') LOOP
     IF i->>'id'=ANY(ids) OR (i->>'deleted')::boolean THEN RAISE EXCEPTION 'Duplicate or deleted entry'; END IF;
     ids:=array_append(ids,i->>'id');
   END LOOP;
   cursor:=page->'next_cursor';
   EXIT WHEN cursor='null'::jsonb;
   page:=public.get_achievement_history(auth.uid(),(cursor->>'completed_at')::timestamptz,cursor->>'id');
 END LOOP;
 IF cardinality(ids)<>125 OR ids[1]<>'125' OR ids[125]<>'001' THEN RAISE EXCEPTION 'Incomplete or incorrectly ordered history'; END IF;
 BEGIN
   PERFORM public.get_achievement_history(auth.uid(),now(),NULL);
   RAISE EXCEPTION 'Incomplete cursor accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END; $$;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000012',true);
DO $$ BEGIN
 BEGIN
   PERFORM public.get_achievement_history('00000000-0000-0000-0000-000000000011');
   RAISE EXCEPTION 'Stranger access allowed' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
RESET ROLE;
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES
 ('00000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000012','accepted');
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 IF jsonb_array_length(public.get_achievement_history('00000000-0000-0000-0000-000000000011')->'items')<>50 THEN RAISE EXCEPTION 'Friend access failed'; END IF;
END; $$;
RESET ROLE;
DELETE FROM public.friends WHERE sender_id='00000000-0000-0000-0000-000000000011';
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 BEGIN
   PERFORM public.get_achievement_history('00000000-0000-0000-0000-000000000011','2026-10-22T12:00:00.123456Z','076');
   RAISE EXCEPTION 'Revoked friend accessed next page' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
SELECT set_config('request.jwt.claim.sub','',true);
DO $$ BEGIN
 BEGIN
   PERFORM public.get_achievement_history('00000000-0000-0000-0000-000000000011');
   RAISE EXCEPTION 'Missing session accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$ BEGIN
 BEGIN
   PERFORM public.get_achievement_history('00000000-0000-0000-0000-000000000011');
   RAISE EXCEPTION 'Anonymous execution allowed' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END; $$;
ROLLBACK;
