import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/view/me.dart';
import 'package:mocktail/mocktail.dart';

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

  testWidgets(
    'weight card observes insertion update and removal from the database',
    (tester) async {
      when(
        () => MockServices.achievementsController.maybeUnlockAchievements(
          AchievementTrigger.weight,
        ),
      ).thenReturn({});
      await tester.runAsync(() async {
        MockServices.container.listen(weightMeasurementsProvider, (_, _) {});
        await MockServices.container.read(weightMeasurementsProvider.future);
      });
      await tester.pumpWidget(
        const WidgetTestApp(wrapWithProviderScope: true, child: WeightCard()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final commands = MockServices.container.read(meControllerProvider);
      final measurement = WeightMeasurement(
        id: 'w',
        weight: 80,
        time: DateTime(2026),
        weightUnit: Weights.kg,
      );
      await tester.runAsync(() async {
        await commands.addWeightMeasurement(measurement);
        await MockServices.database.watchWeightMeasurements().firstWhere(
          (rows) => rows.length == 1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
      expect(find.textContaining('80'), findsOneWidget);
      await tester.runAsync(() async {
        await commands.removeWeightMeasurement(measurement);
        await MockServices.database.watchWeightMeasurements().firstWhere(
          (rows) => rows.isEmpty,
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
      expect(find.textContaining('80'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
