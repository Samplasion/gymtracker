import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/badges.dart';

void expectExercise(Exercise result, Exercise expected) {
  expect(result.name, expected.name);
  expect(result.parameters, expected.parameters);
  expect(result.primaryMuscleGroup, expected.primaryMuscleGroup);
  expect(result.secondaryMuscleGroups, expected.secondaryMuscleGroups);
  expect(result.restTime, expected.restTime);
  expect(result.notes, expected.notes);
  expect(result.sets.length, expected.sets.length);
  for (int i = 0; i < result.sets.length; i++) {
    expect(result.sets[i].kind, expected.sets[i].kind);
    expect(result.sets[i].parameters, expected.sets[i].parameters);
    expect(result.sets[i].reps, expected.sets[i].reps);
    expect(result.sets[i].weight, expected.sets[i].weight);
  }
}

Future<void> testCreateExerciseFlow(
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
  expect(find.text('library.title'.t), findsOneWidget);

  await tester
      .tap(find.widgetWithText(NavigationDestination, 'library.title'.t));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'library.custom'.t));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(ListTile, 'library.newCustomExercise'.t));
  await tester.pumpAndSettle();

  final titleBtn =
      find.widgetWithText(TextField, "exercise.editor.fields.title.label".t);
  final parametersBtn = find.widgetWithText(
      DropdownButtonFormField<SetParameters>,
      "exercise.editor.fields.parameters.label".t);
  final primaryMuscleGroupBtn = find.widgetWithText(
      DropdownButtonFormField<MuscleGroup>,
      "exercise.editor.fields.primaryMuscleGroup.label".t);
  final setFields = [
    titleBtn,
    parametersBtn,
    primaryMuscleGroupBtn,
  ];

  for (final finder in setFields) {
    expect(finder, findsOneWidget);
  }
  await tester.enterText(setFields[0], "EditedExercise");
  await tester.tap(setFields[1]);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(DropdownMenuItem<SetParameters>,
      "exercise.editor.fields.parameters.values.time".t));
  await tester.pumpAndSettle();
  await tester.tap(setFields[2]);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(
      DropdownMenuItem<MuscleGroup>, "muscleGroups.chest".t));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, "muscleGroups.triceps".t));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('done')));
  await tester.pumpAndSettle();

  await tester.tap(find.ancestor(
    of: find.byType(CustomExerciseBadge),
    matching: find.byType(ListTile),
  ));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  final ex = databaseService.exerciseBox.values.first;
  expectExercise(
    ex,
    Exercise.custom(
      id: "",
      name: "EditedExercise",
      parameters: SetParameters.time,
      sets: [],
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: {MuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "",
    ),
  );
}
