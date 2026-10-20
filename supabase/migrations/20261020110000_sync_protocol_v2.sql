-- Additive v2 protocol. Activation is deliberately a separate operator action.
BEGIN;
CREATE TABLE public.sync_protocol_v2(singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), active boolean NOT NULL DEFAULT false);
INSERT INTO public.sync_protocol_v2 VALUES(true,false);
CREATE TABLE public.sync_accounts_v2(user_id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE, revision bigint NOT NULL DEFAULT 0);
CREATE TABLE public.sync_changes_v2(user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, revision bigint NOT NULL, entity text NOT NULL, record_id text NOT NULL, payload jsonb NOT NULL, PRIMARY KEY(user_id,revision));
CREATE INDEX sync_changes_record_v2 ON public.sync_changes_v2(user_id,entity,record_id,revision DESC);
CREATE TABLE public.sync_receipts_v2(user_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, operation_id uuid NOT NULL, request jsonb NOT NULL, receipt jsonb NOT NULL, PRIMARY KEY(user_id,operation_id));
ALTER TABLE public.sync_changes_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_receipts_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_accounts_v2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_protocol_v2 ENABLE ROW LEVEL SECURITY;
CREATE POLICY sync_changes_owner_v2 ON public.sync_changes_v2 FOR SELECT TO authenticated USING(user_id=auth.uid());
GRANT SELECT ON public.sync_changes_v2 TO authenticated;

CREATE OR REPLACE FUNCTION public.discard_older_updates() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
  IF current_setting('gymtracker.sync_v2',true)='on' THEN RETURN NEW; END IF;
  IF (SELECT active FROM public.sync_protocol_v2 WHERE singleton) THEN RAISE EXCEPTION 'Update required: sync protocol v2' USING ERRCODE='42501'; END IF;
  IF NEW.updated_at <= OLD.updated_at THEN RETURN NULL; END IF;
  RETURN NEW;
END; $$;

CREATE FUNCTION public.sync_assign_revision_v2() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  IF (SELECT active FROM public.sync_protocol_v2 WHERE singleton) AND current_setting('gymtracker.sync_v2',true) IS DISTINCT FROM 'on' THEN
    RAISE EXCEPTION 'Update required: sync protocol v2' USING ERRCODE='42501';
  END IF;
  INSERT INTO public.sync_accounts_v2(user_id) VALUES(NEW.user_id) ON CONFLICT DO NOTHING;
  UPDATE public.sync_accounts_v2 SET revision=revision+1 WHERE user_id=NEW.user_id RETURNING revision INTO NEW.revision;
  IF current_setting('gymtracker.sync_v2',true)='on' THEN NEW.updated_at=clock_timestamp(); END IF;
  RETURN NEW;
END; $$;
CREATE FUNCTION public.sync_record_change_v2() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  INSERT INTO public.sync_changes_v2 VALUES(NEW.user_id,NEW.revision,TG_TABLE_NAME,NEW.id::text,to_jsonb(NEW));
  RETURN NEW;
END; $$;
ALTER TABLE public.routine_exercises ADD COLUMN IF NOT EXISTS progression jsonb;
ALTER TABLE public.history_workout_exercises ADD COLUMN IF NOT EXISTS progression jsonb;
ALTER TABLE public.routine_folders ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.routine_folders DISABLE TRIGGER USER;
ALTER TABLE public.routines ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.routines DISABLE TRIGGER USER;
ALTER TABLE public.custom_exercises ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.custom_exercises DISABLE TRIGGER USER;
ALTER TABLE public.routine_exercises ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.routine_exercises DISABLE TRIGGER USER;
ALTER TABLE public.history_workouts ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.history_workouts DISABLE TRIGGER USER;
ALTER TABLE public.history_workout_exercises ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.history_workout_exercises DISABLE TRIGGER USER;
ALTER TABLE public.weight_measurements ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.weight_measurements DISABLE TRIGGER USER;
ALTER TABLE public.body_measurements ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.body_measurements DISABLE TRIGGER USER;
ALTER TABLE public.foods ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.foods DISABLE TRIGGER USER;
ALTER TABLE public.custom_barcode_foods ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.custom_barcode_foods DISABLE TRIGGER USER;
ALTER TABLE public.favorite_foods ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.favorite_foods DISABLE TRIGGER USER;
ALTER TABLE public.nutrition_goals ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.nutrition_goals DISABLE TRIGGER USER;
ALTER TABLE public.nutrition_categories ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.nutrition_categories DISABLE TRIGGER USER;
ALTER TABLE public.achievements_v2 ADD COLUMN revision bigint NOT NULL DEFAULT 0;
ALTER TABLE public.achievements_v2 DISABLE TRIGGER USER;
DO $$ DECLARE r record; p jsonb; n bigint; BEGIN
FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename IN ('routine_folders','routines','custom_exercises','routine_exercises','history_workouts','history_workout_exercises','weight_measurements','body_measurements','foods','custom_barcode_foods','favorite_foods','nutrition_goals','nutrition_categories','achievements_v2') ORDER BY tablename LOOP
  FOR p IN EXECUTE format('SELECT to_jsonb(t) FROM public.%I t ORDER BY user_id,id',r.tablename) LOOP
    INSERT INTO public.sync_accounts_v2(user_id) VALUES((p->>'user_id')::uuid) ON CONFLICT DO NOTHING;
    UPDATE public.sync_accounts_v2 SET revision=revision+1 WHERE user_id=(p->>'user_id')::uuid RETURNING revision INTO n;
    EXECUTE format('UPDATE public.%I SET revision=$1 WHERE user_id=$2 AND id::text=$3',r.tablename) USING n,(p->>'user_id')::uuid,p->>'id';
    INSERT INTO public.sync_changes_v2 VALUES((p->>'user_id')::uuid,n,r.tablename,p->>'id',p||jsonb_build_object('revision',n));
  END LOOP;
