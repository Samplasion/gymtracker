BEGIN;
ALTER TABLE public.history_workouts ADD COLUMN visibility text NOT NULL DEFAULT 'friends' CHECK (visibility IN ('private','friends')),
 ADD COLUMN publication_manifest text;
ALTER TABLE public.history_workout_exercises ADD COLUMN publication_version text;

CREATE TABLE public.user_blocks (
 blocker_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 blocked_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 created_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY(blocker_id,blocked_id), CHECK(blocker_id<>blocked_id));
CREATE INDEX user_blocks_reverse ON public.user_blocks(blocked_id,blocker_id);
CREATE FUNCTION public.social_blocked(a uuid,b uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT EXISTS(SELECT 1 FROM public.user_blocks WHERE (blocker_id=a AND blocked_id=b) OR (blocker_id=b AND blocked_id=a)); $$;
CREATE TABLE public.public_posts (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 kind text NOT NULL CHECK(kind IN ('workout','achievement')), source_id text NOT NULL,
 occurred_at timestamptz NOT NULL, active boolean NOT NULL DEFAULT true,
 UNIQUE(user_id,kind,source_id));
CREATE INDEX public_posts_feed ON public.public_posts(user_id,occurred_at DESC,id) WHERE active;
CREATE FUNCTION public.can_read_post(post uuid, viewer uuid DEFAULT auth.uid()) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT viewer IS NOT NULL AND EXISTS(SELECT 1 FROM public.public_posts p WHERE p.id=post AND
 (p.user_id=viewer OR (p.active AND public.are_friends(viewer,p.user_id) AND NOT public.social_blocked(viewer,p.user_id)))); $$;
CREATE TABLE public.likes (
 post_id uuid NOT NULL REFERENCES public.public_posts ON DELETE CASCADE,
 user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users ON DELETE CASCADE,
 created_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY(post_id,user_id));
CREATE TABLE public.comments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), post_id uuid NOT NULL REFERENCES public.public_posts ON DELETE CASCADE,
 user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users ON DELETE CASCADE,
 body text NOT NULL CHECK(char_length(btrim(body)) BETWEEN 1 AND 2000),
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now());
CREATE INDEX comments_page ON public.comments(post_id,created_at,id);
CREATE TABLE public.reports (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), reporter_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 reported_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, reason text NOT NULL CHECK(char_length(btrim(reason)) BETWEEN 1 AND 2000),
 status text NOT NULL DEFAULT 'received' CHECK(status IN ('received','reviewing','resolved','dismissed')),
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), metadata jsonb NOT NULL DEFAULT '{}',
 CHECK(reporter_id<>reported_id));
-- Internal notes live outside client-readable reports.
CREATE TABLE public.report_notes (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), report_id uuid NOT NULL REFERENCES public.reports ON DELETE CASCADE, body text NOT NULL, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE public.notifications (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 kind text NOT NULL CHECK(kind IN ('friend_request','friend_accepted','like','comment','achievement','report_status')),
 actor_id uuid REFERENCES auth.users ON DELETE CASCADE, post_id uuid REFERENCES public.public_posts ON DELETE CASCADE,
 report_id uuid REFERENCES public.reports ON DELETE CASCADE, comment_id uuid REFERENCES public.comments ON DELETE CASCADE,
 params jsonb NOT NULL DEFAULT '{}', event_key text NOT NULL UNIQUE, created_at timestamptz NOT NULL DEFAULT now(), read_at timestamptz);
