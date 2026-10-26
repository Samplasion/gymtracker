# Riverpod lifecycle fix

This directory contains the runtime library of upstream `riverpod` 3.3.2,
under its original MIT license. It is used through the application’s
`dependency_overrides`; the package cache is never modified.

`lib/src/core/element.dart` backports the flushing guard from the upstream fix:
https://github.com/rrousselGit/riverpod/commit/02b11c3

`flush()` preserves/restores a reentrant `_isFlushing` flag. `invalidateSelf()`
does not schedule a redundant refresh when the same provider is already
being flushed. This prevents scheduling a ProviderScope rebuild while a
consumer mounts and flushes an invalidated provider chain. Notifications,
normal invalidation and lifecycle cleanup remain active.

The local extension in `element.dart` and `scheduler.dart` also tracks nested
flushes in the scheduler. A shared dependency can invalidate a sibling provider
that is not itself being flushed, bypassing the original per-provider guard.
Those sibling refreshes stay queued, but scheduling their scope rebuild is
deferred to a microtask, after the consumer's synchronous build returns. The
flush depth is restored in `finally`, including on errors. Regression coverage
checks paused siblings catch up on resume and continue receiving later updates.

The dependency override is temporary. A normal upgrade to Riverpod >=3.4.2
requires updating the annotation/generator packages together; their analyzer
constraints currently conflict with this app’s Freezed/copy-with generators.
Remove this directory and the override when that coordinated upgrade is made.

Regression coverage: `test/widget/food_provider_resume_test.dart` and
`test/widget/provider_flush_lifecycle_test.dart`.
