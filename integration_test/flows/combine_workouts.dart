import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';

import '../utils.dart';

Future<void> testCombineWorkoutsFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  // Verify that the app has started.
  expect(find.text(t.routines.quickWorkout.title), findsOneWidget);

  await tester.tap(find.text(t.routines.quickWorkout.title));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Tap the add exercise button
  await tester.tap(find.text(t.ongoingWorkout.exercises.add));
  await tester.pumpAndSettle();

  // Verify that we're now at the exercise selection page
  expect(find.byType(ExercisePicker), findsOneWidget);

  // Select "Abs" > "Crunches"
  await tester.tap(find.text(t.library.abs.name));
  await tester.pumpAndSettle();
  final crunches = find.text(t.library.abs.exercises.crunches);
  await scrollToIfNeeded(tester, crunches);
  await tester.tap(crunches);
  await tester.pumpAndSettle();

  // Pick
  final addExercise = find.byKey(const Key("pick"));
  await tester.tap(addExercise);
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Verify that the exercise has been added
  expect(find.text(t.library.abs.exercises.crunches), findsOneWidget);

  // Add one set
  await tester.tap(find.text(t.exercise.actions.addSet));
  await tester.pumpAndSettle();

  // Verify that the set has been added
  expect(find.byType(WorkoutExerciseSetEditor), findsNWidgets(2));

  // Mark the second set as done
  await tester.tap(find.byType(Checkbox).last);
  await tester.pumpAndSettle();

  // Finish the workout
  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.ongoingWorkout.actions.finish));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.text(t.ongoingWorkout.finish.save));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutDoneSheet), findsOneWidget);

  await tester.tap(find.byIcon(GTIcons.done));
  await tester.pumpAndSettle();

  // Go to the history page
  await openHistory(tester);
  await tester.pumpAndSettle();

  // Verify that the workout is in the history
  expect(find.byType(HistoryWorkout), findsAny);

  // Tap the workout
  await tester.tap(find.byType(HistoryWorkout).last);
  await tester.pumpAndSettle();

  // Verify that the workout is displayed
  expect(find.byType(ExercisesView), findsOneWidget);

  // Continue the workout
  await tester.tap(find.text(t.workouts.actions.kContinue));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Verify that there's only one exercise with one done set and one undone set
  expect(find.byType(WorkoutExerciseSetEditor), findsNWidgets(2));
  expect(
    find.descendant(
      of: find.byType(WorkoutExerciseSetEditor),
      matching: find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      ),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: find.byType(WorkoutExerciseSetEditor),
      matching: find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      ),
    ),
    findsOneWidget,
  );

  // Mark the first set as done
  await tester.tap(
    find.descendant(
      of: find.byType(WorkoutExerciseSetEditor),
      matching: find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Finish the workout
  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.ongoingWorkout.actions.finish));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.text(t.ongoingWorkout.finish.save));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutDoneSheet), findsOneWidget);

  await tester.tap(find.byIcon(GTIcons.done));
  await tester.pumpAndSettle();

  // Verify that we're now at the history page
  expect(find.byType(HistoryView), findsOneWidget);

  // Scroll to the bottom
  await tester.fling(find.byType(HistoryView), const Offset(0, -400), 1000);
  await tester.pumpAndSettle();

  // Verify that the workout has been continued
  expect(
    find.descendant(
      of: find.byType(HistoryWorkout).last,
      matching: find.textContaining(
        t.general.totalTime(time: ""),
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
  await tester.fling(find.byType(ExercisesView), const Offset(0, -500), 1000);
  await tester.pumpAndSettle();

  // Tap the "Continuation" button
  await tester.tap(find.text(t.exercise.continuation.label));
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
        t.general.totalTime(time: ""),
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