CREATE INDEX notifications_owner ON public.notifications(user_id,id DESC);
CREATE TABLE public.push_devices (
 id uuid PRIMARY KEY, user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
 token text NOT NULL UNIQUE, platform text NOT NULL CHECK(platform IN ('ios','android')),
 locale text NOT NULL DEFAULT 'en', updated_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE public.push_deliveries (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, notification_id bigint NOT NULL REFERENCES public.notifications ON DELETE CASCADE,
 device_id uuid NOT NULL REFERENCES public.push_devices ON DELETE CASCADE, attempts integer NOT NULL DEFAULT 0,
 available_at timestamptz NOT NULL DEFAULT now(), lease_until timestamptz, lease_id uuid, finished_at timestamptz, last_error text,
 UNIQUE(notification_id,device_id));
CREATE INDEX push_pending ON public.push_deliveries(available_at) WHERE finished_at IS NULL;

CREATE FUNCTION public.reconcile_workout_post(owner uuid, workout text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE w public.history_workouts; ready boolean; manifest jsonb;
BEGIN
 SELECT * INTO w FROM public.history_workouts WHERE user_id=owner AND id=workout;
 IF NOT FOUND OR w.deleted THEN DELETE FROM public.public_posts WHERE user_id=owner AND kind='workout' AND source_id=workout; RETURN; END IF;
 manifest:=w.publication_manifest::jsonb;
 ready:=w.visibility='friends';
 IF manifest IS NOT NULL THEN
  ready:=ready AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(manifest->'ids') x WHERE NOT EXISTS(
   SELECT 1 FROM public.history_workout_exercises e WHERE e.user_id=owner AND e.routine_id=workout AND e.id=x AND NOT e.deleted AND e.publication_version=manifest->>'version'));
 END IF;
 IF ready THEN
  INSERT INTO public.public_posts(user_id,kind,source_id,occurred_at) VALUES(owner,'workout',workout,w.starting_date)
  ON CONFLICT(user_id,kind,source_id) DO UPDATE SET active=true,occurred_at=EXCLUDED.occurred_at;
 ELSE UPDATE public.public_posts SET active=false WHERE user_id=owner AND kind='workout' AND source_id=workout; END IF;
END; $$;
CREATE FUNCTION public.reconcile_social_source() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF TG_TABLE_NAME='history_workout_exercises' THEN PERFORM public.reconcile_workout_post(OLD.user_id,OLD.routine_id);
  ELSE DELETE FROM public.public_posts WHERE user_id=OLD.user_id AND source_id=OLD.id AND kind=CASE WHEN TG_TABLE_NAME='achievements_v2' THEN 'achievement' ELSE 'workout' END; END IF;
  RETURN OLD;
 END IF;
 IF TG_TABLE_NAME='achievements_v2' THEN
  IF NEW.deleted THEN DELETE FROM public.public_posts WHERE user_id=NEW.user_id AND kind='achievement' AND source_id=NEW.id;
  ELSE INSERT INTO public.public_posts(user_id,kind,source_id,occurred_at) VALUES(NEW.user_id,'achievement',NEW.id,NEW.completed_at)
   ON CONFLICT(user_id,kind,source_id) DO UPDATE SET occurred_at=EXCLUDED.occurred_at; END IF;
 ELSE
  PERFORM public.reconcile_workout_post(NEW.user_id,CASE WHEN TG_TABLE_NAME='history_workouts' THEN to_jsonb(NEW)->>'id' ELSE to_jsonb(NEW)->>'routine_id' END);
 END IF;
 RETURN NEW;
END; $$;
CREATE TRIGGER social_source AFTER INSERT OR UPDATE OR DELETE ON public.achievements_v2 FOR EACH ROW EXECUTE FUNCTION public.reconcile_social_source();
CREATE TRIGGER social_source AFTER INSERT OR UPDATE OR DELETE ON public.history_workouts FOR EACH ROW EXECUTE FUNCTION public.reconcile_social_source();
CREATE TRIGGER social_source AFTER INSERT OR UPDATE OR DELETE ON public.history_workout_exercises FOR EACH ROW EXECUTE FUNCTION public.reconcile_social_source();
-- Backfill before installing notification triggers: no historical fan-out.
INSERT INTO public.public_posts(user_id,kind,source_id,occurred_at) SELECT user_id,'achievement',id,completed_at FROM public.achievements_v2 WHERE NOT deleted;
INSERT INTO public.public_posts(user_id,kind,source_id,occurred_at) SELECT user_id,'workout',id,starting_date FROM public.history_workouts WHERE NOT deleted;
CREATE OR REPLACE FUNCTION public.sync_push_v2(operations jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); op jsonb; previous public.sync_receipts_v2; current_row jsonb; result jsonb:='[]'; receipt jsonb; ent text; cols text; vals text; assignments text; oid uuid; current_revision bigint; normalized jsonb;
BEGIN
 IF owner IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 IF jsonb_typeof(operations)<>'array' OR jsonb_array_length(operations)>100 THEN RAISE EXCEPTION 'Invalid operation batch'; END IF;
 INSERT INTO public.sync_accounts_v2(user_id) VALUES(owner) ON CONFLICT DO NOTHING;
 PERFORM 1 FROM public.sync_accounts_v2 WHERE user_id=owner FOR UPDATE;
 PERFORM set_config('gymtracker.sync_v2','on',true);
 FOR op IN SELECT value FROM jsonb_array_elements(operations) LOOP
   oid:=(op->>'operation_id')::uuid; ent:=op->>'entity';
   IF ent NOT IN ('routine_folders','routines','custom_exercises','routine_exercises','history_workouts','history_workout_exercises','weight_measurements','body_measurements','foods','custom_barcode_foods','favorite_foods','nutrition_goals','nutrition_categories','achievements_v2') OR ent IS NULL OR op->>'record_id' IS NULL OR op->>'base_revision' IS NULL OR (op->>'base_revision')::bigint<0 OR jsonb_typeof(op->'payload') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Invalid operation'; END IF;
   IF (op->'payload'->>'user_id')::uuid IS DISTINCT FROM owner OR op->'payload'->>'id' IS DISTINCT FROM op->>'record_id' THEN RAISE EXCEPTION 'Unexpected owner or ID' USING ERRCODE='42501'; END IF;
   SELECT * INTO previous FROM public.sync_receipts_v2 WHERE user_id=owner AND operation_id=oid;
   IF FOUND THEN
     IF previous.request<>op THEN RAISE EXCEPTION 'Operation ID reused with different contents'; END IF;
     result:=result||jsonb_build_array(previous.receipt); CONTINUE;
   END IF;
   EXECUTE format('SELECT to_jsonb(t) FROM public.%I t WHERE user_id=$1 AND id::text=$2',ent) INTO current_row USING owner,op->>'record_id';
   current_revision:=COALESCE((current_row->>'revision')::bigint,0);
   IF current_revision<>(op->>'base_revision')::bigint THEN
     receipt:=jsonb_build_object('operation_id',op->>'operation_id','status','conflict','revision',current_revision,'payload',COALESCE(current_row,'{}'));
   ELSE
     normalized:=op->'payload';
     IF ent='history_workouts' THEN
       normalized:=normalized||jsonb_build_object('visibility',coalesce(nullif(normalized->>'visibility',''),current_row->>'visibility','friends'),
         'publication_manifest',coalesce(normalized->>'publication_manifest',current_row->>'publication_manifest'));
     ELSIF ent='history_workout_exercises' THEN
       normalized:=normalized||jsonb_build_object('publication_version',coalesce(normalized->>'publication_version',current_row->>'publication_version'));
     END IF;
     -- Accept only actual, non-generated business columns; reject unknown keys.
     IF EXISTS(SELECT 1 FROM jsonb_object_keys(op->'payload') k WHERE NOT EXISTS(SELECT 1 FROM information_schema.columns c WHERE c.table_schema='public' AND c.table_name=ent AND c.column_name=k AND c.is_generated='NEVER')) THEN RAISE EXCEPTION 'Unknown payload field'; END IF;
     SELECT string_agg(format('%I',column_name),',' ORDER BY ordinal_position),string_agg(format('p.%I',column_name),',' ORDER BY ordinal_position),string_agg(format('%1$I=EXCLUDED.%1$I',column_name),',' ORDER BY ordinal_position)
       INTO cols,vals,assignments FROM information_schema.columns WHERE table_schema='public' AND table_name=ent AND column_name NOT IN ('revision') AND is_generated='NEVER';
     BEGIN
     EXECUTE format('INSERT INTO public.%1$I(%2$s) SELECT %3$s FROM jsonb_populate_record(NULL::public.%1$I,$1) p ON CONFLICT(user_id,id) DO UPDATE SET %4$s RETURNING to_jsonb(%1$I.*)',ent,cols,vals,assignments) INTO current_row USING normalized;
     IF current_row IS NULL THEN RAISE EXCEPTION 'Write not confirmed'; END IF;
     receipt:=jsonb_build_object('operation_id',op->>'operation_id','status','applied','revision',current_row->'revision','payload',current_row);
     EXCEPTION WHEN data_exception OR integrity_constraint_violation THEN
       receipt:=jsonb_build_object('operation_id',op->>'operation_id','status','error','code',SQLSTATE,'revision',current_revision,'payload',COALESCE(current_row,'{}'));
     END;
   END IF;
   IF receipt->>'status'<>'error' THEN INSERT INTO public.sync_receipts_v2 VALUES(owner,oid,op,receipt); END IF;
   result:=result||jsonb_build_array(receipt);
 END LOOP;
 RETURN result;
END; $$;


-- Restrictive gates also protect projects where legacy direct-table sync has
-- not yet been revoked with activate_sync_v2(). Existing permissive owner and
-- friend policies must never bypass post visibility.
CREATE POLICY history_social_gate ON public.history_workouts AS RESTRICTIVE FOR SELECT TO authenticated
 USING(user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=history_workouts.user_id AND p.kind='workout' AND p.source_id=history_workouts.id AND p.active AND public.can_read_post(p.id)));
