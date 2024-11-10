import 'package:gymtracker/model/model.dart';

Exercise exerciseHelper(
  String id,
  String name, {
  List<GTSet>? sets,
  GTSetParameters? parameters,
  String? supersetID,
  String? workoutID,
}) {
  if (parameters != null) {
    assert(sets == null || sets.every((s) => s.parameters == parameters));
  } else {
    assert(sets == null || sets.isNotEmpty);
  }
  
  sets ??= [
    GTSet.empty(
      parameters: parameters ?? GTSetParameters.repsWeight,
      kind: GTSetKind.normal,
    ),
  ];
  return Exercise.custom(
    id: id,
    name: name,
    restTime: const Duration(seconds: 60),
    parameters: sets.first.parameters,
    sets: sets,
    primaryMuscleGroup: GTMuscleGroup.chest,
    secondaryMuscleGroups: {GTMuscleGroup.shoulders},
    notes: 'Some notes',
    supersetID: supersetID,
    workoutID: workoutID,
    equipment: GTGymEquipment.barbell,
  );
}

Superset supersetHelper(
  String id, {
  List<Exercise>? exercises,
  String? workoutID,
}) {
  assert(exercises == null || exercises.isNotEmpty);
  exercises ??= [
    exerciseHelper('exercise1', 'Bench Press'),
    exerciseHelper('exercise2', 'Shoulder Press'),
  ];
  return Superset(
    id: id,
    restTime: const Duration(seconds: 60),
    exercises: [
      for (final ex in exercises)
        ex.copyWith(workoutID: workoutID, supersetID: id),
    ],
    workoutID: workoutID,
  );
}
