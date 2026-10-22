import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/routines.dart';
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
import 'utils.dart';

class _IntegrationConnectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  TestService().isTest = true;
  late DatabaseService databaseService;

  setUp(() async {
    IntegrationTestWidgetsFlutterBinding.instance.reset();
    databaseService = DatabaseService.withDatabase(
      GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()),
    );
    await databaseService.ensureInitialized();
    integrationContainer = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(databaseService),
        appDatabaseProvider.overrideWithValue(databaseService.db),
        platformLocaleProvider.overrideWithValue(AppLocale.en.flutterLocale),
        networkConnectivityProvider.overrideWith(_IntegrationConnectivity.new),
      ],
    );
    integrationContainer.listen(routinesStreamProvider, (_, _) {});
    integrationContainer.listen(foldersStreamProvider, (_, _) {});
    await Future.wait([
      integrationContainer.read(routinesStreamProvider.future),
      integrationContainer.read(foldersStreamProvider.future),
    ]);
    LocaleSettings.setLocale(AppLocale.en);
    await ColorService().init();
    await VersionService().init();

    final TimezoneInfo currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
  });

  tearDown(() async {
    await integrationContainer.read(accountWorkoutLifecycleProvider).suspend();
    integrationContainer.dispose();
    databaseService.dispose();
    await Future<void>.delayed(Duration.zero);
    await databaseService.db.close();
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
        (tester) =>
            testEditExerciseWhileWorkoutIsOngoingFlow(tester, databaseService),
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
