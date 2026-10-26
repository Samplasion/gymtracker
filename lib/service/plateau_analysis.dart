import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';

/// Conservative screening rules, not a diagnosis of training adaptation.
class PlateauConfig {
  const PlateauConfig();
  final int windowDays = 56;
  final int minimumSessions = 6;
  final int minimumSpanDays = 28;
  final int minimumWeeks = 4;
  final int recentDays = 14;
  final int maximumGapDays = 21;
  final double loadGain = .025;
  final double equivalentLoad = .01;
  final double volumeGain = .05;
}

enum PlateauStatus {
  possiblePlateau,
  progressing,
  insufficientData,
  stale,
  unsupported,
  incomparable,
}

class PlateauSession {
  const PlateauSession(
    this.workout,
    this.exercise,
    this.setCount,
    this.loadKg,
    this.reps,
    this.totalReps,
    this.volumeKg,
  );
  final Workout workout;
  final Exercise exercise;
  final int setCount;
  final double? loadKg;
  final int reps;
  final int totalReps;
  final double? volumeKg;
  DateTime get date => workout.startingDate!;
}

class PlateauResult {
  const PlateauResult(this.exercise, this.status, this.sessions, this.baseline);
  final Exercise exercise;
  final PlateauStatus status;
  final List<PlateauSession> sessions;
  final ({double loadKg, double reps, double totalReps, double volumeKg})?
  baseline;
}

DateTime _day(DateTime date) =>
    DateTime(date.toLocal().year, date.toLocal().month, date.toLocal().day);
// UTC calendar dates avoid daylight-saving shifts in day/week comparisons.
DateTime _calendar(DateTime date) {
  final day = _day(date);
  return DateTime.utc(day.year, day.month, day.day);
}

String _signature(Exercise exercise) => [
  exercise.parameters.name,
  exercise.gymEquipment.name,
  if (exercise.isCustom) ...[
    exercise.name.trim(),
    exercise.primaryMuscleGroup.name,
    (exercise.secondaryMuscleGroups.map((e) => e.name).toList()..sort()).join(
      ',',
    ),
  ],
].join('|');

double _median(Iterable<num> values) {
  final sorted = values.map((e) => e.toDouble()).toList()..sort();
  return sorted[sorted.length ~/ 2];
}

