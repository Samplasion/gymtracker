BEGIN;

-- Limit each training day, counting superset members but not group headers.
CREATE OR REPLACE FUNCTION gymbro_trainer.validate_document(doc jsonb) RETURNS void LANGUAGE plpgsql SET search_path='' AS $$
DECLARE r jsonb; e jsonb; training_set jsonb; folder_ids text[]:='{}'; set_ids text[]:='{}'; ids text[]:='{}'; eid text[]:='{}'; custom_ids text[]:='{}';
BEGIN
 IF jsonb_typeof(doc->'routines') IS DISTINCT FROM 'array' OR jsonb_typeof(doc->'custom_exercises') IS DISTINCT FROM 'array' OR jsonb_array_length(doc->'routines')>100 OR pg_column_size(doc)>1000000 THEN RAISE EXCEPTION 'invalid_document' USING ERRCODE='22023'; END IF;
 IF jsonb_typeof(COALESCE(doc->'folders','[]'))<>'array' THEN RAISE EXCEPTION 'invalid_folders' USING ERRCODE='22023'; END IF;
 FOR r IN SELECT value FROM jsonb_array_elements(COALESCE(doc->'folders','[]')) LOOP
 PERFORM (r->>'id')::uuid;
 IF COALESCE(trim(r->>'name'),'')='' OR r->>'id'=ANY(folder_ids) THEN RAISE EXCEPTION 'invalid_folder' USING ERRCODE='22023'; END IF;
 folder_ids:=array_append(folder_ids,r->>'id');
 END LOOP;
 FOR e IN SELECT value FROM jsonb_array_elements(doc->'custom_exercises') LOOP
 IF NOT COALESCE(gymbro_mcp.muscle(e->>'primary_muscle_group'),false) OR NOT COALESCE(gymbro_mcp.equipment(COALESCE(e->>'equipment','none')),false) OR COALESCE(e->>'parameters','') NOT IN ('repsWeight','repsNegWeight','timeWeight','freeBodyReps','time','distance','setless') THEN RAISE EXCEPTION 'invalid_exercise' USING ERRCODE='22023'; END IF;
 IF COALESCE(e->>'id','')='' OR e->>'id'=ANY(custom_ids) OR COALESCE(trim(e->>'name'),'')='' THEN RAISE EXCEPTION 'invalid_exercise' USING ERRCODE='22023'; END IF;
 custom_ids:=array_append(custom_ids,e->>'id');
 END LOOP;
 FOR r IN SELECT value FROM jsonb_array_elements(doc->'routines') LOOP
 IF COALESCE(r->>'id','')='' OR r->>'id'=ANY(ids) OR COALESCE(trim(r->>'name'),'')='' OR r->>'weight_unit' NOT IN ('kg','lb') OR r->>'distance_unit' NOT IN ('km','mi') OR jsonb_typeof(r->'exercises') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'invalid_routine' USING ERRCODE='22023'; END IF;
 IF NULLIF(r->>'folder_id','') IS NOT NULL AND NOT r->>'folder_id'=ANY(folder_ids) THEN RAISE EXCEPTION 'invalid_folder' USING ERRCODE='22023'; END IF;
 ids:=array_append(ids,r->>'id');
 IF (SELECT count(*) FROM jsonb_array_elements(r->'exercises') entry WHERE NOT COALESCE((entry->>'is_superset')::boolean,false))>50 THEN
  RAISE EXCEPTION 'routine_exercise_limit' USING ERRCODE='22023';
 END IF;
 PERFORM gymbro_trainer.validate_superset_order(r->'exercises');
 FOR e IN SELECT value FROM jsonb_array_elements(r->'exercises') LOOP
 IF COALESCE(e->>'id','')='' OR e->>'id'=ANY(eid) OR (COALESCE((e->>'is_custom')::boolean,false) AND NOT COALESCE((e->>'is_superset')::boolean,false) AND NOT e->>'custom_exercise_id'=ANY(custom_ids)) THEN RAISE EXCEPTION 'invalid_exercise' USING ERRCODE='22023'; END IF;
 IF COALESCE((e->>'is_in_superset')::boolean,false) AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(r->'exercises') parent WHERE parent->>'id'=e->>'superset_id' AND parent->>'is_superset'='true' AND COALESCE(parent->>'is_in_superset','false')='false') THEN RAISE EXCEPTION 'invalid_superset' USING ERRCODE='22023'; END IF;
 IF COALESCE((e->>'is_superset')::boolean,false) AND COALESCE((e->>'is_in_superset')::boolean,false) THEN RAISE EXCEPTION 'nested_superset' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements_text(COALESCE(e->'secondary_muscle_groups','[]')) m WHERE NOT COALESCE(gymbro_mcp.muscle(m),false)) THEN RAISE EXCEPTION 'invalid_muscle' USING ERRCODE='22023'; END IF;
 IF NOT COALESCE((e->>'is_superset')::boolean,false) THEN
 IF COALESCE(trim(e->>'name'),'')='' OR NOT COALESCE(gymbro_mcp.muscle(e->>'primary_muscle_group'),false) OR NOT COALESCE(gymbro_mcp.equipment(COALESCE(e->>'equipment','none')),false) OR COALESCE(e->>'parameters','') NOT IN ('repsWeight','repsNegWeight','timeWeight','freeBodyReps','time','distance','setless') OR jsonb_typeof(e->'sets') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'invalid_exercise' USING ERRCODE='22023'; END IF;
 IF e->'progression' IS NOT NULL AND e->'progression'<>'null'::jsonb THEN PERFORM gymbro_mcp.progression((e->'progression')-'setCount',e->>'parameters',e->'sets'); END IF;
 FOR training_set IN SELECT value FROM jsonb_array_elements(e->'sets') LOOP
 IF COALESCE(training_set->>'id','')='' OR training_set->>'id'=ANY(set_ids) THEN RAISE EXCEPTION 'invalid_set_identity' USING ERRCODE='22023'; END IF;
 set_ids:=array_append(set_ids,training_set->>'id');
 IF COALESCE(training_set->>'kind','') NOT IN ('warmUp','normal','drop','failure','failureStripping') OR training_set->>'parameters' IS DISTINCT FROM e->>'parameters' OR COALESCE((training_set->>'done')::boolean,false) OR COALESCE((training_set->>'reps')::int,0)<0 OR COALESCE((training_set->>'time')::bigint,0)<0 OR COALESCE((training_set->>'distance')::numeric,0)<0 THEN RAISE EXCEPTION 'invalid_set' USING ERRCODE='22023'; END IF;
 END LOOP;
 END IF;
 eid:=array_append(eid,e->>'id');
 IF NOT COALESCE((e->>'is_superset')::boolean,false) AND NOT COALESCE((e->>'is_custom')::boolean,false) AND NOT EXISTS(SELECT 1 FROM gymbro_mcp.catalog c, jsonb_array_elements(c.exercises) x WHERE x->>'id'=e->>'library_exercise_id') THEN RAISE EXCEPTION 'unknown_catalog_exercise' USING ERRCODE='22023'; END IF;
 END LOOP;
 END LOOP;
END $$;

REVOKE ALL ON FUNCTION gymbro_trainer.validate_document(jsonb) FROM PUBLIC,anon,authenticated;
COMMIT;
