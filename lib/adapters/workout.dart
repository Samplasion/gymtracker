import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:hive/hive.dart';

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    return Workout(
      id: reader.read(),
      name: reader.read(),
      exercises: (reader.read() as List).cast<WorkoutExercisable>(),
      duration: reader.read(),
      startingDate: reader.read(),
      parentID: reader.read(),
      infobox: reader.read(),
      completedBy: reader.read(),
      completes: reader.read(),
      weightUnit: reader.availableBytes > 0 ? reader.read() : Weights.kg,
      distanceUnit: reader.availableBytes > 0 ? reader.read() : Distance.km,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.exercises);
    writer.write(obj.duration);
    writer.write(obj.startingDate);
    writer.write(obj.parentID);
    writer.write(obj.infobox);
    writer.write(obj.completedBy);
    writer.write(obj.completes);
    writer.write(obj.weightUnit);
    writer.write(obj.distanceUnit);
  }
}
