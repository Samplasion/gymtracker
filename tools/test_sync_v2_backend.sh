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
# This Postgres image contains auth.uid(), but not the Auth-service JWT helper.
# Provide the official helper shape only in this disposable test database.
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
 SELECT COALESCE(NULLIF(current_setting('request.jwt.claim.sub', true), ''), NULLIF(current_setting('request.jwt.claims', true), '')::jsonb->>'sub')::uuid;
$$;
CREATE OR REPLACE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$
 SELECT COALESCE(NULLIF(current_setting('request.jwt.claims', true), ''), '{}')::jsonb;
$$;
SQL
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_oauth_fixture.sql
for migration in supabase/migrations/*.sql; do
  if [[ "$migration" == *20261024130000_mcp_measurements_oauth.sql ]]; then
    docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_oauth_upgrade.sql
  fi
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < "$migration"
done
if [[ "${BACKEND_TEST_FILTER:-}" == "recipes" ]]; then
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/recipes.sql
  exit 0
fi
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
 IF (SELECT time_zone FROM gymbro_mcp.preferences WHERE user_id='00000000-0000-0000-0000-000000000901') IS DISTINCT FROM 'Europe/Rome'
 OR (SELECT time_zone FROM gymbro_mcp.preferences WHERE user_id='00000000-0000-0000-0000-000000000902') IS DISTINCT FROM 'UTC'
 OR to_regclass('gymbro_mcp.consents') IS NOT NULL OR to_regprocedure('public.mcp_manage_consent(boolean,text)') IS NOT NULL
 THEN RAISE EXCEPTION 'OAuth migration failed to preserve preferences or remove old consent'; END IF;
END $$;
DELETE FROM auth.users WHERE id IN ('00000000-0000-0000-0000-000000000901','00000000-0000-0000-0000-000000000902');
SQL
docker cp supabase/migrations/20261025200000_seed_hydration_food_catalog.sql "$container:/tmp/hydration_catalog_seed.sql"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/hydration_catalog.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/admin_console.sql
bash tools/test_admin_console_concurrency.sh "$container"
if [[ "${BACKEND_TEST_FILTER:-}" == "food_catalog" ]]; then
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/food_catalog.sql
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/food_catalog_create_only.sql
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/catalog_operators.sql
  bash tools/test_food_catalog_concurrency.sh "$container"
  exit 0
fi
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/sync_v2.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/hydration.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/recipes.sql

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/social_posts.sql

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/friend_request_notifications.sql

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_oauth_clients.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/negative_weight.sql
expanded_log=$(mktemp)
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_capabilities.sql | tee "$expanded_log"
if [ -n "${MCP_EXPANDED_COMPATIBILITY_FIXTURE:-}" ]; then
 python3 - "$expanded_log" "$MCP_EXPANDED_COMPATIBILITY_FIXTURE" <<'PYFIXTURE'
import json, sys
from pathlib import Path
line = next(line for line in Path(sys.argv[1]).read_text().splitlines() if line.startswith('MCP_EXPANDED_FIXTURE:'))
Path(sys.argv[2]).write_text(json.dumps(json.loads(line.split(':', 1)[1]), indent=2) + '\n')
PYFIXTURE
fi
rm -f "$expanded_log"
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_measurements.sql
docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/mcp_hydration.sql
bash tools/test_mcp_concurrency.sh "$container"

docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/food_catalog.sql
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/food_catalog_create_only.sql
  docker exec -i "$container" psql -h 127.0.0.1 -U supabase_admin -d postgres -v ON_ERROR_STOP=1 < test/backend/catalog_operators.sql

bash tools/test_food_catalog_concurrency.sh "$container"
