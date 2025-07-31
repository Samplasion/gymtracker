import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/service/native.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/FlutterCommunicator.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'gymtracker',
))
@HostApi()
// This API is called by the Flutter app to communicate with the native OS
abstract class GymBroNativeHostAPI {
  void startWorkout();
  void stopWorkout();
  void setExerciseParameters(Map<String?, Object?> parameters);
}

@FlutterApi()
// This API is called by the native OS to communicate with the Flutter app
abstract class GymBroNativeFlutterAPI {
  // Marks the current set as done
  void markThisSetAsDone();

  // Called by the native OS to read the app's workout data
  void requestTrainingData();
}
