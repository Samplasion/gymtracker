import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/components/badges.dart';

import '../../test/expectations.dart';
import '../utils.dart';

Future<void> testCreateExerciseFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  // Verify that the app has started.
  expect(find.text(t.library.title), findsAny);

  await tester.tap(
    find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.byIcon(GTIcons.library)),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithIcon(ListTile, GTIcons.custom_exercises));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(ListTile, t.library.newCustomExercise));
  await tester.pumpAndSettle();

  final titleBtn =
      find.widgetWithText(TextField, t.exercise.editor.fields.title.label);
  final parametersBtn = find.widgetWithText(
      DropdownButtonFormField<GTSetParameters>,
      t.exercise.editor.fields.parameters.label);
  final primaryMuscleGroupBtn = find.widgetWithText(
      DropdownButtonFormField<GTMuscleGroup>,
      t.exercise.editor.fields.primaryMuscleGroup.label);
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
  await tester.tap(find.widgetWithText(DropdownMenuItem<GTSetParameters>,
      t.exercise.editor.fields.parameters.values['time']!));
  await tester.pumpAndSettle();
  await tester.tap(setFields[2]);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(
      DropdownMenuItem<GTMuscleGroup>, t.muscleGroups['chest']!));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, t.muscleGroups['triceps']!));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('done')));
  await tester.pumpAndSettle();

  await tester.tap(find.ancestor(
    of: find.byType(CustomExerciseBadge),
    matching: find.byType(ListTile),
  ));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  final ex = databaseService.exercises.first;
  expectExercise(
    ex,
    Exercise.custom(
      // We don't care about the ID, just that the data is correct
      id: ex.id,
      name: "EditedExercise",
      parameters: GTSetParameters.time,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "",
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.none,
    ),
  );
}
