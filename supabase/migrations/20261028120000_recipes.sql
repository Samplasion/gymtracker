-- Private recipe definitions. Access goes through the revisioned, owner-scoped sync API.
CREATE TABLE public.recipes (
 user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 id text NOT NULL,
 json_data text NOT NULL,
 updated_at timestamptz NOT NULL DEFAULT now(),
 deleted boolean NOT NULL DEFAULT false,
 revision bigint NOT NULL DEFAULT 0,
 PRIMARY KEY(user_id,id),
 CHECK (jsonb_typeof(json_data::jsonb) = 'object'),
 CHECK (coalesce(jsonb_typeof(json_data::jsonb->'name') = 'string' AND length(trim(json_data::jsonb->>'name')) > 0,false)),
 CHECK (coalesce(jsonb_typeof(json_data::jsonb->'servings') = 'number' AND (json_data::jsonb->>'servings')::numeric BETWEEN 1 AND 32 AND mod((json_data::jsonb->>'servings')::numeric,1)=0,false)),
 CHECK (coalesce(jsonb_typeof(json_data::jsonb->'ingredients') = 'array' AND jsonb_array_length(json_data::jsonb->'ingredients') > 0,false))
);
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
CREATE TRIGGER z_sync_assign_v2 BEFORE INSERT OR UPDATE ON public.recipes FOR EACH ROW EXECUTE FUNCTION public.sync_assign_revision_v2();
CREATE TRIGGER z_sync_record_v2 AFTER INSERT OR UPDATE ON public.recipes FOR EACH ROW EXECUTE FUNCTION public.sync_record_change_v2();
REVOKE ALL ON public.recipes FROM anon,authenticated;
GRANT ALL ON public.recipes TO service_role;

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
   IF ent NOT IN ('routine_folders','routines','custom_exercises','routine_exercises','history_workouts','history_workout_exercises','weight_measurements','body_measurements','foods','custom_barcode_foods','favorite_foods','nutrition_goals','nutrition_categories','achievements_v2','water_logs','recipes') OR ent IS NULL OR op->>'record_id' IS NULL OR op->>'base_revision' IS NULL OR (op->>'base_revision')::bigint<0 OR jsonb_typeof(op->'payload') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Invalid operation'; END IF;
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
     IF ent='nutrition_goals' AND NOT (normalized ? 'water') THEN
       normalized:=normalized||jsonb_build_object('water',current_row->'water');
     END IF;
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

