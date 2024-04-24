import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/superset.dart';
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
    GTSet.empty(
      kind: GTSetKind.normal,
      parameters: GTSetParameters.repsWeight,
    ),
    GTSet.empty(
      kind: GTSetKind.normal,
      parameters: GTSetParameters.repsWeight,
    ),
  ],
  parameters: GTSetParameters.repsWeight,
  primaryMuscleGroup: GTMuscleGroup.abs,
  restTime: Duration.zero,
  notes: "",
  supersetID: null,
  supersedesID: null,
  workoutID: "base",
);
final historyWorkoutBase = Workout(
  id: "base",
  parentID: "routine",
  name: "Combinable Workout",
  exercises: [
    Superset(
      id: "superset",
      exercises: [
        ex.copyWith.supersetID("superset"),
      ],
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
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  await awaitApp(tester, l, databaseService);
  // await databaseService.setRoutine(routine);
  await databaseService.setHistoryWorkout(historyWorkoutBase);
  expect(historyWorkoutBase.isContinuable, true);

  await tester.tap(find.byIcon(Icons.history_rounded));
  await tester.pumpAndSettle();

  expect(find.byType(HistoryWorkout), findsOneWidget);

  await tester.tap(find.byType(HistoryWorkout));
  await tester.pumpAndSettle();

  expect(find.text("workouts.actions.continue".t), findsOneWidget);

  await tester.tap(find.text("workouts.actions.continue".t));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  WorkoutController controller = Get.find<WorkoutController>();

  expect(controller.exercises().expand((element) => element.sets).length, 8);

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);

  HistoryController historyController = Get.find<HistoryController>();

  expect(historyController.history.length, 2);

  var cont =
      historyController.history.firstWhere((element) => element.isContinuation);

  expect(cont.exercises.expand((element) => element.sets).length, 8);
  expect(cont.doneSets.length, 4);

  // Close the Good Job sheet
  expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  await tester.tap(find.byIcon(Icons.done_rounded));
  await tester.pumpAndSettle();

  await tester.fling(
      find.byType(CustomScrollView), const Offset(0.0, -600.0), 1000);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(HistoryWorkout).last);
  await tester.pumpAndSettle();

  expect(find.byType(ExercisesView), findsOneWidget);

  await tester.tap(find.widgetWithIcon(PopupMenuButton, Icons.adaptive.more));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key("edit-workout-cont")));
  await tester.pumpAndSettle();

  await tester.fling(find.byType(ListView), const Offset(0.0, -200.0), 1000);
  await tester.pumpAndSettle();

  var finder = find.descendant(
    of: find.byType(SupersetEditor),
    matching: find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false),
  );
  var elements = finder.evaluate().map((e) => e.widget);
  for (final element in elements) {
    await tester.tap(find.byWidget(element));
    await tester.pumpAndSettle();
  }
  // await tester.tap(
  //   find
  //       .descendant(
  //         of: find.byType(SupersetEditor),
  //         matching: find.byType(Checkbox),
  //       )
  //       .last,
  // );
  // await tester.pumpAndSettle();

  await tester.fling(find.byType(ListView), const Offset(0.0, -700.0), 1000);
  await tester.pumpAndSettle();

  finder = find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.value == false);
  elements = finder.evaluate().map((e) => e.widget);
  for (final element in elements) {
    await tester.tap(find.byWidget(element));
    await tester.pumpAndSettle();
  }
  // await tester.tap(find
  //     .byWidgetPredicate((widget) => widget is Checkbox && widget.value != true)
  //     .first);
  // await tester.tap(find
  //     .byWidgetPredicate((widget) => widget is Checkbox && widget.value != true)
  //     .last);
  // await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish editing"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishEditingPage), findsOneWidget);

  await tester.tap(find.byKey(const Key("submit")));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  expect(find.byType(WorkoutFinishEditingPage), findsNothing);
  expect(find.byType(WorkoutEditor), findsNothing);

  cont =
      historyController.history.firstWhere((element) => element.isContinuation);

  expect(cont.allSets.length, 8);
  expect(cont.doneSets.length, 8);
  expect(cont.isComplete, true);

  final synthesized = cont.synthesizeContinuations();

  print(synthesized.toJson().toPrettyString());

  // Superset + Exercise, Exercise
  expect(synthesized.flattenedExercises.length, 3);
  expect(synthesized.allSets.length, 8);
  expect(synthesized.doneSets.length, 8);
}
