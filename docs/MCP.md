# Gym Bro MCP / ChatGPT

Private, authenticated Streamable HTTP integration. The server now publishes
29 tools; it does not call a model or need an OpenAI API key. Existing endpoint,
OAuth client and the original five tool names are preserved.

## Capabilities

| Area | Tools |
| --- | --- |
| Exercise catalog | `search_exercises`, `get_exercises`, `create_custom_exercises` |
| Routines and folders | `list_routines`, `get_routine`, `get_routines`, `create_routines`, `create_program`, `list_routine_folders`, `create_routine_folders` |
| Saved training | `list_workouts`, `get_workouts`, `get_exercise_history`, `get_training_stats` |
| Hydration | `list_water_entries`, `get_water_entries`, `log_water`, `get_hydration_summary` |
| Measurements | `list_measurements`, `get_measurements`, `create_measurements` |
| Account | `get_account_limits` |
| Nutrition | `search_foods`, `get_foods`, `list_food_entries`, `get_food_entries`, `log_foods`, `get_nutrition_summary`, `get_nutrition_settings` |

No update/delete operations, workout-history writes, live workout controls,
nutrition-goal/category edits, favorites/barcode-catalog edits, or social access.
Writes are called only after the user requests saving. Arrays containing one
item implement single-item operations; bulk writes are atomic.

Inputs are strict Zod schemas in `supabase/functions/mcp/schemas.ts` and the
registered tool definitions. Results have matching structured/text representations.
New lists return `items` and `nextCursor`; the original list/search tools retain
`nextOffset`. Cursors bind to their original filters.
Database lists have deterministic ordering; cursors are not historical snapshots.
Date intervals are inclusive; training and nutrition intervals are bounded to 367 days per request. Training
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

## Actual weight and body measurements

`list_measurements` accepts optional `kind` (`weight`/`body`), `types` (body types),
inclusive local dates `from`/`to`, `cursor`, and `limit` (default 20, max 100).
Results are ordered by instant, kind and ID descending; keyset cursors bind to
filters and account time zone. No commercial date restriction or Pro requirement.

`get_measurements` accepts 1–20 `{kind,id}` references, returning `items` and
`unavailable`. `create_measurements` accepts `idempotencyKey` and 1–100 `entries`:
weight `{kind:"weight",value,unit?:"kg"|"lb",time?}`; body
`{kind:"body",type,value,time?}`. Types match Flutter BodyMeasurementPart; body
units are cm or % for bodyFat. Values are finite/nonnegative; bodyFat ≤100.
Time is an RFC3339 timestamp with offset or local YYYY-MM-DD at midnight;
omitted time uses the server instant. Retry receipts precede resolving default
times. IDs are server-generated and writes atomic with active sync-v2 triggers.
Multiple records per day are retained. No updates, deletes or forecasts.

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

`search_foods` searches the shared Gym Bro food catalog plus the account's local
favorites and personal barcode definitions. The default source is `all`;
`catalog`, `favorite` and `customBarcode` restrict the search. Shared results use
`{source:"catalog",id:"product-uuid"}` and include only published entries. No
Open Food Facts API is contacted. Legacy `openfoodfacts` barcode references resolve
only against published Gym Bro catalog entries.

`get_foods` resolves these references to full definitions. `log_foods` copies all
product fields into the diary; later corrections or moderation cannot alter
existing entries. MCP has no publication, reporting or administration tools.
The shared catalog starts empty and receives only explicit manual submissions
from the app, independently of personal synchronization or account deletion.

Migration `20261024140000_food_catalog.sql` extends the preceding MCP migrations
without changing existing diary JSON. Review migration and `mcp`/`mcp-services`
functions together; deploy only with separate authorization, then refresh the
ChatGPT connection's tool metadata.

