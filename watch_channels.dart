import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/service/watch.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/FlutterCommunicator.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'gymtracker',
))
@HostApi()
abstract class GymWatchHostAPI {
  @SwiftFunction('setIsWorkoutRunning(isWorkoutRunning:)')
  void setIsWorkoutRunning(bool isWorkoutRunning);
  void setExerciseParameters(bool hasExercise, String exerciseName,
      int exerciseColor, String exerciseParameters);
}

@FlutterApi()
abstract class GymWatchFlutterAPI {
  // Marks the current set as done
  void markThisSetAsDone();

  // Called by watchOS to read the app's workout data
  void requestTrainingData();
}