CREATE POLICY exercises_social_gate ON public.history_workout_exercises AS RESTRICTIVE FOR SELECT TO authenticated
 USING(user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts p JOIN public.history_workouts w ON w.user_id=p.user_id AND w.id=p.source_id
 WHERE p.user_id=history_workout_exercises.user_id AND p.kind='workout' AND p.source_id=history_workout_exercises.routine_id AND p.active AND public.can_read_post(p.id)
 AND (w.publication_manifest IS NULL OR (w.publication_manifest::jsonb->'ids') ? history_workout_exercises.id)));
CREATE POLICY achievements_social_gate ON public.achievements_v2 AS RESTRICTIVE FOR SELECT TO authenticated
 USING(user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=achievements_v2.user_id AND p.kind='achievement' AND p.source_id=achievements_v2.id AND p.active AND public.can_read_post(p.id)));
-- All social reads, including direct table reads, apply the same access rules.
ALTER TABLE public.public_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_deliveries ENABLE ROW LEVEL SECURITY;
CREATE POLICY posts_read ON public.public_posts FOR SELECT TO authenticated USING(public.can_read_post(id));
CREATE POLICY likes_read ON public.likes FOR SELECT TO authenticated USING(public.can_read_post(post_id) AND NOT public.social_blocked(auth.uid(),user_id));
CREATE POLICY likes_insert ON public.likes FOR INSERT TO authenticated WITH CHECK(user_id=auth.uid() AND public.can_read_post(post_id) AND EXISTS(SELECT 1 FROM public.public_posts WHERE id=post_id AND active));
CREATE POLICY likes_delete ON public.likes FOR DELETE TO authenticated USING(user_id=auth.uid());
CREATE POLICY comments_read ON public.comments FOR SELECT TO authenticated USING(public.can_read_post(post_id) AND NOT public.social_blocked(auth.uid(),user_id));
CREATE POLICY comments_insert ON public.comments FOR INSERT TO authenticated WITH CHECK(user_id=auth.uid() AND public.can_read_post(post_id) AND EXISTS(SELECT 1 FROM public.public_posts WHERE id=post_id AND active));
CREATE POLICY comments_update ON public.comments FOR UPDATE TO authenticated USING(user_id=auth.uid() AND public.can_read_post(post_id)) WITH CHECK(user_id=auth.uid() AND public.can_read_post(post_id));
CREATE POLICY comments_delete ON public.comments FOR DELETE TO authenticated USING(public.can_read_post(post_id) AND (user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts WHERE id=post_id AND user_id=auth.uid())));
CREATE POLICY blocks_read ON public.user_blocks FOR SELECT TO authenticated USING(blocker_id=auth.uid());
CREATE POLICY reports_read ON public.reports FOR SELECT TO authenticated USING(reporter_id=auth.uid());
CREATE POLICY devices_owner ON public.push_devices FOR ALL TO authenticated USING(user_id=auth.uid()) WITH CHECK(user_id=auth.uid());
DROP POLICY "Profiles are publicly viewable" ON public.profiles;
CREATE POLICY profiles_social_read ON public.profiles FOR SELECT TO authenticated USING(NOT public.social_blocked(auth.uid(),id));
CREATE POLICY friends_block_gate ON public.friends AS RESTRICTIVE FOR ALL TO authenticated USING(NOT public.social_blocked(sender_id,receiver_id)) WITH CHECK(NOT public.social_blocked(sender_id,receiver_id));

