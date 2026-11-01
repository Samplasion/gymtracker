# Gym Bro for Trainers

The professional portal lives in `gym-bro-landing` under the localized `/trainer`
route. It uses existing Supabase accounts, shadcn components and the original icon
blue (`#0c47a1`). Trainer activation does not verify professional qualifications.

## Backend and deployment

1. Apply `20261031160000_trainers.sql` and then
   `20261031170000_trainer_plan_folders_and_account_deletion.sql` and
   `20261031180000_trainer_contiguous_supersets.sql` and
   `20261031190000_trainer_client_serialization.sql` after the existing migrations. They create private trainer data, transactional RPCs, write guards,
   notification support and Auth account-deletion cleanup.
2. Deploy the `trainer-api` Edge Function. It requires the existing Supabase URL
   and service role secret, plus `REVENUECAT_SECRET_API_KEY`,
   `REVENUECAT_ACCESS_ENTITLEMENT_ID`, and optionally `REVENUECAT_ENVIRONMENT`.
   Keep `gymbro_trainer.settings.billing_environment` consistent with the latter
   (default `PRODUCTION`). Reuse the existing push-delivery deployment with its
   updated message catalog; it delivers `trainer_plan` notifications.
3. Ship the updated app before advertising the portal. The acceptance endpoint
   requires `protocol_version: 1`. Older clients cannot write controlled content,
   including via ordinary sync. Other account functionality remains available.
4. Deploy the landing through its existing hosting pipeline. Add the production
   `/auth/callback` URL to the existing Supabase Auth redirect allowlist. Web
   registration uses the same account metadata (`username`) as the app. Existing
   token-hash email confirmations and PKCE callbacks preserve safe return paths.
5. Verify the entire flow on staging with two registered accounts and configured
   billing/push services before opening the portal publicly.

The trainer RPC is service-role-only. `trainer-api` verifies first-party user JWTs
and supplies the actor from the verified identity. It never accepts an actor or
subscription entitlement from the caller. There is no trainer service secret in
browser or Flutter code. All client operations require connectivity; workouts do
not. The portal does not use a separate database or hosting identity.

## Documents and identities

A draft document contains `folders`, `routines` and `custom_exercises`. Content
fields use the existing synchronization row vocabulary; nested routine
`exercises` are flattened SQL rows with superset references. Set durations use
microseconds, rest durations seconds, weights `kg`/`lb` and distances `km`/`mi`.
Only explicit content columns are imported. Owners, sync revisions, deletion flags
and trainer controls cannot be imported from document metadata.

Model copies assigned to a new client receive fresh routine, row and set IDs;
custom definitions keep their stable identity. Accepted revisions update existing
client routines in one transaction. Deleted routine entries become personal
routines rather than being deleted. Imports cannot overwrite unrelated personal
routine, custom-exercise, folder or exercise-row identities.

Each plan has an editable draft, immutable published revisions, one pending
proposal and one active revision. Stale draft writes/publications are rejected by
expected version. Repeating the active acceptance succeeds without duplicating
content. Replacing a proposal invalidates its old acceptance action.

The applicable prescription is reconstructed from the latest acceptance of the
plan at or before workout start time, using server acceptance times in UTC. No
revision pointer is stored in the workout. Missing prescriptions are explicitly
unavailable. Started sessions retain their existing content.

## Authorization, limits and termination

A client has at most one active trainer and cannot coach themselves. Invitation
acceptance, content writes, imports and termination serialize on the same sync
account row. Invites expire after seven days and can be revoked. Client capacity
is configurable in private settings and defaults to no restriction.

The trainer sees the last general workout date; only explicitly authorized
workouts and routines are readable in detail. Sharing a personal routine can
include old history or start now. Revoking sharing removes the entire grant.
Assigned routines cannot be individually unshared while controlled.

Free limits use the app's existing 4 routine / 10 custom-exercise capacities. An
import introducing new elements in a category requires at least one available
slot in that category; the entire document may then exceed its capacity. Existing
identities do not require slots. Folders are exempt. Blocking categories return a
specific paywall error; unavailable billing returns a retryable error, not a
paywall. The ordinary Pro-only routine import flow is unchanged.

Controls are separate from user content. Active controls prevent prescription
edits/deletion, removal of required custom definitions, changes to workout start
or parent, saving controlled sessions as new routines, and automatic prescription
updates/progression. User-recorded exercise content remains editable. Copies and
exports never carry relationship authority.

Termination removes controls, imports, personal grants, proposals, acceptance
history and client-specific plan revisions; accepted content remains owned by the
client with normal account rules. It preserves workout-to-routine associations.
Old control state cannot be reactivated by sync. Essential event kinds and times
remain in the trainer's activity log without access to past workout content.

