import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:rxdart/rxdart.dart';

/// All inputs share an account scope. The first snapshot after a switch is a
/// baseline, not evidence that the new owner has just performed an action.
class AchievementSnapshot {
  AchievementSnapshot(
    this.owner,
    this.scope,
    this.history,
    this.routines,
    this.folders,
    this.weights,
    this.foods,
    this.exercises,
    this.completions,
  );

  final String? owner;
  final Object scope;
  final List<Workout> history, routines;
  final List<GTRoutineFolder> folders;
  final List<WeightMeasurement> weights;
  final List<TaggedFood> foods;
  final List<Exercise> exercises;
  final List<AchievementCompletion> completions;
}

final achievementSnapshotProvider = StreamProvider<AchievementSnapshot>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCurrentUserId().switchMap((owner) {
    final scope = Object();
    return Rx.combineLatest7<
          List<Workout>,
          List<Workout>,
          List<GTRoutineFolder>,
          List<WeightMeasurement>,
          List<TaggedFood>,
          List<Exercise>,
          List<AchievementCompletion>,
          AchievementSnapshot
        >(
          db.getAllHistoryWorkouts(),
          db.getAllRoutines(),
          db.watchRoutineFolders(),
          db.watchWeightMeasurements(),
          db.watchFoods(),
          db.getAllCustomExercises(),
          db.watchAchievementCompletions(),
          (
            history,
            routines,
            folders,
            weights,
            foods,
            exercises,
            completions,
          ) => AchievementSnapshot(
            owner,
            scope,
            history,
            routines,
            folders,
            weights,
            foods,
            exercises,
            completions,
          ),
        )
        .where((snapshot) => snapshot.owner == db.currentUserId);
  });
});
