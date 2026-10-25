# Water tracking

The nutrition diary combines dedicated drinking-water entries with water derived
from food portions. Water is optional in `NutritionValues`, in ml per 100 g/ml;
missing values remain unknown. Daily water goals are optional and dated with the
existing nutrition goals. There is no automatic goal or retrospective estimate.

The six initial foods are seeded into the shared backend catalog by
`20261025200000_seed_hydration_food_catalog.sql`; they are no longer bundled or
injected into client search. The regular catalog search, identity and moderation
apply. Existing diary snapshots remain available locally. Canonical catalog names
are in Italian, like other catalog entries they are not translated by the client.
Raw cucumber (FDC 168409), tomato (170457),
watermelon (167765) and apple with skin (171688) use USDA SR Legacy values verified
through the public FoodData Central API. Water mass is approximated as the same
volume (1 g ≈ 1 ml). Plain still and sparkling water use 100 ml per 100 ml.
Source identifiers survive in the food's brand; preparation is in its name.

## Persistence and export

Local schema 23 adds syncable `water_logs`, nullable nutrition goal `water`, and
device-local hydration settings/export state. SQLite backups restore water entries
but do not import another device's Health connection. JSON export version 23
includes `waterLogs` and `dailyWater`.

Apply `supabase/migrations/20261025180000_hydration.sql` to the backend before
releasing the updated client. It adds owner-isolated, revisioned water sync and
extends food validation. Legacy goal updates preserve water when the field is
absent. Unknown water preserves existing catalog fingerprints.

The diary card shows water progress and opens a preset-quantity bottom sheet;
individual drinking entries are managed in the separate history page. The water
goal is edited in the existing nutrition-goal form, with the same dated history.

Health export is automatic when write permission is granted. The first diary
visit can request permission once; subsequent visits/resumes only check the OS
permission. A denied-permission banner is limited to the first visit, and hides
once access is granted. The existing Settings → Permissions affordance handles
requests and recovery. There are no separate Health connection controls. Export
remains write-only. It begins with the local day
of activation, without exporting earlier diary days. Stable identifiers and a
persistent export journal support retries, edits and deletions. iOS uses HealthKit
sync identifiers/versions through a dedicated channel because the installed
`health` package ignores client record identifiers on iOS. Android uses Health
Connect client record identifiers. Revoking the OS permission pauses export;
existing Health samples remain intact.

## Verification

- `flutter test test/hydration` covers quantities, accounts, migration, retries,
  edits/deletions, backup, JSON export and the Italian UI flow.
- `flutter test integration_test/hydration_test.dart -d <ios-simulator-id>` runs
  the diary flow and checks native HealthKit writes when already permitted, or
  explicit permission-denied handling otherwise. It does not grant permissions.
- `bash tools/test_sync_v2_backend.sh` includes hydration SQL coverage in an
  isolated disposable database.
- The MCP service's `hydration_schema_test.ts` verifies nutrient compatibility.

The iOS simulator build and integration tests passed. Android profile compilation
passed; the existing debug Firebase configuration lacks the `.debug` package.
A live Health Connect round trip and the HealthKit permission-grant UI still need
manual verification on an authorized device/simulator.

## MCP integration

After the base hydration migration, apply `20261025190000_mcp_hydration.sql` and
deploy the updated MCP function. Four tools read/log water and summarize combined
hydration; nutrition summaries expose the same daily hydration object. Existing
OAuth connections remain valid. Free date checks include ID reads, writes are
atomic/idempotent and actual future consumption cannot be logged. See `MCP.md`
for contracts and deployment. Health export remains device-controlled after sync.
