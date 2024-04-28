import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';

Future<void> testCombineWorkoutsFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await tester.pumpWidget(
    MainApp(localizations: l, databaseService: databaseService),
    const Duration(seconds: 5),
  );

  // Wait for the app to finish loading
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify that the app has started.
  expect(find.text('routines.quickWorkout.title'.t), findsOneWidget);

  await tester.tap(find.text("routines.quickWorkout.title".t));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Tap the add exercise button
  await tester.tap(find.text("ongoingWorkout.exercises.add".t));
  await tester.pumpAndSettle();

  // Verify that we're now at the exercise selection page
  expect(find.byType(ExercisePicker), findsOneWidget);

  // Select "Abs" > "Crunches"
  await tester.tap(find.text("library.abs.name".t));
  await tester.pumpAndSettle();
  await tester.tap(find.text("library.abs.exercises.crunches".t));
  await tester.pumpAndSettle();

  // Pick
  final addExercise = find.byKey(const Key("pick"));
  await tester.tap(addExercise);
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Verify that the exercise has been added
  expect(find.text("library.abs.exercises.crunches".t), findsOneWidget);

  // Add one set
  await tester.tap(find.text('exercise.actions.addSet'.t));
  await tester.pumpAndSettle();

  // Verify that the set has been added
  expect(find.byType(WorkoutExerciseSetEditor), findsNWidgets(2));

  // Mark the second set as done
  await tester.tap(find.byType(Checkbox).last);
  await tester.pumpAndSettle();

  // Finish the workout
  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("ongoingWorkout.actions.finish".t));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.widgetWithIcon(IconButton, GymTrackerIcons.done));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutDoneSheet), findsOneWidget);

  await tester.tap(find.byIcon(GymTrackerIcons.done));
  await tester.pumpAndSettle();

  // Go to the history page
  await tester.tap(find.byIcon(GymTrackerIcons.history));
  await tester.pumpAndSettle();

  // Verify that the workout is in the history
  expect(find.byType(HistoryWorkout), findsAny);

  // Tap the workout
  await tester.tap(find.byType(HistoryWorkout).last);
  await tester.pumpAndSettle();

  // Verify that the workout is displayed
  expect(find.byType(ExercisesView), findsOneWidget);

  // Continue the workout
  await tester.tap(find.text("workouts.actions.continue".t));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Verify that there's only one exercise with one done set and one undone set
  expect(find.byType(WorkoutExerciseSetEditor), findsNWidgets(2));
  expect(
    find.descendant(
      of: find.byType(WorkoutExerciseSetEditor),
      matching: find.byWidgetPredicate(
          (widget) => widget is Checkbox && widget.value == true),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: find.byType(WorkoutExerciseSetEditor),
      matching: find.byWidgetPredicate(
          (widget) => widget is Checkbox && widget.value == false),
    ),
    findsOneWidget,
  );

  // Mark the first set as done
  await tester.tap(find.descendant(
    of: find.byType(WorkoutExerciseSetEditor),
    matching: find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false),
  ));
  await tester.pumpAndSettle();

  // Finish the workout
  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("ongoingWorkout.actions.finish".t));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.widgetWithIcon(IconButton, GymTrackerIcons.done));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutDoneSheet), findsOneWidget);

  await tester.tap(find.byIcon(GymTrackerIcons.done));
  await tester.pumpAndSettle();

  // Verify that we're now at the history page
  expect(find.byType(HistoryView), findsOneWidget);

  // Scroll to the bottom
  await tester.fling(find.byType(HistoryView), const Offset(0, -200), 1000);
  await tester.pumpAndSettle();

  // Verify that the workout has been continued
  expect(
    find.descendant(
      of: find.byType(HistoryWorkout).last,
      matching: find.textContaining(
        "general.totalTime".tParams({"time": ""}),
        findRichText: true,
      ),
    ),
    findsOneWidget,
  );

  // Enter the workout
  await tester.tap(find.byType(HistoryWorkout).last);
  await tester.pumpAndSettle();

  // Verify that the workout is displayed
  expect(find.byType(ExercisesView), findsOneWidget);

  // Scroll to the bottom
  await tester.fling(find.byType(ExercisesView), const Offset(0, -400), 1000);
  await tester.pumpAndSettle();

  // Tap the "Continuation" button
  await tester.tap(find.text("exercise.continuation.label".t));
  await tester.pumpAndSettle();

  // Verify that the confirmation dialog is shown
  expect(find.byType(AlertDialog), findsOneWidget);

  // Tap the "OK" button
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();

  // Go back
  await tester.tap(find.byType(BackButtonIcon));
  await tester.pumpAndSettle();

  // Verify that the workout is not continued
  expect(
    find.descendant(
      of: find.byType(HistoryWorkout).last,
      matching: find.textContaining(
        "general.totalTime".tParams({"time": ""}),
        findRichText: true,
      ),
    ),
    findsNothing,
  );

  // Query the database to check how many workouts are in the history
  // (should be 1)
  final workouts = databaseService.workoutHistory;
  expect(workouts.length, 1);
}
