import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/workout.dart' show WorkoutListView;
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  testWidgets('scrolling over an exercise scrolls the workout without errors', (
    tester,
  ) async {
    MockServices.setup();
    addTearDown(MockServices.tearDown);
    await initTestLocalizations();
    final workout = MockServices.createWorkout('Workout', null, null);
    final exercise = exerciseHelper('ex1', 'Bench Press');
    when(
      () => MockServices.exercisesController.exercises,
    ).thenReturn([exercise]);
    when(
      () => MockServices.historyController.getHistoryOf(exercise),
    ).thenReturn([]);
    workout.exercises.add(exercise);
    workout.publishExercises();

    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: WorkoutListView(
          children: [
            WorkoutExerciseEditor(
              exercise: exercise,
              index: (exerciseIndex: 0, supersetIndex: null),
              isCreating: false,
              callbacks: workout.callbacks,
              weightUnit: Weights.kg,
              distanceUnit: Distance.km,
            ),
            const SizedBox(height: 1000),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final position =
        tester.getTopLeft(find.byType(WorkoutExerciseEditor)) +
        const Offset(100, 25);
    final workoutScroll = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(WorkoutListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.sendEventToBinding(
      PointerScrollEvent(position: position, scrollDelta: const Offset(0, 100)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(workoutScroll.position.pixels, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });
}
