\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email) VALUES('11111111-1111-4111-8111-111111111111','personal@test.invalid'),('22222222-2222-4222-8222-222222222222','other-personal@test.invalid');
INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit)
 SELECT 'session-'||i,'11111111-1111-4111-8111-111111111111','Workout '||i,3600,now()-make_interval(days=>i),'kg','km' FROM generate_series(1,1005) i;
INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit,deleted)
 VALUES('foreign','22222222-2222-4222-8222-222222222222','Private',60,now(),'kg','km',false),('deleted','11111111-1111-4111-8111-111111111111','Deleted',60,now(),'kg','km',true);
INSERT INTO public.history_workout_exercises(id,user_id,routine_id,name,parameters,sets,primary_muscle_group,is_custom,library_exercise_id,is_superset,is_in_superset,sort_order)
VALUES
('e1','11111111-1111-4111-8111-111111111111','session-1005','Squat','repsWeight','[{"done":true,"weight":120,"reps":5},{"done":false,"weight":300,"reps":5}]','quadriceps',false,'squat',false,false,0),
('e2','11111111-1111-4111-8111-111111111111','session-1','Squat','repsWeight','[{"done":true,"weight":100,"reps":5}]','quadriceps',false,'squat',false,false,0),
('e3','11111111-1111-4111-8111-111111111111','session-1','Assisted','repsNegWeight','[{"done":true,"weight":40},{"done":true,"weight":20}]','back',false,'assisted',false,false,1),
('e4','22222222-2222-4222-8222-222222222222','foreign','Squat','repsWeight','[{"done":true,"weight":900}]','quadriceps',false,'squat',false,false,0),
('e5','11111111-1111-4111-8111-111111111111','deleted','Squat','repsWeight','[{"done":true,"weight":900}]','quadriceps',false,'squat',false,false,0);
-- A continuation contributes to its original session and uses its own units.
INSERT INTO public.history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit,completes) VALUES
('10000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','Continued session',180,now(),'kg','km',NULL),
('10000000-0000-4000-8000-000000000002','11111111-1111-4111-8111-111111111111','Continuation',60,now(),'lb','mi','10000000-0000-4000-8000-000000000001'),
('10000000-0000-4000-8000-000000000003','11111111-1111-4111-8111-111111111111','Orphan',60,now(),'lb','mi','10000000-0000-4000-8000-000000000099');
INSERT INTO public.history_workout_exercises(id,user_id,routine_id,name,parameters,sets,primary_muscle_group,is_custom,library_exercise_id,is_superset,is_in_superset,sort_order) VALUES
('continued-weight','11111111-1111-4111-8111-111111111111','10000000-0000-4000-8000-000000000002','Continuation lift','repsWeight','[{"done":true,"weight":100,"reps":5}]','chest',false,'continued-lift',false,false,0),
('continued-distance','11111111-1111-4111-8111-111111111111','10000000-0000-4000-8000-000000000002','Run','distance','[{"done":true,"distance":1}]','none',false,'run',false,false,1),
('orphan','11111111-1111-4111-8111-111111111111','10000000-0000-4000-8000-000000000003','Orphan lift','repsWeight','[{"done":true,"weight":900}]','chest',false,'orphan',false,false,0);
DO $$ DECLARE a uuid:='11111111-1111-4111-8111-111111111111'; b uuid:='22222222-2222-4222-8222-222222222222'; result jsonb; saved jsonb; token text; BEGIN
 IF (public.personal_execute(a,'overview')->>'workouts')::int<>1006 THEN RAISE EXCEPTION 'Aggregate truncated or leaked'; END IF;
 result:=public.personal_execute(a,'history','{"offset":1000,"limit":20}');
 IF (result->>'total')::int<>1006 OR jsonb_array_length(result->'items')<>6 THEN RAISE EXCEPTION 'Pagination failed'; END IF;
 BEGIN PERFORM public.personal_execute(a,'detail','{"id":"foreign"}'); RAISE EXCEPTION 'Foreign history leaked'; EXCEPTION WHEN no_data_found THEN NULL; END;
 result:=public.personal_execute(a,'progress',jsonb_build_object('since',now()-interval '30 days'));
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(result) x WHERE x->>'exercise_id'='squat' AND (x->'record'->>'value')::numeric=120 AND jsonb_array_length(x->'points')=1) THEN RAISE EXCEPTION 'All-time record or period failed: %',result; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(result) x WHERE x->>'exercise_id'='assisted' AND (x->'record'->>'value')::numeric=20) THEN RAISE EXCEPTION 'Assistance metric failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(result) x WHERE x->>'exercise_id'='continued-lift' AND (x->'record'->>'value')::numeric=45.359237) THEN RAISE EXCEPTION 'Continuation pounds conversion failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(result) x WHERE x->>'exercise_id'='run' AND (x->'record'->>'value')::numeric=1.609344) THEN RAISE EXCEPTION 'Distance conversion failed'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(result) x WHERE x->>'exercise_id'='orphan') THEN RAISE EXCEPTION 'Orphan continuation leaked'; END IF;
 result:=public.personal_execute(a,'detail','{"id":"10000000-0000-4000-8000-000000000001"}');
 IF (result->>'duration')::int<>240 OR jsonb_array_length(result->'exercises')<>2 OR (result->'exercises'->0->'sets'->0->>'weight')::numeric<>45.359237 THEN RAISE EXCEPTION 'Logical session detail failed: %',result; END IF;
 saved:=public.personal_execute(a,'share_create','{"document":{"version":1,"title":"Snapshot","routines":[]}}'); token:=saved->>'token';
 IF length(token)<>48 OR public.personal_execute(NULL,'read',jsonb_build_object('token',token))->>'title'<>'Snapshot' THEN RAISE EXCEPTION 'Public token read failed'; END IF;
 IF jsonb_array_length(public.personal_execute(b,'shares'))<>0 THEN RAISE EXCEPTION 'Share ownership leaked'; END IF;
 BEGIN PERFORM public.personal_execute(b,'share_revoke',saved); RAISE EXCEPTION 'Other user revoked link'; EXCEPTION WHEN no_data_found THEN NULL; END;
 PERFORM public.personal_execute(a,'share_revoke',saved);
 BEGIN PERFORM public.personal_execute(NULL,'read',jsonb_build_object('token',token)); RAISE EXCEPTION 'Revoked program exposed'; EXCEPTION WHEN no_data_found THEN NULL; END;
 IF has_function_privilege('authenticated','public.personal_execute(uuid,text,jsonb)','execute') OR has_table_privilege('anon','public.shared_programs','select') THEN RAISE EXCEPTION 'Direct actor impersonation allowed'; END IF;
 saved:=public.personal_execute(b,'share_create','{"document":{"version":1,"title":"Cascade","routines":[]}}');
 DELETE FROM auth.users WHERE id=b;
 IF EXISTS(SELECT 1 FROM public.shared_programs WHERE id=(saved->>'id')::uuid) THEN RAISE EXCEPTION 'Account deletion left snapshots'; END IF;
END $$;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT set_config('request.jwt.claims','{"role":"authenticated"}',true);
DO $$ BEGIN
 IF (SELECT count(*) FROM public.shared_programs)<>1 THEN RAISE EXCEPTION 'Owner snapshot access failed'; END IF;
 IF jsonb_array_length(public.export_schema_to_json()::jsonb->'shared_programs')<>1 THEN RAISE EXCEPTION 'Snapshots absent from data export'; END IF;
END $$;
SELECT set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
DO $$ BEGIN IF EXISTS(SELECT 1 FROM public.shared_programs) THEN RAISE EXCEPTION 'Other owner read snapshots'; END IF; END $$;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT set_config('request.jwt.claims','{"role":"authenticated","client_id":"delegated"}',true);
DO $$ BEGIN IF EXISTS(SELECT 1 FROM public.shared_programs) THEN RAISE EXCEPTION 'Delegated session read snapshots'; END IF; END $$;
RESET ROLE;
ROLLBACK;
