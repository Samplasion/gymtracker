import 'package:gymtracker/model/measurements.dart';
import 'package:hive/hive.dart';

class WeightMeasurementAdapter extends TypeAdapter<WeightMeasurement> {
  @override
  final int typeId = 11;

  @override
  WeightMeasurement read(BinaryReader reader) {
    return WeightMeasurement(
      weight: reader.read(),
      time: reader.read(),
      weightUnit: reader.read(),
      id: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, WeightMeasurement obj) {
    writer.write(obj.weight);
    writer.write(obj.time);
    writer.write(obj.weightUnit);
    writer.write(obj.id);
  }
}
