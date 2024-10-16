import 'package:get/get.dart' hide Rx;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:rxdart/rxdart.dart';

class MeController extends GetxController with ServiceableController {
  RxList<WeightMeasurement> weightMeasurements = <WeightMeasurement>[].obs;

  BehaviorSubject<PredictedWeightMeasurement?> predictedWeight =
      BehaviorSubject<PredictedWeightMeasurement?>();

  WeightMeasurement? get latestWeightMeasurement =>
      weightMeasurements.isEmpty ? null : weightMeasurements.last;

  @override
  void onInit() {
    super.onInit();
    predictedWeight.addStream(
      Rx.combineLatest2(
        service.weightMeasurements$,
        service.prefs$,
        (List<WeightMeasurement> measurements, Prefs prefs) {
          final weightUnit = prefs.weightUnit;
          logger.i(
              "Updated predicted weight: ${predictNextWeight(measurements, weightUnit)}");
          return predictNextWeight(measurements, weightUnit);
        },
      ),
    );
    service.weightMeasurements$.listen((event) {
      logger.i("Updated with ${event.length} weight measurements");
      weightMeasurements(event);
      Get.find<Coordinator>()
          .maybeUnlockAchievements(AchievementTrigger.weight);
    });
  }

  @override
  void onServiceChange() {}

  void addWeightMeasurement(WeightMeasurement measurement) {
    service.setWeightMeasurement(measurement);
  }

  void removeWeightMeasurement(WeightMeasurement measurement) {
    service.removeWeightMeasurement(measurement);
  }

  WeightMeasurement? getWeightMeasurementByID(String measurementID) {
    return service.getWeightMeasurement(measurementID);
  }

  PredictedWeightMeasurement? predictNextWeight(
      List<WeightMeasurement> measurements, Weights weightUnit,
      [int _sampleSize = 10]) {
    final sampleSize = _sampleSize.clamp(0, measurements.length);
    if (sampleSize < 2) {
      return null;
    }

    final sorted = measurements.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final points = sorted.sublist(measurements.length - sampleSize).toList();

    Duration averageDuration = Duration.zero;
    double averageWeight = 0;

    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      final previousPoint = points[i - 1];

      final duration = point.time.difference(previousPoint.time);
      final weightDifference =
          point.convertedWeight - previousPoint.convertedWeight;

      averageDuration += duration;
      averageWeight += weightDifference;
    }

    averageDuration ~/= points.length;
    averageWeight /= points.length;

    final nextTime = points.last.time.add(averageDuration);
    final nextWeight = points.last.convertedWeight + averageWeight;

    return PredictedWeightMeasurement(
      weight: nextWeight,
      time: nextTime,
      weightUnit: weightUnit,
    );
  }
}
