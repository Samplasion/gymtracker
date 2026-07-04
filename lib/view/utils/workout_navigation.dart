import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:gymtracker/view/workout.dart';

String getPreferredWorkoutRouteName() {
  final settings = Get.find<SettingsController>();
  if (settings.defaultToSimpleWorkoutView.value) {
    return WorkoutSimpleView.routeName;
  }
  return WorkoutView.routeName;
}

bool isWorkoutRouteName(String? routeName) {
  return routeName == WorkoutView.routeName ||
      routeName == WorkoutSimpleView.routeName;
}