CREATE FUNCTION public.guard_friendship() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 PERFORM pg_advisory_xact_lock(hashtextextended(least(NEW.sender_id,NEW.receiver_id)::text||greatest(NEW.sender_id,NEW.receiver_id)::text,0));
 IF NEW.sender_id=NEW.receiver_id OR public.social_blocked(NEW.sender_id,NEW.receiver_id) THEN RAISE EXCEPTION 'Relationship unavailable' USING ERRCODE='42501'; END IF;
 IF auth.uid() IS NOT NULL THEN
  IF TG_OP='INSERT' AND (NEW.sender_id<>auth.uid() OR NEW.status<>'pending') THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='42501'; END IF;
  IF TG_OP='UPDATE' AND (NEW.sender_id<>OLD.sender_id OR NEW.receiver_id<>OLD.receiver_id OR OLD.status<>'pending' OR NEW.status<>'accepted' OR OLD.receiver_id<>auth.uid()) THEN RAISE EXCEPTION 'Invalid acceptance' USING ERRCODE='42501'; END IF;
 END IF;
 IF TG_OP='INSERT' AND EXISTS(SELECT 1 FROM public.friends WHERE sender_id=NEW.receiver_id AND receiver_id=NEW.sender_id) THEN RAISE EXCEPTION 'Request already exists' USING ERRCODE='23505'; END IF;
 RETURN NEW;
END; $$;
CREATE TRIGGER social_guard BEFORE INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION public.guard_friendship();
CREATE FUNCTION public.set_user_block(target uuid, blocked boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid();
BEGIN
 IF owner IS NULL OR target IS NULL OR target=owner THEN RAISE EXCEPTION 'Invalid account' USING ERRCODE='42501'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(least(owner,target)::text||greatest(owner,target)::text,0));
 IF blocked THEN
  INSERT INTO public.user_blocks VALUES(owner,target,now()) ON CONFLICT DO NOTHING;
  DELETE FROM public.friends WHERE (sender_id=owner AND receiver_id=target) OR (sender_id=target AND receiver_id=owner);
  DELETE FROM public.notifications WHERE (user_id=owner AND actor_id=target) OR (user_id=target AND actor_id=owner);
 ELSE DELETE FROM public.user_blocks WHERE blocker_id=owner AND blocked_id=target; END IF;
END; $$;
CREATE FUNCTION public.submit_report(target uuid, reason text) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE result uuid;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 INSERT INTO public.reports(reporter_id,reported_id,reason,metadata) VALUES(auth.uid(),target,btrim(reason),jsonb_build_object('source','app')) RETURNING id INTO result;
 RETURN result;
END; $$;
CREATE FUNCTION public.social_comment_guard() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
 IF TG_OP='UPDATE' AND (NEW.id<>OLD.id OR NEW.user_id<>OLD.user_id OR NEW.post_id<>OLD.post_id OR NEW.created_at<>OLD.created_at) THEN RAISE EXCEPTION 'Immutable comment fields'; END IF;
 NEW.body:=btrim(NEW.body); NEW.updated_at:=clock_timestamp(); RETURN NEW;
