import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:gymtracker/view/workout_editor.dart';

import '../utils.dart';

final ex = Exercise.raw(
  name: "Crunches",
  parentID: "library.abs.exercises.crunches",
  standard: true,
  sets: [
    GTSet.empty(
      kind: GTSetKind.normal,
      parameters: GTSetParameters.repsWeight,
    ).copyWith(done: true),
    GTSet.empty(
      kind: GTSetKind.normal,
      parameters: GTSetParameters.repsWeight,
    ).copyWith(done: true),
    GTSet.empty(kind: GTSetKind.normal, parameters: GTSetParameters.repsWeight),
    GTSet.empty(kind: GTSetKind.normal, parameters: GTSetParameters.repsWeight),
  ],
  parameters: GTSetParameters.repsWeight,
  primaryMuscleGroup: GTMuscleGroup.abs,
  restTime: Duration.zero,
  notes: "",
  supersetID: null,
  supersedesID: null,
  workoutID: "base",
  equipment: GTGymEquipment.none,
);
final historyWorkoutBase = Workout(
  id: "base",
  parentID: "routine",
  name: "Combinable Workout",
  exercises: [
    Superset(
      id: "superset",
      exercises: [ex.copyWith.supersetID("superset")],
      restTime: Duration.zero,
      workoutID: "base",
      supersedesID: null,
    ),
    ex.makeSibling(),
  ],
  duration: const Duration(minutes: 30),
  startingDate: DateTime.now(),
);
// final routine = historyWorkoutBase.toRoutine(routineID: "routine");

Future<void> testEditWorkoutCombinationFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  await awaitApp(tester, databaseService);
  // await databaseService.setRoutine(routine);
  await databaseService.setHistoryWorkout(historyWorkoutBase);
  expect(historyWorkoutBase.isContinuable, true);

  await openHistory(tester);
  await tester.pumpAndSettle();

  expect(find.byType(HistoryWorkout), findsOneWidget);

  await tester.tap(find.byType(HistoryWorkout));
  await tester.pumpAndSettle();

  expect(find.text(t.workouts.actions.kContinue), findsOneWidget);

  await tester.tap(find.text(t.workouts.actions.kContinue));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  WorkoutController controller = integrationContainer.read(
    workoutControllerProvider.notifier,
  );

  expect(controller.exercises.expand((element) => element.sets).length, 8);

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.text(t.ongoingWorkout.finish.save));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);

  HistoryController historyController = integrationContainer.read(
    historyControllerProvider,
  );

  expect(historyController.history.length, 2);

  var cont = historyController.history.firstWhere(
    (element) => element.isContinuation,
  );

  expect(cont.exercises.expand((element) => element.sets).length, 8);
  expect(cont.doneSets.length, 4);

  // Close the Good Job sheet
  expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  await tester.tap(find.byIcon(GTIcons.done));
  await tester.pumpAndSettle();

  await tester.fling(
    find.byType(CustomScrollView),
    const Offset(0.0, -600.0),
    1000,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byType(HistoryWorkout).last);
  await tester.pumpAndSettle();

  expect(find.byType(ExercisesView), findsOneWidget);

  await tester.tap(find.widgetWithIcon(PopupMenuButton, Icons.adaptive.more));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key("edit-workout-cont")));
  await tester.pumpAndSettle();

  // Reach each unfinished set explicitly; a fling can leave checkboxes built
  // outside the viewport and tapping their centers does not toggle them.
  await dismissKeyboard(tester);
  final list = findMainListView(tester);
  await tester.drag(list, const Offset(0, 1000));
  await tester.pumpAndSettle();
  final unfinished = [
    for (final exercise in [cont].flattenedExercises.whereType<Exercise>())
      for (final set in exercise.sets)
        if (!set.done) (exerciseId: exercise.id, setId: set.id),
  ];
  expect(unfinished.length, 4);
  for (final target in unfinished) {
    final row = find.byWidgetPredicate(
      (widget) =>
          widget is WorkoutExerciseSetEditor &&
          widget.exercise.id == target.exerciseId &&
          widget.set.id == target.setId,
    );
    final checkbox = find.descendant(of: row, matching: find.byType(Checkbox));
    // Nested, shrink-wrapped scroll positions may not have content dimensions;
    // use actual drags rather than ensureVisible's traversal of every ancestor.
    for (var i = 0; i < 50 && checkbox.hitTestable().evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -120));
      await tester.pumpAndSettle();
    }
    expect(checkbox.hitTestable(), findsOneWidget);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    await tester.tap(checkbox.hitTestable());
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  }

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish editing"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishEditingPage), findsOneWidget);

  await tester.tap(find.byKey(const Key("submit")));
  await waitForWidget(
    tester,
    find.byType(WorkoutFinishEditingPage),
    present: false,
  );

  expect(find.byType(WorkoutFinishEditingPage), findsNothing);
  expect(find.byType(WorkoutEditor), findsNothing);

  cont = historyController.history.firstWhere(
    (element) => element.isContinuation,
  );

  expect(cont.allSets.length, 8);
  expect(cont.doneSets.length, 8);
  expect(cont.isComplete, true);

  final synthesized = cont.synthesizeContinuations(
    history: historyController.history,
  );

  print(synthesized.toJson().toPrettyString());

  // Superset + Exercise, Exercise
  expect(synthesized.flattenedExercises.length, 3);
  expect(synthesized.allSets.length, 8);
  expect(synthesized.doneSets.length, 8);
}
