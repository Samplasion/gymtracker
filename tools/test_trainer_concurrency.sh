#!/usr/bin/env bash
# Used only against the disposable database created by test_trainers_backend.sh.
set -euo pipefail
container="$1"
first_log=$(mktemp)
second_log=$(mktemp)
trap 'rm -f "$first_log" "$second_log"' EXIT
psql_test() { docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 "$@"; }
psql_test <<'SQL' >/dev/null
INSERT INTO auth.users(id,email) VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','coach-a@race.invalid'),('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','coach-b@race.invalid'),('cccccccc-cccc-4ccc-8ccc-cccccccccccc','client@race.invalid');
INSERT INTO gymbro_trainer.profiles(user_id,display_name) VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Coach A'),('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Coach B');
INSERT INTO gymbro_trainer.invites(trainer_id,token) VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','aaaaaaaa-0000-4000-8000-000000000001'),('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','bbbbbbbb-0000-4000-8000-000000000001');
SQL
accept_invitation() {
 psql_test <<SQL
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
SELECT public.trainer_execute('cccccccc-cccc-4ccc-8ccc-cccccccccccc','invite_accept','{"token":"$1"}');
SELECT pg_sleep(0.15);
COMMIT;
SQL
}
accept_invitation aaaaaaaa-0000-4000-8000-000000000001 >"$first_log" 2>&1 &
first_pid=$!
accept_invitation bbbbbbbb-0000-4000-8000-000000000001 >"$second_log" 2>&1 &
second_pid=$!
first_status=0; wait "$first_pid" || first_status=$?
second_status=0; wait "$second_pid" || second_status=$?
if [[ "$first_status" -eq "$second_status" ]]; then cat "$first_log" "$second_log"; exit 1; fi
psql_test <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM gymbro_trainer.links WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc' AND ended_at IS NULL)<>1 THEN RAISE EXCEPTION 'Concurrent invitations created multiple links'; END IF;
END $$;
SQL
# Acceptance and termination contend on the same account lock. Whichever wins,
# no controls or client-specific revision history may survive termination.
psql_test <<'SQL' >/dev/null
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO gymbro_mcp.billing VALUES('cccccccc-cccc-4ccc-8ccc-cccccccccccc',false,NULL,clock_timestamp(),'PRODUCTION');
DO $$ DECLARE l gymbro_trainer.links; draft jsonb; BEGIN
 SELECT * INTO l FROM gymbro_trainer.links WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc' AND ended_at IS NULL;
 draft:=public.trainer_execute(l.trainer_id,'plan_save',jsonb_build_object('id','dddddddd-dddd-4ddd-8ddd-dddddddddddd','link_id',l.id,'name','Race plan','document',jsonb_build_object('folders','[]'::jsonb,'custom_exercises','[]'::jsonb,'routines',jsonb_build_array(jsonb_build_object('id','eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee','name','Race routine','weight_unit','kg','distance_unit','km','exercises','[]'::jsonb)))));
 PERFORM public.trainer_execute(l.trainer_id,'publish',jsonb_build_object('link_id',l.id,'plan_id','dddddddd-dddd-4ddd-8ddd-dddddddddddd','version',draft->>'version'));
