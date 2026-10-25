#!/usr/bin/env bash
set -euo pipefail
container="$1"
case "$container" in gymtracker-v2-test-*) ;; *) echo 'Expected disposable test container' >&2; exit 1;; esac
scratch=$(mktemp -d)
trap 'result=$?; if [ "$result" -ne 0 ]; then cat "$scratch"/*.log; fi; rm -rf "$scratch"' EXIT
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO auth.users(id,email,raw_user_meta_data)
 SELECT ('00000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,'catalog-race-'||i||'@test.invalid',jsonb_build_object('username','catalograce'||i)
 FROM generate_series(810,815) i;
SQL
cat > "$scratch/publish.sql" <<'SQL'
SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000810',false);
SELECT public.submit_catalog_food('00000000-0000-0000-0000-000000000819',
 '{"name":"Concurrent product","barcode":"0000810","nutritionalValuesPer100g":{"calories":0,"fat":0,"saturatedFat":0,"carbs":0,"sugar":0,"protein":0}}');
SQL
pids=()
for i in 1 2; do
 docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$scratch/publish.sql" > "$scratch/publish-$i.log" 2>&1 &
 pids+=("$!")
done
for pid in "${pids[@]}"; do wait "$pid"; done
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT count(*) FROM public.food_catalog WHERE barcode='0000810')<>1 OR (SELECT count(*) FROM gymbro_food.receipts WHERE operation_id='00000000-0000-0000-0000-000000000819')<>1 THEN RAISE EXCEPTION 'Concurrent publication was not idempotent'; END IF;
END $$;
SQL
product_id=$(docker exec "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -Atc "SELECT id FROM public.food_catalog WHERE barcode='0000810'")
cat > "$scratch/report.sql" <<'SQL'
SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub',:'account',false);
SELECT public.report_catalog_food(:'product'::uuid,'spam','Concurrent report');
SQL
pids=()
for i in 811 812 813 814 815; do
 account="00000000-0000-0000-0000-$(printf '%012d' "$i")"
 for repeat in 1 2; do
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 -v account="$account" -v product="$product_id" < "$scratch/report.sql" > "$scratch/report-$i-$repeat.log" 2>&1 &
  pids+=("$!")
 done
done
for pid in "${pids[@]}"; do wait "$pid"; done
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ DECLARE product public.food_catalog; BEGIN
 SELECT * INTO product FROM public.food_catalog WHERE barcode='0000810';
 IF product.status<>'suspended' OR product.version<>2 OR (SELECT count(*) FROM public.food_catalog_reports WHERE food_id=product.id)<>5 OR (SELECT count(*) FROM public.food_catalog_audit WHERE food_id=product.id AND action='auto_suspend')<>1 THEN RAISE EXCEPTION 'Concurrent reports lost votes or suspended more than once'; END IF;
END $$;
SQL
