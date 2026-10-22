import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockSettingsController extends Mock implements SettingsController {}

class MockRoutinesController extends Mock implements RoutinesController {}

class MockHistoryController extends Mock implements HistoryController {}

class MockExercisesController extends Mock implements ExercisesController {}

class MockBackupScheduler extends Mock implements BackupScheduler {}

class MockNotificationController extends Mock
    implements NotificationController {}

class MockMeController extends Mock implements MeController {}

class MockAchievementsController extends Mock
    implements AchievementsController {}

class MockPurchasesController extends Mock implements PurchasesController {}

// Global setup helper
class MockServices {
  static late MockDatabaseService databaseService;
  static late GTDatabase database;
  static late ProviderContainer container;
  static late MockBackupScheduler backupScheduler;
  static late MockNotificationController notifications;
  static late MockSettingsController settingsController;
  static late MockRoutinesController routinesController;
  static late MockHistoryController historyController;
  static late StopwatchController stopwatchController;
  static late CountdownController countdownController;
  static late MockExercisesController exercisesController;
  static late MockMeController meController;
  static late MockAchievementsController achievementsController;
  static late MockPurchasesController purchasesController;

  static void setup() {
    WidgetsFlutterBinding.ensureInitialized();
    database = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    databaseService = MockDatabaseService();
    when(() => databaseService.db).thenReturn(database);
    backupScheduler = MockBackupScheduler();
    notifications = MockNotificationController();
    settingsController = MockSettingsController();
    routinesController = MockRoutinesController();
    historyController = MockHistoryController();
    exercisesController = MockExercisesController();
    meController = MockMeController();
    achievementsController = MockAchievementsController();
    purchasesController = MockPurchasesController();
    when(() => purchasesController.dispose()).thenAnswer((_) async {});

    // Default stubbing for critical common stuff
    registerFallbackValue(AchievementTrigger.workout);
    registerFallbackValue(const Duration(seconds: 0));
    registerFallbackValue(Workout(name: '', exercises: []));
    registerFallbackValue(<Workout>[]);

    // SettingsController weight/distance
    when(() => settingsController.weightUnit).thenReturn(Weights.kg);
    when(() => settingsController.distanceUnit).thenReturn(Distance.km);
    when(() => settingsController.locale).thenReturn(const Locale('en', 'US'));
    when(() => settingsController.tintExercises).thenReturn(false);
    when(() => settingsController.usesDynamicColor).thenReturn(false);
    when(() => settingsController.themeMode).thenReturn(ThemeMode.system);
    when(() => settingsController.color).thenReturn(Colors.blue);
    when(() => settingsController.showSuggestedRoutines).thenReturn(true);

    // RoutinesController hasOngoingWorkout
    when(() => routinesController.hasOngoingWorkout).thenReturn(false);
    when(() => routinesController.workouts).thenReturn(<Workout>[]);
    when(
      () => routinesController.isWorkoutContinuable(any()),
    ).thenReturn(false);

    // HistoryController history & userVisibleWorkouts
    when(() => historyController.history).thenReturn(<Workout>[]);
    when(() => historyController.userVisibleWorkouts).thenReturn(<Workout>[]);
    when(
      () => historyController.calculateMuscleCategoryDistributionFor(
        workouts: any(named: 'workouts'),
      ),
    ).thenReturn(<GTMuscleCategory, double>{});

    when(() => databaseService.db).thenReturn(database);

    // DatabaseService empty lists/maps or no-ops
    when(() => databaseService.deleteOngoing()).thenAnswer((_) async {});
    when(() => databaseService.writeToOngoing(any())).thenAnswer((_) async {});

    when(() => backupScheduler.schedule()).thenAnswer((_) {});
    when(
      () => achievementsController.maybeUnlockAchievements(any()),
    ).thenReturn({});
    when(() => notifications.cancelRestOverNotification()).thenAnswer((_) {});

    // PurchasesController
    when(
      () => purchasesController.subscriptionInfoStream,
    ).thenAnswer((_) => Stream.value(SubscriptionInfo.empty));
    when(
      () => purchasesController.subscriptionInfo,
    ).thenReturn(SubscriptionInfo.empty);

    container = ProviderContainer(overrides: defaultOverrides);
    stopwatchController = container.read(stopwatchControllerProvider.notifier);
    countdownController = container.read(countdownControllerProvider.notifier);
    TestService().isTest = true;
  }

  static List<Override> get defaultOverrides => [
    databaseServiceProvider.overrideWithValue(databaseService),
    appDatabaseProvider.overrideWithValue(database),
    settingsControllerProvider.overrideWithValue(settingsController),
    appPreferencesProvider.overrideWith(
      (ref) => Stream.value(Prefs.defaultValue),
    ),
    routinesControllerProvider.overrideWithValue(routinesController),
    historyControllerProvider.overrideWithValue(historyController),
    exercisesControllerProvider.overrideWithValue(exercisesController),
    purchasesControllerProvider.overrideWithValue(purchasesController),
    achievementsControllerProvider.overrideWithValue(achievementsController),
    achievementTriggerProvider.overrideWithValue((trigger) {
      achievementsController.maybeUnlockAchievements(trigger);
    }),
    backupSchedulerProvider.overrideWithValue(backupScheduler),
    notificationControllerProvider.overrideWithValue(notifications),
  ];

  static WorkoutController createWorkout(
    String name,
    String? parentID,
    String? infobox,
  ) =>
      container.read(workoutControllerProvider.notifier)
        ..start(name, parentID, infobox, saveInitial: false);
  static WorkoutController restoreWorkout(Map<String, dynamic> data) =>
      container.read(workoutControllerProvider.notifier)..restore(data);

  static void tearDown() {
    TestService().isTest = false;
    container.dispose();
    database.close();
  }
}
