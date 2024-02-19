import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:hive/hive.dart';

class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 6;

  @override
  MuscleGroup read(BinaryReader reader) {
    final index = reader.readByte();
    return MuscleGroup.values[index];
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    writer.writeByte(obj.index);
  }
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    return Exercise.raw(
      id: reader.read(),
      name: reader.read(),
      parameters: reader.read(),
      sets: (reader.read() as List).cast<ExSet>(),
      primaryMuscleGroup: reader.read() as MuscleGroup,
      secondaryMuscleGroups: (reader.read() as Set).cast<MuscleGroup>(),
      restTime: reader.read(),
      parentID: reader.read(),
      notes: reader.read(),
      standard: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.parameters);
    writer.write(obj.sets);
    writer.write(obj.primaryMuscleGroup);
    writer.write(obj.secondaryMuscleGroups);
    writer.write(obj.restTime);
    writer.write(obj.parentID);
    writer.write(obj.notes);
    writer.write(obj.standard);
  }
}
