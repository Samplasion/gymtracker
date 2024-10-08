import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/workout.dart';

WorkoutController get workoutController => Get.find<WorkoutController>();

Future<void> testDefaultUnitsFlow(
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
  expect(find.text('routines.quickWorkout.title'.t), findsOneWidget);

  await tester.tap(find.text("routines.quickWorkout.title".t));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Check that the default units are set to kilograms and kilometers
  expect(workoutController.weightUnit.value, Weights.kg);
  expect(workoutController.distanceUnit.value, Distance.km);

  // Discard the workout
  await tester.tap(find.byKey(const Key("main-menu")));
  await tester.pumpAndSettle();
  await tester.tap(find.text("ongoingWorkout.actions.cancel".t));
  await tester.pumpAndSettle();

  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.text("ongoingWorkout.cancel.actions.yes".t));
  await tester.pumpAndSettle();

  // Go to the settings and change the units
  await tester.tap(find.byIcon(GTIcons.settings));
  await tester.pumpAndSettle();

  await tester.tap(find.text("settings.options.weightUnit.label".t));
  await tester.pumpAndSettle();
  await tester.tap(find.text("weightUnits.lb".t));
  await tester.pumpAndSettle();
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();

  await tester.tap(find.text("settings.options.distanceUnit.label".t));
  await tester.pumpAndSettle();
  await tester.tap(find.text("distanceUnits.mi".t));
  await tester.pumpAndSettle();
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();

  final settingsController = Get.find<SettingsController>();

  // Check that the units have changed
  expect(settingsController.weightUnit.value, Weights.lb);
  expect(settingsController.distanceUnit.value, Distance.mi);

  // Go back
  await tester.tap(find.byIcon(GTIcons.library));
  await tester.pumpAndSettle();

  // Start another workout and check that the units have changed
  await tester.tap(find.text("routines.quickWorkout.title".t));
  await tester.pumpAndSettle();

  // Verify that we're now at the workout page
  expect(find.byType(WorkoutView), findsOneWidget);

  // Check that the default units are set to kilograms and kilometers
  expect(workoutController.weightUnit.value, Weights.lb);
  expect(workoutController.distanceUnit.value, Distance.mi);

  // Cleanup
  await tester.tap(find.byKey(const Key("main-menu")));
  await tester.pumpAndSettle();
  await tester.tap(find.text("ongoingWorkout.actions.cancel".t));
  await tester.pumpAndSettle();

  expect(find.byType(AlertDialog), findsOneWidget);

  await tester.tap(find.text("ongoingWorkout.cancel.actions.yes".t));
  await tester.pumpAndSettle();
}
