import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/view/components/exercise_set_view.dart';
import 'package:gymtracker/view/utils/workout.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  GTSet set() => GTSet(
    kind: GTSetKind.normal,
    parameters: GTSetParameters.repsNegWeight,
    reps: 10,
    weight: 5,
    done: true,
  );

  test('ongoing workout uses signed volume and excludes unfinished sets', () {
    final controller = MockServices.container.read(
      workoutControllerProvider.notifier,
    );
    controller.exercises = [
      exerciseHelper(
        'negative',
        'Assisted',
        sets: [set(), set().copyWith(done: false)],
      ),
    ];
    expect(controller.liftedWeight, -50);
  });

  testWidgets('history displays negative weight and repetitions', (
    tester,
  ) async {
    final current = set();
    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: ExerciseSetView(
          set: current,
          exercise: exerciseHelper('negative', 'Assisted', sets: [current]),
          isConcrete: true,
          alt: false,
          weightUnit: Weights.kg,
          distanceUnit: Distance.km,
        ),
      ),
    );
    expect(find.textContaining('-5'), findsOneWidget);
    expect(find.textContaining('10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'editor accepts positive weight and preserves the negative type',
    (tester) async {
      final current = set();
      GTSet? changed;
      await tester.pumpWidget(
        WidgetTestApp(
          wrapWithProviderScope: true,
          child: WorkoutExerciseSetEditor(
            exercise: exerciseHelper('negative', 'Assisted', sets: [current]),
            set: current,
            index: (exerciseIndex: 0, supersetIndex: null),
            setIndex: 0,
            alt: false,
            isCreating: true,
            onSetSelectKind: (_) {},
            onSetChangeRPE: (_) {},
            onSetSetDone: (_) {},
            onDelete: () {},
            onSetValueChange: (value) => changed = value,
            weightUnit: Weights.kg,
            distanceUnit: Distance.km,
          ),
        ),
      );
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      expect(tester.widget<TextField>(fields.first).controller!.text, '5');
      await tester.enterText(fields.first, '8');
      expect(changed!.weight, 8);
      expect(changed!.effectiveWeight, -8);
      expect(changed!.parameters, GTSetParameters.repsNegWeight);
      expect(tester.takeException(), isNull);
    },
  );
}
