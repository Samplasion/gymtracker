import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/go.dart';

class Coordinator extends GetxController with ServiceableController {
  RxList<RoutineSuggestion> suggestions = <RoutineSuggestion>[].obs;

  @override
  void onServiceChange() {}

  Future awaitInitialized() {
    return Future.wait([
      Get.find<SettingsController>().awaitInitialized(),
      Get.find<NotificationController>().initialize(),
    ]);
  }

  init() {
    Get.put(NotificationsService());
    Get.put(NotificationController());
    Get.put(CountdownController());
    Get.put(ExercisesController());
    Get.put(DebugController());
    Get.put(StopwatchController());
    Get.put(MeController());
    Get.put(SettingsController());
    Get.put(ErrorController(), permanent: true);
  }

  bool hasExercise(Exercise exercise) {
    final isInWorkout = Get.isRegistered<WorkoutController>() &&
        Get.find<WorkoutController>().hasExercise(exercise);
    final isInHistory = Get.find<HistoryController>().hasExercise(exercise);
    final isInRoutines = Get.find<RoutinesController>().hasExercise(exercise);
    return isInWorkout || isInHistory || isInRoutines;
  }

  void applyExerciseModification(Exercise ex) {
    if (Get.find<HistoryController>().hasExercise(ex)) {
      Get.find<HistoryController>().applyExerciseModification(ex);
    }
    if (Get.find<RoutinesController>().hasExercise(ex)) {
      Get.find<RoutinesController>().applyExerciseModification(ex);
    }
    if (Get.isRegistered<WorkoutController>() &&
        Get.find<WorkoutController>().hasExercise(ex)) {
      Get.find<WorkoutController>().applyExerciseModification(ex);
    }
  }

  void saveWorkoutAsRoutine(Workout workout) {
    final newID = Get.find<RoutinesController>().importWorkout(workout);
    if (workout.parentID == null) {
      Get.find<HistoryController>().setParentID(workout, newParentID: newID);
    }
    Go.snack("workouts.actions.saveAsRoutine.done".t);
  }

  List<Workout> getRoutineHistory({required Workout routine}) {
    return Get.find<HistoryController>().getRoutineHistory(routine);
  }

  computeSuggestions() {
    final today = DateTime.now().weekday;
    final candidates = <Workout, int>{};
    final controller = Get.find<HistoryController>();
    final history = controller.history;
    for (final routine in Get.find<RoutinesController>().workouts) {
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
      Get.find<WorkoutController>().onNotificationTapped(value);
    }
  }

  void onHotReload() {
    logger.i("[#reassemble()] called");
    Get.find<GTLocalizations>().init(false);
  }
}
