import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/service/version.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'flows/achievements.dart';
import 'flows/combine_workouts.dart';
import 'flows/create_exercise.dart';
import 'flows/create_routine.dart';
import 'flows/default_units.dart';
import 'flows/delete_routine.dart';
import 'flows/edit_combination.dart';
import 'flows/edit_exercise_in_routines_and_history.dart';
import 'flows/edit_exercise_while_ongoing.dart';
import 'flows/edit_workout.dart';
import 'flows/log_weight.dart';
import 'flows/routine_from_workout.dart';
import 'flows/workout_from_routine.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestService().isTest = true;
  late DatabaseService databaseService = DatabaseService();
  await databaseService.ensureInitializedForTests(NativeDatabase.memory(), null);

  setUp(() async {
    IntegrationTestWidgetsFlutterBinding.instance.reset();
    globalContainer = ProviderContainer();
    LocaleSettings.setLocale(AppLocale.en);
    await ColorService().init();
    await VersionService().init();

    final TimezoneInfo currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
  });

  tearDown(() async {
    print("Waiting for asynchronous code to finish");
    // Is there a better way to wait for all asynchronous code to finish?
    await Future.delayed(const Duration(seconds: 10));

    print("\n${"=" * 10}\nTearing down the database");
    await databaseService.teardown();
    Get.reset();
  });

  // TODO: Use localized strings ("".t) in the tests
  group('end-to-end test', () {
    testWidgets(
      'create routine',
      (tester) => testCreateRoutineFlow(tester, databaseService),
    );
    testWidgets(
      'create workout from routine and save it back',
      (tester) => testWorkoutFromRoutineFlow(tester, databaseService),
    );
    testWidgets(
      'edit workout',
      (tester) => testEditWorkoutFlow(tester, databaseService),
    );
    group("edit exercise", () {
      testWidgets(
        'edit an exercise that was saved in a routine and/or in history',
        (tester) =>
            testEditExerciseInRoutineAndHistoryFlow(tester, databaseService),
      );
      testWidgets(
        'edit exercise while workout is ongoing',
        (tester) => testEditExerciseWhileWorkoutIsOngoingFlow(
            tester, databaseService),
      );
    });
    testWidgets(
      'create exercise',
      (tester) => testCreateExerciseFlow(tester, databaseService),
    );
    testWidgets(
      'create routine from history workout',
      (tester) => testRoutineFromWorkout(tester, databaseService),
    );
    testWidgets(
      'combine workouts',
      (tester) => testCombineWorkoutsFlow(tester, databaseService),
    );
    testWidgets(
      'edit workout combination',
      (tester) => testEditWorkoutCombinationFlow(tester, databaseService),
    );
    testWidgets(
      'test default units',
      (tester) => testDefaultUnitsFlow(tester, databaseService),
    );
    testWidgets(
      'delete routine',
      (tester) => testDeleteRoutineFlow(tester, databaseService),
    );
    testWidgets(
      'log weight',
      (tester) => testLogWeightFlow(tester, databaseService),
    );
    testWidgets(
      'achievements check',
      (tester) => testAchievementsFlow(tester, databaseService),
    );
  });
}
