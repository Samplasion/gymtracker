\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000041','requests-a@test.local','{"username":"requests_a"}'),
 ('00000000-0000-0000-0000-000000000042','requests-b@test.local','{"username":"requests_b"}'),
 ('00000000-0000-0000-0000-000000000043','requests-c@test.local','{"username":"requests_c"}');

-- Register the receiver before requests, so each request gets a queued push.
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000042',true);
SELECT public.register_push_device('00000000-0000-0000-0000-000000000049','requests-receiver-token','android','it');
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000041',true);
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES(auth.uid(),'00000000-0000-0000-0000-000000000042','pending');
RESET ROLE;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.notifications WHERE kind='friend_request' AND actor_id='00000000-0000-0000-0000-000000000041')<>1 THEN RAISE EXCEPTION 'Request notification missing'; END IF;
 IF (SELECT count(*) FROM public.push_deliveries)<>1 THEN RAISE EXCEPTION 'Request push missing'; END IF;
END; $$;

-- Cancellation must physically remove the notification and a leased delivery.
CREATE TEMP TABLE request_delivery AS SELECT value AS job FROM jsonb_array_elements(public.claim_push_deliveries());
SET LOCAL ROLE authenticated;
DELETE FROM public.friends WHERE sender_id=auth.uid() AND receiver_id='00000000-0000-0000-0000-000000000042';
RESET ROLE;
DO $$ DECLARE job jsonb; BEGIN
 IF EXISTS(SELECT 1 FROM public.notifications WHERE kind='friend_request' AND actor_id='00000000-0000-0000-0000-000000000041') THEN RAISE EXCEPTION 'Cancelled notification survived'; END IF;
 IF EXISTS(SELECT 1 FROM public.push_deliveries) THEN RAISE EXCEPTION 'Cancelled push survived'; END IF;
 SELECT r.job INTO job FROM request_delivery r;
 IF public.authorize_push_delivery((job->>'id')::bigint,(job->>'lease_id')::uuid) THEN RAISE EXCEPTION 'Cancelled leased push authorized'; END IF;
END; $$;

-- A new request must create exactly one fresh notification, even if the first
-- notification was already read. Requests by other senders stay untouched.
SET LOCAL ROLE authenticated;
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES(auth.uid(),'00000000-0000-0000-0000-000000000042','pending');
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000043',true);
INSERT INTO public.friends(sender_id,receiver_id,status) VALUES(auth.uid(),'00000000-0000-0000-0000-000000000042','pending');
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000042',true);
DO $$ BEGIN
 IF (public.notification_summary()->>'unread')::integer<>2 THEN RAISE EXCEPTION 'Duplicate or missing request notifications'; END IF;
 PERFORM public.read_notifications((public.notification_summary()->>'through_id')::bigint);
END; $$;
-- Receiver decline follows the same deletion path as sender cancellation.
DELETE FROM public.friends WHERE sender_id='00000000-0000-0000-0000-000000000041' AND receiver_id=auth.uid();
RESET ROLE;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.notifications WHERE kind='friend_request' AND actor_id='00000000-0000-0000-0000-000000000041') THEN RAISE EXCEPTION 'Read declined notification survived'; END IF;
 IF (SELECT count(*) FROM public.notifications WHERE kind='friend_request' AND actor_id='00000000-0000-0000-0000-000000000043')<>1 THEN RAISE EXCEPTION 'Unrelated request removed'; END IF;
END; $$;

-- Acceptance removes only the pending notification, retaining its separate
-- acceptance event for the original sender.
SET LOCAL ROLE authenticated;
UPDATE public.friends SET status='accepted' WHERE sender_id='00000000-0000-0000-0000-000000000043' AND receiver_id=auth.uid();
RESET ROLE;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.notifications WHERE kind='friend_request') THEN RAISE EXCEPTION 'Accepted pending notification survived'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.notifications WHERE kind='friend_accepted' AND user_id='00000000-0000-0000-0000-000000000043' AND actor_id='00000000-0000-0000-0000-000000000042') THEN RAISE EXCEPTION 'Acceptance event removed'; END IF;
 IF EXISTS(SELECT 1 FROM public.push_deliveries) THEN RAISE EXCEPTION 'Resolved request push survived'; END IF;
END; $$;
ROLLBACK;
