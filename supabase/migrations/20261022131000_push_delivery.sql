BEGIN;
-- Device registration is checked RPC-only; account switches replace the old
-- installation and cascade its pending deliveries before binding a new owner.
REVOKE INSERT,UPDATE ON public.push_devices FROM authenticated;
CREATE FUNCTION public.register_push_device(device uuid, device_token text, device_platform text, device_locale text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 IF auth.uid() IS NULL OR device IS NULL OR char_length(device_token) NOT BETWEEN 10 AND 4096 THEN RAISE EXCEPTION 'Invalid device' USING ERRCODE='42501'; END IF;
 DELETE FROM public.push_devices WHERE (id=device OR token=device_token) AND user_id<>auth.uid();
 INSERT INTO public.push_devices(id,user_id,token,platform,locale) VALUES(device,auth.uid(),device_token,device_platform,CASE WHEN device_locale='it' THEN 'it' ELSE 'en' END)
 ON CONFLICT(id) DO UPDATE SET token=EXCLUDED.token,platform=EXCLUDED.platform,locale=EXCLUDED.locale,updated_at=clock_timestamp();
END; $$;
CREATE OR REPLACE FUNCTION public.notification_visible(n public.notifications, viewer uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT n.user_id=viewer AND NOT public.social_blocked(viewer,n.actor_id)
 AND (n.post_id IS NULL OR (public.can_read_post(n.post_id,viewer) AND EXISTS(SELECT 1 FROM public.public_posts WHERE id=n.post_id AND active)))
 AND (n.kind<>'friend_request' OR EXISTS(SELECT 1 FROM public.friends WHERE sender_id=n.actor_id AND receiver_id=viewer AND status='pending'))
 AND (n.kind<>'friend_accepted' OR public.are_friends(viewer,n.actor_id))
 AND (n.kind<>'like' OR EXISTS(SELECT 1 FROM public.likes WHERE post_id=n.post_id AND user_id=n.actor_id)); $$;
-- Existing pending requests become inbox items, without retroactive pushes.
INSERT INTO public.notifications(user_id,kind,actor_id,event_key,created_at)
 SELECT receiver_id,'friend_request',sender_id,'legacy-request:'||sender_id||':'||receiver_id,created_at
 FROM public.friends WHERE status='pending' AND NOT public.social_blocked(sender_id,receiver_id);

CREATE FUNCTION public.claim_push_deliveries(batch_size integer DEFAULT 50) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 UPDATE public.push_deliveries SET finished_at=now(),last_error='retry_limit_reached' WHERE finished_at IS NULL AND attempts>=8 AND lease_until<now();
 -- Permission changes invalidate queued messages permanently.
 UPDATE public.push_deliveries d SET finished_at=now(),last_error='no_longer_authorized'
 FROM public.notifications n,public.push_devices device WHERE d.notification_id=n.id AND device.id=d.device_id AND d.finished_at IS NULL
 AND (device.user_id<>n.user_id OR NOT public.notification_visible(n,n.user_id));
 WITH picked AS (
  SELECT id FROM public.push_deliveries WHERE finished_at IS NULL AND available_at<=now() AND (lease_until IS NULL OR lease_until<now()) AND attempts<8
  ORDER BY id FOR UPDATE SKIP LOCKED LIMIT greatest(1,least(batch_size,100))
 ), leased AS (
  UPDATE public.push_deliveries d SET attempts=attempts+1,lease_until=now()+interval '2 minutes',lease_id=gen_random_uuid()
  FROM picked WHERE d.id=picked.id RETURNING d.*
 ) SELECT coalesce(jsonb_agg(jsonb_build_object('id',d.id,'lease_id',d.lease_id,'attempts',d.attempts,'notification',to_jsonb(n),
   'device',jsonb_build_object('id',device.id,'token',device.token,'locale',device.locale,'platform',device.platform),
   'actor_name',coalesce(p.full_name,p.username,''))),'[]'::jsonb) INTO result
 FROM leased d JOIN public.notifications n ON n.id=d.notification_id JOIN public.push_devices device ON device.id=d.device_id LEFT JOIN public.profiles p ON p.id=n.actor_id;
 RETURN result;
END; $$;
CREATE FUNCTION public.authorize_push_delivery(delivery bigint, lease uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT EXISTS(SELECT 1 FROM public.push_deliveries d JOIN public.notifications n ON n.id=d.notification_id JOIN public.push_devices p ON p.id=d.device_id
 WHERE d.id=delivery AND d.lease_id=lease AND d.lease_until>now() AND d.finished_at IS NULL AND p.user_id=n.user_id AND public.notification_visible(n,n.user_id)); $$;
CREATE FUNCTION public.finish_push_delivery(delivery bigint, lease uuid, outcome text, failure text DEFAULT NULL) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE d public.push_deliveries;
BEGIN
 SELECT * INTO d FROM public.push_deliveries WHERE id=delivery AND lease_id=lease FOR UPDATE;
 IF NOT FOUND THEN RETURN; END IF;
 IF outcome='invalid_token' THEN DELETE FROM public.push_devices WHERE id=d.device_id; RETURN; END IF;
 UPDATE public.push_deliveries SET finished_at=CASE WHEN outcome IN ('sent','cancelled') OR attempts>=8 THEN now() ELSE NULL END,
 last_error=left(failure,1000),lease_until=NULL,lease_id=NULL,available_at=now()+make_interval(secs=>least(3600,power(2,attempts)::integer*15))
 WHERE id=delivery AND lease_id=lease;
END; $$;
REVOKE ALL ON FUNCTION public.register_push_device(uuid,text,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.register_push_device(uuid,text,text,text) TO authenticated;
REVOKE ALL ON FUNCTION public.claim_push_deliveries(integer),public.authorize_push_delivery(bigint,uuid),public.finish_push_delivery(bigint,uuid,text,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.claim_push_deliveries(integer),public.authorize_push_delivery(bigint,uuid),public.finish_push_delivery(bigint,uuid,text,text),public.notification_visible(public.notifications,uuid) TO service_role;
COMMIT;
