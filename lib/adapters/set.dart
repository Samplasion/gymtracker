import 'package:gymtracker/model/set.dart';
import 'package:hive/hive.dart';

class SetKindAdapter extends TypeAdapter<GTSetKind> {
  @override
  final int typeId = 3;

  @override
  GTSetKind read(BinaryReader reader) {
    final index = reader.readByte();
    return GTSetKind.values[index];
  }

  @override
  void write(BinaryWriter writer, GTSetKind obj) {
    writer.writeByte(obj.index);
  }
}

class SetParametersAdapter extends TypeAdapter<GTSetParameters> {
  @override
  final int typeId = 4;

  @override
  GTSetParameters read(BinaryReader reader) {
    final index = reader.readByte();
    return GTSetParameters.values[index];
  }

  @override
  void write(BinaryWriter writer, GTSetParameters obj) {
    writer.writeByte(obj.index);
  }
}

class ExSetAdapter extends TypeAdapter<GTSet> {
  @override
  final int typeId = 5;

  @override
  GTSet read(BinaryReader reader) {
    return GTSet(
      id: reader.read(),
      kind: reader.read(),
      parameters: reader.read(),
      reps: reader.read(),
      weight: reader.read(),
      time: reader.read(),
      distance: reader.read(),
      done: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GTSet obj) {
    writer.write(obj.id);
    writer.write(obj.kind);
    writer.write(obj.parameters);
    writer.write(obj.reps);
    writer.write(obj.weight);
    writer.write(obj.time);
    writer.write(obj.distance);
    writer.write(obj.done);
  }
}
