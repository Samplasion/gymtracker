#!/usr/bin/env bash
set -euo pipefail
container="$1"
psql_local() { docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 "$@"; }
# Fixed IDs live only in the isolated test container.
psql_local <<'SQL'
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000981','admin-race-a@test.local','{"username":"admin_race_a"}'),
 ('00000000-0000-0000-0000-000000000982','admin-race-b@test.local','{"username":"admin_race_b"}');
INSERT INTO public.reports(id,reporter_id,reported_id,reason,updated_at) VALUES
 ('00000000-0000-0000-0000-000000000983','00000000-0000-0000-0000-000000000981','00000000-0000-0000-0000-000000000982','race','2026-01-01Z');
SQL
race_dir=$(mktemp -d)
trap 'rm -rf "$race_dir"' EXIT
for operator in one two; do
 psql_local -c "SELECT public.admin_transition_report('00000000-0000-0000-0000-000000000983','received','2026-01-01Z','reviewing','Operator $operator');" >"$race_dir/$operator" 2>&1 &
done
wait || true
psql_local <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.report_notes WHERE report_id='00000000-0000-0000-0000-000000000983')<>1 THEN RAISE EXCEPTION 'Concurrent transition wrote duplicate notes'; END IF;
 IF (SELECT status FROM public.reports WHERE id='00000000-0000-0000-0000-000000000983')<>'reviewing' THEN RAISE EXCEPTION 'No transition committed'; END IF;
END $$;
INSERT INTO public.push_devices(id,user_id,token,platform) VALUES
 ('00000000-0000-0000-0000-000000000984','00000000-0000-0000-0000-000000000981','admin-concurrent-device','ios');
INSERT INTO public.push_deliveries(notification_id,device_id,attempts,available_at,finished_at,last_error)
 SELECT id,'00000000-0000-0000-0000-000000000984',8,'2026-01-01Z',now(),'FCM 503: UNAVAILABLE'
 FROM public.notifications WHERE report_id='00000000-0000-0000-0000-000000000983';
SQL
for operator in one two; do
 psql_local <<'SQL' >"$race_dir/push-$operator" 2>&1 &
BEGIN;
SELECT public.admin_requeue_push(
 (SELECT id FROM public.push_deliveries WHERE device_id='00000000-0000-0000-0000-000000000984'),
 8,'2026-01-01Z','00000000-0000-0000-0000-000000000982','Concurrent requeue');
SELECT public.claim_push_deliveries(100);
COMMIT;
SQL
done
wait || true
psql_local <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.admin_console_audit WHERE note='Concurrent requeue')<>1 OR
 NOT EXISTS(SELECT 1 FROM public.push_deliveries WHERE device_id='00000000-0000-0000-0000-000000000984' AND attempts=1 AND lease_id IS NOT NULL) THEN
 RAISE EXCEPTION 'Requeue race with worker lost atomicity'; END IF;
END $$;
DELETE FROM public.admin_console_audit WHERE note='Concurrent requeue';
DELETE FROM auth.users WHERE id IN ('00000000-0000-0000-0000-000000000981','00000000-0000-0000-0000-000000000982');
SQL
