import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/repository/measurements.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurements.g.dart';

@Riverpod(keepAlive: true)
Stream<List<WeightMeasurement>> weightMeasurements(Ref ref) =>
    ref.watch(measurementsRepositoryProvider).watchWeight();

@Riverpod(keepAlive: true)
Stream<List<BodyMeasurement>> bodyMeasurements(Ref ref) =>
    ref.watch(measurementsRepositoryProvider).watchBody();

@Riverpod(keepAlive: true)
AsyncValue<Weights> measurementWeightUnit(Ref ref) =>
    ref.watch(appPreferencesProvider).whenData((prefs) => prefs.weightUnit);

@riverpod
PredictedWeightMeasurement? predictedWeight(Ref ref) {
  final weights = ref.watch(weightMeasurementsProvider).value;
  final unit = ref.watch(measurementWeightUnitProvider).value;
  if (weights == null || unit == null) return null;
  return predictNextWeight(weights, unit);
}
