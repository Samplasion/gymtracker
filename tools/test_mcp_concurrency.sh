#!/usr/bin/env bash
# Internal helper: uses only the disposable container created by the backend suite.
set -euo pipefail
container="$1"
case "$container" in gymtracker-v2-test-*) ;; *) echo 'Expected disposable test container' >&2; exit 1;; esac
task_tmp=$(mktemp -d)
trap 'rm -rf "$task_tmp"' EXIT
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES('00000000-0000-0000-0000-000000000051','mcp-concurrent@unit.test','{"username":"mcpconcurrent"}');
SELECT public.test_mcp_oauth('00000000-0000-0000-0000-000000000051');
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000051',true,NULL,now(),'PRODUCTION');
INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp');
SQL
cat > "$task_tmp/request.sql" <<'SQL'
BEGIN;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000051","session_id":"00000000-0000-0000-0000-000000000051","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SELECT public.mcp_create_program('{"name":"Concurrent","routines":[{"name":"One","exercises":[{"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"sets":[{"reps":8}]}]}]}','00000000-0000-0000-0000-000000000052');
SELECT pg_sleep(0.2);
COMMIT;
SQL
for i in 1 2; do
 docker exec -i "$container" psql -qAt -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$task_tmp/request.sql" > "$task_tmp/result-$i" &
 if [ "$i" = 1 ]; then first_pid=$!; else second_pid=$!; fi
done
wait "$first_pid"
wait "$second_pid"
cmp "$task_tmp/result-1" "$task_tmp/result-2"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM gymbro_mcp.receipts WHERE user_id='00000000-0000-0000-0000-000000000051')<>1
 OR (SELECT count(*) FROM public.routine_folders WHERE user_id='00000000-0000-0000-0000-000000000051')<>1
 OR (SELECT count(*) FROM public.routines WHERE user_id='00000000-0000-0000-0000-000000000051')<>1
 OR (SELECT count(*) FROM public.routine_exercises WHERE user_id='00000000-0000-0000-0000-000000000051')<>1
 THEN RAISE EXCEPTION 'Concurrent retry created duplicates'; END IF;
END $$;
SQL
if [ -n "${MCP_COMPATIBILITY_FIXTURE:-}" ]; then
 docker exec "$container" psql -qAt -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 -c "SELECT jsonb_build_object('routine',to_jsonb(r),'folder',to_jsonb(f),'exercises',(SELECT jsonb_agg(to_jsonb(e) ORDER BY e.sort_order) FROM public.routine_exercises e WHERE e.routine_id=r.id AND e.user_id=r.user_id)) FROM public.routines r JOIN public.routine_folders f ON f.id=r.folder_id AND f.user_id=r.user_id WHERE r.user_id='00000000-0000-0000-0000-000000000051'" > "$MCP_COMPATIBILITY_FIXTURE"
fi
# Two distinct requests compete for the final Free routine slot.
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES('00000000-0000-0000-0000-000000000091','mcp-quota@unit.test','{"username":"mcpquota"}');
SELECT public.test_mcp_oauth('00000000-0000-0000-0000-000000000091');
INSERT INTO gymbro_mcp.billing VALUES('00000000-0000-0000-0000-000000000091',false,NULL,now(),'PRODUCTION');
BEGIN;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000091","session_id":"00000000-0000-0000-0000-000000000091","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SELECT public.mcp_create_program(jsonb_build_object('name','Free initial','routines',(SELECT jsonb_agg('{"name":"Day","exercises":[{"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"sets":[{"reps":8}]}]}'::jsonb) FROM generate_series(1,3))),gen_random_uuid());
COMMIT;
SQL
cat > "$task_tmp/quota.sql" <<'SQL'
BEGIN;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000091","session_id":"00000000-0000-0000-0000-000000000091","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SELECT public.mcp_create_program('{"name":"Final slot","routines":[{"name":"Final","exercises":[{"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"sets":[{"reps":8}]}]}]}',gen_random_uuid());
SELECT pg_sleep(0.2);
COMMIT;
SQL
for i in 1 2; do
 docker exec -i "$container" psql -qAt -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$task_tmp/quota.sql" > "$task_tmp/quota-$i" 2>&1 &
 if [ "$i" = 1 ]; then first_pid=$!; else second_pid=$!; fi
