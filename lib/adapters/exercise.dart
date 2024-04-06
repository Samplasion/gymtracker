import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:hive/hive.dart';

class MuscleGroupAdapter extends TypeAdapter<GTMuscleGroup> {
  @override
  final int typeId = 6;

  @override
  GTMuscleGroup read(BinaryReader reader) {
    final index = reader.readByte();
    return GTMuscleGroup.values[index];
  }

  @override
  void write(BinaryWriter writer, GTMuscleGroup obj) {
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
      sets: (reader.read() as List).cast<GTSet>(),
      primaryMuscleGroup: reader.read() as GTMuscleGroup,
      secondaryMuscleGroups: (reader.read() as Set).cast<GTMuscleGroup>(),
      restTime: reader.read(),
      parentID: reader.read(),
      notes: reader.read(),
      standard: reader.read(),
      supersetID: reader.availableBytes > 0 ? reader.read() : null,
      workoutID: reader.availableBytes > 0 ? reader.read() : null,
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
    writer.write(obj.supersetID);
    writer.write(obj.workoutID);
  }
}
