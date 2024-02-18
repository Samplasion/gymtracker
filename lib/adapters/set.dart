import 'package:gymtracker/model/set.dart';
import 'package:hive/hive.dart';

class SetKindAdapter extends TypeAdapter<SetKind> {
  @override
  final int typeId = 3;

  @override
  SetKind read(BinaryReader reader) {
    final index = reader.readByte();
    return SetKind.values[index];
  }

  @override
  void write(BinaryWriter writer, SetKind obj) {
    writer.writeByte(obj.index);
  }
}

class SetParametersAdapter extends TypeAdapter<SetParameters> {
  @override
  final int typeId = 4;

  @override
  SetParameters read(BinaryReader reader) {
    final index = reader.readByte();
    return SetParameters.values[index];
  }

  @override
  void write(BinaryWriter writer, SetParameters obj) {
    writer.writeByte(obj.index);
  }
}

class ExSetAdapter extends TypeAdapter<ExSet> {
  @override
  final int typeId = 5;

  @override
  ExSet read(BinaryReader reader) {
    return ExSet(
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
  void write(BinaryWriter writer, ExSet obj) {
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
