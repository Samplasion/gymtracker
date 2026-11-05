# Personal dashboard and shared programs

The companion Next.js site in `gym-bro-landing` uses the `personal-api` Edge
Function. Apply `20261104140000_personal_dashboard_shares.sql` and deploy the
function before releasing the app and site, in that order. Follow the existing
release process; this change does not migrate site hosting.

## API

POST JSON `{ "operation": "...", ... }` to `/functions/v1/personal-api`.
Private operations verify a first-party `authenticated` JWT and fetch the current
user; delegated OAuth tokens are rejected. Caller-supplied actor IDs have no
effect. The service-only SQL function enforces owner predicates on every query. Owner-only
SELECT under RLS also includes snapshots in the existing data export; delegated
JWTs and other accounts cannot read those rows directly.

- `overview`: account counts and five recent logical sessions.
- `history`: `since` (ISO timestamp, optional), `search` (literal substring),
  `offset`, `limit` (1–100); returns `{ items, total }`.
- `detail`: `id`; returns one logical session with its continuations and exercises.
- `progress`: optional `since`; returns exercise/metric groups with canonical
  units, all-time `record: { value, date }` and filtered `points`.
- `routines`: returns `{ folders, routines }` for the current account.
- `share_create`: `document`; returns `{ id, token, created_at }`.
- `shares`: returns owner-only link metadata, including revoked links.
- `share_revoke`: `id`; idempotently revokes an owned snapshot.
- Public `read`: `token`; returns only the active snapshot, otherwise 404.
- Public `catalog`: `offset`, `limit`; localized public exercise definitions.

Responses use `Cache-Control: no-store`. Errors distinguish unauthorized (401),
forbidden (403), missing/revoked (404), invalid/unsupported documents (400) and
server unavailability (500). Requests are limited to 1.1 MB. Tokens contain 24
cryptographically random bytes encoded as 48 hex characters. No automatic expiry.

## SharedProgramV1

The canonical document contains `version: 1`, `title`, `notes`, `kind`
(`routine` or `program`), ordered `routines`, and derived `custom_exercises`.
Each routine contains `id`, `name`, `infobox`, `weight_unit`, `distance_unit` and
ordered `exercises`. Exercise rows use the portable snake_case prescription
fields from trainer documents: IDs, name, parameter kind, muscles, equipment,
custom/library identity, superset flags/reference, rest time, notes, progression
and sets. Rest time is in seconds; set time is in microseconds. Units travel with
each routine. The API allowlists fields and resets all set completion flags.
Account IDs, trainer assignments and history references never enter a snapshot.
Custom definitions are derived from the self-contained exercise rows at creation.

`SharedProgramV1.fromWorkouts` converts unsynchronized local Flutter routines.
`materialize` maps the canonical document back to Flutter and allocates new IDs
for folder, days, exercises, sets, supersets and custom definitions, preserving
internal references. At import confirmation the app fetches the token again,
then stores all definitions and routines in a single account-bound transaction.
Previously downloaded/captured content cannot be recalled; revocation prevents
subsequent reads and imports through the link.

Creation requires an account and a connection. Preview reads and local Pro
imports do not require sign-in. The existing `?json=` native import remains
supported. New sharing uses web links, with QR and copy actions; “Shared links”
is available from the routines page and folder editor for revocation.

The app uses `GYM_BRO_SITE_URL` as an optional Dart define, defaulting to the
existing production site. Match the site's public origin when deploying staging.

## Verification

- `bash tools/test_personal_backend.sh` creates/removes a disposable PostgreSQL
  container and applies the complete migration history before SQL assertions.
- `deno test --allow-env supabase/functions/personal-api/*_test.ts`
- `.fvm/flutter_sdk/bin/flutter test --no-pub test/model/shared_program_test.dart test/widget/shared_program_import_test.dart test/widget/routine_link_flow_test.dart test/widget/routine_import_decisions_test.dart`
- In the site: `npm test`, `npx tsc --noEmit --incremental false`, `npm run build`.

Before publishing, test actual HTTPS links on iOS and Android with cold/warm app
starts, both locales, free/Pro accounts and revoked tokens. Deploying the site
before shipping the token-aware app would make new links unusable in old apps.
