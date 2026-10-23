# Gym Bro MCP / ChatGPT

This integration exposes five authenticated tools: `search_exercises`,
`get_exercises`, `list_routines`, `get_routine`, and `create_program`.
ChatGPT composes a proposal; it calls `create_program` only after the user asks
it to save. There is no model call, OpenAI API key, public directory listing,
or embedded ChatGPT UI in this server.

## Components and permissions

- `supabase/functions/mcp`: official MCP TypeScript SDK 2.0.0, stateless
  Streamable HTTP, structured and text results, schemas, tool annotations.
- `supabase/migrations/20261023100000_mcp.sql`: RPCs, internal catalog/config,
  idempotency receipts and OAuth hook. No existing data is rewritten and the
  optional sync-v2 activation function is not called.
- `supabase/migrations/20261023101000_mcp_catalog.sql`: catalog generated from
  the actual Flutter exercise models and Italian/English translations.
- `gym-bro-landing`: existing Next.js login plus `/oauth/consent`, localized
  consent, safe internal login redirects and account grant revocation.
- The checked-in copies of `delete-user-complete` and `gdpr-data-export` were
  retrieved read-only from the linked project. Their new guard rejects delegated
  OAuth JWTs before any account-management/admin operation. The scheduled push
  worker uses a separate secret and does not accept user OAuth credentials.

MCP tokens use `gymbro_mcp_user`, **not** `authenticated`. The role has no table
privileges or membership in `authenticated`; only the four MCP RPCs are granted.
Each RPC also checks the signed subject, role, registered client and audience.
Existing public function grants to PUBLIC are converted to explicit grants for
existing anon/authenticated/service callers, preserving their current access.
Future migrations must not grant private tables or unrelated RPCs to PUBLIC or
to `gymbro_mcp_user`; the backend test audits those permissions.

The server verifies asymmetric ES256/RS256 JWTs against Supabase JWKS, issuer,
canonical resource audience, expiry/not-before and the configured OAuth client.
The database repeats the identity checks, so callers cannot bypass them through
PostgREST. No service-role key is used by the MCP function. Ordinary app/site
sessions keep their existing claims and privileges.

Supabase's `openid` scope is for identity; it is not a database permission scope.
The dedicated database role is the authorization boundary. Unknown OAuth clients
also receive that isolated role and fail the MCP client allowlist.

## Tool contract

References are `{ "source": "standard" | "custom", "id": "..." }`.
Search matches Italian and English names, optionally category, equipment and all
specified primary/secondary muscles. Both searches and routine lists return
`items` and nullable `nextOffset`. Search also returns `catalogVersion`.
Custom exercise names are returned unchanged. Deleted and other-user data are
never returned. Missing exercise references are listed in `unavailable`.

Example write (one folder, any number of daily routines between 1 and 31):

```json
{
  "idempotencyKey": "d1e1f23d-1d18-48b5-a20b-5d7038b8ac09",
  "program": {
    "name": "Programma tre giorni",
    "routines": [{
      "name": "Giorno 1",
      "weightUnit": "kg",
      "distanceUnit": "km",
      "exercises": [{
        "exerciseRef": {
          "source": "standard",
          "id": "library.chest.exercises.barbellBenchPressFlat"
        },
        "restSeconds": 120,
        "sets": [{ "kind": "normal", "reps": 8 }]
      }]
    }]
  }
}
```

Optional notes default to empty strings; unit defaults are kg/km, kind defaults
to normal and rest defaults to zero. A weight omitted for a weighted exercise is
zero (unspecified load), not a guessed prescription. Durations use `timeSeconds`
in the MCP interface and microseconds in stored GTSet JSON. Distances follow the
routine unit. The database enforces parameter compatibility and generates IDs,
set parameter names and exercise metadata itself. Setless exercises require `[]`.
Creation is limited to simple exercises, up to 100 exercises per routine and 100
sets per exercise; no creation of supersets/progressions/custom definitions.
Existing supersets/progressions are preserved when reading routines.

A canonical tool retry uses the same UUID and identical normalized program.
Receipts are durable and scoped to the user. Reusing a key with a different
payload gives `idempotency_conflict`; invalid input gives `invalid_input`;
unavailable references give `reference_unavailable`. Authentication failures
return a challenge; unexpected backend errors are sanitized as `server_error`.
No user-supplied owner, UUID, exercise type or metadata is accepted in creation.

The creation RPC locks the sync account row, creates the entire hierarchy and
receipt in one transaction, sets the existing sync-v2 transaction context and
lets the existing revision/change-log triggers run. Any validation error rolls
back everything. Routine ordering follows the payload, and the new folder is
appended. Realtime/pull delivers it to clients without changing Flutter sync.

## Local verification

```sh
# Set FLUTTER if your shell's Flutter wrapper points to a missing SDK.
FLUTTER=/path/to/flutter/bin/flutter bash tools/export_mcp_catalog.sh --dart-define=CHECK_CATALOG=true
flutter test --no-pub test/model/mcp_compatibility_test.dart
cd supabase/functions/mcp
deno task check
deno task test
cd ../../..
deno test supabase/functions/_shared/first_party_test.ts
bash tools/test_sync_v2_backend.sh
```

The SQL suite uses a disposable Docker Postgres container, with no published
ports, not the linked project. It tests existing sync/social behavior as well as
atomicity, rollback, permissions, units, pagination, post-activation writes,
change-log delivery and simultaneous retries from two connections.
`MCP_COMPATIBILITY_FIXTURE=test/fixtures/mcp_program.json` regenerates the Flutter
compatibility fixture from an actually persisted SQL program during that suite.
It is a synthetic test account, never production data.

