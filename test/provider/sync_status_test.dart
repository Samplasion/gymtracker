import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/sync_status.dart';
import 'package:gymtracker/service/online.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MockServices.setup();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('SyncStatus model', () {
    test('isSyncing and hasError reflect SyncState', () {
      const syncing = SyncStatus(state: SyncState.syncing);
      expect(syncing.isSyncing, isTrue);
      expect(syncing.hasError, isFalse);

      const notSyncing = SyncStatus(state: SyncState.notSyncing);
      expect(notSyncing.isSyncing, isFalse);
      expect(notSyncing.hasError, isFalse);

      const error = SyncStatus(state: SyncState.error);
      expect(error.isSyncing, isFalse);
      expect(error.hasError, isTrue);
    });

    test('copyWith works correctly', () {
      const initial = SyncStatus(state: SyncState.notSyncing);
      final updated = initial.copyWith(
        state: SyncState.syncing,
        lastSync: DateTime(2026, 9, 6, 12, 0),
      );
      expect(updated.state, equals(SyncState.syncing));
      expect(updated.lastSync, equals(DateTime(2026, 9, 6, 12, 0)));
      expect(updated.isSyncing, isTrue);
    });

    test('equality and hashCode', () {
      final now = DateTime(2026, 9, 6, 12, 0);
      final a = SyncStatus(state: SyncState.notSyncing, lastSync: now);
      final b = SyncStatus(state: SyncState.notSyncing, lastSync: now);
      final c = SyncStatus(state: SyncState.syncing, lastSync: now);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('SyncStatusNotifier', () {
    const testUserId = 'user_123';
    final initialDate = DateTime(2026, 9, 1, 10, 0);

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'gymtracker_last_sync_$testUserId': initialDate.millisecondsSinceEpoch,
      });
    });

    test(
      'loads initial lastSync from SharedPreferences for logged in user',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWith((ref) => testUserId),
            onlineProvider.overrideWith(
              () => _FakeOnline(
                OnlineAccount(
                  id: testUserId,
                  email: 'test@example.com',
                  name: 'tester',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.listen(syncStatusProvider, (_, _) {});
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final status = container.read(syncStatusProvider);
        expect(status.state, equals(SyncState.notSyncing));
        expect(status.lastSync, equals(initialDate));
      },
    );

    test(
      'updates state on GBSyncStartedEvent and GBSyncFinishedEvent',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWith((ref) => testUserId),
            onlineProvider.overrideWith(
              () => _FakeOnline(
                OnlineAccount(
                  id: testUserId,
                  email: 'test@example.com',
                  name: 'tester',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(syncStatusProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final bus = container.read(eventBusProvider);

        bus.emit(const GBSyncStartedEvent());
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(syncStatusProvider).state,
          equals(SyncState.syncing),
        );
        expect(container.read(syncStatusProvider).isSyncing, isTrue);

        final finishDate = DateTime(2026, 9, 6, 18, 30);
        bus.emit(GBSyncFinishedEvent(lastSync: finishDate));
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(syncStatusProvider).state,
          equals(SyncState.notSyncing),
        );
        expect(container.read(syncStatusProvider).lastSync, equals(finishDate));
      },
    );

    test(
      'updates lastSync and persists to SharedPreferences on GBSyncTimestampUpdatedEvent',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWith((ref) => testUserId),
            onlineProvider.overrideWith(
              () => _FakeOnline(
                OnlineAccount(
                  id: testUserId,
                  email: 'test@example.com',
                  name: 'tester',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(syncStatusProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final newTimestamp = DateTime.utc(2026, 9, 6, 19, 0);
        final bus = container.read(eventBusProvider);
        bus.emit(GBSyncTimestampUpdatedEvent(newTimestamp));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final status = container.read(syncStatusProvider);
        expect(status.lastSync, equals(newTimestamp.toLocal()));

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getInt('gymtracker_last_sync_$testUserId'),
          equals(newTimestamp.toLocal().millisecondsSinceEpoch),
        );
      },
    );

    test('sync() triggers online.sync() and updates state via event', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => testUserId),
          onlineProvider.overrideWith(
            () => _FakeOnline(
              OnlineAccount(
                id: testUserId,
                email: 'test@example.com',
                name: 'tester',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(syncStatusProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final success = await container.read(syncStatusProvider.notifier).sync();
      await pumpEventQueue();

      expect(success, isTrue);
      final status = container.read(syncStatusProvider);
      expect(status.state, equals(SyncState.notSyncing));
      expect(status.lastSync, isNotNull);
    });

    test(
      'GBSyncFinishedEvent with null lastSync keeps existing lastSync',
      () async {
        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWith((ref) => testUserId),
            onlineProvider.overrideWith(
              () => _FakeOnline(
                OnlineAccount(
                  id: testUserId,
                  email: 'test@example.com',
                  name: 'tester',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(syncStatusProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final initialSyncDate = DateTime.utc(2026, 9, 6, 10, 0);
        final bus = container.read(eventBusProvider);
        bus.emit(GBSyncFinishedEvent(lastSync: initialSyncDate));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(container.read(syncStatusProvider).lastSync, equals(initialSyncDate));

        // Now emit a failed sync finished event (lastSync == null)
        bus.emit(const GBSyncStartedEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(container.read(syncStatusProvider).state, equals(SyncState.syncing));

        bus.emit(const GBSyncFinishedEvent(lastSync: null));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // State returns to notSyncing, but lastSync is NOT overwritten
        expect(container.read(syncStatusProvider).state, equals(SyncState.notSyncing));
        expect(container.read(syncStatusProvider).lastSync, equals(initialSyncDate));
      },
    );

    test('sync() ignores requests if less than 1 minute has passed since lastSync', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => testUserId),
          onlineProvider.overrideWith(
            () => _FakeOnline(
              OnlineAccount(
                id: testUserId,
                email: 'test@example.com',
                name: 'tester',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(syncStatusProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // First sync succeeds
      final first = await container.read(syncStatusProvider.notifier).sync();
      await pumpEventQueue();
      expect(first, isTrue);

      // Immediate second sync is rate-limited
      final second = await container.read(syncStatusProvider.notifier).sync();
      expect(second, isFalse);

      // Forced sync bypasses the rate limit
      final forced = await container.read(syncStatusProvider.notifier).sync(force: true);
      await pumpEventQueue();
      expect(forced, isTrue);
    });

    test('updates state to SyncState.error on GBSyncErrorEvent', () async {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => testUserId),
          onlineProvider.overrideWith(
            () => _FakeOnline(
              OnlineAccount(
                id: testUserId,
                email: 'test@example.com',
                name: 'tester',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(syncStatusProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final bus = container.read(eventBusProvider);
      bus.emit(const GBSyncStartedEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(syncStatusProvider).state, equals(SyncState.syncing));

      bus.emit(GBSyncErrorEvent(Exception('Connection reset')));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final status = container.read(syncStatusProvider);
      expect(status.state, equals(SyncState.error));
      expect(status.hasError, isTrue);
      expect(status.isSyncing, isFalse);

      // Subsequent GBSyncFinishedEvent with null lastSync keeps SyncState.error
      bus.emit(const GBSyncFinishedEvent(lastSync: null));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(syncStatusProvider).state, equals(SyncState.error));

      // New sync starts: error state is cleared
      bus.emit(const GBSyncStartedEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(syncStatusProvider).state, equals(SyncState.syncing));
      expect(container.read(syncStatusProvider).hasError, isFalse);
    });
  });
}

class _FakeOnline extends Online {
  final OnlineAccount? _account;
  _FakeOnline(this._account);

  @override
  FutureOr<OnlineAccount?> build() {
    return _account;
  }

  @override
  Future<void> sync() async {
    final eventBus = ref.read(eventBusProvider);
    eventBus.emit(const GBSyncStartedEvent());
    eventBus.emit(GBSyncFinishedEvent(lastSync: DateTime.now()));
  }
}
