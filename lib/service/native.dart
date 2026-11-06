import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:gymtracker/service/wearable/training_transport.dart';
import 'package:gymtracker/service/widgets.dart'
    show restKey, streakKey, totalWorkoutsKey;
import 'package:rxdart/rxdart.dart';

enum RecordingState { pending, confirmed, unavailable, finished }

class RecordingUpdate {
  const RecordingUpdate(this.workoutId, this.state, [this.message]);
  final String workoutId;
  final RecordingState state;
  final String? message;
}

abstract class NativeService {
  static NativeService instance({
    WearableTrainingTransport? trainingTransport,
    String Function()? ownerScopeProvider,
  }) {
    if (Platform.isIOS || Platform.isAndroid) {
      return _NativeServiceImpl(null, trainingTransport, ownerScopeProvider);
    } else {
      return _UnsupportedNativeService._();
    }
  }

  factory NativeService.withHost(GymBroNativeHostAPI host) = _NativeServiceImpl;

  NativeService._();
  Future<bool> Function(String, double, int, String)? onImportWaterEntry;
  void waterReceiverReady() {}
  Future<void> publishTrainingTerminal(Map<String, dynamic> document) async {}

  void Function()? onMarkSetDone;
  bool Function()? onCursorNext;
  bool Function()? onCursorPrevious;
  void Function()? onRequestTrainingData;
  void Function(double?, double?, int?, double?)? onUpdateSetParameters;

  /// Binds subsequent updates to an adopted session without starting sensors.
  void adoptWorkoutIdentity(String workoutId) {}

  void attach() {}

  void clearCallbacks() {
    onImportWaterEntry = null;
    onMarkSetDone = null;
    onCursorNext = null;
    onCursorPrevious = null;
    onRequestTrainingData = null;
    onUpdateSetParameters = null;
  }

  void dispose() => clearCallbacks();

  Stream<double?> get energyStream;
  Stream<double?> get heartRateStream;
  Stream<RecordingUpdate?> get recordingStream => const Stream.empty();

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
  void handleRecordingStatus(
    String workoutId,
    String status,
    String? message,
  ) {}

  @override
  Stream<double?> get energyStream => const Stream<double?>.empty();
  @override
  Stream<double?> get heartRateStream => const Stream<double?>.empty();

  @override
  Future<bool> importWaterEntry(
    String id,
    double milliliters,
    int timeMilliseconds,
    String ownerScope,
  ) async => false;

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
  final GymBroNativeHostAPI _watch;
  String? _workoutId;

  final WearableTrainingTransport _trainingTransport;
  final String Function()? _ownerScopeProvider;
  _NativeServiceImpl([
    GymBroNativeHostAPI? host,
    WearableTrainingTransport? trainingTransport,
    this._ownerScopeProvider,
  ]) : _watch = host ?? GymBroNativeHostAPI(),
       _trainingTransport =
           trainingTransport ?? WearableTrainingTransport.forPlatform(),
       super._();
  bool _disposed = false;
  @override
  Future<void> publishTrainingTerminal(Map<String, dynamic> document) async {
    await _trainingTransport.publishTerminal(document);
  }

  bool _attached = false;

  @override
  void adoptWorkoutIdentity(String workoutId) {
    if (_disposed) return;
    if (_workoutId != workoutId) {
      _energy$.add(null);
      _heartRate$.add(null);
    }
    _workoutId = workoutId;
    _recording$.add(null);
    _refreshRecordingStatus();
  }

  @override
  void attach() {
    if (_disposed || _attached) return;
    _attached = true;
    GymBroNativeFlutterAPI.setUp(this);
    GymBroNativeLoggerChannel.setUp(this);
    _refreshRecordingStatus();
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
    unawaited(_recording$.close());
  }

  final _energy$ = BehaviorSubject<double?>();
  final _heartRate$ = BehaviorSubject<double?>();
  final _recording$ = BehaviorSubject<RecordingUpdate?>.seeded(null);

  @override
  Stream<RecordingUpdate?> get recordingStream => _recording$.stream;

  void _refreshRecordingStatus() {
    if (!Platform.isIOS || _disposed) return;
    unawaited(
      _watch
          .getRecordingStatus()
          .then((snapshot) {
            if (_disposed) return;
            final id = snapshot['workoutId'];
            final state = snapshot['status'];
            if (id is String && state is String) {
              handleRecordingStatus(id, state, snapshot['message'] as String?);
            }
          })
          .catchError((Object error) {
            logger.w('Recording status temporarily unavailable', error: error);
          }),
    );
  }

  @override
  void handleRecordingStatus(String workoutId, String status, String? message) {
    if (_disposed || workoutId != _workoutId) return;
    final state = RecordingState.values
        .where((value) => value.name == status)
        .firstOrNull;
    if (state != null) {
      _recording$.add(RecordingUpdate(workoutId, state, message));
    }
  }

  @override
  Stream<double?> get energyStream => _energy$.stream;
  @override
  Stream<double?> get heartRateStream => _heartRate$.stream;

  @override
  void waterReceiverReady() {
    if (!_disposed) {
      unawaited(
        _watch.waterReceiverReady().catchError((Object error) {
          logger.e('Watch water receiver unavailable', error: error);
        }),
      );
    }
  }

  @override
  Future<bool> importWaterEntry(
    String id,
    double milliliters,
    int timeMilliseconds,
    String ownerScope,
  ) async {
    if (_disposed) return false;
    return await onImportWaterEntry?.call(
          id,
          milliliters,
          timeMilliseconds,
          ownerScope,
        ) ??
        false;
  }

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
      if (Platform.isIOS) {
        _recording$.add(RecordingUpdate(workoutId, RecordingState.pending));
      }
      unawaited(
        _watch.startWorkout(workoutId, start.millisecondsSinceEpoch).catchError(
          (Object error) {
            logger.e('Native workout start failed', error: error);
          },
        ),
      );
      _refreshRecordingStatus();
    } else {
      _recording$.add(RecordingUpdate(workoutId, RecordingState.finished));
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
    if (Platform.isAndroid && _ownerScopeProvider != null) {
      unawaited(
        const MethodChannel('gymbro/training')
            .invokeMethod<void>('statistics', {
              'ownerScope': _ownerScopeProvider(),
              streakKey: weekStreak,
              restKey: lastWorkoutDay.millisecondsSinceEpoch,
              totalWorkoutsKey: workouts,
              'density': workoutDensityChartData,
            })
            .catchError((Object error) {
              logger.w('Wear OS statistics deferred', error: error);
            }),
      );
    }
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
    // Zero explicitly invalidates only the current heart-rate reading.
    // Null still means that this particular metric was not updated.
    if (heartRate != null) _heartRate$.add(heartRate > 0 ? heartRate : null);
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
  final service = NativeService.instance(
    trainingTransport: ref.watch(wearableTrainingTransportProvider),
    ownerScopeProvider: () {
      final user = ref.read(databaseServiceProvider).db.currentUserId;
      return user == null ? 'guest' : 'user:$user';
    },
  );
  service.attach();
  ref.onDispose(service.dispose);
  return service;
});

final recordingStatusProvider = StreamProvider<RecordingUpdate?>((ref) {
  return ref.watch(nativeServiceProvider).recordingStream;
});
