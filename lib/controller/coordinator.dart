import 'dart:async';
import 'dart:math';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Rx;
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/intents_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/migrations_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:rxdart/rxdart.dart';

enum ScheduledEvent {
  onboardingComplete,
  userWillLogin,
  userDidLogin,
  userWillLogout,
  userDidLogout,
  userDidUpdate,
  userDidUpdateSubscription,
}

const double kRoutineSuggestionHalfLifeDays = 28.0;
const double kRoutineSuggestionMatchingDayWeight = 1.0;
const double kRoutineSuggestionOtherDayWeight = 0.2;

class Coordinator extends GetxController
    with LoggerConfigurationMixin, ServiceableController {
  @override
  int get loggerMethodCount => 0;

  RxList<RoutineSuggestion> suggestions = <RoutineSuggestion>[].obs;
  final showPermissionTilesStream = BehaviorSubject<bool>.seeded(true);
  StreamSubscription<bool>? _permissionSubscription;
  Future<void>? _ongoingRestore;

  @override
  void onServiceChange() {}

  T get<T>() => Get.find<T>();

  Future awaitInitialized() async {
    logger.i(
      "[Coordinator.awaitInitialized] Started. "
      "prefs onboardingComplete=${service.prefs$.valueOrNull?.onboardingComplete}, "
      "currentUserId=${service.db.currentUserId}",
    );

    await Future.wait([
      Go.awaitInitialization(),
      get<SettingsController>().awaitInitialized(),
      get<NotificationController>().initialize(),
      if (_ongoingRestore != null) _ongoingRestore!,
      _awaitRemoteInitialization(globalContainer.read(onlineProvider.future)),
      _awaitRemoteInitialization(get<PurchasesService>().init()),
    ]);
    logger.i(
      "[Coordinator.awaitInitialized] Completed Future.wait. "
      "prefs onboardingComplete=${service.prefs$.valueOrNull?.onboardingComplete}, "
      "currentUserId=${service.db.currentUserId}",
    );
    get<AchievementsController>().init();
    IntentsController.initialize();

    showPermissionTilesStream.add(
      get<NotificationController>().showSettingsTileStream.value ||
          globalContainer.read(showFoodPermissionsSettingsTileProvider) ||
          !get<HealthController>().hasPermissionStream.value,
    );
    await _permissionSubscription?.cancel();
    _permissionSubscription = Rx.combineLatest<bool, bool>(
      [
        get<NotificationController>().showSettingsTileStream,
        get<HealthController>().hasPermissionStream.map((e) => !e),
      ],
      (e) {
        logger.d("Show permission tiles: $e");
        return e.any((element) => element) ||
            globalContainer.read(showFoodPermissionsSettingsTileProvider);
      },
    ).listen(showPermissionTilesStream.add);

    schedulePeriodicBackup();
    loadColdbootDeeplink();
  }

  Future<void> _awaitRemoteInitialization(Future<dynamic> work) async {
    try {
      await work.timeout(const Duration(seconds: 10));
    } catch (error, stack) {
      logger.w(
        'Remote initialization deferred; local data remains available',
        error: error,
        stackTrace: stack,
      );
    }
  }

  @override
  void onClose() async {
    service.beforeUserChange = null;
    service.afterUserChange = null;
    EasyDebounce.cancel('scheduleBackup');
    await _permissionSubscription?.cancel();
    await showPermissionTilesStream.close();

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
    Get.delete<AchievementsController>();
    Get.delete<BoutiqueController>();
    Get.delete<HealthController>();
    Get.delete<PurchasesController>();
    globalContainer.invalidate(onlineProvider);

    super.onClose();
  }

  void init() {
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

    service.beforeUserChange = suspendOngoingWorkout;
    service.afterUserChange = restoreOngoingWorkout;

    // Add any providers that need to live for the app's lifespan here (and mark them as keepAlive)
    globalContainer.read(foodNativeSyncProvider);

    final online = globalContainer.read(onlineProvider.notifier);
    Get.put(AchievementsController(online.onlineService));
    Get.put(BoutiqueController());
    Get.put(HealthController());
    Get.put(PurchasesService(this));
    Get.put(
      PurchasesController(get<PurchasesService>(), this, online.onlineService),
    );

    _ongoingRestore = restoreOngoingWorkout();
  }

  Future<void> suspendOngoingWorkout() async {
    if (!Get.isRegistered<WorkoutController>()) return;
    final workout = get<WorkoutController>();
    await workout.persist(force: true);
    workout.preserveOngoingOnClose = true;
    Get.delete<WorkoutController>();
    get<StopwatchController>().globalStopwatch.reset();
  }

  Future<void> restoreOngoingWorkout() async {
    final userId = service.db.currentUserId;
    final data = await service.db.watchOngoing().first;
    if (userId != service.db.currentUserId ||
        data == null ||
        Get.isRegistered<WorkoutController>()) {
      return;
    }
    get<StopwatchController>().globalStopwatch.reset();
    Get.put(WorkoutController.fromSavedData(data));
  }

  /// If the app was launched by a deeplink while it was closed, this method
  /// will be called to handle the deeplink as if it was received in the
  /// foreground.
  void loadColdbootDeeplink() async {
    final deeplink = await ProtocolService().getInitialUrl();
    if (deeplink != null) {
      logger.d("Coldboot deeplink: $deeplink");
      for (final listener in ProtocolService().listeners) {
        listener.onProtocolUrlReceived(deeplink);
      }
    }
  }

  bool hasExercise(Exercise exercise) {
    final isInWorkout =
        Get.isRegistered<WorkoutController>() &&
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
    final t = globalContainer.read(translationsProvider);
    Go.snack(t.workouts.actions.saveAsRoutine.done);
  }

  List<Workout> getRoutineHistory({required Workout routine}) {
    return get<HistoryController>().getRoutineHistory(routine);
  }

  void computeSuggestions({
    DateTime? now,
    double halfLifeDays = kRoutineSuggestionHalfLifeDays,
  }) {
    final referenceDate = now ?? DateTime.now();
    final today = referenceDate.weekday;
    final candidates = <Workout, double>{};
    final controller = get<HistoryController>();
    final history = controller.history;
    for (final routine in get<RoutinesController>().workouts) {
      final occurrences = history.where((wo) => wo.parentID == routine.id);
      double score = 0.0;

      for (final wo in occurrences) {
        final startingDate = wo.startingDate;
        if (startingDate == null) continue;

        final secondsAgo = referenceDate.difference(startingDate).inSeconds;
        final daysAgo = max(0.0, secondsAgo / 86400.0);

        final decay = pow(2.0, -daysAgo / halfLifeDays).toDouble();
        final dayWeight = (startingDate.weekday == today)
            ? kRoutineSuggestionMatchingDayWeight
            : kRoutineSuggestionOtherDayWeight;

        score += dayWeight * decay;
      }

      if (score > 0) {
        candidates[routine] = score;
      }
    }

    final listCandidates = [...candidates.entries];
    listCandidates.sort((a, b) => b.value.compareTo(a.value));
    suggestions([
      ...listCandidates.map((a) => (routine: a.key, score: a.value)).take(5),
    ]);
    logger.d(
      "Recomputed suggested routines with ${suggestions().length} values",
    );
  }

  void computeStreaks() {
    if (Get.isRegistered<HistoryController>()) {
      get<HistoryController>().computeStreaks();
    }
  }

  void onNotificationTapped(NotificationResponse value) {
    if (Get.isRegistered<WorkoutController>()) {
      get<WorkoutController>().onNotificationTapped(value);
    }
  }

  void scheduleBackup() {
    EasyDebounce.debounce(
      'scheduleBackup',
      const Duration(minutes: 1),
      () => get<DatabaseService>().createBackup(),
    );
  }

  void schedulePeriodicBackup() {
    get<DatabaseService>().schedulePeriodicBackup();
  }

  Map<Achievement, List<AchievementCompletion>> maybeUnlockAchievements(
    AchievementTrigger trigger,
  ) {
    return get<AchievementsController>().maybeUnlockAchievements(trigger);
  }

  void installRoutines(List<Workout> routines) {
    get<RoutinesController>().installRoutines(routines);
  }

  Future<void> overrideDatabase(DatabaseSnapshot snapshot) {
    return get<DatabaseService>().overrideDatabase(snapshot);
  }

  void bootProcedure() {
    final isTest = TestService().isTest;
    final prefsValue = service.prefs$.valueOrNull;
    final onboardingComplete = prefsValue?.onboardingComplete;
    logger.i(
      "[Coordinator.bootProcedure] Evaluating onboarding state: "
      "isTest=$isTest, "
      "hasValue=${service.prefs$.hasValue}, "
      "onboardingComplete=$onboardingComplete, "
      "currentUserId=${service.db.currentUserId}",
    );
    if (!isTest && !service.prefs$.value.onboardingComplete) {
      logger.i(
        "[Coordinator.bootProcedure] Result: Routing -> OnboardingScreen "
        "(onboardingComplete is false)",
      );
      Go.offWithoutAnimation(() => const OnboardingScreen());
    } else {
      logger.i(
        "[Coordinator.bootProcedure] Result: Routing -> SkeletonView "
        "(onboardingComplete=$onboardingComplete, isTest=$isTest)",
      );
      Go.offWithoutAnimation(() => const SkeletonView());
    }
  }

  void onFinishedOnboarding() {
    logger.i(
      "[Coordinator.onFinishedOnboarding] Marking onboardingComplete=true "
      "for currentUserId=${service.db.currentUserId}",
    );
    service.writeSettings(service.prefs$.value.copyWithOnboardingComplete());
    Go.offWithoutAnimation(() => const SkeletonView());
  }

  void syncNative() {
    computeStreaks();
    if (Get.isRegistered<WorkoutController>()) {
      get<WorkoutController>().refreshWatchData();
    } else {
      logger.w("No WorkoutController registered, cannot sync native data.");
    }
  }
}
