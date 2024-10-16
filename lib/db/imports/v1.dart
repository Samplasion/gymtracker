import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class VersionedJsonImportV1 extends VersionedJsonImportBase {
  @override
  int get version => 1;

  const VersionedJsonImportV1();

  @override
  DatabaseSnapshot process(Map<String, dynamic> json) {
    List<Exercise> exercises = [];
    if (json['exercise'] is List) {
      exercises = [
        for (final json in json['exercise']) Exercise.fromJson(json),
      ];
    }

    List<Workout> routines = [];
    if (json['routines'] is List) {
      routines = [
        for (final json in json['routines']) Workout.fromJson(json),
      ];
    }

    List<Workout> history = [];
    if (json['workouts'] is List) {
      history = [
        for (final json in json['workouts']) Workout.fromJson(json),
      ];
    }

    _normalize(exercises, routines, history);

    final expectedHistoryLength = history.fold<int>(
      0,
      (prev, workout) =>
          prev +
          workout.exercises.fold(
            0,
            (prev, ex) =>
                prev +
                ex.map(
                  exercise: (_) => 1,
                  superset: (ss) => 1 + ss.exercises.length,
                ),
          ),
    );

    var actualHistory = _flat([
      for (final routine in history)
        ...routine.exercises.map(
          (e) => e.map(
              exercise: (ex) => [ex], superset: (ss) => [ss, ...ss.exercises]),
        ),
    ]);

    logger.i('History exercises count: ${actualHistory.length}');
    if (actualHistory.length != expectedHistoryLength) {
      throw Exception('History exercises count mismatch: '
          'expected $expectedHistoryLength, got ${actualHistory.length}');
    }

    final prefs = json['settings'];
    if (prefs['locale'] != null) prefs['locale'] = [prefs['locale']];

    final weightMeasurements = [
      for (final measurement in json['weightMeasurements'])
        WeightMeasurement.fromJson(measurement),
    ];

    return DatabaseSnapshot(
      customExercises: exercises,
      routines: routines,
      routineExercises: _flat([
        for (final routine in routines)
          ...routine.exercises.map(
            (e) => e.map(
                exercise: (ex) => [ex],
                superset: (ss) => [ss, ...ss.exercises]),
          ),
      ]),
      historyWorkouts: history,
      historyWorkoutExercises: actualHistory,
      preferences: Prefs.fromJson(prefs),
      weightMeasurements: weightMeasurements,
      folders: [],
      foods: [],
      nutritionGoals: [],
      customBarcodeFoods: {},
      favoriteFoods: [],
      foodCategories: {},
      achievements: [],
    );
  }

  List<T> _flat<T>(List<List<T>> deep) {
    final res = <T>[];
    for (final el in deep) {
      res.addAll(el);
    }
    return res;
  }

  void _normalize(
      List<Exercise> exercises, List<Workout> routines, List<Workout> history) {
    final exerciseIDs = {for (final ex in exercises) ex.id};
    final exerciseNamesToIDs = {for (final ex in exercises) ex.name: ex.id};

    final allRoutineExercises = routines.flattenedExercises;
    final allHistoryExercises = history.flattenedExercises;

    Exercise _processExercise(
        Workout workout, Exercise ex, String? supersetID) {
      ex = ex.copyWith(
        workoutID: ex.workoutID ?? workout.id,
        supersetID: ex.parentID ?? supersetID,
      );

      if (ex.standard) {
        // TODO: check that the exercise is still in the library
      } else if (!exerciseIDs.contains(ex.parentID)) {
        ex = ex.copyWith.parentID(exerciseNamesToIDs[ex.name]);

        if (ex.parentID == null) {
          throw Exception('Exercise not found: ${ex.name}');
        }
      }

      return ex;
    }

    final validRoutineIDs = {null, for (final routine in routines) routine.id};

    final processedRoutineIDs = <String>{};

    for (int i = 0; i < routines.length; i++) {
      final routine = routines[i];
      final newExercises = <WorkoutExercisable>[];
      for (final ex in routine.exercises) {
        ex.when(
          exercise: (ex) {
            if (processedRoutineIDs.contains(ex.id)) {
              ex = ex.copyWith.id(const Uuid().v4());
            }
            processedRoutineIDs.add(ex.id);
            newExercises.add(_processExercise(routine, ex, null));
          },
          superset: (ss) {
            final newSupersetExercises = <Exercise>[];

            if (processedRoutineIDs.contains(ss.id)) {
              ss = ss.copyWith.id(const Uuid().v4());
            }
            processedRoutineIDs.add(ss.id);
            ss = ss.copyWith.workoutID(ss.workoutID ?? routine.id);

            for (var ex in ss.exercises) {
              if (processedRoutineIDs.contains(ex.id)) {
                ex = ex.copyWith.id(const Uuid().v4());
              }
              processedRoutineIDs.add(ex.id);
              newSupersetExercises.add(_processExercise(routine, ex, ss.id));
            }

            newExercises.add(ss.copyWith(exercises: newSupersetExercises));
          },
        );
      }

      routines[i] = routine.copyWith(exercises: newExercises);
    }

    logger.t('Processed routine IDs: ${processedRoutineIDs.length}\n'
        'All routine exercises: ${allRoutineExercises.length}');
    assert(processedRoutineIDs.length == allRoutineExercises.length);

    final processedHistoryIDs = <String>{};

    for (int i = 0; i < history.length; i++) {
      final workout = history[i];
      final newExercises = <WorkoutExercisable>[];
      if (!validRoutineIDs.contains(workout.parentID)) {
        throw Exception(
            'Routine not found: ${workout.parentID} (in workout ${workout.id})');
      }
      for (final ex in workout.exercises) {
        ex.when(
          exercise: (ex) {
            if (processedHistoryIDs.contains(ex.id)) {
              ex = ex.copyWith.id(const Uuid().v4());
            }
            processedHistoryIDs.add(ex.id);
            newExercises.add(_processExercise(workout, ex, null));
          },
          superset: (ss) {
            final newSupersetExercises = <Exercise>[];

            if (processedHistoryIDs.contains(ss.id)) {
              ss = ss.copyWith.id(const Uuid().v4());
            }
            processedHistoryIDs.add(ss.id);
            ss = ss.copyWith.workoutID(ss.workoutID ?? workout.id);

            for (var ex in ss.exercises) {
              if (processedHistoryIDs.contains(ex.id)) {
                ex = ex.copyWith.id(const Uuid().v4());
              }
              processedHistoryIDs.add(ex.id);
              newSupersetExercises.add(_processExercise(workout, ex, ss.id));
            }

            newExercises.add(ss.copyWith(exercises: newSupersetExercises));
          },
        );

        history[i] = workout.copyWith(exercises: newExercises);
      }
    }

    logger.t('Processed history IDs: ${processedHistoryIDs.length}\n'
        'All history exercises: ${allHistoryExercises.length}');
    assert(processedHistoryIDs.length == allHistoryExercises.length);
  }
}
