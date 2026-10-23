-- Additive MCP capability expansion. Never activates the optional sync gate.
BEGIN;
ALTER TABLE gymbro_mcp.settings ADD COLUMN billing_environment text NOT NULL DEFAULT 'PRODUCTION' CHECK(billing_environment IN ('PRODUCTION','SANDBOX'));
CREATE INDEX foods_mcp_day ON public.foods(user_id,reference_date,id) WHERE NOT deleted;
CREATE INDEX goals_mcp_day ON public.nutrition_goals(user_id,reference_date) WHERE NOT deleted;
CREATE INDEX categories_mcp_day ON public.nutrition_categories(user_id,reference_date) WHERE NOT deleted;
CREATE TABLE gymbro_mcp.consents (
 user_id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
 client_id text NOT NULL, version integer NOT NULL CHECK(version=2),
 time_zone text NOT NULL, approved_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE gymbro_mcp.billing (
 user_id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
 is_pro boolean NOT NULL, expires_at timestamptz, checked_at timestamptz NOT NULL,
 environment text NOT NULL CHECK(environment IN ('PRODUCTION','SANDBOX'))
);
CREATE TABLE gymbro_mcp.webhook_events (id text PRIMARY KEY, received_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE gymbro_mcp.operations (
 user_id uuid REFERENCES auth.users ON DELETE CASCADE,
 idempotency_key uuid, operation text NOT NULL, request jsonb NOT NULL, result jsonb NOT NULL,
 PRIMARY KEY(user_id,idempotency_key)
);
REVOKE ALL ON ALL TABLES IN SCHEMA gymbro_mcp FROM PUBLIC,anon,authenticated,gymbro_mcp_user;

CREATE FUNCTION public.mcp_manage_consent(approve boolean DEFAULT NULL, time_zone text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=auth.uid(); client text;
BEGIN
 IF owner IS NULL OR auth.jwt()->>'role' IS DISTINCT FROM 'authenticated' OR NULLIF(auth.jwt()->>'client_id','') IS NOT NULL THEN
 RAISE EXCEPTION 'Ordinary account session required' USING ERRCODE='42501'; END IF;
 SELECT client_id INTO client FROM gymbro_mcp.settings WHERE singleton;
 IF approve=true THEN
  IF client IS NULL OR time_zone IS NULL OR NOT EXISTS(SELECT 1 FROM pg_timezone_names z WHERE z.name=time_zone) THEN RAISE EXCEPTION 'Invalid timezone' USING ERRCODE='22023'; END IF;
  INSERT INTO gymbro_mcp.consents VALUES(owner,client,2,time_zone,now())
  ON CONFLICT(user_id) DO UPDATE SET client_id=excluded.client_id,version=2,time_zone=excluded.time_zone,approved_at=now();
 ELSIF approve=false THEN DELETE FROM gymbro_mcp.consents WHERE user_id=owner;
 END IF;
 RETURN COALESCE((SELECT jsonb_build_object('version',version,'timeZone',c.time_zone) FROM gymbro_mcp.consents c WHERE user_id=owner AND client_id=client),'{}');
END $$;
REVOKE ALL ON FUNCTION public.mcp_manage_consent(boolean,text) FROM PUBLIC,anon,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.mcp_manage_consent(boolean,text) TO authenticated;

CREATE FUNCTION gymbro_mcp.require_consent() RETURNS uuid LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); BEGIN
 IF NOT EXISTS(SELECT 1 FROM gymbro_mcp.consents c JOIN gymbro_mcp.settings s ON s.client_id=c.client_id WHERE c.user_id=owner AND c.version=2)
 THEN RAISE EXCEPTION 'consent_required' USING ERRCODE='P1001'; END IF;
 RETURN owner;
END $$;
CREATE FUNCTION gymbro_mcp.pro(owner uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE b gymbro_mcp.billing; BEGIN
 SELECT * INTO b FROM gymbro_mcp.billing WHERE user_id=owner;
 IF NOT FOUND OR b.checked_at<now()-interval '5 minutes' OR b.environment IS DISTINCT FROM (SELECT billing_environment FROM gymbro_mcp.settings WHERE singleton) THEN RAISE EXCEPTION 'billing_unavailable' USING ERRCODE='P1002'; END IF;
 RETURN b.is_pro AND (b.expires_at IS NULL OR b.expires_at>now());
END $$;
CREATE FUNCTION public.mcp_billing_status() RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); BEGIN
 RETURN COALESCE((SELECT jsonb_build_object('checkedAt',checked_at,'expiresAt',expires_at,'isPro',is_pro,'environment',environment) FROM gymbro_mcp.billing WHERE user_id=owner),'{}');
END $$;
REVOKE ALL ON FUNCTION public.mcp_billing_status() FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mcp_billing_status() TO gymbro_mcp_user;
-- These endpoints are exclusively for the trusted RevenueCat adapter.
CREATE FUNCTION public.mcp_store_billing(account_id uuid, active boolean, expiration timestamptz, environment text, observed_at timestamptz) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ BEGIN
 IF auth.jwt()->>'role' IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Service required' USING ERRCODE='42501'; END IF;
 IF observed_at>now()+interval '5 seconds' OR observed_at<now()-interval '5 minutes' THEN RAISE EXCEPTION 'Stale observation' USING ERRCODE='22023'; END IF;
 INSERT INTO gymbro_mcp.billing VALUES(account_id,active,expiration,observed_at,environment)
 ON CONFLICT(user_id) DO UPDATE SET is_pro=excluded.is_pro,expires_at=excluded.expires_at,checked_at=excluded.checked_at,environment=excluded.environment
 WHERE gymbro_mcp.billing.checked_at<=excluded.checked_at;
END $$;
CREATE FUNCTION public.mcp_webhook_event(event_id text, complete boolean DEFAULT false) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ BEGIN
 IF auth.jwt()->>'role' IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Service required' USING ERRCODE='42501'; END IF;
 IF length(event_id) NOT BETWEEN 1 AND 300 THEN RAISE EXCEPTION 'Invalid event' USING ERRCODE='22023'; END IF;
 IF complete THEN INSERT INTO gymbro_mcp.webhook_events(id) VALUES(event_id) ON CONFLICT DO NOTHING; RETURN true; END IF;
 RETURN EXISTS(SELECT 1 FROM gymbro_mcp.webhook_events WHERE id=event_id);
END $$;
REVOKE ALL ON FUNCTION public.mcp_store_billing(uuid,boolean,timestamptz,text,timestamptz),public.mcp_webhook_event(text,boolean) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.mcp_store_billing(uuid,boolean,timestamptz,text,timestamptz),public.mcp_webhook_event(text,boolean) TO service_role;

CREATE FUNCTION gymbro_mcp.day(value text) RETURNS date LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
DECLARE d date; BEGIN
 IF value IS NULL OR value !~ '^20[0-9]{2}-[0-9]{2}-[0-9]{2}$' THEN RAISE EXCEPTION 'Invalid date' USING ERRCODE='22023'; END IF;
 d:=value::date; IF to_char(d,'YYYY-MM-DD')<>value THEN RAISE EXCEPTION 'Invalid date' USING ERRCODE='22023'; END IF; RETURN d;
END $$;
CREATE FUNCTION gymbro_mcp.check_days(owner uuid, first_day date, last_day date) RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE today date; BEGIN
 IF first_day IS NULL OR last_day IS NULL OR first_day>last_day OR last_day-first_day>366 THEN RAISE EXCEPTION 'Invalid date range (maximum 367 days)' USING ERRCODE='22023'; END IF;
 SELECT (now() AT TIME ZONE time_zone)::date INTO today FROM gymbro_mcp.consents WHERE user_id=owner;
 IF NOT gymbro_mcp.pro(owner) AND (first_day<today-7 OR last_day>today+7) THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
END $$;
CREATE FUNCTION gymbro_mcp.lock_account(owner uuid) RETURNS void LANGUAGE plpgsql SET search_path='' AS $$ BEGIN
 INSERT INTO public.sync_accounts_v2(user_id) VALUES(owner) ON CONFLICT DO NOTHING;
 PERFORM 1 FROM public.sync_accounts_v2 WHERE user_id=owner FOR UPDATE;
 PERFORM set_config('gymtracker.sync_v2','on',true);
END $$;

CREATE FUNCTION gymbro_mcp.normalize_routine(r jsonb) RETURNS jsonb LANGUAGE plpgsql SET search_path='' AS $$
DECLARE e jsonb; child jsonb; flat jsonb:='[]'; clean jsonb; BEGIN
 PERFORM gymbro_mcp.object_keys(r,ARRAY['name','notes','weightUnit','distanceUnit','exercises','folderId']);
 IF jsonb_typeof(r->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(r->'exercises') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid exercises' USING ERRCODE='22023'; END IF;
 FOR e IN SELECT value FROM jsonb_array_elements(r->'exercises') LOOP
  IF e->>'type'='superset' THEN
   PERFORM gymbro_mcp.object_keys(e,ARRAY['type','notes','restSeconds','exercises']);
   PERFORM gymbro_mcp.text_value(e->'notes',10000);
   PERFORM gymbro_mcp.number_value(e->'restSeconds',86400,true);
   IF jsonb_typeof(e->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(e->'exercises') NOT BETWEEN 2 AND 100 THEN RAISE EXCEPTION 'Invalid superset' USING ERRCODE='22023'; END IF;
   FOR child IN SELECT value FROM jsonb_array_elements(e->'exercises') LOOP
    PERFORM gymbro_mcp.object_keys(child,ARRAY['type','exerciseRef','notes','restSeconds','sets','rpe','progression']);
    IF child ? 'type' AND child->>'type' IS DISTINCT FROM 'exercise' THEN RAISE EXCEPTION 'Nested superset' USING ERRCODE='22023'; END IF;
    flat:=flat||jsonb_build_array(child-ARRAY['type','rpe','progression']);
   END LOOP;
  ELSE
   PERFORM gymbro_mcp.object_keys(e,ARRAY['type','exerciseRef','notes','restSeconds','sets','rpe','progression']);
   IF e ? 'type' AND e->>'type' IS DISTINCT FROM 'exercise' THEN RAISE EXCEPTION 'Invalid entry type' USING ERRCODE='22023'; END IF;
   flat:=flat||jsonb_build_array(e-ARRAY['type','rpe','progression']);
  END IF;
 END LOOP;
 IF jsonb_array_length(flat)>100 THEN RAISE EXCEPTION 'Maximum 100 leaf exercises' USING ERRCODE='22023'; END IF;
 RETURN jsonb_set(r-'folderId','{exercises}',flat);
END $$;

CREATE FUNCTION gymbro_mcp.insert_program(program jsonb, make_folder boolean, destination uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); previous gymbro_mcp.receipts; folder_id uuid:=gen_random_uuid(); routine_id text; exercise_id text;
 routine jsonb; exercise jsonb; reference jsonb; definition jsonb; item jsonb; normalized_sets jsonb; routines_result jsonb:='[]'; result jsonb;
 folder_name text; routine_name text; notes text; exercise_notes text; info text; weight_unit text; distance_unit text; parameters text; kind text;
 repetitions numeric; weight numeric; duration numeric; distance numeric; perceived numeric; rest numeric; routine_order integer:=0; exercise_order integer; folder_order integer; catalog jsonb;
BEGIN
 IF octet_length(program::text)>1048576 THEN RAISE EXCEPTION 'Invalid program' USING ERRCODE='22023'; END IF;
 PERFORM gymbro_mcp.object_keys(program,ARRAY['name','notes','routines']);
 folder_name:=gymbro_mcp.text_value(program->'name',200,true);
 notes:=gymbro_mcp.text_value(program->'notes',10000);
 IF jsonb_typeof(program->'routines') IS DISTINCT FROM 'array' OR jsonb_array_length(program->'routines') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid routines' USING ERRCODE='22023'; END IF;
 SELECT exercises INTO catalog FROM gymbro_mcp.catalog WHERE singleton;
 IF catalog IS NULL THEN RAISE EXCEPTION 'Catalog not configured'; END IF;
 PERFORM set_config('gymtracker.sync_v2','on',true);
 IF make_folder THEN
 SELECT COALESCE(max(sort_order)+1,0) INTO folder_order FROM public.routine_folders WHERE user_id=owner AND NOT deleted;
 INSERT INTO public.routine_folders(id,user_id,name,notes,sort_order) VALUES(folder_id,owner,folder_name,notes,folder_order);
 ELSE folder_id:=destination; END IF;
 SELECT COALESCE(max(sort_order)+1,0) INTO routine_order FROM public.routines rr WHERE rr.user_id=owner AND rr.folder_id IS NOT DISTINCT FROM destination AND NOT deleted;
 FOR routine IN SELECT value FROM jsonb_array_elements(program->'routines') LOOP
  PERFORM gymbro_mcp.object_keys(routine,ARRAY['name','notes','weightUnit','distanceUnit','exercises']);
  routine_name:=gymbro_mcp.text_value(routine->'name',200,true);
  info:=gymbro_mcp.text_value(routine->'notes',10000);
  weight_unit:=COALESCE(routine->>'weightUnit','kg'); distance_unit:=COALESCE(routine->>'distanceUnit','km');
  IF (routine ? 'weightUnit' AND jsonb_typeof(routine->'weightUnit')<>'string') OR (routine ? 'distanceUnit' AND jsonb_typeof(routine->'distanceUnit')<>'string') OR weight_unit NOT IN ('kg','lb') OR distance_unit NOT IN ('km','mi') OR jsonb_typeof(routine->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(routine->'exercises') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid routine' USING ERRCODE='22023'; END IF;
  routine_id:=gen_random_uuid()::text;
  INSERT INTO public.routines(id,user_id,name,infobox,weight_unit,distance_unit,folder_id,sort_order)
  VALUES(routine_id,owner,routine_name,info,weight_unit,distance_unit,folder_id,routine_order);
  exercise_order:=0;
  FOR exercise IN SELECT value FROM jsonb_array_elements(routine->'exercises') LOOP
   PERFORM gymbro_mcp.object_keys(exercise,ARRAY['exerciseRef','notes','restSeconds','sets']);
   reference:=exercise->'exerciseRef';
   PERFORM gymbro_mcp.object_keys(reference,ARRAY['source','id']);
   PERFORM gymbro_mcp.text_value(reference->'id',300,true);
   definition:=NULL;
   IF reference->>'source'='standard' THEN
    SELECT value INTO definition FROM jsonb_array_elements(catalog) WHERE value->>'id'=reference->>'id';
   ELSIF reference->>'source'='custom' THEN
    SELECT jsonb_build_object('names',jsonb_build_object('it',name),'parameters',c.parameters,'primaryMuscleGroup',primary_muscle_group,'secondaryMuscleGroups',COALESCE(secondary_muscle_groups,'{}'::text[]),'equipment',COALESCE(equipment,'none'))
    INTO definition FROM public.custom_exercises c WHERE c.user_id=owner AND c.id=reference->>'id' AND NOT c.deleted FOR SHARE;
   END IF;
   IF definition IS NULL THEN RAISE EXCEPTION 'Exercise unavailable' USING ERRCODE='P0002'; END IF;
   parameters:=definition->>'parameters';
   IF parameters IS NULL OR parameters NOT IN ('repsWeight','timeWeight','freeBodyReps','time','distance','setless') THEN RAISE EXCEPTION 'Exercise definition unavailable' USING ERRCODE='P0002'; END IF;
   rest:=COALESCE(gymbro_mcp.number_value(exercise->'restSeconds',86400,true),0);
   exercise_notes:=gymbro_mcp.text_value(exercise->'notes',10000);
   IF jsonb_typeof(exercise->'sets') IS DISTINCT FROM 'array' OR jsonb_array_length(exercise->'sets')>100 OR (parameters<>'setless' AND jsonb_array_length(exercise->'sets')=0) OR (parameters='setless' AND jsonb_array_length(exercise->'sets')<>0) THEN RAISE EXCEPTION 'Invalid sets' USING ERRCODE='22023'; END IF;
   normalized_sets:='[]';
   FOR item IN SELECT value FROM jsonb_array_elements(exercise->'sets') LOOP
    PERFORM gymbro_mcp.object_keys(item,ARRAY['kind','reps','weight','timeSeconds','distance','rpe']);
    kind:=COALESCE(item->>'kind','normal');
    IF (item ? 'kind' AND jsonb_typeof(item->'kind')<>'string') OR kind NOT IN ('warmUp','normal','drop','failure','failureStripping') THEN RAISE EXCEPTION 'Invalid set kind' USING ERRCODE='22023'; END IF;
    repetitions:=gymbro_mcp.number_value(item->'reps',100000,true);
    weight:=gymbro_mcp.number_value(item->'weight',100000);
    duration:=gymbro_mcp.number_value(item->'timeSeconds',604800);
    distance:=gymbro_mcp.number_value(item->'distance',100000);
    perceived:=gymbro_mcp.number_value(item->'rpe',10);
    IF (perceived IS NOT NULL AND perceived<1)
     OR (parameters IN ('repsWeight','freeBodyReps') AND repetitions IS NULL)
     OR (parameters NOT IN ('repsWeight','freeBodyReps') AND repetitions IS NOT NULL)
     OR (parameters NOT IN ('repsWeight','timeWeight') AND weight IS NOT NULL)
     OR (parameters IN ('time','timeWeight') AND duration IS NULL)
     OR (parameters NOT IN ('time','timeWeight') AND duration IS NOT NULL)
     OR (parameters='distance' AND distance IS NULL) OR (parameters<>'distance' AND distance IS NOT NULL)
    THEN RAISE EXCEPTION 'Set parameters do not match exercise' USING ERRCODE='22023'; END IF;
    normalized_sets:=normalized_sets||jsonb_build_array(jsonb_build_object('id',gen_random_uuid(),'kind',kind,'parameters',parameters,'reps',COALESCE(repetitions,0),'weight',COALESCE(weight,0),'time',COALESCE(round(duration*1000000),0),'distance',COALESCE(distance,0),'rpe',perceived,'done',false));
   END LOOP;
   exercise_id:=gen_random_uuid()::text;
   INSERT INTO public.routine_exercises(id,user_id,routine_id,name,parameters,sets,primary_muscle_group,secondary_muscle_groups,rest_time,is_custom,library_exercise_id,custom_exercise_id,notes,is_superset,is_in_superset,sort_order,equipment)
   VALUES(exercise_id,owner,routine_id,definition->'names'->>'it',parameters,normalized_sets,definition->>'primaryMuscleGroup',ARRAY(SELECT jsonb_array_elements_text(definition->'secondaryMuscleGroups')),rest::bigint,reference->>'source'='custom',CASE WHEN reference->>'source'='standard' THEN reference->>'id' END,CASE WHEN reference->>'source'='custom' THEN reference->>'id' END,exercise_notes,false,false,exercise_order,definition->>'equipment');
   exercise_order:=exercise_order+1;
  END LOOP;
  routines_result:=routines_result||jsonb_build_array(jsonb_build_object('id',routine_id,'name',routine_name,'exerciseCount',exercise_order));
  routine_order:=routine_order+1;
 END LOOP;
 result:=jsonb_build_object('folderId',folder_id,'name',folder_name,'routines',routines_result);

 RETURN result;
END $$;
CREATE FUNCTION gymbro_mcp.progression(p jsonb, parameters text, sets jsonb) RETURNS text LANGUAGE plpgsql SET search_path='' AS $$
DECLARE lo int; hi int; step_size int; n int; cycle int; step int; weight numeric; weight_step numeric; cycle_weight numeric; targets jsonb; BEGIN
 IF p IS NULL THEN RETURN NULL; END IF;
 PERFORM gymbro_mcp.object_keys(p,ARRAY['mode','minReps','maxReps','repsPerStep','startingWeight','weightPerStep','weightPerCycle','cycle','step','targetReps']);
 lo:=gymbro_mcp.number_value(p->'minReps',100000,true); hi:=gymbro_mcp.number_value(p->'maxReps',100000,true); step_size:=gymbro_mcp.number_value(p->'repsPerStep',100000,true);
 weight:=gymbro_mcp.number_value(p->'startingWeight',100000); weight_step:=gymbro_mcp.number_value(p->'weightPerStep',100000); cycle_weight:=gymbro_mcp.number_value(p->'weightPerCycle',100000);
 cycle:=COALESCE(gymbro_mcp.number_value(p->'cycle',100000,true),0); step:=COALESCE(gymbro_mcp.number_value(p->'step',100000,true),0);
 SELECT count(*) INTO n FROM jsonb_array_elements(sets) s WHERE s->>'kind'='normal';
 IF parameters NOT IN ('repsWeight','freeBodyReps') OR p->>'mode' NOT IN ('doubleProgression','cyclicLinear') OR p->>'mode' IS NULL
 OR lo IS NULL OR hi IS NULL OR step_size IS NULL OR weight IS NULL OR weight_step IS NULL OR cycle_weight IS NULL
 OR lo<1 OR hi<lo OR step_size<1 OR weight_step<=0 OR n<1 THEN RAISE EXCEPTION 'Invalid progression' USING ERRCODE='22023'; END IF;
 IF step>=(hi-lo)/step_size+1 OR (p->>'mode'='cyclicLinear' AND (parameters<>'repsWeight' OR (hi-lo)%step_size<>0)) THEN RAISE EXCEPTION 'Invalid progression step' USING ERRCODE='22023'; END IF;
 targets:=p->'targetReps';
 IF targets IS NOT NULL THEN
  IF jsonb_typeof(targets)<>'array' OR jsonb_array_length(targets)<>n THEN RAISE EXCEPTION 'Invalid progression targets' USING ERRCODE='22023'; END IF;
  PERFORM gymbro_mcp.number_value(value,hi,true) FROM jsonb_array_elements(targets);
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(targets) v WHERE (v#>>'{}')::int<lo) THEN RAISE EXCEPTION 'Invalid progression target range' USING ERRCODE='22023'; END IF;
 END IF;
 IF targets IS NULL THEN SELECT jsonb_agg(lo) INTO targets FROM generate_series(1,n); END IF;
 RETURN (p||jsonb_build_object('setCount',n,'cycle',cycle,'step',step,'targetReps',targets))::text;
END $$;
CREATE FUNCTION gymbro_mcp.decorate_routine(routine_id text, r jsonb) RETURNS void LANGUAGE plpgsql SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); ids text[]; leaf int:=1; pos int:=0; subpos int; e jsonb; child jsonb; group_id text; row public.routine_exercises; BEGIN
 SELECT array_agg(id ORDER BY sort_order,id) INTO ids FROM public.routine_exercises WHERE user_id=owner AND routine_exercises.routine_id=decorate_routine.routine_id AND NOT deleted;
 FOR e IN SELECT value FROM jsonb_array_elements(r->'exercises') LOOP
  group_id:=NULL; subpos:=0;
  IF e->>'type'='superset' THEN
   group_id:=gen_random_uuid()::text;
   INSERT INTO public.routine_exercises(id,user_id,routine_id,name,rest_time,notes,is_custom,is_superset,is_in_superset,sort_order,equipment)
   VALUES(group_id,owner,routine_id,'',COALESCE((e->>'restSeconds')::bigint,0),COALESCE(e->>'notes',''),false,true,false,pos,'none');
  END IF;
  FOR child IN SELECT value FROM jsonb_array_elements(CASE WHEN group_id IS NULL THEN jsonb_build_array(e) ELSE e->'exercises' END) LOOP
   SELECT * INTO row FROM public.routine_exercises WHERE user_id=owner AND id=ids[leaf];
   IF child ? 'rpe' AND (gymbro_mcp.number_value(child->'rpe',10,true) IS NULL OR (child->>'rpe')::int<1) THEN RAISE EXCEPTION 'Invalid exercise RPE' USING ERRCODE='22023'; END IF;
   IF group_id IS NOT NULL OR row.sort_order<>pos OR child ? 'rpe' OR child ? 'progression' THEN
   UPDATE public.routine_exercises SET sort_order=CASE WHEN group_id IS NULL THEN pos ELSE subpos END,
    is_in_superset=group_id IS NOT NULL,superset_id=group_id,rpe=(child->>'rpe')::int,
    progression=gymbro_mcp.progression(child->'progression',row.parameters,row.sets),updated_at=clock_timestamp()
    WHERE user_id=owner AND id=ids[leaf];
   END IF;
   leaf:=leaf+1; subpos:=subpos+1;
  END LOOP;
  pos:=pos+1;
 END LOOP;
END $$;

CREATE FUNCTION gymbro_mcp.muscle(value text) RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path='' AS $$
 SELECT value=ANY(ARRAY['abductors','abs','adductors','biceps','calves','chest','glutes','hamstrings','lats','lowerBack','none','other','quadriceps','shoulders','traps','triceps','upperBack','thighs','forearms','obliques','hands','tibialis']);
$$;
CREATE FUNCTION gymbro_mcp.equipment(value text) RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path='' AS $$
 SELECT value=ANY(ARRAY['none','barbell','dumbbell','cable','machine','kettlebell','plates','resistanceBand','suspensionBands','landmine','other']);
$$;
CREATE FUNCTION gymbro_mcp.create(operation text, request jsonb, idempotency_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); receipt gymbro_mcp.operations; old gymbro_mcp.receipts; pro boolean; result jsonb:='{}'; items jsonb:='[]'; item jsonb; r jsonb; normalized jsonb; saved jsonb; uid text; destination uuid; make_folder boolean; count_new int; i int:=0; BEGIN
 IF idempotency_key IS NULL OR request IS NULL OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 IF operation<>'create_program' OR EXISTS(SELECT 1 FROM jsonb_array_elements(request->'routines') rr CROSS JOIN LATERAL jsonb_array_elements(rr->'exercises') ee WHERE ee ? 'type' OR ee ? 'rpe' OR ee ? 'progression') THEN PERFORM gymbro_mcp.require_consent(); END IF;
 PERFORM gymbro_mcp.lock_account(owner);
 SELECT * INTO receipt FROM gymbro_mcp.operations WHERE user_id=owner AND operations.idempotency_key=$3;
 IF FOUND THEN
  IF receipt.operation<>operation OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN receipt.result;
 END IF;
 SELECT * INTO old FROM gymbro_mcp.receipts WHERE user_id=owner AND receipts.idempotency_key=$3;
 IF FOUND THEN
  IF operation<>'create_program' OR old.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN old.result;
 END IF;
 pro:=gymbro_mcp.pro(owner);
 IF operation IN ('create_program','create_routines') THEN
  IF operation='create_program' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['name','notes','routines']);
  ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['routines']); END IF;
  IF jsonb_typeof(request->'routines') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'routines') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid routines' USING ERRCODE='22023'; END IF;
  count_new:=jsonb_array_length(request->'routines');
  IF NOT pro AND (SELECT count(*) FROM public.routines WHERE user_id=owner AND NOT deleted)+count_new>4 THEN RAISE EXCEPTION 'plan_limit_exceeded' USING ERRCODE='P1004'; END IF;
  IF operation='create_program' THEN
   IF EXISTS(SELECT 1 FROM jsonb_array_elements(request->'routines') rr WHERE rr ? 'folderId') THEN RAISE EXCEPTION 'Program owns destination' USING ERRCODE='22023'; END IF;
   SELECT jsonb_agg(gymbro_mcp.normalize_routine(value)) INTO normalized FROM jsonb_array_elements(request->'routines');
   saved:=gymbro_mcp.insert_program(jsonb_set(request,'{routines}',normalized),pro);
   FOR r IN SELECT value FROM jsonb_array_elements(request->'routines') LOOP
    PERFORM gymbro_mcp.decorate_routine(saved->'routines'->i->>'id',r); i:=i+1;
   END LOOP;
   result:=saved||jsonb_build_object('placement',CASE WHEN pro THEN 'folder' ELSE 'root' END,'warnings',CASE WHEN pro THEN '[]'::jsonb ELSE '["Program folder name and notes were not persisted; routines were saved in the home."]'::jsonb END);
  ELSE
   FOR r IN SELECT value FROM jsonb_array_elements(request->'routines') LOOP
    normalized:=gymbro_mcp.normalize_routine(r); destination:=(r->>'folderId')::uuid;
    IF destination IS NOT NULL THEN
     IF NOT pro THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
     IF NOT EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id=owner AND id=destination AND NOT deleted) THEN RAISE EXCEPTION 'Folder unavailable' USING ERRCODE='P0002'; END IF;
    END IF;
    saved:=gymbro_mcp.insert_program(jsonb_build_object('name','Routines','routines',jsonb_build_array(normalized)),false,destination);
    PERFORM gymbro_mcp.decorate_routine(saved->'routines'->0->>'id',r);
    items:=items||(saved->'routines');
   END LOOP; result:=jsonb_build_object('items',items);
  END IF;
 ELSIF operation='create_custom_exercises' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['exercises']);
  IF jsonb_typeof(request->'exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'exercises') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid exercises' USING ERRCODE='22023'; END IF;
  IF NOT pro AND (SELECT count(*) FROM public.custom_exercises WHERE user_id=owner AND NOT deleted)+jsonb_array_length(request->'exercises')>10 THEN RAISE EXCEPTION 'plan_limit_exceeded' USING ERRCODE='P1004'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'exercises') LOOP
   PERFORM gymbro_mcp.object_keys(item,ARRAY['name','parameters','primaryMuscleGroup','secondaryMuscleGroups','equipment']);
   PERFORM gymbro_mcp.text_value(item->'name',200,true);
   IF NOT COALESCE(gymbro_mcp.muscle(item->>'primaryMuscleGroup'),false) OR NOT COALESCE(gymbro_mcp.equipment(COALESCE(item->>'equipment','none')),false)
   OR COALESCE(item->>'parameters','') NOT IN ('repsWeight','timeWeight','freeBodyReps','time','distance','setless')
   OR jsonb_typeof(COALESCE(item->'secondaryMuscleGroups','[]'))<>'array' THEN RAISE EXCEPTION 'Invalid exercise metadata' USING ERRCODE='22023'; END IF;
   IF EXISTS(SELECT 1 FROM jsonb_array_elements_text(COALESCE(item->'secondaryMuscleGroups','[]')) m WHERE NOT COALESCE(gymbro_mcp.muscle(m),false)) THEN RAISE EXCEPTION 'Invalid muscle' USING ERRCODE='22023'; END IF;
   uid:=gen_random_uuid()::text;
   INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group,secondary_muscle_groups,equipment)
   VALUES(uid,owner,btrim(item->>'name'),item->>'parameters',item->>'primaryMuscleGroup',ARRAY(SELECT DISTINCT jsonb_array_elements_text(COALESCE(item->'secondaryMuscleGroups','[]'))),COALESCE(item->>'equipment','none'));
   items:=items||jsonb_build_array(jsonb_build_object('source','custom','id',uid,'name',btrim(item->>'name')));
  END LOOP; result:=jsonb_build_object('items',items);
 ELSIF operation='create_routine_folders' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['folders']);
  IF NOT pro THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
  IF jsonb_typeof(request->'folders') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'folders') NOT BETWEEN 1 AND 31 THEN RAISE EXCEPTION 'Invalid folders' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'folders') LOOP
   PERFORM gymbro_mcp.object_keys(item,ARRAY['name','notes']);
   uid:=gen_random_uuid()::text;
   INSERT INTO public.routine_folders(id,user_id,name,notes,sort_order) SELECT uid::uuid,owner,gymbro_mcp.text_value(item->'name',200,true),gymbro_mcp.text_value(item->'notes',10000),COALESCE(max(sort_order)+1,0) FROM public.routine_folders WHERE user_id=owner AND NOT deleted;
   items:=items||jsonb_build_array(jsonb_build_object('id',uid,'name',item->>'name'));
  END LOOP; result:=jsonb_build_object('items',items);
 ELSE RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023'; END IF;
 IF operation='create_program' THEN INSERT INTO gymbro_mcp.receipts VALUES(owner,idempotency_key,request,result);
 ELSE INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,operation,request,result); END IF;
 RETURN result;
