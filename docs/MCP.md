# Gym Bro MCP / ChatGPT

Private, authenticated Streamable HTTP integration. The server now publishes
22 tools; it does not call a model or need an OpenAI API key. Existing endpoint,
OAuth client and the original five tool names are preserved.

## Capabilities

| Area | Tools |
| --- | --- |
| Exercise catalog | `search_exercises`, `get_exercises`, `create_custom_exercises` |
| Routines and folders | `list_routines`, `get_routine`, `get_routines`, `create_routines`, `create_program`, `list_routine_folders`, `create_routine_folders` |
| Saved training | `list_workouts`, `get_workouts`, `get_exercise_history`, `get_training_stats` |
| Account | `get_account_limits` |
| Nutrition | `search_foods`, `get_foods`, `list_food_entries`, `get_food_entries`, `log_foods`, `get_nutrition_summary`, `get_nutrition_settings` |

No update/delete operations, workout-history writes, live workout controls,
nutrition-goal/category edits, favorites/barcode-catalog edits, or social access.
Writes are called only after the user requests saving. Arrays containing one
item implement single-item operations; bulk writes are atomic.

Inputs are strict Zod schemas in `supabase/functions/mcp/schemas.ts` and the
registered tool definitions. Results have matching structured/text representations.
New lists return `items` and `nextCursor`; the original list/search tools retain
`nextOffset`. Cursors bind to the original filters and page size for OFF search.
Database lists have deterministic ordering; cursors are not historical snapshots.
Date intervals are inclusive and bounded to 367 days per request. Training
aggregation is bounded to 1,000 logical workouts and nutrition summaries to
10,000 consumptions; larger inputs are rejected explicitly. Detail batches
are limited to 20 IDs, food logs to 100 entries, routine creations to 31,
custom exercises to 100 and folders to 31. Request/result size is bounded to 1MiB;
narrow the interval or batch when a result is too large.

`unavailable` never distinguishes missing, deleted or other-user references.
All writes use a UUID `idempotencyKey`: reuse it with identical normalized input
on retry. A different operation/payload conflicts. Prior `create_program` receipts
remain valid; new program receipts also remain in the original receipt table.
Receipts for the other operations are kept separately, with cross-table conflict
checks. Successful retries do not consume quota or need fresh billing.

## Complete routines and logical workout history

`create_program` and `create_routines` use the same routine schema. The legacy
simple exercise shape still works. A superset entry is:

```json
{"type":"superset","restSeconds":120,"notes":"Alternate the exercises","exercises":[
  {"exerciseRef":{"source":"standard","id":"library.chest.exercises.barbellBenchPressFlat"},"sets":[{"reps":8}]},
  {"exerciseRef":{"source":"standard","id":"library.abs.exercises.bicycleCrunches"},"sets":[{"reps":12}]}
]}
```

Supersets are one level deep, with ordered children and independent notes/rests.
All five set kinds and all six parameter types are supported, including setless
exercises (`sets: []`), exercise/set RPE and kg/lb/km/mi units. Missing weight is
zero, never an inferred recommendation. Set times are seconds at the MCP boundary
and microseconds in stored GTSet JSON; rests and workout duration are seconds.
IDs, muscle groups, equipment and set parameters are server-generated/resolved.

Exercise `progression` supports `doubleProgression` and `cyclicLinear` with
`minReps`, `maxReps`, `repsPerStep`, `startingWeight`, `weightPerStep`,
`weightPerCycle`, optional `cycle`, `step`, `targetReps`. Working-set count is
computed from normal sets. Defaults start at cycle/step zero. Validation follows
Flutter; cyclic progression requires a weighted rep exercise. Progression state
continues advancing through the existing app lifecycle, not through MCP writes.

`get_routine` retains its flat `exercises` and adds hierarchical `entries`.
Notes retain their stored representation; `notesText` exposes readable Quill text.
Original and continuation workouts are composed with the same modern/legacy
supersedence rules as Flutter. Logical IDs use the original session, with
`componentIds`, raw-session details and missing-component warnings. Active
durations exclude gaps between sessions. Filters/pagination operate on logical
workouts; totals count each logical workout and performed set once.

## Food diary and sources

`search_foods` searches only the account's local favorites and personal barcode
food definitions. The default source is `all`; `favorite` and `customBarcode`
restrict the search. No Open Food Facts search is performed. References are
`{source,id}` and always identify the actual local source. These definitions are
read-only. This is not a complete local food catalog; missing foods require
explicit manual nutritional values until that database is available.

`get_foods` still supports explicit Open Food Facts barcode references; it does
not search that catalog. External product definitions are cached privately.

