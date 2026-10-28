import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/view/me.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Me extends Mock implements MeController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final scenario in [
    (
      stored: Weights.kg,
      display: Weights.lb,
      previous: 80.0,
      latest: 78.0,
      expected: GTIcons.weight_down,
    ),
    (
      stored: Weights.lb,
      display: Weights.kg,
      previous: 170.0,
      latest: 174.0,
      expected: GTIcons.weight_up,
    ),
    (
      stored: Weights.kg,
      display: Weights.lb,
      previous: 78.0,
      latest: 78.0,
      expected: GTIcons.weight_flat,
    ),
  ]) {
    testWidgets(
      'weight trend converts ${scenario.stored} to ${scenario.display} '
      'for ${scenario.previous} -> ${scenario.latest}',
      (tester) async {
        MockServices.setup();
        addTearDown(MockServices.tearDown);
        await initTestLocalizations();
        final points = [
          WeightMeasurement(
            id: 'a',
            weight: scenario.previous,
            time: DateTime(2026, 1, 1),
            weightUnit: scenario.stored,
          ),
          WeightMeasurement(
            id: 'b',
            weight: scenario.latest,
            time: DateTime(2026, 1, 3),
            weightUnit: scenario.stored,
          ),
        ];
        final prediction = predictWeight(points, scenario.display)!;
        when(
          () => MockServices.settingsController.weightUnit,
        ).thenReturn(scenario.display);
        final me = _Me();
        when(() => me.weightMeasurements).thenReturn(points);
        when(() => me.bodyMeasurements).thenReturn([]);
        when(() => me.latestWeightMeasurement).thenReturn(points.last);
        when(
          () => me.weightMeasurementsStream,
        ).thenAnswer((_) => Stream.value(points));
        when(
          () => me.bodyMeasurementsStream,
        ).thenAnswer((_) => Stream.value([]));
        final container = ProviderContainer(
          parent: MockServices.container,
          overrides: [
            meControllerProvider.overrideWithValue(me),
            weightMeasurementsProvider.overrideWithValue(AsyncData(points)),
            bodyMeasurementsProvider.overrideWithValue(const AsyncData([])),
            measurementWeightUnitProvider.overrideWithValue(
              AsyncData(scenario.display),
            ),
            predictedWeightProvider.overrideWith((ref) => prediction),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const WidgetTestApp(child: WeightMeasurementDataPage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(scenario.expected), findsOneWidget);
        for (final icon in [
          GTIcons.weight_up,
          GTIcons.weight_down,
          GTIcons.weight_flat,
        ]) {
          if (icon != scenario.expected)
            expect(find.byIcon(icon), findsNothing);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}
