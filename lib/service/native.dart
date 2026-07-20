import 'dart:io';

import 'package:get/get.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:gymtracker/service/widgets.dart'
    show restKey, streakKey, totalWorkoutsKey;
import 'package:rxdart/rxdart.dart';

abstract class NativeService {
  static NativeService instance() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _NativeServiceImpl();
    } else {
      return _UnsupportedNativeService._();
    }
  }

  NativeService._();

  Stream<double?> get energyStream;
  Stream<double?> get heartRateStream;

  void setIsWorkoutRunning(bool isWorkoutRunning);
  void setExerciseParameters(NativeWorkoutStateMessage parameters);
  Future<void> updateHomeWidgetParameters({
    required int weekStreak,
    required DateTime lastWorkoutDay,
    required int workouts,
    required List<int> workoutDensityChartData,
  });
  void setFoodParameters(NativeFoodStateMessage parameters);

  void updateShadowRoutines(Map<String, String> routines);
}

class _UnsupportedNativeService extends NativeService
    implements GymBroNativeFlutterAPI {
  _UnsupportedNativeService._() : super._();

  @override
  Stream<double?> get energyStream => const Stream<double?>.empty();
  @override
  Stream<double?> get heartRateStream => const Stream<double?>.empty();

  @override
  void markThisSetAsDone() {
    // no-op
  }

  @override
  bool moveWorkoutCursorNext() {
    return false;
  }

  @override
  bool moveWorkoutCursorPrevious() {
    return false;
  }

  @override
  void requestTrainingData() {
    // no-op
  }

  @override
  void setExerciseParameters(NativeWorkoutStateMessage parameters) {
    // no-op
  }

  @override
  void setIsWorkoutRunning(bool isWorkoutRunning) {
    // no-op
  }

  @override
  Future<void> updateHomeWidgetParameters({
    required int weekStreak,
    required DateTime lastWorkoutDay,
    required int workouts,
    required List<int> workoutDensityChartData,
  }) async {
    // no-op
  }

  @override
  void handleWorkoutMetrics(double? energy, double? heartRate) {
    // no-op
  }

  @override
  void updateSetParameters(
      double? weight, double? timeSeconds, int? reps, double? distance) {
    // no-op
  }

  @override
  void setFoodParameters(NativeFoodStateMessage parameters) {
    // no-op
  }

  @override
  void updateShadowRoutines(Map<String, String> routines) {
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

  final _energy$ = BehaviorSubject<double?>();
  final _heartRate$ = BehaviorSubject<double?>();

  @override
  Stream<double?> get energyStream => _energy$.stream;
  @override
  Stream<double?> get heartRateStream => _heartRate$.stream;

  @override
  void markThisSetAsDone() {
    logger.i("Received markThisSetAsDone from native.");
    Get.find<WorkoutController>().autoMarkNextSetDone();
  }

  @override
  bool moveWorkoutCursorNext() {
    logger.i("Received moveWorkoutCursorNext from native.");
    return Get.find<WorkoutController>().moveSetCursorToNext();
  }

  @override
  bool moveWorkoutCursorPrevious() {
    logger.i("Received moveWorkoutCursorPrevious from native.");
    return Get.find<WorkoutController>().moveSetCursorToPrevious();
  }

  @override
  void setIsWorkoutRunning(bool isWorkoutRunning) {
    logger.i("Setting isWorkoutRunning on native side: $isWorkoutRunning");
    if (isWorkoutRunning) {
      _watch.startWorkout();
    } else {
      _energy$.add(null);
      _heartRate$.add(null);
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
      // Cancel workout
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

  @override
  Future<void> updateHomeWidgetParameters({
    required int weekStreak,
    required DateTime lastWorkoutDay,
    required int workouts,
    required List<int> workoutDensityChartData,
  }) {
    logger.i("""Sending complication data to native side: ${(
      weekStreak: weekStreak,
      restDays: lastWorkoutDay,
      workouts: workouts,
      workoutDensityChartData: workoutDensityChartData,
    )}""");
    return _watch.updateHomeWidgetParameters({
      streakKey: weekStreak,
      restKey: lastWorkoutDay.millisecondsSinceEpoch,
      totalWorkoutsKey: workouts,
    }, workoutDensityChartData);
  }

  @override
  void handleWorkoutMetrics(double? energy, double? heartRate) {
    logger.i(
        "Native side sent the following metrics: $energy kcal, $heartRate bpm");
    if (energy != null) _energy$.add(energy);
    if (heartRate != null) _heartRate$.add(heartRate);
    if (energy == null && heartRate == null) {
      // If both are null, reset
      _energy$.add(null);
      _heartRate$.add(null);
    }
  }

  @override
  void updateSetParameters(
      double? weight, double? timeSeconds, int? reps, double? distance) {
    Get.find<WorkoutController>()
        .updateSetParameters(weight, timeSeconds, reps, distance);
  }

  @override
  void setFoodParameters(NativeFoodStateMessage parameters) {
    logger.i(
        """Setting food parameters on native side: ${parameters.toJson()}""");
    _watch.updateFoodParameters(parameters.toJson());
  }

  @override
  void updateShadowRoutines(Map<String, String> routines) {
    logger.i(
        """Updating shadow routines on native side: ${routines.toString()}""");
    _watch.updateShadowRoutines(routines);
  }
}
