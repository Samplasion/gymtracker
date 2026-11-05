import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/workout_editor.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUpAll(() => registerFallbackValue(exerciseHelper("fallback", "Fallback")));
  setUp(() async {
    MockServices.setup();
    when(() => MockServices.exercisesController.exercises).thenReturn([]);
    when(
      () => MockServices.historyController.getHistoryOf(any()),
    ).thenReturn([]);
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  test(
    'ongoing workout changes shared rest from either child or group index',
    () async {
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      controller.start('Workout', null, null, saveInitial: false);
      final group = supersetHelper('group');
      controller.setExercises([exerciseHelper('single', 'Single'), group]);
      controller.onExerciseChangeRestTime((
        exerciseIndex: 0,
        supersetIndex: 1,
      ), const Duration(seconds: 90));
      final updated = controller.exercises[1] as Superset;
      expect(updated.restTime, const Duration(seconds: 90));
      expect(
        updated.exercises.map((e) => e.restTime),
        group.exercises.map((e) => e.restTime),
      );
      expect(controller.exercises[0].restTime, const Duration(seconds: 60));
      controller.onExerciseChangeRestTime((
        exerciseIndex: 1,
        supersetIndex: null,
      ), Duration.zero);
      expect(controller.exercises[1].restTime, Duration.zero);
      await controller.suspend();
    },
  );

  for (final routine in [true, false]) {
    testWidgets(
      '${routine ? 'routine' : 'history'} editor updates shared rest for nested callbacks',
      (tester) async {
        final base = Workout(
          id: 'workout',
          name: 'Workout',
          infobox: '',
          exercises: [supersetHelper('group')],
          weightUnit: Weights.kg,
          distanceUnit: Distance.km,
        );
        await tester.pumpWidget(
          WidgetTestApp(
            wrapWithProviderScope: true,
            child: routine
                ? RoutineCreator(base: base)
                : WorkoutEditor(baseWorkout: base),
          ),
        );
        await tester.pumpAndSettle();
        var editor = tester.widget<SupersetEditor>(find.byType(SupersetEditor));
        editor.callbacks.onExerciseChangeRestTime((
          exerciseIndex: 1,
          supersetIndex: 0,
        ), const Duration(seconds: 90));
        await tester.pump();
        editor = tester.widget<SupersetEditor>(find.byType(SupersetEditor));
        expect(editor.superset.restTime, const Duration(seconds: 90));
        expect(
          editor.superset.exercises.every(
            (e) => e.restTime == const Duration(seconds: 60),
          ),
          isTrue,
        );
        editor.callbacks.onExerciseChangeRestTime((
          exerciseIndex: 0,
          supersetIndex: null,
        ), Duration.zero);
        await tester.pump();
        editor = tester.widget<SupersetEditor>(find.byType(SupersetEditor));
        expect(editor.superset.restTime, Duration.zero);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