In `gym-bro-landing`, run `yarn test:oauth`, `yarn lint`, `yarn build`.
The build needs the site's MongoDB service; use an isolated test database when
checking the build. It must not run migrations against the live CMS database.

Regenerate the initial catalog with `bash tools/export_mcp_catalog.sh`. After a
catalog migration has been deployed, **do not rewrite that applied migration**:
pass `--dart-define=CATALOG_MIGRATION=supabase/migrations/<new_timestamp>_mcp_catalog.sql`
to generate a new migration and pass the same flag to the check command. Deploy
the registry migration and matching Edge JSON together.

## Staged deployment

1. Verify the migration history and real schema. The repository baseline is a
   snapshot of an existing database: do not replay it on production. Deploy the
   required existing incremental sync-v2 migrations if absent, then the two MCP
   migrations. Do not call `activate_sync_v2()` as part of this feature.
2. Deploy the protected account-management functions **before enabling OAuth**:
   `supabase functions deploy delete-user-complete` and
   `supabase functions deploy gdpr-data-export`. Their middleware verifies JWTs
   itself; the checked-in function config disables the legacy gateway JWT gate.
   Audit any additional deployed functions introduced later for admin bypasses.
3. Configure asymmetric signing keys in Supabase Auth and make JWKS reachable.
   Deploy the site and MCP function into a test environment first. Keep Auth OAuth
   disabled until the hook, role, settings and account-management guards exist.
4. Register a dedicated static OAuth client for ChatGPT (authorization code +
   S256 PKCE). Leave dynamic registration disabled. Obtain the exact redirect URI
   from ChatGPT's MCP connection configuration and register exactly that URI;
   do not guess between stable and callback-specific redirect formats.
5. The function can serve discovery before a client is registered; authenticated
   tool calls fail closed until the client ID and settings row are configured.
   Set `MCP_OAUTH_CLIENT_ID` and `MCP_RESOURCE_URL` on the MCP function. The latter
   is its canonical external URL, e.g.
   `https://<project-ref>.supabase.co/functions/v1/mcp`, without a trailing slash.
   Set `MCP_SITE_ORIGIN=https://gym-bro.techtonicfault.com` (or the test site's
   origin). Supabase supplies its URL and public/anon key to the runtime.
6. Set these **server-only** site variables: `MCP_OAUTH_CLIENT_ID`,
   `MCP_CHATGPT_REDIRECT_URI`. Use the same Supabase URL and publishable key as
   Gym Bro, via `NEXT_PUBLIC_SUPABASE_URL` and
   `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`; the legacy ANON_KEY name is supported.
   Keep the existing CMS/database configuration. Do not add any service key to
   browser environment variables.
7. Configure the private settings row as the database operator:

   ```sql
   INSERT INTO gymbro_mcp.settings(singleton, client_id, resource)
   VALUES (true, '<registered-client-id>', '<canonical-MCP-resource-URL>')
   ON CONFLICT (singleton) DO UPDATE
   SET client_id=EXCLUDED.client_id, resource=EXCLUDED.resource;
   ```

8. Enable `public.gymbro_mcp_access_token_hook` as the Auth custom access-token
   hook. If another token hook is configured, compose its existing claims logic
   with this hook rather than discarding it. Verify an ordinary login/refresh
   still has its existing role, and an OAuth login/refresh has the isolated role,
   the registered client ID and both `authenticated` and canonical MCP audiences.
9. In Auth OAuth Server, set the authorization path to `/oauth/consent`,
   configure the site URL as the landing site's origin, keep dynamic registration
   off and enable OAuth. Local config already includes these OAuth/hook settings;
   the canonical resource may use HTTP only for loopback development.
10. Connect the HTTPS endpoint privately in ChatGPT with the static client's
    credentials. Confirm discovery, login/consent, rejection, token refresh,
    search, proposal, save, retry, receipt IDs, and appearance in the mobile app.
    A token must fail when used against sync, social, Storage writes, GDPR export
    and account deletion. Confirm both a normal web session and mobile session
    still work. Run the same checks in staging before production promotion.

The function serves protected-resource metadata below its own endpoint and
advertises that URL in every 401 challenge. This works without controlling
`/.well-known` at the root of the shared Supabase domain. Gateway-stripped and
external function paths are both supported. Requests from unapproved browser
origins are rejected; the site origin and ChatGPT origin are allowed.

Revocation uses Supabase OAuth grants from the site's account page. It stops
renewal; already-issued JWTs can remain usable until their expiry. Keep access
JWT expiry at 3600 seconds or less. Validate refresh/revocation behavior in the
actual hosted Auth version; offline JWT verification does not promise immediate
access-token invalidation.

Observe Supabase request/error/timing metrics; do not log Authorization headers,
OAuth codes, credentials or program bodies. Disable the MCP endpoint/remove the
ChatGPT connection and disable OAuth to roll back exposure; keep saved programs,
receipts and sync history. Existing app sessions are independent of OAuth.

## References

- https://supabase.com/docs/guides/ai-tools/byo-mcp
- https://supabase.com/docs/guides/auth/oauth-server/token-security
- https://supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook
- https://developers.openai.com/plugins/build/auth
- https://developers.openai.com/plugins/deploy/connect-chatgpt
