import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';

/// Domain data only: fixtures never replace a rule or supply computed progress.
class AchievementFixture {
  AchievementFixture({
    DateTime? now,
    this.history = const [],
    this.routines = const [],
    this.weights = const [],
    this.foods = const [],
    this.hasFolders = false,
  }) : now = now ?? DateTime(2024, 6, 15, 12);

  final DateTime now;
  final List<Workout> history;
  final List<Workout> routines;
  final List<WeightMeasurement> weights;
  final List<TaggedFood> foods;
  final bool hasFolders;

  AchievementRules get rules => AchievementRules(
    clock: () => now,
    history: () => history,
    routines: () => routines,
    weights: () => weights,
    foods: () => foods,
    hasFolders: () => hasFolders,
  );
}

Workout workout({
  String id = 'workout',
  String? parentID,
  DateTime? date,
  Duration duration = const Duration(minutes: 30),
  List<WorkoutExercisable> exercises = const [],
  Weights weightUnit = Weights.kg,
  Distance distanceUnit = Distance.km,
}) => Workout(
  id: id,
  name: id,
  parentID: parentID,
  startingDate: date ?? DateTime(2024, 6, 15, 12),
  duration: duration,
  exercises: exercises,
  weightUnit: weightUnit,
  distanceUnit: distanceUnit,
);

Workout routine({
  String id = 'routine',
  List<WorkoutExercisable> exercises = const [],
}) => Workout(id: id, name: id, exercises: exercises);

Exercise strength(
  double weight, {
  bool done = true,
  GTSetParameters parameters = GTSetParameters.repsWeight,
  GTGymEquipment equipment = GTGymEquipment.barbell,
}) => Exercise.custom(
  id: 'strength',
  name: 'Strength',
  parentID: 'strength-parent',
  parameters: parameters,
  sets: [
    GTSet(
      kind: GTSetKind.normal,
      parameters: parameters,
      reps: 1,
      weight: weight,
      done: done,
    ),
  ],
  primaryMuscleGroup: GTMuscleGroup.chest,
  restTime: Duration.zero,
  notes: '',
  supersetID: null,
  workoutID: 'workout',
  equipment: equipment,
);

Exercise distance(double value, {bool cycling = false, bool done = true}) {
  final parent = getStandardExerciseByID(
    cycling
        ? GTStandardLibrary.cardio.biking
        : GTStandardLibrary.cardio.running,
  )!;
  return parent.copyWith(
    id: 'distance',
    parentID: parent.id,
    workoutID: 'workout',
    sets: [
      GTSet(
        kind: GTSetKind.normal,
        parameters: GTSetParameters.distance,
        distance: value,
        done: done,
      ),
    ],
  );
}

WeightMeasurement bodyWeight(double value, {Weights unit = Weights.kg}) =>
    WeightMeasurement(
      id: 'body-weight',
      weight: value,
      time: DateTime(2024, 6, 15),
      weightUnit: unit,
    );

TaggedFood meal(DateTime date) => DateTagged(
  date: date,
  value: const Food(
    name: 'Meal',
    amount: 100,
    nutritionalValuesPer100g: NutritionValues(
      calories: 100,
      fat: 0,
      saturatedFat: 0,
      carbs: 0,
      sugar: 0,
      protein: 0,
    ),
  ),
);

List<TaggedFood> consecutiveMeals(int count) => [
  for (var i = 0; i < count; i++) meal(DateTime(2024, 6, 15 - i)),
];

AchievementFixture monthlyRoutine(int months) => AchievementFixture(
  routines: [routine()],
  history: [
    for (var i = 0; i < months; i++)
      workout(
        id: 'month-$i',
        parentID: 'routine',
        date: DateTime(2023, 7 + i, 15),
      ),
  ],
);

AchievementFixture personalBest({
  double oldWeight = 50,
  double newWeight = 60,
  DateTime? latestDate,
  Duration oldDuration = const Duration(hours: 1),
  Duration newDuration = const Duration(minutes: 30),
}) => AchievementFixture(
  routines: [
    routine(exercises: [strength(newWeight)]),
  ],
  history: [
    workout(
      id: 'old',
      parentID: 'routine',
      date: DateTime(2024, 6, 8),
      duration: oldDuration,
      exercises: [strength(oldWeight)],
    ),
    workout(
      id: 'new',
      parentID: 'routine',
      date: latestDate ?? DateTime(2024, 6, 9, 11, 59),
      duration: newDuration,
      exercises: [strength(newWeight)],
    ),
  ],
);

AchievementFixture libraryCompletion({required bool complete}) {
  final entries = complete
      ? exerciseStandardLibraryAsList
      : exerciseStandardLibraryAsList.skip(1);
  return AchievementFixture(
    history: [
      workout(
        exercises: [
          for (final entry in entries)
            entry.copyWith(
              id: '${entry.id}-performed',
              parentID: entry.id,
              workoutID: 'workout',
            ),
        ],
      ),
    ],
  );
}
