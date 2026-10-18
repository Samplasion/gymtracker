import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/components/legacy_workout_recovery.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Online extends Online {
  @override
  FutureOr<OnlineAccount?> build() => OnlineAccount(id: 'A', name: 'Alice');
}

void main() {
  late GTDatabaseImpl db;
  final legacy = {
    'name': 'Legacy session',
    'time': 1792310400000,
    'exercises': <dynamic>[],
  };

  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    db = MockServices.database as GTDatabaseImpl;
    db.setCurrentUserId('A');
    await db
        .into(db.ongoingData)
        .insert(OngoingDataCompanion(data: Value(jsonEncode(legacy))));
    globalContainer = ProviderContainer(
      overrides: [onlineProvider.overrideWith(_Online.new)],
    );
  });
  tearDown(() {
    globalContainer.dispose();
    MockServices.tearDown();
  });

  testWidgets('preview does not claim the workout until confirmed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const WidgetTestApp(
        wrapWithProviderScope: true,
        child: LegacyWorkoutRecoveryTile(),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('Legacy session'), findsOneWidget);
    expect(await tester.runAsync(() => db.watchOngoing().first), isNull);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.textContaining('@Alice'), findsOneWidget);
    expect(await tester.runAsync(() => db.watchOngoing().first), isNull);
    await tester.tap(find.text('OK'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => db.watchOngoing().first), legacy);
    expect(await tester.runAsync(() => db.watchLegacyOngoing().first), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
