import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Rx;
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/migrations_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/online_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:rxdart/rxdart.dart';

class Coordinator extends GetxController
    with LoggerConfigurationMixin, ServiceableController {
  @override
  int get loggerMethodCount => 0;

  RxList<RoutineSuggestion> suggestions = <RoutineSuggestion>[].obs;
  late BehaviorSubject<bool> showPermissionTilesStream;

  @override
  void onServiceChange() {}

  T get<T>() => Get.find<T>();

  Future awaitInitialized() async {
    showPermissionTilesStream = BehaviorSubject<bool>.seeded(true);

    await Future.wait([
      Go.awaitInitialization(),
      get<SettingsController>().awaitInitialized(),
      get<NotificationController>().initialize(),
      if (Configuration.isOnlineAccountEnabled)
        get<OnlineController>().init().then((_) {
          if (get<OnlineController>().accountSync == null) return;
          get<OnlineController>().sync(
            currentSnapshot: get<DatabaseService>().currentSnapshot,
          );
        }),
    ]);

    showPermissionTilesStream.add(
        get<NotificationController>().showSettingsTileStream.value ||
            get<FoodController>().showSettingsTileStream.value);
    Rx.combineLatest([
      get<NotificationController>().showSettingsTileStream,
      get<FoodController>().showSettingsTileStream,
    ], (e) {
      logger.d("Show permission tiles: $e");
      return e.any((element) => element);
    }).pipe(showPermissionTilesStream);

    schedulePeriodicBackup();
    loadColdbootDeeplink();
  }

  @override
  void onClose() async {
    await showPermissionTilesStream.drain(true);
    showPermissionTilesStream.close();

    Get.delete<DebugController>();
    Get.delete<NotificationsService>();
    Get.delete<NotificationController>();
    Get.delete<RoutinesController>();
    Get.delete<HistoryController>();
    Get.delete<CountdownController>();
    Get.delete<ExercisesController>();
    Get.delete<StopwatchController>();
    Get.delete<MeController>();
    Get.delete<SettingsController>();
    Get.delete<ErrorController>();
    Get.delete<MigrationsController>();
    Get.delete<FoodController>();
    Get.delete<AchievementsController>();
    Get.delete<BoutiqueController>();
    if (Configuration.isOnlineAccountEnabled) {
      Get.delete<OnlineController>();
    }

    super.onClose();
  }

  init() {
    Get.put(DebugController());
    Get.put(NotificationsService());
    Get.put(NotificationController());
    Get.put(RoutinesController());
    Get.put(HistoryController());
    Get.put(CountdownController());
    Get.put(ExercisesController());
    Get.put(StopwatchController());
    Get.put(MeController());
    Get.put(SettingsController());
    Get.put(ErrorController(), permanent: true);
    Get.put(MigrationsController());
    Get.put(FoodController());
    Get.put(AchievementsController());
    Get.put(BoutiqueController());
    if (Configuration.isOnlineAccountEnabled) {
      Get.put(OnlineController());
    }

    if (service.hasOngoing) {
      Get.put(WorkoutController.fromSavedData(service.getOngoingData()!));
    }
  }

  /// If the app was launched by a deeplink while it was closed, this method
  /// will be called to handle the deeplink as if it was received in the
  /// foreground.
  void loadColdbootDeeplink() async {
    final deeplink = await protocolHandler.getInitialUrl();
    if (deeplink != null) {
      logger.d("Coldboot deeplink: $deeplink");
      for (final listener in protocolHandler.listeners) {
        listener.onProtocolUrlReceived(deeplink);
      }
    }
  }

  bool hasExercise(Exercise exercise) {
    final isInWorkout = Get.isRegistered<WorkoutController>() &&
        get<WorkoutController>().hasExercise(exercise);
    final isInHistory = get<HistoryController>().hasExercise(exercise);
    final isInRoutines = get<RoutinesController>().hasExercise(exercise);
    return isInWorkout || isInHistory || isInRoutines;
  }

  Future<void> applyExerciseModification(Exercise ex) async {
    if (get<HistoryController>().hasExercise(ex)) {
      await get<HistoryController>().applyExerciseModification(ex);
    }
    if (get<RoutinesController>().hasExercise(ex)) {
      await get<RoutinesController>().applyExerciseModification(ex);
    }
    if (Get.isRegistered<WorkoutController>() &&
        get<WorkoutController>().hasExercise(ex)) {
      get<WorkoutController>().applyExerciseModification(ex);
    }
  }

  void saveWorkoutAsRoutine(Workout workout) {
    final newID = get<RoutinesController>().importWorkout(workout);
    if (workout.parentID == null) {
      get<HistoryController>().setParentID(workout, newParentID: newID);
    }
    Go.snack("workouts.actions.saveAsRoutine.done".t);
  }

  List<Workout> getRoutineHistory({required Workout routine}) {
    return get<HistoryController>().getRoutineHistory(routine);
  }

  computeSuggestions() {
    final today = DateTime.now().weekday;
    final candidates = <Workout, int>{};
    final controller = get<HistoryController>();
    final history = controller.history;
    for (final routine in get<RoutinesController>().workouts) {
      final occurrences = history.where((wo) => wo.parentID == routine.id);
      candidates[routine] =
          occurrences.where((wo) => wo.startingDate?.weekday == today).length;
    }
    candidates.removeWhere((k, v) => v == 0);

    final listCandidates = [...candidates.entries];
    listCandidates.sort((a, b) => b.value - a.value);
    suggestions([
      ...listCandidates
          .map((a) => (routine: a.key, occurrences: a.value))
          .take(5)
    ]);
    logger
        .d("Recomputed suggested routines with ${suggestions().length} values");
  }

  void onNotificationTapped(NotificationResponse value) {
    if (Get.isRegistered<WorkoutController>()) {
      get<WorkoutController>().onNotificationTapped(value);
    }
  }

  void onHotReload() {
    logger.t("[#reassemble()] called");
    get<GTLocalizations>().init(false);
  }

  void scheduleBackup() {
    Future.delayed(const Duration(seconds: 5), () async {
      get<DatabaseService>().createBackup();

      if (Configuration.isOnlineAccountEnabled &&
          get<OnlineController>().accountSync != null) {
        get<OnlineController>().sync(
          currentSnapshot: get<DatabaseService>().currentSnapshot,
        );
      }
    });
  }

  void schedulePeriodicBackup() {
    get<DatabaseService>().schedulePeriodicBackup();
  }

  Map<Achievement, List<AchievementCompletion>> maybeUnlockAchievements(
      AchievementTrigger trigger) {
    return get<AchievementsController>().maybeUnlockAchievements(trigger);
  }

  void installRoutines(List<Workout> routines) {
    get<RoutinesController>().installRoutines(routines);
  }

  void onSuccessfulLogin() {
    get<OnlineController>().checkLocalAndRemoteDatabases(
      currentSnapshot: get<DatabaseService>().currentSnapshot,
    );
  }

  Future<void> overrideDatabase(DatabaseSnapshot snapshot) {
    return get<DatabaseService>().overrideDatabase(snapshot);
  }

  void bootProcedure() {
    final isTest = TestService().isTest;
    if (!isTest && !service.prefs$.value.onboardingComplete) {
      Go.offWithoutAnimation(() => const OnboardingScreen());
    } else {
      Go.offWithoutAnimation(() => const SkeletonView());
    }
  }

  void onFinishedOnboarding() {
    service.writeSettings(service.prefs$.value.copyWithOnboardingComplete());
    Go.offWithoutAnimation(() => const SkeletonView());
  }
}