List<PlateauResult> analyzePlateaus(
  List<Workout> history, {
  required DateTime now,
  PlateauConfig config = const PlateauConfig(),
}) {
  final groups = <String, List<(Workout, Exercise)>>{};
  final seenWorkouts = <String>{};
  final today = _calendar(now);
  for (final workout in history) {
    final date = workout.startingDate;
    if (!workout.isConcrete ||
        date == null ||
        date.isAfter(now) ||
        today.difference(_calendar(date)).inDays > config.windowDays ||
        !seenWorkouts.add(workout.id)) {
      continue;
    }
    for (final exercise in workout.flattenedExercises.whereType<Exercise>()) {
      final key = exercise.parentID ?? 'orphan:${exercise.id}';
      groups.putIfAbsent(key, () => []).add((workout, exercise));
    }
  }
  return List.unmodifiable(
    groups.values.map((entries) {
      entries.sort((a, b) => a.$1.startingDate!.compareTo(b.$1.startingDate!));
      final latest = entries.last.$2;
      PlateauResult result(
        PlateauStatus status,
        List<PlateauSession> sessions, [
        ({double loadKg, double reps, double totalReps, double volumeKg})?
        baseline,
      ]) =>
          PlateauResult(latest, status, List.unmodifiable(sessions), baseline);
      if (latest.parentID == null) {
        return result(PlateauStatus.incomparable, []);
      }
      if (latest.parameters != GTSetParameters.repsWeight &&
          latest.parameters != GTSetParameters.freeBodyReps) {
        return result(PlateauStatus.unsupported, []);
      }
      final signature = _signature(latest);
      var start = entries.length - 1;
      while (start > 0 && _signature(entries[start - 1].$2) == signature) {
        start--;
      }
      final byWorkout = <String, List<(Workout, Exercise)>>{};
      for (final entry in entries.skip(start)) {
        byWorkout.putIfAbsent(entry.$1.id, () => []).add(entry);
      }
      final sessions = <PlateauSession>[];
      final seenDays = <DateTime>{};
      var ambiguous = false;
      for (final occurrences in byWorkout.values) {
        final workout = occurrences.first.$1;
        final exercises = occurrences.map((e) => e.$2).toList();
        if (exercises.any((e) => _signature(e) != signature)) {
          ambiguous = true;
          continue;
        }
        final sets = exercises
            .expand((e) => e.sets)
            .where((s) => s.done && s.kind == GTSetKind.normal)
            .toList();
        final weighted = latest.parameters == GTSetParameters.repsWeight;
        if (sets.isEmpty) {
          continue;
        }
        // Reject the whole observation rather than silently reducing its set count.
        if (sets.any(
          (s) =>
              s.parameters != latest.parameters ||
              s.reps == null ||
              s.reps! <= 0 ||
              (weighted &&
                  (s.weight == null || !s.weight!.isFinite || s.weight! <= 0)),
        )) {
          continue;
        }
        if (!seenDays.add(_calendar(workout.startingDate!))) {
          ambiguous = true;
          continue;
        }
        sets.sort((a, b) {
          final load = weighted ? b.weight!.compareTo(a.weight!) : 0;
          return load != 0 ? load : b.reps!.compareTo(a.reps!);
        });
        double kg(double value) => Weights.convert(
          value: value,
          from: workout.weightUnit,
          to: Weights.kg,
        );
        sessions.add(
          PlateauSession(
            workout,
            exercises.last,
            sets.length,
            weighted ? kg(sets.first.weight!) : null,
            sets.first.reps!,
            sets.fold(0, (sum, s) => sum + s.reps!),
            weighted
                ? kg(sets.fold(0.0, (sum, s) => sum + s.liftedWeight))
                : null,
          ),
        );
      }
      if (ambiguous) return result(PlateauStatus.incomparable, sessions);
      // A changed set prescription starts a new comparison period.
      var segmentStart = sessions.length - 1;
      while (segmentStart > 0 &&
          sessions[segmentStart - 1].setCount == sessions.last.setCount) {
        segmentStart--;
      }
      final comparable = segmentStart < 0
          ? <PlateauSession>[]
          : sessions.sublist(segmentStart);
      if (comparable.isNotEmpty &&
          today.difference(_calendar(comparable.last.date)).inDays >
              config.recentDays) {
        return result(PlateauStatus.stale, comparable);
      }
      final weeks = comparable.map((s) {
        final day = _calendar(s.date);
        return day.subtract(Duration(days: day.weekday - 1));
      }).toSet();
      if (comparable.length < config.minimumSessions ||
          weeks.length < config.minimumWeeks ||
          _calendar(
                comparable.last.date,
              ).difference(_calendar(comparable.first.date)).inDays <
              config.minimumSpanDays) {
        return result(PlateauStatus.insufficientData, comparable);
      }
      for (var i = 1; i < comparable.length; i++) {
        if (_calendar(
              comparable[i].date,
            ).difference(_calendar(comparable[i - 1].date)).inDays >
            config.maximumGapDays) {
          return result(PlateauStatus.insufficientData, comparable);
        }
      }
      final first = comparable.take(3);
      final baseline = (
        loadKg: _median(first.map((s) => s.loadKg ?? 0)),
        reps: _median(first.map((s) => s.reps)),
        totalReps: _median(first.map((s) => s.totalReps)),
        volumeKg: _median(first.map((s) => s.volumeKg ?? 0)),
      );
      final progressing = comparable.skip(3).any((s) {
        if (s.loadKg == null) {
          return s.reps >= baseline.reps + 1 ||
              s.totalReps >= baseline.totalReps * (1 + config.volumeGain);
        }
        const epsilon = 1e-8;
        return (s.loadKg! + epsilon >=
                    baseline.loadKg * (1 + config.loadGain) &&
                s.reps >= baseline.reps) ||
            ((s.loadKg! - baseline.loadKg).abs() <=
                    baseline.loadKg * config.equivalentLoad + epsilon &&
                s.reps >= baseline.reps + 1) ||
            s.volumeKg! + epsilon >=
                baseline.volumeKg * (1 + config.volumeGain);
      });
      return result(
        progressing ? PlateauStatus.progressing : PlateauStatus.possiblePlateau,
        comparable,
        baseline,
      );
    }),
  );
}