END $$;
COMMIT;
SQL
accept_offer() {
 psql_test <<'SQL'
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
SELECT public.trainer_execute('cccccccc-cccc-4ccc-8ccc-cccccccccccc','accept',jsonb_build_object('link_id',(SELECT id FROM gymbro_trainer.links WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc'),'plan_id','dddddddd-dddd-4ddd-8ddd-dddddddddddd','revision_id',(SELECT pending_id FROM gymbro_trainer.plans WHERE id='dddddddd-dddd-4ddd-8ddd-dddddddddddd')));
SELECT pg_sleep(0.15);
COMMIT;
SQL
}
end_relationship() {
 psql_test <<'SQL'
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
SELECT public.trainer_execute(trainer_id,'disconnect',jsonb_build_object('link_id',id)) FROM gymbro_trainer.links WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc';
COMMIT;
SQL
}
accept_offer >"$first_log" 2>&1 &
first_pid=$!
end_relationship >"$second_log" 2>&1 &
second_pid=$!
# Acceptance may succeed or observe termination; termination must always succeed.
wait "$first_pid" || true
if ! wait "$second_pid"; then cat "$second_log"; exit 1; fi
psql_test <<'SQL'
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM gymbro_trainer.links WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc' AND ended_at IS NULL)
 OR EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id='cccccccc-cccc-4ccc-8ccc-cccccccccccc')
 OR EXISTS(SELECT 1 FROM gymbro_trainer.plans WHERE id='dddddddd-dddd-4ddd-8ddd-dddddddddddd') THEN RAISE EXCEPTION 'Termination race left active controls'; END IF;
 IF EXISTS(SELECT 1 FROM public.routines WHERE id='eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee' AND deleted) THEN RAISE EXCEPTION 'Termination deleted an accepted routine'; END IF;
END $$;
SQL

# A hard Auth deletion races an acceptance with the same account lock.
psql_test <<'SQL' >/dev/null
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
INSERT INTO auth.users(id,email) VALUES('ffffffff-ffff-4fff-8fff-ffffffffffff','delete-race-client@race.invalid');
INSERT INTO gymbro_mcp.billing VALUES('ffffffff-ffff-4fff-8fff-ffffffffffff',false,NULL,clock_timestamp(),'PRODUCTION');
DO $$ DECLARE invitation jsonb; relationship jsonb; draft jsonb; BEGIN
 invitation:=public.trainer_execute('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','invite_create');
 relationship:=public.trainer_execute('ffffffff-ffff-4fff-8fff-ffffffffffff','invite_accept',jsonb_build_object('token',invitation->>'token'));
 draft:=public.trainer_execute('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','plan_save',jsonb_build_object('id','dddddddd-dddd-4ddd-8ddd-dddddddddd01','link_id',relationship->>'id','name','Deletion race plan','document',jsonb_build_object('folders','[]'::jsonb,'custom_exercises','[]'::jsonb,'routines',jsonb_build_array(jsonb_build_object('id','eeeeeeee-eeee-4eee-8eee-eeeeeeeeee01','name','Deletion race day','weight_unit','kg','distance_unit','km','exercises','[]'::jsonb)))));
 PERFORM public.trainer_execute('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','publish',jsonb_build_object('link_id',relationship->>'id','plan_id',draft->>'id','version',draft->>'version'));
END $$;
COMMIT;
SQL
accept_before_delete() {
 psql_test <<'SQL'
BEGIN;
SELECT set_config('request.jwt.claims','{"role":"service_role"}',true);
SELECT public.trainer_execute('ffffffff-ffff-4fff-8fff-ffffffffffff','accept',jsonb_build_object('link_id',(SELECT id FROM gymbro_trainer.links WHERE client_id='ffffffff-ffff-4fff-8fff-ffffffffffff'),'plan_id','dddddddd-dddd-4ddd-8ddd-dddddddddd01','revision_id',(SELECT pending_id FROM gymbro_trainer.plans WHERE id='dddddddd-dddd-4ddd-8ddd-dddddddddd01')));
SELECT pg_sleep(0.15);
COMMIT;
SQL
}
delete_coach() {
 psql_test <<'SQL'
DELETE FROM auth.users WHERE id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
SQL
}
accept_before_delete >"$first_log" 2>&1 &
first_pid=$!
delete_coach >"$second_log" 2>&1 &
second_pid=$!
wait "$first_pid" || true
if ! wait "$second_pid"; then cat "$second_log"; exit 1; fi
psql_test <<'SQL'
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM auth.users WHERE id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
 OR EXISTS(SELECT 1 FROM gymbro_trainer.links WHERE client_id='ffffffff-ffff-4fff-8fff-ffffffffffff')
 OR EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id='ffffffff-ffff-4fff-8fff-ffffffffffff')
 OR EXISTS(SELECT 1 FROM gymbro_trainer.plans WHERE id='dddddddd-dddd-4ddd-8ddd-dddddddddd01') THEN RAISE EXCEPTION 'Account deletion race left professional constraints'; END IF;
 IF NOT EXISTS(SELECT 1 FROM auth.users WHERE id='ffffffff-ffff-4fff-8fff-ffffffffffff') THEN RAISE EXCEPTION 'Coach deletion removed client'; END IF;
 IF EXISTS(SELECT 1 FROM public.routines WHERE id='eeeeeeee-eeee-4eee-8eee-eeeeeeeeee01' AND deleted) THEN RAISE EXCEPTION 'Account deletion removed accepted content'; END IF;
END $$;
SQL