END LOOP; END; $$;
ALTER TABLE public.routine_folders ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.routine_folders FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.routine_folders FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS routine_folders_owner_id_v2 ON public.routine_folders(user_id,id);
ALTER TABLE public.routines ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.routines FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.routines FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS routines_owner_id_v2 ON public.routines(user_id,id);
ALTER TABLE public.custom_exercises ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.custom_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.custom_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS custom_exercises_owner_id_v2 ON public.custom_exercises(user_id,id);
ALTER TABLE public.routine_exercises ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.routine_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.routine_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS routine_exercises_owner_id_v2 ON public.routine_exercises(user_id,id);
ALTER TABLE public.history_workouts ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.history_workouts FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.history_workouts FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS history_workouts_owner_id_v2 ON public.history_workouts(user_id,id);
ALTER TABLE public.history_workout_exercises ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.history_workout_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.history_workout_exercises FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS history_workout_exercises_owner_id_v2 ON public.history_workout_exercises(user_id,id);
ALTER TABLE public.weight_measurements ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.weight_measurements FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.weight_measurements FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS weight_measurements_owner_id_v2 ON public.weight_measurements(user_id,id);
ALTER TABLE public.body_measurements ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.body_measurements FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.body_measurements FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS body_measurements_owner_id_v2 ON public.body_measurements(user_id,id);
ALTER TABLE public.foods ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.foods FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.foods FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS foods_owner_id_v2 ON public.foods(user_id,id);
ALTER TABLE public.custom_barcode_foods ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.custom_barcode_foods FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.custom_barcode_foods FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS custom_barcode_foods_owner_id_v2 ON public.custom_barcode_foods(user_id,id);
ALTER TABLE public.favorite_foods ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.favorite_foods FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.favorite_foods FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS favorite_foods_owner_id_v2 ON public.favorite_foods(user_id,id);
ALTER TABLE public.nutrition_goals ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.nutrition_goals FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.nutrition_goals FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS nutrition_goals_owner_id_v2 ON public.nutrition_goals(user_id,id);
ALTER TABLE public.nutrition_categories ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.nutrition_categories FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.nutrition_categories FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS nutrition_categories_owner_id_v2 ON public.nutrition_categories(user_id,id);
ALTER TABLE public.achievements_v2 ENABLE TRIGGER USER;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.achievements_v2 FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.achievements_v2 FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
CREATE INDEX IF NOT EXISTS achievements_v2_owner_id_v2 ON public.achievements_v2(user_id,id);

CREATE FUNCTION public.sync_push_v2(operations jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); op jsonb; previous public.sync_receipts_v2; current_row jsonb; result jsonb:='[]'; receipt jsonb; ent text; cols text; vals text; assignments text; oid uuid; current_revision bigint;
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
     -- Accept only actual, non-generated business columns; reject unknown keys.
     IF EXISTS(SELECT 1 FROM jsonb_object_keys(op->'payload') k WHERE NOT EXISTS(SELECT 1 FROM information_schema.columns c WHERE c.table_schema='public' AND c.table_name=ent AND c.column_name=k AND c.is_generated='NEVER')) THEN RAISE EXCEPTION 'Unknown payload field'; END IF;
     SELECT string_agg(format('%I',column_name),',' ORDER BY ordinal_position),string_agg(format('p.%I',column_name),',' ORDER BY ordinal_position),string_agg(format('%1$I=EXCLUDED.%1$I',column_name),',' ORDER BY ordinal_position)
       INTO cols,vals,assignments FROM information_schema.columns WHERE table_schema='public' AND table_name=ent AND column_name NOT IN ('revision') AND is_generated='NEVER';
     BEGIN
     EXECUTE format('INSERT INTO public.%1$I(%2$s) SELECT %3$s FROM jsonb_populate_record(NULL::public.%1$I,$1) p ON CONFLICT(user_id,id) DO UPDATE SET %4$s RETURNING to_jsonb(%1$I.*)',ent,cols,vals,assignments) INTO current_row USING op->'payload';
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

