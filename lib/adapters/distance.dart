import 'package:gymtracker/data/distance.dart';
import 'package:hive/hive.dart';

class DistanceAdapter extends TypeAdapter<Distance> {
  @override
  final int typeId = 12;

  @override
  Distance read(BinaryReader reader) {
    final index = reader.readByte();
    return Distance.values[index];
  }

  @override
  void write(BinaryWriter writer, Distance obj) {
    writer.writeByte(obj.index);
  }
}
