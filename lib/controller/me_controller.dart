import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/repository/measurements.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'me_controller.g.dart';

/// Measurement commands; observed data belongs to the database stream providers.
class MeController {
  MeController(
    this._ref,
    this._repository, {
    required void Function() onWeightChanged,
  }) : _onWeightChanged = onWeightChanged;
  final Ref _ref;
  final MeasurementsRepository _repository;
  final void Function() _onWeightChanged;

  List<WeightMeasurement> get weightMeasurements =>
      _ref.read(weightMeasurementsProvider).value ?? const [];
  List<BodyMeasurement> get bodyMeasurements =>
      _ref.read(bodyMeasurementsProvider).value ?? const [];
  Stream<List<WeightMeasurement>> get weightMeasurementsStream =>
      _repository.watchWeight();
  Stream<List<BodyMeasurement>> get bodyMeasurementsStream =>
      _repository.watchBody();
  PredictedWeightMeasurement? get predictedWeight =>
      _ref.read(predictedWeightProvider);
  WeightMeasurement? get latestWeightMeasurement =>
      weightMeasurements.lastOrNull;

  final _pendingWeightChanges = <_WeightChange>[];

  Future<void> _changeWeight(
    Future<void> Function() write,
    bool Function(List<WeightMeasurement>) observed,
  ) async {
    final change = _WeightChange(
      _ref.read(appDatabaseProvider).currentUserId,
      observed,
    );
    _pendingWeightChanges.add(change);
    try {
      await write();
      if (!_ref.mounted) return;
      change.committed = true;
      _weightObserved(weightMeasurements);
    } catch (_) {
      _pendingWeightChanges.remove(change);
      rethrow;
    }
  }

  void _weightObserved(List<WeightMeasurement> measurements) {
    final owner = _ref.read(appDatabaseProvider).currentUserId;
    for (final change in _pendingWeightChanges.toList()) {
      if (change.owner != owner) {
        _pendingWeightChanges.remove(change);
      } else if (change.committed && change.observed(measurements)) {
        _pendingWeightChanges.remove(change);
        _onWeightChanged();
      }
    }
  }

  Future<void> addWeightMeasurement(WeightMeasurement measurement) =>
      _changeWeight(
        () => _repository.saveWeight(measurement),
        (rows) => rows.any(
          (row) =>
              row.id == measurement.id &&
              row.weight == measurement.weight &&
              row.weightUnit == measurement.weightUnit &&
              row.time.millisecondsSinceEpoch ~/ 1000 ==
                  measurement.time.millisecondsSinceEpoch ~/ 1000,
        ),
      );

  Future<void> removeWeightMeasurement(WeightMeasurement measurement) =>
      _changeWeight(
        () => _repository.deleteWeight(measurement.id),
        (rows) => rows.every((row) => row.id != measurement.id),
      );

  WeightMeasurement? getWeightMeasurementByID(String id) =>
      weightMeasurements.where((m) => m.id == id).firstOrNull;
  Future<void> addBodyMeasurement(BodyMeasurement measurement) =>
      _repository.saveBody(measurement);
  Future<void> removeBodyMeasurement(BodyMeasurement measurement) =>
      _repository.deleteBody(measurement.id);
  BodyMeasurement? getBodyMeasurementByID(String id) =>
      bodyMeasurements.where((m) => m.id == id).firstOrNull;

  PredictedWeightMeasurement? predictNextWeight(
    List<WeightMeasurement> measurements,
    Weights unit, [
    int sampleSize = 10,
  ]) => predictWeight(measurements, unit, sampleSize);
}

/// Supplied by the application lifecycle; retained separately from measurement data.
@Riverpod(keepAlive: true)
void Function() weightChanged(Ref ref) => () {
  ref.read(achievementTriggerProvider)(AchievementTrigger.weight);
};

@Riverpod(keepAlive: true)
MeController meController(Ref ref) {
  ref.listen(bodyMeasurementsProvider, (_, _) {});
  final controller = MeController(
    ref,
    ref.watch(measurementsRepositoryProvider),
    onWeightChanged: ref.watch(weightChangedProvider),
  );
  ref.listen(weightMeasurementsProvider, (_, next) {
    if (next.value case final rows?) controller._weightObserved(rows);
  });
  ref.onDispose(controller._pendingWeightChanges.clear);
  return controller;
}

class _WeightChange {
  _WeightChange(this.owner, this.observed);
  final String? owner;
  final bool Function(List<WeightMeasurement>) observed;
  bool committed = false;
}

PredictedWeightMeasurement? predictNextWeight(
  List<WeightMeasurement> measurements,
  Weights unit, [
  int sampleSize = 10,
]) => predictWeight(measurements, unit, sampleSize);

PredictedWeightMeasurement? predictWeight(
  List<WeightMeasurement> measurements,
  Weights unit, [
  int sampleSize = 10,
]) {
  final size = sampleSize.clamp(0, measurements.length);
  if (size < 2) return null;
  final sorted = measurements.toList()
    ..sort((a, b) => a.time.compareTo(b.time));
  final points = sorted.sublist(sorted.length - size);
  var averageDuration = Duration.zero;
  var averageWeight = 0.0;
  for (var i = 1; i < points.length; i++) {
    averageDuration += points[i].time.difference(points[i - 1].time);
    averageWeight +=
        Weights.convert(
          value: points[i].weight,
          from: points[i].weightUnit,
          to: unit,
        ) -
        Weights.convert(
          value: points[i - 1].weight,
          from: points[i - 1].weightUnit,
          to: unit,
        );
  }
  averageDuration ~/= points.length;
  averageWeight /= points.length;
  return PredictedWeightMeasurement(
    weight:
        Weights.convert(
          value: points.last.weight,
          from: points.last.weightUnit,
          to: unit,
        ) +
        averageWeight,
    time: points.last.time.add(averageDuration),
    weightUnit: unit,
  );
}
