import 'dart:io';

import 'package:get/get.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/watch.g.dart';

abstract class WatchService {
  static WatchService instance() {
    if (Platform.isIOS) {
      return _iOSWatchService();
    } else {
      return _UnsupportedWatchService._();
    }
  }

  WatchService._();

  void setIsWorkoutRunning(bool isWorkoutRunning);
  void setExerciseParameters(
    bool hasExercise,
    String exerciseName,
    int exerciseColor,
    String exerciseParameters,
  );
}

class _UnsupportedWatchService extends WatchService
    implements GymWatchFlutterAPI {
  _UnsupportedWatchService._() : super._();

  @override
  void markThisSetAsDone() {
    /// no-op
  }

  @override
  void requestTrainingData() {
    /// no-op
  }

  @override
  void setExerciseParameters(bool hasExercise, String exerciseName,
      int exerciseColor, String exerciseParameters) {
    // no-op
  }

  @override
  void setIsWorkoutRunning(bool isWorkoutRunning) {
    // no-op
  }
}

class _iOSWatchService extends WatchService implements GymWatchFlutterAPI {
  final _watch = GymWatchHostAPI();

  static final _iOSWatchService _instance = _iOSWatchService._internal();
  factory _iOSWatchService() => _instance;
  _iOSWatchService._internal() : super._() {
    GymWatchFlutterAPI.setUp(this);
  }

  @override
  void markThisSetAsDone() {
    logger.i("Received markThisSetAsDone from watch.");
    Get.find<WorkoutController>().markThisSetAsDone();
  }

  void setIsWorkoutRunning(bool isWorkoutRunning) {
    logger.i("Setting isWorkoutRunning on watch: $isWorkoutRunning");
    _watch.setIsWorkoutRunning(isWorkoutRunning);
  }

  void setExerciseParameters(
    bool hasExercise,
    String exerciseName,
    int exerciseColor,
    String exerciseParameters,
  ) {
    logger.i("""Setting exercise parameters on watch: {
      "hasExercise": $hasExercise,
      "exerciseName": $exerciseName,
      "exerciseColor": $exerciseColor,
      "exerciseParameters": $exerciseParameters
    }""");
    _watch.setExerciseParameters(
      hasExercise,
      exerciseName,
      exerciseColor,
      exerciseParameters,
    );
  }

  @override
  void requestTrainingData() {
    logger.i("Received requestTrainingData from watch.");
    if (!Get.isRegistered<WorkoutController>()) {
      _watch.setIsWorkoutRunning(false);
      return;
    }
    _watch.setIsWorkoutRunning(false);
    Get.find<WorkoutController>().refreshWatchData();
  }
}
