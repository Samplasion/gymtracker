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
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:rxdart/rxdart.dart';

class Coordinator extends GetxController with ServiceableController {
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
      get<OnlineController>().init(),
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
    Get.delete<OnlineController>();

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
    Get.put(OnlineController());

    logger.d((service.hasOngoing, service.getOngoingData()));
    if (service.hasOngoing) {
      Get.put(WorkoutController.fromSavedData(service.getOngoingData()!));
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
        .i("Recomputed suggested routines with ${suggestions().length} values");
  }

  void onNotificationTapped(NotificationResponse value) {
    if (Get.isRegistered<WorkoutController>()) {
      get<WorkoutController>().onNotificationTapped(value);
    }
  }

  void onHotReload() {
    logger.i("[#reassemble()] called");
    get<GTLocalizations>().init(false);
  }

  void scheduleBackup() {
    Future.delayed(const Duration(seconds: 5), () async {
      get<DatabaseService>().createBackup();
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
}