`log_foods` accepts `{idempotencyKey,entries:[{date,amount,pieces,category?,foodRef? ,food?}]}`.
Provide exactly one of `foodRef` or a manual `food` definition. Manual definitions
contain `name`, optional `brand`, `unit` (`g`/`ml`), `servingSizes` and
`nutritionalValuesPer100g`. Calories, fat, saturated fat, carbs, sugar and protein
are mandatory. Other fields use Flutter's nutrient units (exposed as
`nutrientUnits`); unknown optional values stay unknown. Incomplete catalog foods
must be completed explicitly as a manual definition before logging.

For "X units of Y", `amount` is grams/ml for ONE unit and `pieces` is X.
Three slices weighing **30 g total** use `amount:10,pieces:3`; three slices
weighing **30 g each** use `amount:30,pieces:3`. Use user-supplied quantities or
a matching serving size; ask when unknown. Divide total quantities for equal
units by their count. Do not invent spoon/glass sizes. Nutrient definitions remain
per 100g/100ml; never multiply quantities twice. Preserve known named serving
sizes in manual snapshots when applicable.

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

A merged RevenueCat entitlement can select a sandbox lifetime product while an
independent production support grant is active. The adapter also checks exact
`rc_promo_<configured entitlement>_<v1 duration>` subscriptions with
`store: promotional`, `is_sandbox: false`, no refund and a future expiration.
It uses the grant's expiration, never the sandbox entitlement's unbounded access.
Other entitlements, sandbox-only purchases and expired grants do not unlock Pro.
Redeploy `mcp-services` for this fix; existing billing caches refresh after five
minutes or an authenticated webhook. No database migration is needed.

## Drinking water and hydration

`log_water` accepts `{idempotencyKey,entries:[{milliliters,time?}]}` (1–100).
Milliliters are the total volume, finite and positive; two 250ml glasses are one
500ml record. Convert liters exactly and ask when glass/bottle volume is unknown.
Time is RFC3339 with offset or YYYY-MM-DD at account-zone midnight; omitted time
uses the server instant. Diary dates use the same supported 2000–2099 range as
other nutrition tools. Actual future instants are rejected for all plans.
Do not also log drinking water for a beverage already recorded as food with its
water nutrient. The tool never changes/deletes records or deduplicates by similarity.

`list_water_entries` accepts inclusive `from`/`to`, `cursor`, `limit` (20/100).
Records sort by actual time and ID descending. `get_water_entries` accepts 1–20
IDs with `items`/`unavailable`. Actual JSON time and account IANA zone determine
local dates and Free restrictions, not stale/imported `reference_date` metadata.
Free allows today ±7 days, including ID access; Pro has no commercial date window.
A mixed invalid/out-of-window bulk fails wholly. Completed retries retain their
original IDs even after the billing cache expires; identity must remain valid.

`get_hydration_summary` and the new daily `hydration` object in
`get_nutrition_summary` use one calculation: `drinkingWaterMl`, `knownFoodWaterMl`,
`knownTotalWaterMl`, `foodWaterComplete`, `waterGoalMl`, `waterGoalEffectiveFrom`.
Food water uses the saved snapshot × amount × pieces / 100; missing water remains
unknown, with the known subtotal and completeness reported separately. Empty
days are included. Water goals follow existing DateSequence settings, are null
when unset and are never inferred. `totals.water` remains food-only. Summary
ranges are capped at 367 days, with at most 10,000 water records; overflow is an
explicit error, never silent truncation. Numeric overflow is rejected too.

Rows use the existing `water_logs` JSON-text model, with actual `date_added`,
local calendar day at UTC midnight in `reference_date`, and active sync-v2
triggers. The app may export them to Health after pull according to the existing
device permission/preferences; MCP never enables Health or writes to it directly.
No new OAuth scope, consent page or client is needed; only informational copy is
updated in Italian/English.

### Deploying the water tools

Apply `20261025190000_mcp_hydration.sql` after the existing
`20261025180000_hydration.sql` and earlier catalog/OAuth migrations. This preserves
the catalog search wrapper and all earlier tools. It also makes the shared date
validator evaluate verified billing explicitly, avoiding SQL AND short-circuiting
inside the Free date window. Deploy the updated `mcp` function, the site's copy
change, and refresh ChatGPT metadata (29 tools). The adapter `mcp-services` needs
no change for this water integration. No new secrets or sync-v2 activation.
Use `supabase db push --linked --dry-run` to review pending migrations first;
this task does not deploy production automatically.