END; $$;
CREATE TRIGGER comment_guard BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.social_comment_guard();
CREATE FUNCTION public.notification_visible(n public.notifications, viewer uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT n.user_id=viewer AND NOT public.social_blocked(viewer,n.actor_id)
 AND (n.post_id IS NULL OR public.can_read_post(n.post_id,viewer))
 AND (n.kind<>'friend_request' OR EXISTS(SELECT 1 FROM public.friends WHERE sender_id=n.actor_id AND receiver_id=viewer AND status='pending'))
 AND (n.kind<>'friend_accepted' OR public.are_friends(viewer,n.actor_id)); $$;
CREATE POLICY notifications_read ON public.notifications FOR SELECT TO authenticated USING(public.notification_visible(notifications,auth.uid()));
CREATE FUNCTION public.enqueue_notification(recipient uuid, event text, actor uuid, post uuid, report uuid, comment uuid, data jsonb, dedupe text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE nid bigint;
BEGIN
 IF recipient=actor OR public.social_blocked(recipient,actor) THEN RETURN; END IF;
 INSERT INTO public.notifications(user_id,kind,actor_id,post_id,report_id,comment_id,params,event_key) VALUES(recipient,event,actor,post,report,comment,data,dedupe) ON CONFLICT(event_key) DO NOTHING RETURNING id INTO nid;
 IF nid IS NOT NULL THEN INSERT INTO public.push_deliveries(notification_id,device_id) SELECT nid,id FROM public.push_devices WHERE user_id=recipient; END IF;
END; $$;
CREATE FUNCTION public.social_notification_event() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE recipient uuid; post public.public_posts; data jsonb; dedupe text;
BEGIN
 IF TG_TABLE_NAME='friends' THEN
  IF TG_OP='INSERT' THEN
   PERFORM public.enqueue_notification(NEW.receiver_id,'friend_request',NEW.sender_id,NULL,NULL,NULL,'{}','request:'||gen_random_uuid());
  ELSIF OLD.status='pending' AND NEW.status='accepted' THEN
   PERFORM public.enqueue_notification(NEW.sender_id,'friend_accepted',NEW.receiver_id,NULL,NULL,NULL,'{}','accepted:'||gen_random_uuid());
  END IF;
 ELSIF TG_TABLE_NAME='public_posts' THEN
  IF NEW.kind='achievement' THEN
   SELECT jsonb_build_object('achievement_id',a.achievement_id,'level',a.level) INTO data FROM public.achievements_v2 a WHERE a.user_id=NEW.user_id AND a.id=NEW.source_id;
   FOR recipient IN SELECT CASE WHEN sender_id=NEW.user_id THEN receiver_id ELSE sender_id END FROM public.friends WHERE status='accepted' AND (sender_id=NEW.user_id OR receiver_id=NEW.user_id) LOOP
    PERFORM public.enqueue_notification(recipient,'achievement',NEW.user_id,NEW.id,NULL,NULL,data,'achievement:'||NEW.user_id||':'||NEW.source_id||':'||recipient);
   END LOOP;
  END IF;
 ELSIF TG_TABLE_NAME='reports' THEN
  NEW.updated_at:=clock_timestamp();
  IF NEW.status<>OLD.status THEN
   PERFORM public.enqueue_notification(NEW.reporter_id,'report_status',NULL,NULL,NEW.id,NULL,jsonb_build_object('status',NEW.status),'report:'||NEW.id||':'||gen_random_uuid());
  END IF;
 ELSE
  SELECT * INTO post FROM public.public_posts WHERE id=NEW.post_id;
  PERFORM public.enqueue_notification(post.user_id,CASE WHEN TG_TABLE_NAME='likes' THEN 'like' ELSE 'comment' END,NEW.user_id,post.id,NULL,
   CASE WHEN TG_TABLE_NAME='comments' THEN (to_jsonb(NEW)->>'id')::uuid ELSE NULL END,'{}',
   CASE WHEN TG_TABLE_NAME='likes' THEN 'like:'||NEW.post_id||':'||NEW.user_id ELSE 'comment:'||(to_jsonb(NEW)->>'id') END);
 END IF;
 RETURN NEW;
END; $$;
CREATE TRIGGER social_notification AFTER INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION public.social_notification_event();
CREATE TRIGGER social_notification AFTER INSERT ON public.public_posts FOR EACH ROW EXECUTE FUNCTION public.social_notification_event();
CREATE TRIGGER social_notification AFTER INSERT ON public.likes FOR EACH ROW EXECUTE FUNCTION public.social_notification_event();
CREATE TRIGGER social_notification AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.social_notification_event();
CREATE TRIGGER social_notification BEFORE UPDATE ON public.reports FOR EACH ROW EXECUTE FUNCTION public.social_notification_event();

CREATE FUNCTION public.read_notifications(through_id bigint) RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path='' AS $$
 UPDATE public.notifications SET read_at=clock_timestamp() WHERE user_id=auth.uid() AND id<=through_id AND read_at IS NULL; $$;
CREATE FUNCTION public.get_post_social(post uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path='' AS $$
DECLARE p public.public_posts;
BEGIN
 SELECT * INTO p FROM public.public_posts WHERE id=post;
 IF NOT FOUND THEN RAISE EXCEPTION 'Post unavailable' USING ERRCODE='42501'; END IF;
 RETURN jsonb_build_object('post',to_jsonb(p),'likes',(SELECT count(*) FROM public.likes WHERE post_id=post),
 'liked',EXISTS(SELECT 1 FROM public.likes WHERE post_id=post AND user_id=auth.uid()),'comments',(SELECT count(*) FROM public.comments WHERE post_id=post));
END; $$;
CREATE FUNCTION public.list_post_comments(post uuid, after_at timestamptz DEFAULT NULL, after_id uuid DEFAULT NULL) RETURNS SETOF public.comments LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$
 SELECT * FROM public.comments WHERE post_id=post AND (after_at IS NULL OR (created_at,id)>(after_at,after_id)) ORDER BY created_at,id LIMIT 50; $$;

REVOKE ALL ON public.public_posts,public.likes,public.comments,public.user_blocks,public.reports,public.report_notes,public.notifications,public.push_devices,public.push_deliveries FROM anon,authenticated;
GRANT SELECT ON public.public_posts,public.likes,public.comments,public.user_blocks,public.reports,public.notifications,public.push_devices TO authenticated;
GRANT INSERT,DELETE ON public.likes TO authenticated;
GRANT INSERT(post_id,user_id,body),UPDATE(body) ON public.comments TO authenticated;
GRANT DELETE ON public.comments TO authenticated;
GRANT INSERT,UPDATE,DELETE ON public.push_devices TO authenticated;
GRANT ALL ON public.public_posts,public.likes,public.comments,public.user_blocks,public.reports,public.report_notes,public.notifications,public.push_devices,public.push_deliveries TO service_role;
GRANT USAGE,SELECT ON SEQUENCE public.notifications_id_seq,public.push_deliveries_id_seq TO service_role;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications,public.user_blocks;
CREATE OR REPLACE FUNCTION public.get_friends_feed(start_at timestamptz,end_at timestamptz)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 IF start_at>=end_at THEN RAISE EXCEPTION 'Invalid interval'; END IF;
 WITH friends AS (
   SELECT DISTINCT CASE WHEN sender_id=auth.uid() THEN receiver_id ELSE sender_id END AS id
   FROM public.friends WHERE status='accepted' AND NOT public.social_blocked(sender_id,receiver_id) AND (sender_id=auth.uid() OR receiver_id=auth.uid())
 ), workouts AS (
   SELECT w.* FROM public.history_workouts w JOIN friends f ON w.user_id=f.id
   WHERE NOT w.deleted AND EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=w.user_id AND p.source_id=w.id AND p.kind='workout' AND p.active) AND w.starting_date>=start_at AND w.starting_date<end_at
 ), achievements AS (
   SELECT a.* FROM public.achievements_v2 a JOIN friends f ON a.user_id=f.id
   WHERE NOT a.deleted AND EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=a.user_id AND p.source_id=a.id AND p.kind='achievement' AND p.active) AND a.completed_at>=start_at AND a.completed_at<end_at
 ), authors AS (SELECT user_id FROM workouts UNION SELECT user_id FROM achievements), older AS (
   SELECT max(w.starting_date) AS at FROM public.history_workouts w JOIN friends f ON w.user_id=f.id WHERE NOT w.deleted AND EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=w.user_id AND p.source_id=w.id AND p.kind='workout' AND p.active) AND w.starting_date<start_at
   UNION ALL SELECT max(a.completed_at) FROM public.achievements_v2 a JOIN friends f ON a.user_id=f.id WHERE NOT a.deleted AND EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=a.user_id AND p.source_id=a.id AND p.kind='achievement' AND p.active) AND a.completed_at<start_at
 )
 SELECT jsonb_build_object(
   'workouts',coalesce((SELECT jsonb_agg(to_jsonb(w)) FROM workouts w),'[]'),
   'achievements',coalesce((SELECT jsonb_agg(to_jsonb(a)) FROM achievements a),'[]'),
   'exercises',coalesce((SELECT jsonb_agg(to_jsonb(e)) FROM public.history_workout_exercises e JOIN workouts w ON e.user_id=w.user_id AND e.routine_id=w.id WHERE NOT e.deleted AND (w.publication_manifest IS NULL OR (w.publication_manifest::jsonb->'ids') ? e.id)),'[]'),
   'profiles',coalesce((SELECT jsonb_agg(jsonb_build_object('id',p.id,'username',p.username,'full_name',p.full_name,'updated_at',p.updated_at)) FROM public.profiles p JOIN authors a ON p.id=a.user_id),'[]'),
   'previous_at',(SELECT max(at) FROM older)) INTO result;
 RETURN result;
