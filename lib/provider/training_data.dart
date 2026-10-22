import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'training_data.g.dart';

final trainingClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

@Riverpod(keepAlive: true)
Stream<List<Workout>> historyWorkouts(Ref ref) => ref
    .watch(appDatabaseProvider)
    .getAllHistoryWorkouts()
    .map(
      (values) => List<Workout>.unmodifiable(
        [...values]..sort(
          (a, b) => (a.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(
                b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0),
              ),
        ),
      ),
    );

@Riverpod(keepAlive: true)
Stream<List<Exercise>> customExercises(Ref ref) =>
    ref.watch(appDatabaseProvider).getAllCustomExercises();

@riverpod
List<RoutineSuggestion> routineSuggestions(Ref ref) {
  final routines = ref.watch(routinesStreamProvider).value ?? const <Workout>[];
  final history = ref.watch(historyWorkoutsProvider).value ?? const <Workout>[];
  return computeRoutineSuggestions(
    routines,
    history,
    now: ref.watch(trainingClockProvider)(),
  );
}

List<RoutineSuggestion> computeRoutineSuggestions(
  List<Workout> routines,
  List<Workout> history, {
  DateTime? now,
  double halfLifeDays = 28,
}) {
  final reference = now ?? DateTime.now();
  final candidates = <RoutineSuggestion>[];
  for (final routine in routines) {
    var score = 0.0;
    for (final workout in history.where((w) => w.parentID == routine.id)) {
      final date = workout.startingDate;
      if (date == null) continue;
      final daysAgo = max(0.0, reference.difference(date).inSeconds / 86400);
      score +=
          (date.weekday == reference.weekday ? 1 : 0.2) *
          pow(2, -daysAgo / halfLifeDays);
    }
    if (score > 0) candidates.add((routine: routine, score: score));
  }
  candidates.sort((a, b) => b.score.compareTo(a.score));
  return List.unmodifiable(candidates.take(5));
}