Migration `20261023120000_mcp_local_foods.sql` also reads existing JSONB strings
from Flutter and native JSON documents from MCP for categories and foods, without
rewriting existing records. Deploy this migration and the `mcp`/`mcp-services`
functions together, then refresh the ChatGPT connection's tool metadata.

`log_foods` accepts `{idempotencyKey,entries:[{date,amount,pieces,category?,foodRef? ,food?}]}`.
Provide exactly one of `foodRef` or a manual `food` definition. Manual definitions
contain `name`, optional `brand`, `unit` (`g`/`ml`), `servingSizes` and
`nutritionalValuesPer100g`. Calories, fat, saturated fat, carbs, sugar and protein
are mandatory. Other fields use Flutter's nutrient units (exposed as
`nutrientUnits`); unknown optional values stay unknown. Incomplete catalog foods
must be completed explicitly as a manual definition before logging.

Consumed totals are `valuesPer100 * amount * pieces / 100`. No implicit
mass/volume conversion is performed. Category names must exist for the requested
day; omitted means unassigned. Each consumption stores a snapshot. Definitions
never change existing logs. Dates are `YYYY-MM-DD`, stored at UTC midnight as
calendar dates, following the existing database convention.

Settings follow Flutter DateSequence: latest effective settings, earliest fallback
before the first record, app defaults if there are no goals. Defaults are marked
and never written implicitly. Summaries include empty days, meal totals,
remaining macros and missing optional nutrient indicators.

Open Food Facts requests use an app User-Agent, attribution, shared cache and
a shared conservative budget of 15 product lookups per minute.
Product cache is 24 hours. The search service action is disabled, including for
stale clients. Timeouts/provider limits
produce explicit errors. No user identity or diary content is sent to OFF.

## Troubleshooting billing refresh

If nutrition tools report `invalid_input: Gym Bro service unavailable` after
billing was refreshed, redeploy the current `mcp-services` function. PostgREST
returns HTTP 204 for `mcp_store_billing` (a void RPC); the adapter must accept that
empty successful response without trying to parse JSON. Older adapters saved the
billing state but then reported a parse error, often on the first request after
the five-minute cache expired. This fix needs no migration or OAuth reset.

## Billing, isolation and consent

| Capability | Free | Pro |
| --- | --- | --- |
| Active routines, all sources | 4 total | No commercial cap |
| Active personal exercises | 10 total | No commercial cap |
| Create folders | Denied | Allowed |
| `create_program` destination | Home | New folder |
| Nutrition diary/settings/summary dates | Today ±7 days, inclusive | Any supported date |
| Basic training reads, food catalog lookup | Allowed | Allowed |

Technical batch limits still apply to Pro. Free programs return `folderId:null`,
`placement:"root"` and a warning that folder name/notes were not saved; routine
names/notes are unchanged. No records are deleted on downgrade. Explicit folder
selection by a Free caller is rejected. Tombstones do not count toward quotas.

The database repeats every ownership, permission, consent and quota check.
MCP tokens use isolated role `gymbro_mcp_user` with no direct table privileges.
All new functions use closed `search_path` and explicit grants. Writes acquire
the same account lock as sync v2 and run with its transaction context/triggers.
Quota checks consider the entire bulk. Concurrent requests cannot both consume
the final Free slot. The app's existing offline/sync commercial behavior is not
changed by this implementation.

The MCP transport has no service key. It invokes the separate `mcp-services`
adapter using the verified user bearer. The adapter verifies issuer, audience,
client, signature and role again. Its service key can only be used by code paths
that refresh a verified account's RevenueCat state, cache public products or
process authenticated RevenueCat events. The user cannot choose another billing
account. Catalog operations repeat database consent checks before external calls.

RevenueCat App User ID is the Supabase UUID already used by Flutter. The adapter
uses the same entitlement ID as the app. State is checked on first use and after
5 minutes, with webhook-driven refresh in between. Expiration is evaluated even
inside the cache lifetime; cancellation of renewal does not revoke access early.
Lifetime access, trial, grace periods and transfers are supported. Sandbox
purchases never grant production Pro. Webhooks use the dedicated Authorization
secret, deduplicate successful events and refetch authoritative subscriber data
instead of replaying stale event state. Configure this secret as a high-entropy
value in RevenueCat; never reuse a user JWT or service key.

Fresh cached state can be used during an outage. Without a fresh verified state,
writes and plan-restricted nutrition reads return `billing_unavailable`; unrelated
reads still work. No client-supplied plan or entitlement is accepted. The cache
means entitlement changes may take up to 5 minutes to propagate if a webhook is
missed. `get_account_limits` is informational, not an authorization token.