END $$;
CREATE OR REPLACE FUNCTION public.mcp_create_program(program jsonb,idempotency_key uuid) RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path='' AS $$
 SELECT gymbro_mcp.create('create_program',program,idempotency_key);
$$;
CREATE TABLE gymbro_mcp.food_cache(key text PRIMARY KEY, definition jsonb NOT NULL, cached_at timestamptz NOT NULL DEFAULT now());
REVOKE ALL ON gymbro_mcp.food_cache FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE FUNCTION public.mcp_cache_food(cache_key text, definition jsonb DEFAULT NULL) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ BEGIN
 IF auth.jwt()->>'role' IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Service required' USING ERRCODE='42501'; END IF;
 IF definition IS NOT NULL THEN INSERT INTO gymbro_mcp.food_cache VALUES(cache_key,definition,now()) ON CONFLICT(key) DO UPDATE SET definition=excluded.definition,cached_at=excluded.cached_at; END IF;
 RETURN (SELECT c.definition FROM gymbro_mcp.food_cache c WHERE key=cache_key AND cached_at>now()-CASE WHEN cache_key LIKE 'search:%' THEN interval '5 minutes' ELSE interval '24 hours' END);
END $$;
REVOKE ALL ON FUNCTION public.mcp_cache_food(text,jsonb) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.mcp_cache_food(text,jsonb) TO service_role;
CREATE FUNCTION gymbro_mcp.settings_for(owner uuid, day date) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE goal public.nutrition_goals; categories public.nutrition_categories; BEGIN
 SELECT * INTO goal FROM public.nutrition_goals WHERE user_id=owner AND NOT deleted
 ORDER BY (reference_date <= day::timestamp AT TIME ZONE 'UTC') DESC,
 CASE WHEN reference_date<=day::timestamp AT TIME ZONE 'UTC' THEN reference_date END DESC,reference_date ASC LIMIT 1;
 SELECT * INTO categories FROM public.nutrition_categories WHERE user_id=owner AND NOT deleted
 ORDER BY (reference_date <= day::timestamp AT TIME ZONE 'UTC') DESC,
 CASE WHEN reference_date<=day::timestamp AT TIME ZONE 'UTC' THEN reference_date END DESC,reference_date ASC LIMIT 1;
 RETURN jsonb_build_object('date',day,'goal',CASE WHEN goal.id IS NULL THEN jsonb_build_object('dailyCalories',2000,'dailyFat',2000.0/30,'dailyCarbs',250,'dailyProtein',100)
 ELSE jsonb_build_object('dailyCalories',goal.calories,'dailyFat',goal.fat,'dailyCarbs',goal.carbs,'dailyProtein',goal.protein) END,
 'goalIsDefault',goal.id IS NULL,'goalEffectiveFrom',goal.reference_date::date,
 'categories',COALESCE((SELECT jsonb_object_agg(c->>'name',c) FROM jsonb_array_elements(COALESCE(categories.json_data,'[]')) c),'{}'),'categoriesEffectiveFrom',categories.reference_date::date);
