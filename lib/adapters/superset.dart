import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:hive/hive.dart';

class SupersetAdapter extends TypeAdapter<Superset> {
  @override
  final int typeId = 2;

  @override
  Superset read(BinaryReader reader) {
    return Superset(
      id: reader.read(),
      exercises: (reader.read() as List).cast<Exercise>(),
      restTime: reader.read(),
      notes: reader.read(),
      workoutID: reader.availableBytes > 0 ? reader.read() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Superset obj) {
    writer.write(obj.id);
    writer.write(obj.exercises);
    writer.write(obj.restTime);
    writer.write(obj.notes);
    writer.write(obj.workoutID);
  }
}
