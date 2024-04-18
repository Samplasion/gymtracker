import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/model/measurements.dart';

class MeController extends GetxController with ServiceableController {
  RxList<WeightMeasurement> weightMeasurements = <WeightMeasurement>[].obs;

  WeightMeasurement? get latestWeightMeasurement =>
      weightMeasurements.isEmpty ? null : weightMeasurements.last;

  @override
  void onInit() {
    super.onInit();
    weightMeasurements.bindStream(service.weightMeasurements$);
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
}
