#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
container="gymtracker-personal-test-$$"
image="public.ecr.aws/supabase/postgres:17.6.1.155"
docker run --rm -d --name "$container" --tmpfs /var/lib/postgresql/data -e POSTGRES_PASSWORD=gymtracker-local-test "$image" >/dev/null
trap 'docker rm -f "$container" >/dev/null 2>&1 || true' EXIT
for attempt in {1..30}; do
  if docker exec "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -Atc "SELECT to_regclass('auth.users') IS NOT NULL" 2>/dev/null | grep -qx t; then break; fi
  sleep 1
done
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS storage.objects(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),bucket_id text,name text);
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT COALESCE(NULLIF(current_setting('request.jwt.claim.sub', true), ''), NULLIF(current_setting('request.jwt.claims', true), '')::jsonb->>'sub')::uuid; $$;
CREATE OR REPLACE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$ SELECT COALESCE(NULLIF(current_setting('request.jwt.claims', true), ''), '{}')::jsonb; $$;
SQL
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_oauth_fixture.sql
for migration in supabase/migrations/*.sql; do
  if [[ "$migration" == *20261031170000_trainer_plan_folders_and_account_deletion.sql ]]; then
    docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/trainer_plan_folder_upgrade.sql
  fi
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$migration" >/dev/null
done
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/personal_dashboard.sql
