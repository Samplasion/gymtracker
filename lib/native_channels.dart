import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/service/native.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/FlutterCommunicator.g.swift',
  swiftOptions: SwiftOptions(),
  kotlinOut:
      'android/app/src/main/java/org/js/samplasion/gymtracker/FlutterCommunicator.kt',
  kotlinOptions: KotlinOptions(
    package: "org.js.samplasion.gymtracker",
  ),
  dartPackageName: 'gymtracker',
))
@HostApi()
// This API is called by the Flutter app to communicate with the native OS
abstract class GymBroNativeHostAPI {
  void startWorkout();
  void stopWorkout();
  void setExerciseParameters(Map<String?, Object?> parameters);
  void updateHomeWidgetParameters(
      Map<String, int> parameters, List<int> workoutDensityChartData);
  void requestHealthPermission();

  // Food
  void updateFoodParameters(Map<String?, Object?> parameters);
}

@FlutterApi()
// This API is called by the native OS to communicate with the Flutter app
abstract class GymBroNativeFlutterAPI {
  // Marks the current set as done
  void markThisSetAsDone();

  // Move the focused workout set cursor one step forward/backward
  bool moveWorkoutCursorNext();
  bool moveWorkoutCursorPrevious();

  // Called by the native OS to read the app's workout data
  void requestTrainingData();

  // Sends the current workout metrics
  void handleWorkoutMetrics(double? energy, double? heartRate);

  // Update set parameters from native interfaces
  void updateSetParameters(
      double? weight, double? timeSeconds, int? reps, double? distance);
}

@FlutterApi()
abstract class GymBroNativeLoggerChannel {
  // Called by the native OS to log messages
  void logMessage(String message);

  // Called by the native OS to log errors
  void logError(String error);
}
