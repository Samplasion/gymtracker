#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
container="gymtracker-v2-test-$$"
image="public.ecr.aws/supabase/postgres:17.6.1.155"
docker run --rm -d --name "$container" --tmpfs /var/lib/postgresql/data -e POSTGRES_PASSWORD=gymtracker-local-test "$image" >/dev/null
trap 'docker rm -f "$container" >/dev/null 2>&1 || true' EXIT
for attempt in {1..30}; do
  if docker exec "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -Atc "SELECT to_regclass('auth.users') IS NOT NULL AND to_regprocedure('auth.uid()') IS NOT NULL" 2>/dev/null | grep -qx t; then break; fi
  sleep 1
done
docker exec "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 -c "CREATE TABLE IF NOT EXISTS storage.objects(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),bucket_id text,name text); DO \$\$ BEGIN IF NOT EXISTS(SELECT 1 FROM pg_publication WHERE pubname='supabase_realtime') THEN CREATE PUBLICATION supabase_realtime; END IF; END; \$\$;"
for migration in supabase/migrations/*.sql; do
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$migration"
done
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/sync_v2.sql

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/social_posts.sql

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/friend_request_notifications.sql
