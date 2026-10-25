-- Accept positive stored weights for negative-weight repetition sets.
BEGIN;

CREATE OR REPLACE FUNCTION gymbro_mcp.insert_program(program jsonb, make_folder boolean, destination uuid DEFAULT NULL) RETURNS jsonb
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
   IF parameters IS NULL OR parameters NOT IN ('repsWeight','repsNegWeight','timeWeight','freeBodyReps','time','distance','setless') THEN RAISE EXCEPTION 'Exercise definition unavailable' USING ERRCODE='P0002'; END IF;
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
     OR (parameters IN ('repsWeight','repsNegWeight','freeBodyReps') AND repetitions IS NULL)
     OR (parameters NOT IN ('repsWeight','repsNegWeight','freeBodyReps') AND repetitions IS NOT NULL)
     OR (parameters NOT IN ('repsWeight','repsNegWeight','timeWeight') AND weight IS NOT NULL)
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

CREATE OR REPLACE FUNCTION gymbro_mcp.create(operation text, request jsonb, idempotency_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); receipt gymbro_mcp.operations; old gymbro_mcp.receipts; pro boolean; result jsonb:='{}'; items jsonb:='[]'; item jsonb; r jsonb; normalized jsonb; saved jsonb; uid text; destination uuid; make_folder boolean; count_new int; i int:=0; BEGIN
 IF idempotency_key IS NULL OR request IS NULL OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
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
   OR COALESCE(item->>'parameters','') NOT IN ('repsWeight','repsNegWeight','timeWeight','freeBodyReps','time','distance','setless')
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

COMMIT;
