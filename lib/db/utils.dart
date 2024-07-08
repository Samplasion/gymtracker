import 'dart:convert';

import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/struct/nutrition.dart' as model;

model.Workout workoutFromDatabase(
  Routine routine,
  List<ConcreteExercise> rawExercises, {
  RoutineFolder? dbFolder,
}) {
  final entries = databaseExercisesToExercises(rawExercises);

  model.GTRoutineFolder? modelFolder;
  if (dbFolder != null) {
    modelFolder = folderFromDatabase(dbFolder);
  }

  return model.Workout(
    id: routine.id,
    name: routine.name,
    exercises: entries,
    duration: null,
    startingDate: null,
    parentID: null,
    infobox: routine.infobox,
    completedBy: null,
    completes: null,
    weightUnit: routine.weightUnit,
    distanceUnit: routine.distanceUnit,
    folder: modelFolder,
  );
}

model.Workout historyWorkoutFromDatabase(
    HistoryWorkout routine, List<ConcreteExercise> rawExercises) {
  final entries = databaseExercisesToExercises(rawExercises);

  return model.Workout(
    id: routine.id,
    name: routine.name,
    exercises: entries,
    duration: Duration(seconds: routine.duration),
    startingDate: routine.startingDate,
    parentID: routine.parentId,
    infobox: routine.infobox,
    completedBy: routine.completedBy,
    completes: routine.completes,
    weightUnit: routine.weightUnit,
    distanceUnit: routine.distanceUnit,
  );
}

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
      rpe: data.rpe,
    );
  }
}

model.GTRoutineFolder folderFromDatabase(RoutineFolder folder) {
  return model.GTRoutineFolder(
    id: folder.id,
    name: folder.name,
    sortOrder: folder.sortOrder,
  );
}

model.TaggedFood foodFromDatabase(DBFood food) {
  return model.TaggedFood(
    date: food.referenceDate,
    value: model.Food.fromJson(jsonDecode(food.jsonData)).copyWith.id(food.id),
  );
}

model.TaggedNutritionGoal goalFromDatabase(DBNutritionGoal goal) {
  return model.TaggedNutritionGoal(
    date: goal.referenceDate,
    value: model.NutritionGoal(
      dailyCalories: goal.calories,
      dailyProtein: goal.protein,
      dailyCarbs: goal.carbs,
      dailyFat: goal.fat,
    ),
  );
}
