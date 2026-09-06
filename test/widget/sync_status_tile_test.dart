import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/sync_status.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/settings.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('SyncStatusListTile renders syncing state with rotating icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWithValue(
            const SyncStatus(state: SyncState.syncing),
          ),
          onlineProvider.overrideWith(
            () => _FakeOnlineForWidgetTest(
              OnlineAccount(
                id: '123',
                name: 'test',
                email: 'test@example.com',
              ),
            ),
          ),
        ],
        child: const WidgetTestApp(
          child: Material(
            child: SyncStatusListTile(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify title and syncing status text
    expect(find.text('Sync status'), findsOneWidget);
    expect(find.text('Syncing...'), findsOneWidget);

    // Verify rotation transition with sync icon exists
    expect(
      find.descendant(
        of: find.byType(RotationTransition),
        matching: find.byIcon(GTIcons.sync),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SyncStatusListTile renders not syncing state with last sync date',
      (WidgetTester tester) async {
    final lastSyncDate = DateTime(2026, 9, 6, 12, 30);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWithValue(
            SyncStatus(
              state: SyncState.notSyncing,
              lastSync: lastSyncDate,
            ),
          ),
          onlineProvider.overrideWith(
            () => _FakeOnlineForWidgetTest(
              OnlineAccount(
                id: '123',
                name: 'test',
                email: 'test@example.com',
              ),
            ),
          ),
        ],
        child: const WidgetTestApp(
          child: Material(
            child: SyncStatusListTile(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('Sync status'), findsOneWidget);

    // Verify subtitle contains "Not syncing" and "Last sync:"
    expect(find.textContaining('Not syncing'), findsOneWidget);
    expect(find.textContaining('Last sync:'), findsOneWidget);

    // Verify static sync icon (not inside RotationTransition)
    expect(find.byIcon(GTIcons.sync), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RotationTransition),
        matching: find.byIcon(GTIcons.sync),
      ),
      findsNothing,
    );

    // Verify tile has onTap enabled when logged in
    final listTile = tester.widget<ListTile>(find.byType(ListTile));
    expect(listTile.onTap, isNotNull);
  });

  testWidgets('SyncStatusListTile renders not syncing state when not logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWithValue(
            const SyncStatus(state: SyncState.notSyncing, lastSync: null),
          ),
          onlineProvider.overrideWith(() => _FakeOnlineForWidgetTest(null)),
        ],
        child: const WidgetTestApp(
          child: Material(
            child: SyncStatusListTile(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sync status'), findsOneWidget);
    expect(find.textContaining('Not syncing'), findsOneWidget);
    expect(find.textContaining('Not logged in'), findsOneWidget);

    // Verify tile has onTap disabled when not logged in
    final listTile = tester.widget<ListTile>(find.byType(ListTile));
    expect(listTile.onTap, isNull);
  });

  testWidgets(
      'SyncStatusListTile shows snackbar and ignores sync when tapped within 1 minute of last sync',
      (WidgetTester tester) async {
    final recentSync = DateTime.now().subtract(const Duration(seconds: 20));
    final fakeOnline = _FakeOnlineForWidgetTest(
      OnlineAccount(
        id: '123',
        name: 'test',
        email: 'test@example.com',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWithValue(
            SyncStatus(state: SyncState.notSyncing, lastSync: recentSync),
          ),
          onlineProvider.overrideWith(() => fakeOnline),
        ],
        child: const WidgetTestApp(
          child: Material(
            child: SyncStatusListTile(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    // Verify snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Please wait a minute before syncing again'),
      findsOneWidget,
    );
    // Verify sync was not initiated
    expect(fakeOnline.syncCalls, equals(0));
  });

  testWidgets('SyncStatusListTile renders error state with sync_problem icon and failure message',
      (WidgetTester tester) async {
    final lastSyncDate = DateTime(2026, 9, 6, 12, 30);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncStatusProvider.overrideWithValue(
            SyncStatus(
              state: SyncState.error,
              lastSync: lastSyncDate,
            ),
          ),
          onlineProvider.overrideWith(
            () => _FakeOnlineForWidgetTest(
              OnlineAccount(
                id: '123',
                name: 'test',
                email: 'test@example.com',
              ),
            ),
          ),
        ],
        child: const WidgetTestApp(
          child: Material(
            child: SyncStatusListTile(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and subtitle
    expect(find.text('Sync status'), findsOneWidget);
    expect(find.textContaining('Sync failed'), findsOneWidget);
    expect(find.textContaining('Last sync:'), findsOneWidget);

    // Verify sync_problem icon is displayed
    expect(find.byIcon(GTIcons.sync_problem), findsOneWidget);

    // Verify tile is still tappable (user can retry)
    final listTile = tester.widget<ListTile>(find.byType(ListTile));
    expect(listTile.onTap, isNotNull);
  });
}

class _FakeOnlineForWidgetTest extends Online {
  final OnlineAccount? _account;
  int syncCalls = 0;
  _FakeOnlineForWidgetTest(this._account);

  @override
  FutureOr<OnlineAccount?> build() {
    return _account;
  }

  @override
  Future<void> sync() async {
    syncCalls++;
  }
}