END $$;
CREATE FUNCTION gymbro_mcp.food(owner uuid, ref jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE result jsonb; BEGIN
 PERFORM gymbro_mcp.object_keys(ref,ARRAY['source','id']); PERFORM gymbro_mcp.text_value(ref->'id',300,true);
 CASE ref->>'source'
 WHEN 'openfoodfacts' THEN SELECT definition INTO result FROM gymbro_mcp.food_cache WHERE key='product:'||(ref->>'id') AND cached_at>now()-interval '24 hours';
 WHEN 'favorite' THEN SELECT f.json_data INTO result FROM public.favorite_foods fav JOIN public.foods f ON f.id=fav.id AND f.user_id=owner WHERE fav.user_id=owner AND NOT fav.deleted AND NOT f.deleted AND f.id=ref->>'id';
 WHEN 'customBarcode' THEN SELECT json_data INTO result FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND id=ref->>'id';
 ELSE RAISE EXCEPTION 'Invalid food reference' USING ERRCODE='22023'; END CASE;
 RETURN result;
END $$;
CREATE FUNCTION gymbro_mcp.validate_food(f jsonb) RETURNS void LANGUAGE plpgsql SET search_path='' AS $$
DECLARE k text; v jsonb; BEGIN
 PERFORM gymbro_mcp.object_keys(f,ARRAY['name','brand','unit','nutritionalValuesPer100g','servingSizes','barcode','isDownloaded']);
 PERFORM gymbro_mcp.text_value(f->'name',200,true); IF f->'brand' IS NOT NULL AND f->'brand'<>'null'::jsonb THEN PERFORM gymbro_mcp.text_value(f->'brand',200); END IF;
 IF COALESCE(f->>'unit','') NOT IN ('g','ml') OR jsonb_typeof(f->'nutritionalValuesPer100g') IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'Invalid food definition' USING ERRCODE='22023'; END IF;
 FOREACH k IN ARRAY ARRAY['calories','fat','saturatedFat','carbs','sugar','protein'] LOOP
  IF gymbro_mcp.number_value(f->'nutritionalValuesPer100g'->k,1e9) IS NULL THEN RAISE EXCEPTION 'Missing nutrient: %',k USING ERRCODE='22023'; END IF;
 END LOOP;
 PERFORM gymbro_mcp.object_keys(f->'nutritionalValuesPer100g',ARRAY['calories','fat','saturatedFat','carbs','sugar','protein','salt','sodium','fiber','addedSugars','caffeine','calcium','iron','vitaminC','magnesium','phosphorus','potassium','zinc','copper','selenium','vitaminA','vitaminE','vitaminD','vitaminB1','vitaminB2','vitaminPP','vitaminB6','vitaminB12','vitaminB9','vitaminK','cholesterol','butyricAcid','caproicAcid','caprylicAcid','capricAcid','lauricAcid','myristicAcid','palmiticAcid','stearicAcid','oleicAcid','linoleicAcid','docosahexaenoicAcid','eicosapentaenoicAcid','erucicAcid','monounsaturatedFat','polyunsaturatedFat','alcohol','pantothenicAcid','biotin','chloride','chromium','fluoride','iodine','manganese','molybdenum','omega3','omega6','omega9','betaCarotene','bicarbonate','sugarAlcohol','alphaLinolenicAcid','arachidicAcid','arachidonicAcid','behenicAcid','ceroticAcid','dihomoGammaLinolenicAcid','elaidicAcid','gammaLinolenicAcid','gondoicAcid','lignocericAcid','meadAcid','melissicAcid','montanicAcid','nervonicAcid','transFat']);
 FOR k,v IN SELECT * FROM jsonb_each(f->'nutritionalValuesPer100g') LOOP
  IF v<>'null'::jsonb THEN PERFORM gymbro_mcp.number_value(v,1e9); END IF;
 END LOOP;
 IF jsonb_typeof(COALESCE(f->'servingSizes','[]'))<>'array' OR jsonb_array_length(COALESCE(f->'servingSizes','[]'))>100 THEN RAISE EXCEPTION 'Invalid serving sizes' USING ERRCODE='22023'; END IF;
 FOR v IN SELECT value FROM jsonb_array_elements(COALESCE(f->'servingSizes','[]')) LOOP
  PERFORM gymbro_mcp.object_keys(v,ARRAY['name','amount']); PERFORM gymbro_mcp.text_value(v->'name',200);
  IF COALESCE(gymbro_mcp.number_value(v->'amount',1e6),0)<=0 THEN RAISE EXCEPTION 'Invalid serving amount' USING ERRCODE='22023'; END IF;
 END LOOP;
END $$;
CREATE FUNCTION gymbro_mcp.log_foods(request jsonb, idempotency_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.require_consent(); receipt gymbro_mcp.operations; item jsonb; f jsonb; day date; settings jsonb; uid text; amount numeric; pieces int; items jsonb:='[]'; result jsonb; BEGIN
 PERFORM gymbro_mcp.lock_account(owner);
 IF idempotency_key IS NULL OR request IS NULL OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid food request' USING ERRCODE='22023'; END IF;
 SELECT * INTO receipt FROM gymbro_mcp.operations o WHERE user_id=owner AND o.idempotency_key=log_foods.idempotency_key;
 IF FOUND THEN IF receipt.operation<>'log_foods' OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF; RETURN receipt.result; END IF;
 IF EXISTS(SELECT 1 FROM gymbro_mcp.receipts r WHERE user_id=owner AND r.idempotency_key=log_foods.idempotency_key) THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
 PERFORM gymbro_mcp.pro(owner);
 PERFORM gymbro_mcp.object_keys(request,ARRAY['entries']);
 IF jsonb_typeof(request->'entries') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'entries') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid entries' USING ERRCODE='22023'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(request->'entries') LOOP
  PERFORM gymbro_mcp.object_keys(item,ARRAY['date','category','amount','pieces','food','foodRef']);
  day:=gymbro_mcp.day(item->>'date'); PERFORM gymbro_mcp.check_days(owner,day,day);
  IF (item ? 'food')=(item ? 'foodRef') THEN RAISE EXCEPTION 'Supply food or foodRef exclusively' USING ERRCODE='22023'; END IF;
  f:=CASE WHEN item ? 'food' THEN item->'food' ELSE gymbro_mcp.food(owner,item->'foodRef') END;
  IF f IS NULL THEN RAISE EXCEPTION 'Food unavailable' USING ERRCODE='P0002'; END IF;
  -- Only the server-resolved definition can carry catalog provenance.
  IF item ? 'food' AND (f ? 'barcode' OR f ? 'isDownloaded') THEN RAISE EXCEPTION 'Forged provenance' USING ERRCODE='22023'; END IF;
  f:=f-ARRAY['id','amount','pieces','category']; PERFORM gymbro_mcp.validate_food(f);
  amount:=gymbro_mcp.number_value(item->'amount',1e6); pieces:=COALESCE(gymbro_mcp.number_value(item->'pieces',10000,true),1);
  IF amount IS NULL OR amount<=0 OR pieces<=0 THEN RAISE EXCEPTION 'Invalid quantity' USING ERRCODE='22023'; END IF;
  settings:=gymbro_mcp.settings_for(owner,day);
  IF item ? 'category' THEN
   PERFORM gymbro_mcp.text_value(item->'category',200,true);
   IF NOT (settings->'categories' ? (item->>'category')) THEN RAISE EXCEPTION 'Category unavailable' USING ERRCODE='P0002'; END IF;
  END IF;
  uid:=gen_random_uuid()::text;
  f:=f||jsonb_build_object('id',uid,'amount',amount,'pieces',pieces,'category',item->'category','servingSizes',COALESCE(f->'servingSizes','[]'),'isDownloaded',COALESCE(f->'isDownloaded','false'));
  INSERT INTO public.foods(id,user_id,date_added,reference_date,json_data) VALUES(uid,owner,clock_timestamp(),day::timestamp AT TIME ZONE 'UTC',f);
  items:=items||jsonb_build_array(jsonb_build_object('id',uid,'date',day,'food',f));
 END LOOP;
 result:=jsonb_build_object('items',items);
 INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,'log_foods',request,result);
 RETURN result;
