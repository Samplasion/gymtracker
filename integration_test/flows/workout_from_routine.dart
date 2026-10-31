import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';

import '../utils.dart';
import 'create_routine.dart';

Future<void> testWorkoutFromRoutineFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Create our routine
  await testCreateRoutineFlow(tester, databaseService);

  await tester.tap(find.widgetWithText(ListTile, "Test Routine"));
  await tester.pumpAndSettle();

  expect(find.widgetWithText(FilledButton, 'Start routine'), findsOneWidget);
  expect(find.byType(ExerciseDataView, skipOffstage: false), findsOneWidget);
  expect(find.text("Rest time: 01:00"), findsOneWidget);
  for (final count in [5, 10, 15]) {
    expect(find.text("$count reps"), findsOneWidget);
  }

  await tester.tap(find.widgetWithText(FilledButton, 'Start routine'));
  await tester.pumpAndSettle(const Duration(seconds: 5));

  expect(find.byType(WorkoutView), findsOneWidget);

  final setFields = find.widgetWithText(TextField, "Reps");
  expect(setFields, findsNWidgets(3));

  for (final field in setFields.evaluate()) {
    await enterTextAndDismissKeyboard(
      tester,
      find.byWidget(field.widget),
      "10",
    );
  }

  final checkboxes = find.byType(Checkbox);
  expect(checkboxes, findsNWidgets(3));

  for (final checkbox in checkboxes.evaluate()) {
    await tester.tap(find.byWidget(checkbox.widget));
  }

  // Avoiding pumpAndSettle here because the animation in WorkoutTimerView
  // causes the tester to wait for the entire duration of the timer
  await tester.pump(const Duration(seconds: 2));
  // The first frame rebuilds the Riverpod consumer and starts the 300ms
  // crossfade from a zero-height bottom bar. Finish that transition without
  // waiting for the countdown's continuously animated progress indicator.
  await tester.pump(const Duration(milliseconds: 350));

  expect(find.byType(WorkoutTimerView), findsOneWidget);
  final skipRest = find
      .descendant(
        of: find.byType(WorkoutTimerView),
        matching: find.byIcon(GTIcons.skip),
      )
      .hitTestable();
  expect(skipRest, findsOneWidget);

  // Stop the rest timer before the next pumpAndSettle calls.
  await tester.tap(skipRest);
  await tester.pumpAndSettle();
  expect(skipRest, findsNothing);

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.text('Save workout'));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);
  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.widgetWithText(TextButton, "OK"));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  final routine = databaseService.routines.first;
  final firstExercise = routine.exercises.first;
  for (final set in firstExercise.sets) {
    expect(set.reps, 10);
  }

  // Close the Good Job sheet
  expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  await tester.tap(find.byIcon(GTIcons.done));
  await tester.pumpAndSettle();

  // Check the history view
  await openHistory(tester);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.byType(HistoryWorkout), findsOneWidget);
  expect(find.text("Test Routine"), findsOneWidget);
  expect(find.text("3 × 10 reps"), findsOneWidget);

  // Check the history entry in the db
  final history = databaseService.workoutHistory.single;
  expect(history.id == routine.id, false);
  expect(history.parentID, routine.id);
  final historyFirstExercise = history.exercises.single;
  // debugPrint("$historyFirstExercise");
  for (final set in historyFirstExercise.sets) {
    expect(set.done, true);
  }
}
