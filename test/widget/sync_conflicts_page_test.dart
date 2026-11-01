import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/view/utils/sync_recovery.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  test(
    'SQLite and server deletion flags have the same human-readable label',
    () {
      for (final it in [false, true]) {
        expect(
          describeRecovery('{"deleted":0}', it),
          describeRecovery('{"deleted":false}', it),
        );
        expect(
          describeRecovery('{"deleted":1}', it),
          describeRecovery('{"deleted":true}', it),
        );
      }
    },
  );

  testWidgets(
    'bulk choices fit a narrow screen, require confirmation and stay out of history',
    (tester) async {
      final db = MockServices.database;
      db.setCurrentUserId('owner');
      await db.customStatement("""INSERT INTO sync_conflicts
      (operation_id,owner,entity,record_id,local_payload,server_payload,server_revision)
      VALUES ('one','owner','routines','one','{}','{}',1),
             ('two','owner','routines','two','{}','{}',1)""");
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...MockServices.defaultOverrides,
            currentUserIdProvider.overrideWithValue('owner'),
          ],
          child: WidgetTestApp(
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.4)),
                child: const SyncConflictsPage(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final title in [
        'Keep everything from server',
        'Keep everything from device',
      ]) {
        await tester.ensureVisible(find.text(title));
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.textContaining('2 conflicting changes'), findsOneWidget);
        expect(find.text('Confirm choice'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(
          await db
              .customSelect('SELECT * FROM sync_conflicts WHERE resolved=0')
              .get(),
          hasLength(2),
        );
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Keep everything from server'), findsNothing);
      expect(find.text('Keep everything from device'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'old queued snapshots remain readable without newer required columns',
    (tester) async {
      final db = MockServices.database;
      db.setCurrentUserId('owner');
      await db.customStatement(
        '''INSERT INTO history_workouts
      (id,user_id,name,duration,starting_date,weight_unit,distance_unit)
      VALUES ('session','owner','Latest local workout',3600,1792490400,'kg','km')''',
      );
      final op = await db.customSelect('SELECT * FROM sync_outbox').getSingle();
      final snapshot =
          Map<String, dynamic>.from(
              jsonDecode(op.read<String>('payload')) as Map,
            )
            ..remove('visibility')
            ..remove('publication_manifest');
      await db.customStatement('UPDATE sync_outbox SET payload=?,blocked=1', [
        jsonEncode(snapshot),
      ]);
      await db.customStatement(
        '''INSERT INTO sync_conflicts
      (operation_id,owner,entity,record_id,local_payload,server_payload,server_revision)
      VALUES (?,'owner','history_workouts','session',?,?,1)''',
        [
          op.read<String>('operation_id'),
          jsonEncode({'name': 'Older queued snapshot'}),
          jsonEncode({'name': 'Server workout'}),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...MockServices.defaultOverrides,
            currentUserIdProvider.overrideWithValue('owner'),
          ],
          child: const WidgetTestApp(child: SyncConflictsPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Completed workouts'), findsOneWidget);
      expect(find.textContaining('Null check operator'), findsNothing);
      await tester.tap(find.text('Completed workouts'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Latest local workout'), findsOneWidget);
      expect(find.textContaining('Server workout'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        (await db.customSelect('SELECT * FROM sync_outbox').getSingle())
            .read<int>('blocked'),
        1,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