Expanded operations require version-2 application consent. Legacy simple
`create_program` and the four original reads keep their earlier consent behavior,
but writes enforce billing. Advanced creation requires expanded consent.
The ordinary authenticated website calls `mcp_manage_consent`; MCP tokens cannot
approve themselves. Users approve at `/oauth/capabilities` (localized internally),
including workout history and food read/log access, and can change their IANA
time zone there. The server derives today's diary date in that stored zone.
Requests cannot supply their own "today". Existing OAuth grants route through
this page if expanded consent is missing, without replacing client/connection.
Revocation in account management also removes application consent.

Error codes include `authentication_required`, `consent_required`, `invalid_input`,
`reference_unavailable`, `idempotency_conflict`, `plan_limit_exceeded`,
`pro_required`, `billing_unavailable`, `external_rate_limited`,
`external_service_unavailable`, `result_too_large`, `server_error`.
Unexpected provider/database messages are sanitized. Do not log bodies, queries,
food/training content, tokens or credentials.

## Verification

```sh
(cd supabase/functions/mcp && deno task check && deno task test)
(cd supabase/functions/mcp-services && deno task check && deno task test)
bash tools/test_sync_v2_backend.sh
flutter test --no-pub test/model/mcp_compatibility_test.dart test/model/mcp_expanded_compatibility_test.dart test/model/progression_test.dart test/model/workout_test.dart
```

The backend suite uses disposable Docker Postgres, never the linked project.
It tests sync/social regressions, post-gate writes, permissions, atomicity,
concurrent retries and competing Free quota writes. To regenerate synthetic
Flutter fixtures from persisted SQL, set `MCP_COMPATIBILITY_FIXTURE` or
`MCP_EXPANDED_COMPATIBILITY_FIXTURE` to their respective fixture paths when
running the suite. In `gym-bro-landing`, run `npm run test:oauth`, `npm run lint`,
`npm run build`; use an isolated local MongoDB for the build, not the live CMS.

Catalog generation still uses the Flutter runtime via `tools/export_mcp_catalog.sh`.
Use `--dart-define=CHECK_CATALOG=true` for verification. Never rewrite deployed
catalog migrations; generate a new migration path for catalog changes.

## Deploying this expansion into a test project

Prepare the same test project's existing OAuth/client/settings first. Set these
server secrets in the **test project**, without committing their values:

- `MCP_RESOURCE_URL`, `MCP_SITE_ORIGIN`, `MCP_OAUTH_CLIENT_ID` (existing configuration).
- `REVENUECAT_SECRET_API_KEY`: RevenueCat server API key with subscriber read access.
- `REVENUECAT_ACCESS_ENTITLEMENT_ID`: identical to Flutter configuration.
- `REVENUECAT_ENVIRONMENT`: `SANDBOX` for sandbox testing, `PRODUCTION` for release.
  Set `gymbro_mcp.settings.billing_environment` to the same value in the test
  project; its migration default is `PRODUCTION`. Mismatched cache environments
  fail closed in the database.
- `REVENUECAT_WEBHOOK_AUTHORIZATION`: independent random secret, including any
  desired `Bearer ` prefix exactly as configured in RevenueCat.

`SUPABASE_SERVICE_ROLE_KEY` is provided to the isolated adapter by the Edge runtime;
it must never be added to the website or used for MCP user database operations.

Apply only the new incremental migration, deploy `mcp-services`, then the updated
site and `mcp` function. Coordinate this rollout: the migrated write RPC requires
billing, so old transports cannot create until the updated adapter/transport are
available. Configure the RevenueCat webhook URL to the test project's
`/functions/v1/mcp-services`, with the dedicated Authorization header and matching
environment. Test purchases, restore, cancellation, expiration and account
transfer; test a Free account separately. Refresh the private ChatGPT connection's
metadata, approve expanded access, and verify app pull/reconnection.

Do not run `activate_sync_v2()`, replay the remote baseline, replace the OAuth
client or migrate the live project as a substitute for staging. Rollout requires
real RevenueCat credentials, webhook configuration and a test project.

## Initial OAuth setup (new installations only)

Existing connections keep their client and settings. Use the expansion rollout
above; the following steps are for a new installation or a future test project.

1. Verify the migration history and real schema. The repository baseline is a
   snapshot of an existing database: do not replay it on production. Deploy the
   required existing incremental sync-v2 migrations if absent, then the original MCP migrations and `20261023110000_mcp_capabilities.sql`. Do not call `activate_sync_v2()` as part of this feature.
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
