import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void Function()? onMarkSetDone;
  bool Function()? onCursorNext;
  bool Function()? onCursorPrevious;
  void Function()? onRequestTrainingData;
  void Function(double?, double?, int?, double?)? onUpdateSetParameters;

  void attach() {}

  void clearCallbacks() {
    onMarkSetDone = null;
    onCursorNext = null;
    onCursorPrevious = null;
    onRequestTrainingData = null;
    onUpdateSetParameters = null;
  }

  void dispose() => clearCallbacks();

  Stream<double?> get energyStream;
  Stream<double?> get heartRateStream;

  void setIsWorkoutRunning(
    bool isWorkoutRunning, {
    required String workoutId,
    required DateTime start,
    bool save = true,
  });
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
  void setIsWorkoutRunning(
    bool isWorkoutRunning, {
    required String workoutId,
    required DateTime start,
    bool save = true,
  }) {
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
    double? weight,
    double? timeSeconds,
    int? reps,
    double? distance,
  ) {
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
  String? _workoutId;

  _NativeServiceImpl() : super._();
  bool _disposed = false;
  bool _attached = false;

  @override
  void attach() {
    if (_disposed || _attached) return;
    _attached = true;
    GymBroNativeFlutterAPI.setUp(this);
    GymBroNativeLoggerChannel.setUp(this);
  }

  @override
  void clearCallbacks() {
    super.clearCallbacks();
    if (!_attached) return;
    _attached = false;
    GymBroNativeFlutterAPI.setUp(null);
    GymBroNativeLoggerChannel.setUp(null);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    clearCallbacks();
    unawaited(_energy$.close());
    unawaited(_heartRate$.close());
  }

  final _energy$ = BehaviorSubject<double?>();
  final _heartRate$ = BehaviorSubject<double?>();

  @override
  Stream<double?> get energyStream => _energy$.stream;
  @override
  Stream<double?> get heartRateStream => _heartRate$.stream;

  @override
  void markThisSetAsDone() {
    if (_disposed) return;
    logger.i("Received markThisSetAsDone from native.");
    onMarkSetDone?.call();
  }

  @override
  bool moveWorkoutCursorNext() {
    if (_disposed) return false;
    logger.i("Received moveWorkoutCursorNext from native.");
    return onCursorNext?.call() ?? false;
  }

  @override
  bool moveWorkoutCursorPrevious() {
    if (_disposed) return false;
    logger.i("Received moveWorkoutCursorPrevious from native.");
    return onCursorPrevious?.call() ?? false;
  }

  @override
  void setIsWorkoutRunning(
    bool isWorkoutRunning, {
    required String workoutId,
    required DateTime start,
    bool save = true,
  }) {
    if (_disposed) return;
    logger.i("Setting isWorkoutRunning on native side: $isWorkoutRunning");
    if (isWorkoutRunning && _workoutId != workoutId) {
      _energy$.add(null);
      _heartRate$.add(null);
    }
    _workoutId = workoutId;
    if (isWorkoutRunning) {
      unawaited(
        _watch.startWorkout(workoutId, start.millisecondsSinceEpoch).catchError(
          (Object error) {
            logger.e('Native workout start failed', error: error);
          },
        ),
      );
    } else {
      _energy$.add(null);
      _heartRate$.add(null);
      unawaited(
        _watch.stopWorkout(workoutId, save).catchError((Object error) {
          logger.e('Native workout stop failed', error: error);
        }),
      );
    }
  }

  @override
  void setExerciseParameters(NativeWorkoutStateMessage parameters) {
    if (_disposed) return;
    logger.i(
      """Setting exercise parameters on native side: ${parameters.toJson()}""",
    );
    _watch.setExerciseParameters({
      ...parameters.toJson(),
      'workoutId': _workoutId,
    });
  }

  @override
  void requestTrainingData() {
    if (_disposed) return;
    logger.i("Received requestTrainingData from native.");
    if (onRequestTrainingData == null) {
      // Flutter may still be bootstrapping; absence of a callback is not a stop.
      return;
    }
    onRequestTrainingData?.call();
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
    if (_disposed) return Future<void>.value();
    logger.i(
      """Sending complication data to native side: ${(weekStreak: weekStreak, restDays: lastWorkoutDay, workouts: workouts, workoutDensityChartData: workoutDensityChartData)}""",
    );
    return _watch.updateHomeWidgetParameters({
      streakKey: weekStreak,
      restKey: lastWorkoutDay.millisecondsSinceEpoch,
      totalWorkoutsKey: workouts,
    }, workoutDensityChartData);
  }

  @override
  void handleWorkoutMetrics(double? energy, double? heartRate) {
    if (_disposed) return;
    logger.i(
      "Native side sent the following metrics: $energy kcal, $heartRate bpm",
    );
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
    double? weight,
    double? timeSeconds,
    int? reps,
    double? distance,
  ) {
    if (_disposed) return;
    onUpdateSetParameters?.call(weight, timeSeconds, reps, distance);
  }

  @override
  void setFoodParameters(NativeFoodStateMessage parameters) {
    if (_disposed) return;
    logger.i(
      """Setting food parameters on native side: ${parameters.toJson()}""",
    );
    _watch.updateFoodParameters(parameters.toJson());
  }

  @override
  void updateShadowRoutines(Map<String, String> routines) {
    if (_disposed) return;
    logger.i(
      """Updating shadow routines on native side: ${routines.toString()}""",
    );
    _watch.updateShadowRoutines(routines);
  }
}

final nativeServiceProvider = Provider<NativeService>((ref) {
  final service = NativeService.instance();
  service.attach();
  ref.onDispose(service.dispose);
  return service;
});
