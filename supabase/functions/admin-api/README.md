# Administrative API

The Flutter console and operational contract are documented in
`gym_bro_admin/README.md` in the adjacent workspace.

Run locally with Supabase CLI after applying all migrations. The handler
verifies JWTs itself and fetches the live Auth user before every operation.
Never replace this check with cached JWT metadata or client-provided operator
identity.

```sh
deno check supabase/functions/admin-api/index.ts
deno test supabase/functions/admin-api/handler_test.ts supabase/functions/admin-api/dashboard_test.ts
BACKEND_TEST_FILTER=food_catalog bash tools/test_sync_v2_backend.sh
```

The SQL migration grants new RPC execution only to service_role; browser/native
clients call the authenticated Edge Function. Food administration continues to
use the existing catalog RPCs. Social transitions atomically change state and
insert an internal note, leaving notification triggers responsible for delivery.
Push retries lock and revalidate a single delivery and append a dedicated audit
record without exposing device tokens.

No migrations or functions are deployed automatically. Remote deployment
requires separate review and authorization as specified in
`internal_docs/ADMIN.md`.

The `dashboard` operation uses exact database counts and returns a server
timestamp, catalog counts by status, pending correction/open report counts,
received/reviewing social counts, push queue/error/exhaustion counts, and the
latest five catalog audit actions. It uses the same live administrator gate as
all other operations. No new migration is needed; existing deployments must
redeploy `admin-api` to expose this operation.
