import 'package:gymtracker/data/weights.dart';
import 'package:hive/hive.dart';

class WeightsAdapter extends TypeAdapter<Weights> {
  @override
  final int typeId = 10;

  @override
  Weights read(BinaryReader reader) {
    final index = reader.readByte();
    return Weights.values[index];
  }

  @override
  void write(BinaryWriter writer, Weights obj) {
    writer.writeByte(obj.index);
  }
}