Tests include `test/backend/mcp_hydration.sql`, concurrent water retries, Deno
contracts/summaries, and the shared `mcp_hydration.json` Flutter compatibility
fixture. Run `flutter test --no-pub test/model/mcp_hydration_compatibility_test.dart
test/hydration` plus the normal Deno/backend suites.

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

The database repeats every ownership, OAuth grant/session and quota check.
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
account. Catalog operations repeat database OAuth grant/session checks before external calls.

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

OAuth is the only authorization. The private owner check verifies the configured
client/audience, user, live `auth.sessions` row from JWT `session_id`, matching
OAuth client and an unrevoked `auth.oauth_consents` grant. Revoked/deleted sessions
fail immediately, including direct RPCs and legacy tools. No capability versions,
application-consent records or grandfathering paths remain.

Ordinary website sessions manage only `mcp_preferences(time_zone)`; MCP tokens
cannot change preferences. The OAuth approval form saves the selected zone and
approves the standard grant in one flow. Already-approved grants return to the
checked callback without an additional prompt. The old capabilities URL is only
a compatibility redirect. Authorized apps/revocation and time zone settings
remain under Advanced in the account page. No OAuth client or scopes change.

Time zones use a searchable, selection-only IANA dropdown with city/offset labels.
Stored values retain DST behavior. Missing preferences default to UTC at the
server; a new approval form detects the browser zone. Invalid values fall back
to UTC/GMT+0 in the site and RPC. The response includes `isDefault` so the site
distinguishes missing settings from an explicit UTC selection. Diary "today"
always uses the server-side preference.

Error codes include `authentication_required`, `invalid_input`,
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
flutter test --no-pub test/model/mcp_compatibility_test.dart test/model/mcp_expanded_compatibility_test.dart test/model/mcp_measurements_compatibility_test.dart test/model/progression_test.dart test/model/workout_test.dart
```

The backend suite uses disposable Docker Postgres, never the linked project.
It tests sync/social regressions, post-gate writes, permissions, atomicity,
concurrent retries and competing Free quota writes. To regenerate synthetic
Flutter fixtures from persisted SQL, set `MCP_COMPATIBILITY_FIXTURE` or
`MCP_EXPANDED_COMPATIBILITY_FIXTURE` to their respective fixture paths when
running the suite. In `gym-bro-landing`, run `npm run test:oauth`, `npm run lint`,
`npm run build`; use an isolated local MongoDB for the build, not the live CMS.

Catalog generation still uses the Flutter runtime via `tools/export_mcp_catalog.sh`.
Exports automatically create `supabase/migrations/YYYYMMDDHHMMSS_mcp_catalog.sql`
using the current UTC timestamp. Existing migrations are never overwritten with
different content. `--dart-define=CATALOG_MIGRATION=path` can select an explicit
new path when needed.
Use `--dart-define=CHECK_CATALOG=true` for read-only verification of the JSON and
the most recent generated catalog migration. An explicit `CATALOG_MIGRATION`
checks that file instead. Never rewrite deployed catalog migrations.

## Deploying measurements and OAuth-only authorization

Apply `20261024130000_mcp_measurements_oauth.sql` after the earlier MCP migrations.
It migrates time zones into private preferences, replaces permission checks with
live OAuth session/grant checks and removes the separate consent objects.
Deploy the site, `mcp-services` and `mcp` in one maintenance window: the old site
references the removed RPC. Keep the existing OAuth client, resource URL, hook,
RevenueCat settings and connections. Refresh ChatGPT metadata (29 tools). No
sync-v2 activation or baseline replay is needed. This task does not deploy
production automatically.

The disposable harness supplies Auth OAuth schema fixtures matching the current
hosted project; production uses the existing Auth-managed tables without
modifying them. Run the backend suite and web checks before deployment, then
verify revocation and app pull end to end.

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
metadata, verify the single OAuth approval and app pull/reconnection.

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
