import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/database.dart';
import 'package:mocktail/mocktail.dart';

class MockInternalFinalCallback<T> extends Mock
    implements InternalFinalCallback<T> {
  @override
  T call() => null as dynamic;
}

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();

  @override
  void addListener(void Function() listener) {}
  @override
  void removeListener(void Function() listener) {}
}

class MockCoordinator extends Mock implements Coordinator {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockSettingsController extends Mock implements SettingsController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockRoutinesController extends Mock implements RoutinesController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockHistoryController extends Mock implements HistoryController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockStopwatchController extends Mock implements StopwatchController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockCountdownController extends Mock implements CountdownController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockExercisesController extends Mock implements ExercisesController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockMeController extends Mock implements MeController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}


class MockAchievementsController extends Mock
    implements AchievementsController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockPurchasesController extends Mock implements PurchasesController {}

// Global setup helper
class MockServices {
  static late MockDatabaseService databaseService;
  static late MockCoordinator coordinator;
  static late MockSettingsController settingsController;
  static late MockRoutinesController routinesController;
  static late MockHistoryController historyController;
  static late MockStopwatchController stopwatchController;
  static late MockCountdownController countdownController;
  static late MockExercisesController exercisesController;
  static late MockMeController meController;
  static late MockAchievementsController achievementsController;
  static late MockPurchasesController purchasesController;

  static void setup() {
    Get.reset();
    Get.testMode = true;
    databaseService = MockDatabaseService();
    coordinator = MockCoordinator();
    settingsController = MockSettingsController();
    routinesController = MockRoutinesController();
    historyController = MockHistoryController();
    stopwatchController = MockStopwatchController();
    countdownController = MockCountdownController();
    exercisesController = MockExercisesController();
    meController = MockMeController();
    achievementsController = MockAchievementsController();
    purchasesController = MockPurchasesController();

    Get.put<DatabaseService>(databaseService);
    Get.put<Coordinator>(coordinator);
    Get.put<SettingsController>(settingsController);
    Get.put<RoutinesController>(routinesController);
    Get.put<HistoryController>(historyController);
    Get.put<StopwatchController>(stopwatchController);
    Get.put<CountdownController>(countdownController);
    Get.put<ExercisesController>(exercisesController);
    Get.put<MeController>(meController);
    Get.put<AchievementsController>(achievementsController);
    Get.put<PurchasesController>(purchasesController);

    // Default stubbing for critical common stuff
    registerFallbackValue(const Duration(seconds: 0));
    registerFallbackValue(Workout(name: '', exercises: []));
    registerFallbackValue(<Workout>[]);

    // SettingsController weight/distance
    when(() => settingsController.weightUnit).thenReturn(Weights.kg.obs);
    when(() => settingsController.distanceUnit).thenReturn(Distance.km.obs);
    when(
      () => settingsController.locale,
    ).thenReturn(Rx<Locale?>(const Locale('en', 'US')));
    when(() => settingsController.tintExercises).thenReturn(false.obs);
    when(() => settingsController.usesDynamicColor).thenReturn(false.obs);
    when(() => settingsController.themeMode).thenReturn(ThemeMode.system.obs);
    when(() => settingsController.color).thenReturn(Rx<Color>(Colors.blue));
    when(() => settingsController.showSuggestedRoutines).thenReturn(true.obs);

    // RoutinesController hasOngoingWorkout
    when(() => routinesController.hasOngoingWorkout).thenReturn(false.obs);
    when(() => routinesController.workouts).thenReturn(<Workout>[].obs);
    when(
      () => routinesController.isWorkoutContinuable(any()),
    ).thenReturn(false);

    // HistoryController history & userVisibleWorkouts
    when(() => historyController.history).thenReturn(<Workout>[].obs);
    when(() => historyController.userVisibleWorkouts).thenReturn(<Workout>[]);
    when(
      () => historyController.calculateMuscleCategoryDistributionFor(
        workouts: any(named: 'workouts'),
      ),
    ).thenReturn(<GTMuscleCategory, double>{});

    // DatabaseService empty lists/maps or no-ops
    when(() => databaseService.deleteOngoing()).thenAnswer((_) async {});
    when(() => databaseService.writeToOngoing(any())).thenAnswer((_) async {});

    // StopwatchController globalStopwatch
    final gs = GlobalStopwatch(onTick: (duration) {});
    when(() => stopwatchController.globalStopwatch).thenReturn(gs);
    when(
      () => stopwatchController.updateBinding(any(), any()),
    ).thenAnswer((_) {});
    when(() => stopwatchController.removeStopwatches(any())).thenAnswer((_) {});

    // CountdownController
    when(() => countdownController.removeCountdown()).thenAnswer((_) {});
    when(
      () => countdownController.startingTime,
    ).thenReturn(Rx<DateTime?>(null));
    when(() => countdownController.targetTime).thenReturn(Rx<DateTime?>(null));

    // Coordinator methods
    when(() => coordinator.onServiceChange()).thenAnswer((_) {});

    // PurchasesController
    when(
      () => purchasesController.subscriptionInfoStream,
    ).thenAnswer((_) => Stream.value(SubscriptionInfo.empty));
    when(
      () => purchasesController.subscriptionInfo,
    ).thenReturn(SubscriptionInfo.empty);
  }

  static void tearDown() {
    Get.reset();
  }
}
