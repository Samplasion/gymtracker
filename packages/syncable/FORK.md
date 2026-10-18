# GymTracker's syncable fork

Based on syncable 1.0.3 (https://github.com/Mr-Pepe/syncable), downloaded
from pub.dev. Original archive SHA-256:
`f7764d31f3422445625e75981a8431fd650b8c651522a566569f19d61a39fad7`.
The upstream LICENSE is retained. This package is private and resolved by path.

## Lifecycle contract

- One worker handles reconciliation, incoming writes and outgoing uploads.
  Manual/automatic requests join the running worker. Timers cannot create a
  second loop. Background errors are observed and exposed through lifecycle hooks.
- `disableSync()` stops scheduling and invalidates callbacks immediately.
  `suspend()` additionally awaits HTTP requests, local transactions and
  subscription cleanup. A timeout leaves sync disabled; it does not cancel an
  HTTP request or permit database replacement.
- `runPaused()` prevents re-enabling during maintenance. A successful restore may
  discard obsolete queues; a failed transaction retains pending work. Local
  records remain the durable source for reconciliation after restart.
- Changing the account while work is in flight is rejected. Callers must await
  suspension before changing credentials or ownership. Account changes clear
  in-memory queues and rebuild subscriptions.
- All local lookups and incoming writes include the owner. Incoming transactions
  roll back if the generation changes. Local query subscriptions are not cached
  beyond their lifetime.
- Queues are acknowledged after successful writes. An upload is read back because
  the existing server trigger may silently reject older updates. A reply for an
  older local version never acknowledges a newer queued edit. The later
  `updated_at` wins; equal timestamps with different contents choose the server
  row, including after an upload readback. Full reconciliation also fetches rows
  with equal timestamps to resolve conflicts left by earlier app versions.
- Full reconciliation compares all paginated metadata. Persistent timestamps
  remain informational; they cannot exclude unsent legacy rows. Realtime is an
  optimization, not the only recovery path.

## Compatibility and boundaries

The wire format, table schema, conflict trigger and client timestamps remain
compatible with the existing backend. The original public registration API is
retained. `onSyncStarted`, `onSyncFinished` and `onSyncError` replace polling for
completion in the app. Tests run from the application's Flutter test suite under
`test/sync/` with SQLite and a simulated HTTP backend.

This is the first reliability increment. It does not introduce a persistent
operation outbox, server revisions, conflict history, or recovery of already
lost records. Reconciliation still uses client timestamps; older offline edits
can lose to a newer server value under the existing conflict policy. Server
records and local sync models currently have no `created_at` field, so creation
time cannot break an `updated_at` tie. SQLite stores these timestamps at second
precision; two distinct edits within one second can tie and use the server rule.
Server metadata pagination is not a transactionally consistent snapshot; a
later full reconciliation recovers rows moved during pagination. Deployment against the
actual backend and testing on physical devices remain required.
