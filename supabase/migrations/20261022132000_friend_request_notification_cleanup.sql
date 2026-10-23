BEGIN;

-- Request notifications belong to the pending request's lifetime. Removing or
-- accepting that request must delete its inbox item, not only hide it with RLS.
-- Pending/leased push deliveries disappear through their notification FK.
CREATE FUNCTION public.cleanup_friend_request_notification() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 IF OLD.status<>'pending' THEN RETURN NULL; END IF;
 IF TG_OP='UPDATE' THEN
  IF NEW.status='pending' THEN RETURN NULL; END IF;
 END IF;
 DELETE FROM public.notifications
  WHERE kind='friend_request' AND actor_id=OLD.sender_id AND user_id=OLD.receiver_id;
 RETURN NULL;
END; $$;
REVOKE ALL ON FUNCTION public.cleanup_friend_request_notification() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER friend_request_notification_cleanup
 AFTER DELETE OR UPDATE ON public.friends
 FOR EACH ROW EXECUTE FUNCTION public.cleanup_friend_request_notification();

-- Clean up records left by previous versions. A new request between the same
-- people must never make the old notification reappear or duplicate the badge.
DELETE FROM public.notifications n WHERE n.kind='friend_request' AND NOT EXISTS(
 SELECT 1 FROM public.friends f WHERE f.sender_id=n.actor_id AND f.receiver_id=n.user_id AND f.status='pending'
);
WITH duplicates AS (
 SELECT id,row_number() OVER(PARTITION BY user_id,actor_id ORDER BY id DESC) AS position
 FROM public.notifications WHERE kind='friend_request'
)
DELETE FROM public.notifications n USING duplicates d WHERE n.id=d.id AND d.position>1;

COMMIT;