END; $$;

CREATE OR REPLACE FUNCTION public.get_public_profile_v2(profile_id uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 IF public.social_blocked(auth.uid(),profile_id) THEN RAISE EXCEPTION 'Profile unavailable' USING ERRCODE='42501'; END IF;
 IF profile_id<>auth.uid() AND NOT public.are_friends(auth.uid(),profile_id) THEN
   RETURN jsonb_build_object('workouts','[]'::jsonb,'exercises','[]'::jsonb,'achievements','[]'::jsonb,'friend_count',0);
 END IF;
 WITH workouts AS (SELECT * FROM public.history_workouts WHERE user_id=profile_id AND NOT deleted AND (profile_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=profile_id AND p.kind='workout' AND p.source_id=history_workouts.id AND p.active)) AND completes IS NULL ORDER BY starting_date DESC,id LIMIT 25), achievements AS (SELECT * FROM public.achievements_v2 WHERE user_id=profile_id AND NOT deleted ORDER BY completed_at DESC,id LIMIT 100)
 SELECT jsonb_build_object(
   'workouts',coalesce((SELECT jsonb_agg(to_jsonb(w)) FROM workouts w),'[]'),
   'achievements',coalesce((SELECT jsonb_agg(to_jsonb(a)) FROM achievements a),'[]'),
   'exercises',coalesce((SELECT jsonb_agg(to_jsonb(e)) FROM public.history_workout_exercises e JOIN workouts w ON e.user_id=w.user_id AND e.routine_id=w.id WHERE NOT e.deleted AND (w.publication_manifest IS NULL OR (w.publication_manifest::jsonb->'ids') ? e.id)),'[]'),
   -- Preserve the existing relationship visibility: caller must participate.
   'friend_count',(SELECT count(*) FROM public.friends WHERE status='accepted' AND (sender_id=profile_id OR receiver_id=profile_id) AND (sender_id=auth.uid() OR receiver_id=auth.uid()))) INTO result;
 RETURN result;
