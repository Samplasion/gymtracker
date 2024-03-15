import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/workout.dart';

import 'create_routine.dart';

Future<void> testWorkoutFromRoutineFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Create our routine
  await testCreateRoutineFlow(tester, l, databaseService);

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
    await tester.enterText(find.byWidget(field.widget), "10");
  }

  final checkboxes = find.byType(Checkbox);
  expect(checkboxes, findsNWidgets(3));

  for (final checkbox in checkboxes.evaluate()) {
    await tester.tap(find.byWidget(checkbox.widget));
  }

  // Avoiding pumpAndSettle here because the animation in WorkoutTimerView
  // causes the tester to wait for the entire duration of the timer
  await tester.pump(const Duration(seconds: 2));

  expect(find.byType(WorkoutTimerView), findsOneWidget);

  // Avoid the above issue for the next pumpAndSettle calls
  await tester.tap(find.widgetWithIcon(IconButton, Icons.skip_next_rounded));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);
  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.widgetWithText(TextButton, "OK"));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  final routine = databaseService.routinesBox.values.first;
  final firstExercise = routine.exercises.first;
  for (final set in firstExercise.sets) {
    expect(set.reps, 10);
  }

  // Check the history view
  await tester.tap(find.byIcon(Icons.history_rounded));
  await tester.pumpAndSettle();

  expect(find.byType(HistoryWorkout), findsOneWidget);
  expect(find.text("Test Routine"), findsOneWidget);
  expect(find.text("3 × 10 reps"), findsOneWidget);

  // Check the history entry in the db
  final history = databaseService.historyBox.values.first;
  expect(history.id == routine.id, false);
  expect(history.parentID, routine.id);
  final historyFirstExercise = routine.exercises.first;
  for (final set in historyFirstExercise.sets) {
    expect(set.done, true);
  }
}
