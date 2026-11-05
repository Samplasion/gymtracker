\set ON_ERROR_STOP on
BEGIN;
INSERT INTO auth.users(id,email) VALUES
('11111111-1111-4111-8111-111111111111','stats@test.invalid'),
('22222222-2222-4222-8222-222222222222','other-stats@test.invalid');

-- Two visible logical sessions, one continuation, a deleted session and a
-- continuation with a missing original. Other-account rows must never count.
INSERT INTO public.history_workouts(id,user_id,deleted,name,duration,starting_date,completed_by,completes,weight_unit,distance_unit) VALUES
('10000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111',false,'Original',100,date_trunc('week',CURRENT_DATE),'10000000-0000-4000-8000-000000000002',null,'kg','km'),
('10000000-0000-4000-8000-000000000002','11111111-1111-4111-8111-111111111111',false,'Continuation',100,date_trunc('week',CURRENT_DATE),null,'10000000-0000-4000-8000-000000000001','kg','km'),
('10000000-0000-4000-8000-000000000003','11111111-1111-4111-8111-111111111111',false,'Previous week',100,date_trunc('week',CURRENT_DATE)-interval '1 week',null,null,'kg','km'),
('10000000-0000-4000-8000-000000000004','11111111-1111-4111-8111-111111111111',true,'Deleted',100,date_trunc('week',CURRENT_DATE)-interval '2 weeks',null,null,'kg','km'),
('10000000-0000-4000-8000-000000000005','11111111-1111-4111-8111-111111111111',false,'Orphan continuation',100,date_trunc('week',CURRENT_DATE)-interval '2 weeks',null,'10000000-0000-4000-8000-000000000099','kg','km'),
('10000000-0000-4000-8000-000000000006','22222222-2222-4222-8222-222222222222',false,'Other owner',100,date_trunc('week',CURRENT_DATE)-interval '2 weeks',null,null,'kg','km');
INSERT INTO public.foods(id,user_id,deleted,date_added,reference_date,json_data) VALUES
('food','11111111-1111-4111-8111-111111111111',false,now(),now(),'{}'),
('deleted','11111111-1111-4111-8111-111111111111',true,now(),now(),'{}'),
('other','22222222-2222-4222-8222-222222222222',false,now(),now(),'{}');

-- Assert explicit ownership even when invoked by a privileged database role.
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
DO $$ BEGIN
 IF public.get_user_stats()::jsonb <> '{"workouts":2,"foods":1,"weeks":2}'::jsonb THEN
   RAISE EXCEPTION 'Incorrect visible account stats: %', public.get_user_stats();
 END IF;
END $$;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 IF public.get_user_stats()::jsonb <> '{"workouts":2,"foods":1,"weeks":2}'::jsonb THEN
   RAISE EXCEPTION 'Incorrect stats under authenticated RLS: %', public.get_user_stats();
 END IF;
END $$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
DO $$ BEGIN
 IF public.get_user_stats()::jsonb <> '{"workouts":1,"foods":1,"weeks":0}'::jsonb THEN
   RAISE EXCEPTION 'Stats leaked across accounts: %', public.get_user_stats();
 END IF;
END $$;
SELECT set_config('request.jwt.claim.sub','',true);
DO $$ BEGIN
 IF public.get_user_stats()::jsonb <> '{"workouts":0,"foods":0,"weeks":0}'::jsonb THEN
   RAISE EXCEPTION 'Missing identity exposed stats';
 END IF;
 IF has_function_privilege('anon','public.get_user_stats()','execute') THEN
   RAISE EXCEPTION 'Anonymous clients can still call account statistics';
 END IF;
END $$;
-- Removing the current week's only visible workout breaks the streak, even
-- though its continuation remains. Soft-deleted food also disappears.
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT set_config('gymtracker.sync_v2','on',true);
UPDATE public.history_workouts SET deleted=true WHERE name='Original';
UPDATE public.foods SET deleted=true WHERE id='food';
DO $$ BEGIN
 IF public.get_user_stats()::jsonb <> '{"workouts":1,"foods":0,"weeks":0}'::jsonb THEN
   RAISE EXCEPTION 'Deletion did not update visible statistics: %', public.get_user_stats();
 END IF;
END $$;
ROLLBACK;
