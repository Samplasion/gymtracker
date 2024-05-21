import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';

Future<void> testCreateRoutineFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await tester.pumpWidget(
    MainApp(localizations: l, databaseService: databaseService),
    duration: const Duration(seconds: 5),
  );

  // Wait for the app to finish loading
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify that the app has started.
  expect(find.text('New routine'), findsOneWidget);

  final button = find.widgetWithText(ListTile, "New routine");
  await tester.tap(button);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Verify that we're at a new page
  expect(find.text('New routine'), findsNothing);
  expect(find.text('Create new routine'), findsOneWidget);

  final nameField = find.widgetWithText(TextFormField, "Routine name");
  await tester.enterText(nameField, "Test Routine");

  // Add an exercise
  final addExerciseButton = find.widgetWithText(ListTile, "Add exercises");
  await tester.tap(addExerciseButton);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Verify that we're at a new page
  expect(find.text('Select exercises'), findsOneWidget);

  // Add an exercise
  final category = find.widgetWithText(ListTile, "Abs");
  await tester.tap(category);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Verify that we're at a new page
  expect(find.text('Select exercises'), findsNothing);

  final exercise = find.widgetWithText(ListTile, 'Crunches');
  expect(exercise, findsOneWidget);

  await tester.tap(exercise);

  // Trigger a frame.
  await tester.pumpAndSettle();

  final addExercise = find.byKey(const Key("pick"));
  await tester.tap(addExercise);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Scroll down
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Add two more sets
  final addSetButton =
      find.widgetWithText(FilledButton, "+ Add Set", skipOffstage: false);

  await tester.tap(addSetButton);
  await tester.pumpAndSettle();

  // Scroll down
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));

  // Trigger a frame.
  await tester.pumpAndSettle();

  await tester.tap(addSetButton);
  await tester.pumpAndSettle();

  expect(find.widgetWithText(TextField, "Reps"), findsNWidgets(3));

  // Fill in the rest timer field
  final restTimerField = find.widgetWithText(TextField, "Rest time");
  await tester.enterText(restTimerField, "100");
  await tester.pumpAndSettle();
  expect(find.text('01:00'), findsOneWidget);

  // Remove focus
  FocusManager.instance.primaryFocus?.unfocus();

  // Scroll down
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Fill in the sets
  final repsFields =
      find.widgetWithText(TextField, "Reps", skipOffstage: false).evaluate();
  int currentReps = 5;
  for (final repsField in repsFields) {
    await tester.enterText(find.byWidget(repsField.widget), "$currentReps");
    currentReps += 5;
  }

  // Scroll down
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Save the routine
  final saveButton = find.widgetWithIcon(IconButton, GymTrackerIcons.done);
  await tester.tap(saveButton);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Verify that we're at the routine page
  expect(find.text('New routine'), findsOneWidget);
  expect(find.text('Test Routine'), findsOneWidget);
  expect(databaseService.routines.length, 1);

  final newRoutine = databaseService.routines.first;
  expect(newRoutine.name, "Test Routine");
  expect(newRoutine.exercises.length, 1);
  final exerciseObj = newRoutine.exercises.first as Exercise;
  expect(exerciseObj.name, "Crunches");
  expect(exerciseObj.parentID, "library.abs.exercises.crunches");
  expect(exerciseObj.restTime, const Duration(minutes: 1));
  expect(exerciseObj.sets.length, 3);
  expect(exerciseObj.sets.map((e) => e.reps).toList(), [5, 10, 15]);
}
