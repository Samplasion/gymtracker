import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    // Register fallback value for Workout
    registerFallbackValue(Workout(name: '', exercises: []));

    // Stub hasContinuation
    when(() => MockServices.historyController.hasContinuation(
          incompleteWorkout: any(named: 'incompleteWorkout'),
        )).thenReturn(false);

    // Stub ExercisesController exercises
    when(() => MockServices.exercisesController.exercises)
        .thenReturn(<Exercise>[].obs);
    when(() => MockServices.exercisesController.onServiceChange())
        .thenAnswer((_) {});
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('ExercisesView canStart disabling logic',
      (WidgetTester tester) async {
    final customEx = Exercise.custom(
      id: 'custom_1',
      name: 'Custom Pushup',
      parameters: GTSetParameters.repsWeight,
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {},
      sets: [],
      restTime: Duration.zero,
      notes: '',
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.none,
    );

    final workout = Workout(
      id: 'workout_1',
      name: 'Test Workout',
      exercises: [customEx],
      duration: const Duration(hours: 1),
      startingDate: DateTime.now(),
    );

    // 1. By default, with no matching local custom exercise, starting should be disabled.
    await tester.pumpWidget(WidgetTestApp(
      child: ExercisesView(workout: workout),
    ));
    await tester.pumpAndSettle();

    // Find the filled button (which contains text 'Redo this workout' or starting routines/workouts)
    final redoButtonFinder = find.byType(FilledButton);
    expect(redoButtonFinder, findsOneWidget);

    FilledButton redoButton = tester.widget<FilledButton>(redoButtonFinder);
    expect(redoButton.onPressed, isNull); // Disabled because customEx is unmatched!

    // 2. Now matching the custom exercise locally
    when(() => MockServices.exercisesController.exercises)
        .thenReturn(<Exercise>[customEx].obs);

    await tester.pumpWidget(WidgetTestApp(
      child: ExercisesView(workout: workout),
    ));
    await tester.pumpAndSettle();

    redoButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(redoButton.onPressed, isNotNull); // Enabled now!

    // 3. Setting canStart = false explicitly should disable it even if exercises match
    await tester.pumpWidget(WidgetTestApp(
      child: ExercisesView(workout: workout, canStart: false),
    ));
    await tester.pumpAndSettle();

    redoButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(redoButton.onPressed, isNull); // Disabled because canStart is false!
  });
}