END; $$;
CREATE OR REPLACE FUNCTION public.get_achievement_history(
  profile_id uuid,
  before_completed_at timestamptz DEFAULT NULL,
  before_id text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
  IF auth.uid() IS NULL OR profile_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501';
  END IF;
  IF public.social_blocked(auth.uid(),profile_id) OR (profile_id <> auth.uid() AND NOT public.are_friends(auth.uid(),profile_id)) THEN
    RAISE EXCEPTION 'Friendship required' USING ERRCODE='42501';
  END IF;
  IF (before_completed_at IS NULL) <> (before_id IS NULL) THEN
    RAISE EXCEPTION 'Incomplete cursor' USING ERRCODE='22023';
  END IF;
  WITH candidates AS (
    SELECT a.* FROM public.achievements_v2 a
    WHERE a.user_id=profile_id AND NOT a.deleted AND (profile_id=auth.uid() OR EXISTS(SELECT 1 FROM public.public_posts p WHERE p.user_id=profile_id AND p.kind='achievement' AND p.source_id=a.id AND p.active))
      AND (before_completed_at IS NULL OR (a.completed_at,a.id)<(before_completed_at,before_id))
    ORDER BY a.completed_at DESC,a.id DESC LIMIT 51
  ), page AS (
    SELECT * FROM candidates ORDER BY completed_at DESC,id DESC LIMIT 50
  ), last_item AS (
    SELECT completed_at,id FROM page ORDER BY completed_at ASC,id ASC LIMIT 1
  )
  SELECT jsonb_build_object(
    'items',coalesce((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.completed_at DESC,p.id DESC) FROM page p),'[]'::jsonb),
    'next_cursor',CASE WHEN (SELECT count(*) FROM candidates)>50
      THEN (SELECT jsonb_build_object('completed_at',completed_at,'id',id) FROM last_item)
      ELSE NULL END
  ) INTO result;
  RETURN result;
END; $$;

DO $$ BEGIN
 IF to_regclass('storage.buckets') IS NOT NULL THEN
  UPDATE storage.buckets SET public=false WHERE id='profile_pictures';
 END IF;
