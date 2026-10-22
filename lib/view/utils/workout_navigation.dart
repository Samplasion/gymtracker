import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:gymtracker/view/workout.dart';

String getPreferredWorkoutRouteName({required bool simple}) {
  if (simple) {
    return WorkoutSimpleView.routeName;
  }
  return WorkoutView.routeName;
}

bool isWorkoutRouteName(String? routeName) {
  return routeName == WorkoutView.routeName ||
      routeName == WorkoutSimpleView.routeName;
}