Flutter stores only an owner-scoped authorization snapshot in Drift schema 25.
It is not a syncable user table and is not imported by JSON/backup restore. The
last confirmed snapshot is retained offline; missing relationships are normal
states, not null assertions. Refresh runs before/after sync and on the trainer
screen. Successful sync also updates the trainer's data-freshness indicator.

## Verification

- `bash tools/test_trainers_backend.sh`: isolated disposable Postgres, all
  migrations, invite/access checks, atomic soft-limit imports, stable revisions,
  saturation, protected writes, history isolation and complete termination.
- `deno test supabase/functions/trainer-api/handler_test.ts`: verified actors,
  delegated OAuth rejection, version negotiation, billing and error semantics.
- `flutter test test/db/trainer_control_test.dart test/model/trainer_difference_test.dart`:
  local controls, guest/owner isolation, unlock behavior and identity comparisons.
- In the landing: `node --experimental-strip-types --test tests/trainer.test.mjs`,
  `npx tsc --noEmit --incremental false`, and `npm run build` with a reachable CMS
  MongoDB. An empty disposable MongoDB is sufficient for the build check.

Staging checks must include an offline session, concurrent acceptance/termination,
email redirects, real notifications, and responsive authenticated portal views.

## Regression guarantees for ordinary accounts

The profile action and all invitation acceptance controls are hidden from guests.
A guest opening a trainer deep link gets only a sign-in action, with the invitation
kept for after authentication. Registered users without a trainer can access the
invitation entry, but all personal routine/workout/exercise flows remain unlocked.

`trainer_guest_visibility_test.dart` verifies the actual Profile screen for both
account states and the guest deep-link screen. `trainer_unlinked_regression_test.dart`
checks routine creation/edit/import/deletion, folder creation/deletion, custom
exercise edits/deletion and workout date/association edits for guests and unlinked
registered owners. Existing progression, import, ownership and offline tests remain
part of the full Flutter suite.

`WorkoutDifference` has one identity-based implementation, including canonical
routine-row identities shared by session instances. Its UI summary includes
reordering and routine metadata in both languages. The Intensity Innovator
achievement uses its exercise-content result, so independent workout titles and
notes do not alter the business rule or create spurious awards.

## Trainer editor and account deletion

Each plan has one server-owned `folder_id`. Saving and publishing normalize all
training days into that folder, named after the plan; clients cannot supply arbitrary
folders or move an assigned day to another folder. Revisions reuse the folder ID.
The portal offers no folder creation or folder selector. The upgrade groups already
controlled days without deleting existing user folders or changing immutable revisions.
Folders remain exempt from free limits and survive relationship termination.

Every superset has an “Add exercise to superset” picker for catalog and custom
exercises. New rows are inserted after the group's existing members with stable
parent IDs and consistent persisted ordering. Superset names are editable.

A hard Auth account deletion locks the affected clients against imports/sync,
revokes and detaches consumed invitations, removes pending plan notifications and
lets foreign-key cascades remove all relationship authority. Owned-content delete
guards allow the Auth cascade rather than recreating a deleted sync account.
Surviving clients retain routines, custom exercises, folders and workout links; the
next successful refresh removes cached controls. The folder foreign key clears only
`folder_id` when a folder is deleted, preserving the routine's owner.

`trainer_plan_folders.sql` covers server folder ownership, multiple supplied folders,
revisions, names and preservation. `trainer_account_deletion.sql` deletes a trainer
who is also a client, with multiple clients, accepted content, pending revisions and
personal shares. The concurrency suite also races acceptance against hard deletion.

## Interrupted acceptance recovery

Acceptance requests allow 45 seconds because trusted billing verification may
make two sequential requests with 15-second timeouts. Transport failures and server
unavailability have distinct messages. Before acceptance, pending personal edits
must synchronize; after acceptance, the download result is checked instead of
assuming success. A fresh pull waits for any older cycle/horizon to finish first.

Opening or refreshing My trainer resumes content downloads for confirmed controls,
including acceptances whose response was lost. Background snapshots issued before
a mutation cannot restore an outdated acceptance prompt. Tests simulate response
loss and interrupted downloads through the real sync engine into Drift and verify
one routine, folder and custom definition, with no second acceptance.

## Contiguous supersets and homepage

The web editor follows the app's nested-group invariant: only adjacent exercises
can join a superset and only the first or last member can leave it. Header arrows
move whole groups; member arrows reorder only within their group. Legacy invalid
drafts have an explicit grouping repair action, preserving exercise identities.

Server validation checks both array order and persisted `sort_order`, rejects
ambiguous positions, and enforces contiguity at template/plan save, publish and
acceptance (including legacy pending proposals). The API error is
`noncontiguous_superset`. Apply the latest migration and deploy trainer-api with
its updated application error mapping.

The localized homepage ends with a Trainers section immediately before the footer.
The trainer dashboard link follows all other desktop navbar actions and is the
last action in the mobile menu.
