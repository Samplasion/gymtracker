import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/go.dart';

class Coordinator extends GetxController with ServiceableController {
  @override
  void onServiceChange() {}

  init() {
    Get.put(NotificationsService());
    Get.put(CountdownController());
    Get.put(ExercisesController());
    Get.put(DebugController());
    Get.put(StopwatchController());
    Get.put(MeController());
    Get.put(SettingsController());
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
}