END $$;
CREATE FUNCTION gymbro_mcp.workout(owner uuid, wanted text) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE root public.history_workouts; row public.history_workouts; components jsonb; BEGIN
 SELECT * INTO row FROM public.history_workouts WHERE user_id=owner AND id=wanted AND NOT deleted;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT * INTO root FROM public.history_workouts WHERE user_id=owner AND id=COALESCE(row.completes::text,row.id) AND NOT deleted;
 IF NOT FOUND THEN root:=row; END IF;
 SELECT jsonb_agg(to_jsonb(w)-ARRAY['user_id','publication_manifest']||jsonb_build_object('exercises',COALESCE((SELECT jsonb_agg(to_jsonb(e)-ARRAY['user_id','publication_version'] ORDER BY sort_order,id) FROM public.history_workout_exercises e WHERE e.user_id=owner AND e.routine_id=w.id AND NOT deleted),'[]')) ORDER BY w.starting_date,w.id)
 INTO components FROM public.history_workouts w WHERE w.user_id=owner AND NOT w.deleted AND (w.id=root.id OR w.completes::text=root.id);
 RETURN jsonb_build_object('id',root.id,'components',components,'warnings',CASE WHEN root.completes IS NOT NULL OR (root.completed_by IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.history_workouts WHERE user_id=owner AND id=root.completed_by::text AND NOT deleted)) THEN '["Missing continuation component"]'::jsonb ELSE '[]'::jsonb END);
