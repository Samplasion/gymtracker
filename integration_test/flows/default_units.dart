import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/workout.dart';

import '../utils.dart';

WorkoutController get workoutController =>
    integrationContainer.read(workoutControllerProvider.notifier);

Future<void> testDefaultUnitsFlow(
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

  // Check that the default units are set to kilograms and kilometers
  expect(workoutController.weightUnit, Weights.kg);
  expect(workoutController.distanceUnit, Distance.km);

  // Discard the workout
  await tester.tap(find.byKey(const Key("main-menu")));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.ongoingWorkout.actions.cancel));
  await tester.pumpAndSettle();

  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.text(t.ongoingWorkout.cancel.actions.yes));
  await tester.pumpAndSettle();

  // Go to the settings and change the units
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationDrawerDestination),
      matching: find.byIcon(GTIcons.settings),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text(t.settings.panes.units));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.settings.options.weightUnit.label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.weightUnits['lb']!));
  await tester.pumpAndSettle();
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();

  await tester.tap(find.text(t.settings.options.distanceUnit.label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.distanceUnits['mi']!));
  await tester.pumpAndSettle();
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();

  final settingsController = integrationContainer.read(
    settingsControllerProvider,
  );

  // Check that the units have changed
  expect(settingsController.weightUnit, Weights.lb);
  expect(settingsController.distanceUnit, Distance.mi);

  // Return from settings before selecting the main section.
  await tester.tap(find.byType(BackButton).hitTestable().first);
  await tester.pumpAndSettle();
  await openMainSection(tester, GTIcons.muscle);

  // Start another workout and check that the units have changed
  await tester.tap(find.text(t.routines.quickWorkout.title));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Check that the default units are set to kilograms and kilometers
  expect(workoutController.weightUnit, Weights.lb);
  expect(workoutController.distanceUnit, Distance.mi);

  // Cleanup
  await tester.tap(find.byKey(const Key("main-menu")));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.ongoingWorkout.actions.cancel));
  await tester.pumpAndSettle();

  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.text(t.ongoingWorkout.cancel.actions.yes));
  await tester.pumpAndSettle();
}
