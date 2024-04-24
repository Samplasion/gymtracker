import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';

List<WorkoutExercisable> databaseExercisesToExercises(
    List<ConcreteExercise> data) {
  final sortOrders = <String, int>{
    for (final e in data) e.id: e.sortOrder,
  };
  final exercises = data
      .map((e) => (e, exerciseFromDatabaseExercise(e), e.isInSuperset))
      .toList();
  final mapped = {
    for (var (_, exercise, isInSuperset) in exercises)
      if (!isInSuperset) exercise.id: exercise,
  };
  for (final (datum, exerciseInSuperset, _) in exercises.where((e) => e.$3)) {
    final superset = mapped[datum.supersetId!] as Superset;
    superset.exercises.add(exerciseInSuperset.asExercise);
  }
  final entries = mapped.values.toList();
  entries.sort((a, b) => sortOrders[a.id]!.compareTo(sortOrders[b.id]!));
  return entries;
}

WorkoutExercisable exerciseFromDatabaseExercise(ConcreteExercise data) {
  assert(() {
    if (!data.isSuperset) {
      return data.parameters != null &&
          data.primaryMuscleGroup != null &&
          data.secondaryMuscleGroups != null;
    }
    return true;
  }(),
      "Non-superset exercises must have set parameters, kinds and muscle groups.");
  if (data.isSuperset) {
    return Superset(
      id: data.id,
      restTime: Duration(seconds: data.restTime!),
      notes: data.notes ?? "",
      exercises: [],
      workoutID: data.routineId,
      supersedesID: data.supersedesId,
    );
  } else {
    return Exercise.raw(
      id: data.id,
      name: data.name,
      restTime: data.restTime == null
          ? Duration.zero
          : Duration(seconds: data.restTime!),
      notes: data.notes ?? "",
      parameters: data.parameters!,
      sets: data.sets!,
      primaryMuscleGroup: data.primaryMuscleGroup!,
      secondaryMuscleGroups: data.secondaryMuscleGroups!,
      parentID:
          data.isCustom ? data.customExerciseId! : data.libraryExerciseId!,
      standard: !data.isCustom,
      workoutID: data.routineId,
      supersetID: data.supersetId,
      supersedesID: data.supersedesId,
    );
  }
}
