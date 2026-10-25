\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000094','negative-weight@unit.test','{"username":"negativeweight"}');
SELECT public.test_mcp_oauth('00000000-0000-0000-0000-000000000094');
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp') ON CONFLICT(singleton) DO NOTHING;
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000094',false,NULL,now(),'PRODUCTION');
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000094","session_id":"00000000-0000-0000-0000-000000000094","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
DO $$ DECLARE created jsonb; request jsonb; result jsonb; routine jsonb; BEGIN
 created:=public.mcp_execute('create_custom_exercises','{"exercises":[{"name":"Assisted lift","parameters":"repsNegWeight","primaryMuscleGroup":"chest","equipment":"machine"}]}',gen_random_uuid());
 request:=jsonb_build_object('name','Negative','routines',jsonb_build_array(jsonb_build_object('name','Assisted','exercises',jsonb_build_array(jsonb_build_object('exerciseRef',(created->'items'->0)-'name','sets','[{"reps":10,"weight":5}]'::jsonb)))));
 result:=public.mcp_create_program(request,gen_random_uuid());
 routine:=public.mcp_get_routine(result->'routines'->0->>'id');
 IF routine->'exercises'->0->>'parameters' IS DISTINCT FROM 'repsNegWeight'
 OR routine->'exercises'->0->'sets'->0->>'parameters' IS DISTINCT FROM 'repsNegWeight'
 OR (routine->'exercises'->0->'sets'->0->>'weight')::numeric IS DISTINCT FROM 5
 THEN RAISE EXCEPTION 'Negative-weight parameters or positive input did not persist'; END IF;
 BEGIN
  PERFORM public.mcp_create_program(jsonb_set(request, '{routines,0,exercises,0,progression}', '{"mode":"doubleProgression","minReps":8,"maxReps":12,"repsPerStep":1,"startingWeight":5,"weightPerStep":2.5,"weightPerCycle":0}'),gen_random_uuid());
  RAISE EXCEPTION 'Negative-weight progression accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
END $$;
ROLLBACK;