END; $$;
CREATE POLICY social_avatar_read ON storage.objects FOR SELECT TO authenticated USING(bucket_id='profile_pictures' AND EXISTS(SELECT 1 FROM public.profiles p WHERE p.id::text=name AND NOT public.social_blocked(auth.uid(),p.id)));
-- Internal definer helpers cannot be called by clients. Keep only the checked API.
REVOKE ALL ON FUNCTION public.reconcile_workout_post(uuid,text),public.reconcile_social_source(),public.guard_friendship(),public.social_comment_guard(),public.enqueue_notification(uuid,text,uuid,uuid,uuid,uuid,jsonb,text),public.social_notification_event(),public.notification_visible(public.notifications,uuid) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.social_blocked(uuid,uuid),public.can_read_post(uuid,uuid),public.set_user_block(uuid,boolean),public.submit_report(uuid,text),public.read_notifications(bigint),public.get_post_social(uuid),public.list_post_comments(uuid,timestamptz,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.social_blocked(uuid,uuid),public.can_read_post(uuid,uuid),public.notification_visible(public.notifications,uuid),public.set_user_block(uuid,boolean),public.submit_report(uuid,text),public.read_notifications(bigint),public.get_post_social(uuid),public.list_post_comments(uuid,timestamptz,uuid) TO authenticated;

CREATE FUNCTION public.get_source_social(owner uuid, source text, source_kind text) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path='' AS $$
DECLARE pid uuid;
BEGIN
 SELECT id INTO pid FROM public.public_posts WHERE user_id=owner AND source_id=source AND kind=source_kind;
 IF pid IS NULL THEN RETURN NULL; END IF;
 RETURN public.get_post_social(pid);
END; $$;
CREATE FUNCTION public.get_social_post(post uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.public_posts; content jsonb; exercises jsonb;
BEGIN
 IF NOT public.can_read_post(post) THEN RAISE EXCEPTION 'Post unavailable' USING ERRCODE='42501'; END IF;
 SELECT * INTO p FROM public.public_posts WHERE id=post;
 IF p.kind='workout' THEN
  SELECT to_jsonb(w) INTO content FROM public.history_workouts w WHERE w.user_id=p.user_id AND w.id=p.source_id AND NOT w.deleted;
  SELECT coalesce(jsonb_agg(to_jsonb(e)),'[]') INTO exercises FROM public.history_workout_exercises e WHERE e.user_id=p.user_id AND e.routine_id=p.source_id AND NOT e.deleted
   AND (content->>'publication_manifest' IS NULL OR ((content->>'publication_manifest')::jsonb->'ids') ? e.id);
 ELSE SELECT to_jsonb(a) INTO content FROM public.achievements_v2 a WHERE a.user_id=p.user_id AND a.id=p.source_id AND NOT a.deleted;
 END IF;
 RETURN jsonb_build_object('post',to_jsonb(p),'content',content,'exercises',coalesce(exercises,'[]'));
END; $$;
CREATE FUNCTION public.list_blocked_users() RETURNS TABLE(id uuid,username text,full_name text) LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT p.id,p.username,p.full_name FROM public.profiles p JOIN public.user_blocks b ON b.blocked_id=p.id WHERE b.blocker_id=auth.uid() ORDER BY b.created_at DESC; $$;
CREATE FUNCTION public.notification_summary() RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$
 SELECT jsonb_build_object('unread',count(*) FILTER(WHERE read_at IS NULL),'through_id',coalesce(max(id),0)) FROM public.notifications; $$;
REVOKE ALL ON FUNCTION public.get_source_social(uuid,text,text),public.get_social_post(uuid),public.list_blocked_users(),public.notification_summary() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.get_source_social(uuid,text,text),public.get_social_post(uuid),public.list_blocked_users(),public.notification_summary() TO authenticated;

CREATE TABLE public.social_revisions(user_id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE, revision bigint NOT NULL DEFAULT 1);
ALTER TABLE public.social_revisions ENABLE ROW LEVEL SECURITY;
CREATE POLICY social_revision_owner ON public.social_revisions FOR SELECT TO authenticated USING(user_id=auth.uid());
REVOKE ALL ON public.social_revisions FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.social_revisions TO authenticated;
GRANT ALL ON public.social_revisions TO service_role;
CREATE FUNCTION public.touch_social_access() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE row_data jsonb; a uuid; b uuid;
BEGIN
 row_data:=CASE WHEN TG_OP='DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END;
 a:=coalesce(row_data->>'sender_id',row_data->>'blocker_id')::uuid;
 b:=coalesce(row_data->>'receiver_id',row_data->>'blocked_id')::uuid;
 INSERT INTO public.social_revisions(user_id) SELECT id FROM auth.users WHERE id IN (a,b) ON CONFLICT(user_id) DO UPDATE SET revision=social_revisions.revision+1;
 RETURN NULL;
END; $$;
CREATE TRIGGER social_access AFTER INSERT OR UPDATE OR DELETE ON public.friends FOR EACH ROW EXECUTE FUNCTION public.touch_social_access();
CREATE TRIGGER social_access AFTER INSERT OR DELETE ON public.user_blocks FOR EACH ROW EXECUTE FUNCTION public.touch_social_access();
REVOKE ALL ON FUNCTION public.touch_social_access() FROM PUBLIC,anon,authenticated;
ALTER PUBLICATION supabase_realtime ADD TABLE public.social_revisions;
CREATE FUNCTION public.touch_post_access() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid;
BEGIN
 IF TG_OP='UPDATE' AND NEW.active=OLD.active AND NEW.occurred_at=OLD.occurred_at THEN RETURN NULL; END IF;
 owner:=CASE WHEN TG_OP='DELETE' THEN OLD.user_id ELSE NEW.user_id END;
 INSERT INTO public.social_revisions(user_id)
 SELECT u.id FROM auth.users u JOIN (
 SELECT owner AS id UNION SELECT CASE WHEN sender_id=owner THEN receiver_id ELSE sender_id END FROM public.friends WHERE status='accepted' AND (sender_id=owner OR receiver_id=owner)
 ) recipients ON recipients.id=u.id
 ON CONFLICT(user_id) DO UPDATE SET revision=social_revisions.revision+1;
 RETURN NULL;
END; $$;
CREATE TRIGGER social_post_access AFTER INSERT OR UPDATE OR DELETE ON public.public_posts FOR EACH ROW EXECUTE FUNCTION public.touch_post_access();
REVOKE ALL ON FUNCTION public.touch_post_access() FROM PUBLIC,anon,authenticated;
COMMIT;