done
successes=0
if wait "$first_pid"; then successes=$((successes+1)); fi
if wait "$second_pid"; then successes=$((successes+1)); fi
[ "$successes" = 1 ] || { echo 'Expected exactly one competing Free write to succeed' >&2; exit 1; }
rg -q 'plan_limit_exceeded' "$task_tmp/quota-1" "$task_tmp/quota-2"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.routines WHERE user_id='00000000-0000-0000-0000-000000000091' AND NOT deleted)<>4
 OR EXISTS(SELECT 1 FROM public.routine_folders WHERE user_id='00000000-0000-0000-0000-000000000091')
 THEN RAISE EXCEPTION 'Concurrent Free quota was bypassed'; END IF;
END $$;
SQL

# Concurrent retries of a mixed measurement batch must produce one receipt and IDs.
cat > "$task_tmp/measurements.sql" <<'SQL'
BEGIN;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000091","session_id":"00000000-0000-0000-0000-000000000091","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SELECT public.mcp_execute('create_measurements','{"entries":[{"kind":"weight","value":70},{"kind":"body","type":"waist","value":80}]}','00000000-0000-0000-0000-000000000095');
SELECT pg_sleep(0.2);
COMMIT;
SQL
for i in 1 2; do
 docker exec -i "$container" psql -qAt -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$task_tmp/measurements.sql" > "$task_tmp/measurements-$i" &
 if [ "$i" = 1 ]; then first_pid=$!; else second_pid=$!; fi
done
wait "$first_pid"
wait "$second_pid"
cmp "$task_tmp/measurements-1" "$task_tmp/measurements-2"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.weight_measurements WHERE user_id='00000000-0000-0000-0000-000000000091')<>1
 OR (SELECT count(*) FROM public.body_measurements WHERE user_id='00000000-0000-0000-0000-000000000091')<>1
 OR (SELECT count(*) FROM gymbro_mcp.operations WHERE user_id='00000000-0000-0000-0000-000000000091' AND operation='create_measurements')<>1
 THEN RAISE EXCEPTION 'Concurrent measurement retry duplicated data'; END IF;
END $$;
SQL

# Water retries share the account lock and cross-operation receipt namespace.
cat > "$task_tmp/water.sql" <<'SQL'
BEGIN;
SET LOCAL ROLE gymbro_mcp_user;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-0000-0000-000000000091","session_id":"00000000-0000-0000-0000-000000000091","role":"gymbro_mcp_user","client_id":"00000000-0000-0000-0000-000000000090","aud":["https://gym-bro.test/mcp"]}';
SELECT public.mcp_execute('log_water','{"entries":[{"milliliters":500.25},{"milliliters":125.5}]}','00000000-0000-0000-0000-000000000096');
SELECT pg_sleep(0.2);
COMMIT;
SQL
for i in 1 2; do
 docker exec -i "$container" psql -qAt -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$task_tmp/water.sql" > "$task_tmp/water-$i" &
 if [ "$i" = 1 ]; then first_pid=$!; else second_pid=$!; fi
done
wait "$first_pid"
wait "$second_pid"
cmp "$task_tmp/water-1" "$task_tmp/water-2"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.water_logs WHERE user_id='00000000-0000-0000-0000-000000000091')<>2
 OR (SELECT sum((json_data::jsonb->>'milliliters')::numeric) FROM public.water_logs WHERE user_id='00000000-0000-0000-0000-000000000091')<>625.75
 OR (SELECT count(*) FROM gymbro_mcp.operations WHERE user_id='00000000-0000-0000-0000-000000000091' AND operation='log_water')<>1
 THEN RAISE EXCEPTION 'Concurrent water retry duplicated data'; END IF;
END $$;
SQL