END $$;
CREATE FUNCTION public.mcp_execute(operation text, request jsonb DEFAULT '{}', idempotency_key uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.require_consent(); result jsonb; items jsonb:='[]'; unavailable jsonb:='[]'; item jsonb; raw jsonb; first_day date; last_day date; offset_value int:=0; page_limit int:=20; cursor_data jsonb; fingerprint text; target text; d date; pro boolean; BEGIN
 IF request IS NULL OR jsonb_typeof(request)<>'object' OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 IF operation IN ('create_routines','create_custom_exercises','create_routine_folders') THEN RETURN gymbro_mcp.create(operation,request,idempotency_key); END IF;
 IF operation='log_foods' THEN RETURN gymbro_mcp.log_foods(request,idempotency_key); END IF;
 -- Every direct caller is validated before executing even read-only operations.
 IF operation IN ('get_routines','get_workouts','get_food_entries') THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['ids','language']);
  IF jsonb_typeof(request->'ids') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'ids') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid IDs' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'ids') LOOP
   target:=gymbro_mcp.text_value(item,300,true); raw:=NULL;
   IF operation='get_routines' THEN
    IF EXISTS(SELECT 1 FROM public.routines WHERE user_id=owner AND id=target AND NOT deleted) THEN raw:=public.mcp_get_routine(target); END IF;
   ELSIF operation='get_workouts' THEN raw:=gymbro_mcp.workout(owner,target);
   ELSE
    SELECT jsonb_build_object('id',id,'date',(reference_date AT TIME ZONE 'UTC')::date,'food',json_data) INTO raw FROM public.foods WHERE user_id=owner AND id=target AND NOT deleted;
    IF raw IS NOT NULL THEN d:=gymbro_mcp.day(raw->>'date'); PERFORM gymbro_mcp.check_days(owner,d,d); END IF;
   END IF;
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(target); ELSE items:=items||jsonb_build_array(raw); END IF;
  END LOOP; RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 END IF;
 IF operation='external_access' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY[]::text[]); RETURN '{"allowed":true}'::jsonb; END IF;
 IF operation='get_foods' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['references']);
  IF jsonb_typeof(request->'references') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'references') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid references' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'references') LOOP
   raw:=gymbro_mcp.food(owner,item);
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(item); ELSE items:=items||jsonb_build_array(jsonb_build_object('reference',item,'food',raw)); END IF;
  END LOOP; RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 END IF;
 IF operation='get_account_limits' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY[]::text[]); pro:=gymbro_mcp.pro(owner);
  SELECT (now() AT TIME ZONE time_zone)::date INTO d FROM gymbro_mcp.consents WHERE user_id=owner;
  RETURN jsonb_build_object('plan',CASE WHEN pro THEN 'pro' ELSE 'free' END,'routineLimit',CASE WHEN pro THEN NULL ELSE 4 END,'customExerciseLimit',CASE WHEN pro THEN NULL ELSE 10 END,
   'routinesUsed',(SELECT count(*) FROM public.routines WHERE user_id=owner AND NOT deleted),'customExercisesUsed',(SELECT count(*) FROM public.custom_exercises WHERE user_id=owner AND NOT deleted),
   'canCreateFolders',pro,'nutritionFrom',CASE WHEN pro THEN '2000-01-01'::date ELSE d-7 END,'nutritionTo',CASE WHEN pro THEN '2099-12-31'::date ELSE d+7 END);
 END IF;
 IF operation IN ('get_nutrition_summary','get_nutrition_settings','list_food_entries') THEN
  IF operation='list_food_entries' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to','category','cursor','limit']);
  ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to']); END IF;
  first_day:=gymbro_mcp.day(request->>'from'); last_day:=gymbro_mcp.day(request->>'to');
  PERFORM gymbro_mcp.check_days(owner,first_day,last_day);
  IF operation IN ('get_nutrition_summary','get_nutrition_settings') THEN
   SELECT jsonb_agg(gymbro_mcp.settings_for(owner,day::date) ORDER BY day) INTO items FROM generate_series(first_day::timestamp,last_day::timestamp,interval '1 day') day;
   IF operation='get_nutrition_settings' THEN RETURN jsonb_build_object('items',items); END IF;
   SELECT COALESCE(jsonb_agg(jsonb_build_object('id',id,'date',(reference_date AT TIME ZONE 'UTC')::date,'food',json_data) ORDER BY reference_date,date_added,id),'[]') INTO raw FROM (SELECT id,reference_date,date_added,json_data FROM public.foods WHERE user_id=owner AND NOT deleted AND reference_date>=first_day::timestamp AT TIME ZONE 'UTC' AND reference_date<(last_day+1)::timestamp AT TIME ZONE 'UTC' ORDER BY reference_date,date_added,id LIMIT 10001) f;
   IF jsonb_array_length(raw)>10000 THEN RAISE EXCEPTION 'Nutrition interval too large; narrow dates' USING ERRCODE='22023'; END IF;
   RETURN jsonb_build_object('settings',items,'entries',raw);
  END IF;
 END IF;
 IF operation IN ('list_routine_folders','list_workouts','get_exercise_history','list_food_entries','search_foods','get_training_stats') THEN
  IF operation='list_routine_folders' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['cursor','limit']); END IF;
  IF operation IN ('list_workouts','get_training_stats','get_exercise_history') THEN
   IF operation='get_exercise_history' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['references','from','to','routineId','cursor','limit','language']);
   ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to','routineId','cursor','limit','language','weightUnit','distanceUnit']); END IF;
   first_day:=gymbro_mcp.day(request->>'from'); last_day:=gymbro_mcp.day(request->>'to');
   IF first_day>last_day OR last_day-first_day>366 THEN RAISE EXCEPTION 'Invalid training range' USING ERRCODE='22023'; END IF;
   IF operation='get_exercise_history' THEN
    IF jsonb_typeof(request->'references') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'references') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid references' USING ERRCODE='22023'; END IF;
    FOR item IN SELECT value FROM jsonb_array_elements(request->'references') LOOP
     PERFORM gymbro_mcp.object_keys(item,ARRAY['source','id']); PERFORM gymbro_mcp.text_value(item->'id',300,true);
     IF COALESCE(item->>'source','') NOT IN ('standard','custom') THEN RAISE EXCEPTION 'Invalid reference source' USING ERRCODE='22023'; END IF;
    END LOOP;
   END IF;
  END IF;
  IF operation='search_foods' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['query','source','cursor','limit','language','country']);
   IF COALESCE(request->>'source','') NOT IN ('favorite','customBarcode') THEN RAISE EXCEPTION 'Invalid private food source' USING ERRCODE='22023'; END IF;
  END IF;
  IF request ? 'limit' THEN page_limit:=gymbro_mcp.number_value(request->'limit',100,true); END IF;
  IF page_limit IS NULL OR page_limit<1 THEN RAISE EXCEPTION 'Invalid limit' USING ERRCODE='22023'; END IF;
  fingerprint:=md5(operation||(request-ARRAY['cursor','limit'])::text);
  IF request ? 'cursor' THEN
   BEGIN cursor_data:=convert_from(decode(request->>'cursor','base64'),'UTF8')::jsonb;
    offset_value:=(cursor_data->>'offset')::int;
    IF cursor_data->>'filter' IS DISTINCT FROM fingerprint OR offset_value IS NULL OR offset_value NOT BETWEEN 0 AND 1000000 THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
   EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Invalid cursor' USING ERRCODE='22023'; END;
  END IF;
  IF operation='list_routine_folders' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (SELECT f.id,f.name,f.notes,f.sort_order AS "sortOrder",(SELECT count(*) FROM public.routines r WHERE r.user_id=owner AND r.folder_id=f.id AND NOT r.deleted) AS "routineCount" FROM public.routine_folders f WHERE f.user_id=owner AND NOT f.deleted ORDER BY f.sort_order,f.id OFFSET offset_value LIMIT page_limit+1) t;
  ELSIF operation='list_food_entries' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (SELECT id,(reference_date AT TIME ZONE 'UTC')::date AS date,json_data AS food FROM public.foods WHERE user_id=owner AND NOT deleted AND reference_date>=first_day::timestamp AT TIME ZONE 'UTC' AND reference_date<(last_day+1)::timestamp AT TIME ZONE 'UTC' AND (NOT request ? 'category' OR json_data->>'category'=request->>'category') ORDER BY reference_date DESC,date_added DESC,id OFFSET offset_value LIMIT page_limit+1) t;
  ELSIF operation='search_foods' THEN
   SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (
    SELECT jsonb_build_object('source',request->>'source','id',id) AS reference,json_data AS food FROM (
     SELECT f.id,f.json_data FROM public.favorite_foods fav JOIN public.foods f ON f.user_id=owner AND f.id=fav.id AND NOT f.deleted WHERE fav.user_id=owner AND NOT fav.deleted AND request->>'source'='favorite'
     UNION ALL SELECT id,json_data FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND request->>'source'='customBarcode'
    ) foods WHERE position(lower(COALESCE(request->>'query','')) IN lower(COALESCE(json_data->>'name','')||' '||COALESCE(json_data->>'brand','')))>0 ORDER BY id OFFSET offset_value LIMIT page_limit+1) t;
  ELSE
   SELECT COALESCE(jsonb_agg(gymbro_mcp.workout(owner,t.id)),'[]') INTO items FROM (
    SELECT w.id FROM public.history_workouts w WHERE w.user_id=owner AND NOT w.deleted
    AND (w.completes IS NULL OR NOT EXISTS(SELECT 1 FROM public.history_workouts original WHERE original.user_id=owner AND original.id=w.completes::text AND NOT original.deleted))
    AND w.starting_date>=first_day::timestamp AT TIME ZONE 'UTC' AND w.starting_date<(last_day+1)::timestamp AT TIME ZONE 'UTC'
    AND (NOT request ? 'routineId' OR w.parent_id=request->>'routineId')
    AND (operation<>'get_exercise_history' OR EXISTS(SELECT 1 FROM public.history_workout_exercises e JOIN public.history_workouts component ON component.id=e.routine_id AND component.user_id=owner CROSS JOIN LATERAL jsonb_array_elements(request->'references') ref WHERE e.user_id=owner AND NOT e.deleted AND NOT component.deleted AND (component.id=w.id OR component.completes::text=w.id) AND ((ref->>'source'='standard' AND e.library_exercise_id=ref->>'id' AND NOT e.is_custom) OR (ref->>'source'='custom' AND e.custom_exercise_id=ref->>'id' AND e.is_custom))))
    ORDER BY w.starting_date DESC,w.id OFFSET CASE WHEN operation='get_training_stats' THEN 0 ELSE offset_value END LIMIT CASE WHEN operation='get_training_stats' THEN 1001 ELSE page_limit+1 END
   ) t;
   -- Never silently truncate aggregation input.
   IF operation='get_training_stats' THEN
    IF jsonb_array_length(items)>1000 THEN RAISE EXCEPTION 'Training interval too large' USING ERRCODE='22023'; END IF;
    RETURN jsonb_build_object('items',items);
   END IF;
  END IF;
  RETURN jsonb_build_object('items',(SELECT COALESCE(jsonb_agg(value),'[]') FROM jsonb_array_elements(items) WITH ORDINALITY t(value,n) WHERE n<=page_limit),
   'nextCursor',CASE WHEN jsonb_array_length(items)>page_limit THEN encode(convert_to(jsonb_build_object('offset',offset_value+page_limit,'filter',fingerprint)::text,'UTF8'),'base64') ELSE NULL END);
 END IF;
 RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023';
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_mcp FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
REVOKE ALL ON FUNCTION public.mcp_execute(text,jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mcp_execute(text,jsonb,uuid) TO gymbro_mcp_user;
CREATE TABLE gymbro_mcp.external_budget(kind text PRIMARY KEY, minute timestamptz NOT NULL, used int NOT NULL);
REVOKE ALL ON gymbro_mcp.external_budget FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE FUNCTION public.mcp_external_budget(budget_kind text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE used_now int; max_calls int; BEGIN
 IF auth.jwt()->>'role' IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'Service required' USING ERRCODE='42501'; END IF;
 max_calls:=CASE budget_kind WHEN 'search' THEN 10 WHEN 'product' THEN 15 ELSE 0 END;
 IF max_calls=0 THEN RAISE EXCEPTION 'Invalid budget' USING ERRCODE='22023'; END IF;
 INSERT INTO gymbro_mcp.external_budget VALUES(budget_kind,date_trunc('minute',now()),1)
 ON CONFLICT(kind) DO UPDATE SET minute=excluded.minute,used=CASE WHEN gymbro_mcp.external_budget.minute=excluded.minute THEN gymbro_mcp.external_budget.used+1 ELSE 1 END RETURNING used INTO used_now;
 IF used_now>max_calls THEN RAISE EXCEPTION 'external_rate_limited' USING ERRCODE='P1005'; END IF;
END $$;
REVOKE ALL ON FUNCTION public.mcp_external_budget(text) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
GRANT EXECUTE ON FUNCTION public.mcp_external_budget(text) TO service_role;

COMMIT;