CREATE FUNCTION public.sync_pull_v2(cursor bigint DEFAULT 0,horizon bigint DEFAULT NULL,page_limit integer DEFAULT 500) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); upper_bound bigint; items jsonb; next_cursor bigint;
BEGIN
 IF owner IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 SELECT COALESCE(revision,0) INTO upper_bound FROM public.sync_accounts_v2 WHERE user_id=owner;
 upper_bound:=LEAST(COALESCE(horizon,upper_bound,0),COALESCE(upper_bound,0));
 IF cursor<0 OR cursor>upper_bound THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
 SELECT COALESCE(jsonb_agg(to_jsonb(p) ORDER BY revision),'[]'),COALESCE(max(revision),cursor) INTO items,next_cursor FROM (SELECT revision,entity,record_id,payload FROM public.sync_changes_v2 WHERE user_id=owner AND revision>cursor AND revision<=upper_bound ORDER BY revision LIMIT LEAST(GREATEST(page_limit,1),500)) p;
 RETURN jsonb_build_object('horizon',upper_bound,'cursor',next_cursor,'changes',items,'has_more',EXISTS(SELECT 1 FROM public.sync_changes_v2 WHERE user_id=owner AND revision>next_cursor AND revision<=upper_bound));
END; $$;
CREATE FUNCTION public.sync_reconcile_v2(cursor bigint DEFAULT 0,horizon bigint DEFAULT NULL,page_limit integer DEFAULT 500) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); upper_bound bigint; items jsonb; next_cursor bigint; more boolean;
BEGIN
 IF owner IS NULL THEN RAISE EXCEPTION 'Not authenticated' USING ERRCODE='42501'; END IF;
 SELECT COALESCE(revision,0) INTO upper_bound FROM public.sync_accounts_v2 WHERE user_id=owner;
 upper_bound:=LEAST(COALESCE(horizon,upper_bound,0),COALESCE(upper_bound,0));
 WITH latest AS (SELECT DISTINCT ON(entity,record_id) revision,entity,record_id,payload FROM public.sync_changes_v2 WHERE user_id=owner AND revision<=upper_bound ORDER BY entity,record_id,revision DESC), page AS (SELECT * FROM latest WHERE revision>cursor ORDER BY revision LIMIT LEAST(GREATEST(page_limit,1),500))
 SELECT COALESCE(jsonb_agg(to_jsonb(page) ORDER BY revision),'[]'),COALESCE(max(revision),cursor) INTO items,next_cursor FROM page;
 SELECT EXISTS(SELECT 1 FROM (SELECT DISTINCT ON(entity,record_id) revision FROM public.sync_changes_v2 WHERE user_id=owner AND revision<=upper_bound ORDER BY entity,record_id,revision DESC) t WHERE revision>next_cursor) INTO more;
 RETURN jsonb_build_object('horizon',upper_bound,'cursor',next_cursor,'changes',items,'has_more',more);
END; $$;

-- Separate, reversible gate; do not invoke as part of deploying additive SQL.
CREATE FUNCTION public.activate_sync_v2() RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 UPDATE public.sync_protocol_v2 SET active=true WHERE singleton;
 REVOKE ALL ON public.routine_folders FROM anon,authenticated;
 REVOKE ALL ON public.routines FROM anon,authenticated;
 REVOKE ALL ON public.custom_exercises FROM anon,authenticated;
 REVOKE ALL ON public.routine_exercises FROM anon,authenticated;
 REVOKE ALL ON public.history_workouts FROM anon,authenticated;
 REVOKE ALL ON public.history_workout_exercises FROM anon,authenticated;
 REVOKE ALL ON public.weight_measurements FROM anon,authenticated;
 REVOKE ALL ON public.body_measurements FROM anon,authenticated;
 REVOKE ALL ON public.foods FROM anon,authenticated;
 REVOKE ALL ON public.custom_barcode_foods FROM anon,authenticated;
 REVOKE ALL ON public.favorite_foods FROM anon,authenticated;
 REVOKE ALL ON public.nutrition_goals FROM anon,authenticated;
 REVOKE ALL ON public.nutrition_categories FROM anon,authenticated;
 REVOKE ALL ON public.achievements_v2 FROM anon,authenticated;
END; $$;
REVOKE ALL ON FUNCTION public.activate_sync_v2() FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.activate_sync_v2() TO service_role;
REVOKE ALL ON FUNCTION public.sync_push_v2(jsonb) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.sync_push_v2(jsonb) TO authenticated;
REVOKE ALL ON FUNCTION public.sync_pull_v2(bigint,bigint,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.sync_pull_v2(bigint,bigint,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.sync_reconcile_v2(bigint,bigint,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.sync_reconcile_v2(bigint,bigint,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.sync_assign_revision_v2() FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.sync_record_change_v2() FROM PUBLIC,anon,authenticated;
DO $$ BEGIN IF NOT EXISTS(SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename='sync_changes_v2') THEN ALTER PUBLICATION supabase_realtime ADD TABLE public.sync_changes_v2; END IF; END; $$;
COMMIT;
