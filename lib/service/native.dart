import 'dart:io';

import 'package:get/get.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.g.dart';

abstract class NativeService {
  static NativeService instance() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _NativeServiceImpl();
    } else {
      return _UnsupportedNativeService._();
    }
  }

  NativeService._();

  void setIsWorkoutRunning(bool isWorkoutRunning);
  void setExerciseParameters(NativeWorkoutStateMessage parameters);
}

class _UnsupportedNativeService extends NativeService
    implements GymBroNativeFlutterAPI {
  _UnsupportedNativeService._() : super._();

  @override
  void markThisSetAsDone() {
    /// no-op
  }

  @override
  void requestTrainingData() {
    /// no-op
  }

  @override
  void setExerciseParameters(NativeWorkoutStateMessage parameters) {
    // no-op
  }

  @override
  void setIsWorkoutRunning(bool isWorkoutRunning) {
    // no-op
  }
}

// ignore: camel_case_types
class _NativeServiceImpl extends NativeService
    implements GymBroNativeFlutterAPI, GymBroNativeLoggerChannel {
  final _watch = GymBroNativeHostAPI();

  static final _NativeServiceImpl _instance = _NativeServiceImpl._internal();
  factory _NativeServiceImpl() => _instance;
  _NativeServiceImpl._internal() : super._() {
    GymBroNativeFlutterAPI.setUp(this);
    GymBroNativeLoggerChannel.setUp(this);
  }

  @override
  void markThisSetAsDone() {
    logger.i("Received markThisSetAsDone from native.");
    Get.find<WorkoutController>().autoMarkNextSetDone();
  }

  @override
  void setIsWorkoutRunning(bool isWorkoutRunning) {
    logger.i("Setting isWorkoutRunning on native side: $isWorkoutRunning");
    if (isWorkoutRunning) {
      _watch.startWorkout();
    } else {
      _watch.stopWorkout();
    }
  }

  @override
  void setExerciseParameters(NativeWorkoutStateMessage parameters) {
    logger.i(
        """Setting exercise parameters on native side: ${parameters.toJson()}""");
    _watch.setExerciseParameters(parameters.toJson());
  }

  @override
  void requestTrainingData() {
    logger.i("Received requestTrainingData from native.");
    if (!Get.isRegistered<WorkoutController>()) {
      _watch.stopWorkout();
      return;
    }
    Get.find<WorkoutController>().refreshWatchData();
  }

  @override
  void logMessage(String message) {
    logger.i("[Native] $message");
  }

  @override
  void logError(String error) {
    logger.e("[Native] $error");
  }
}
