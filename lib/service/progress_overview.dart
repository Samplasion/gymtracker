import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';

class DailyTrainingVolume {
  const DailyTrainingVolume(this.date, this.volume);
  final DateTime date;
  final double volume;
}

class PersonalLoadRecord {
  const PersonalLoadRecord({
    required this.exercise,
    required this.date,
    required this.weightKg,
    required this.reps,
  });
  final Exercise exercise;
  final DateTime date;
  final double weightKg;
  final int reps;

  double weightIn(Weights unit) =>
      Weights.convert(value: weightKg, from: Weights.kg, to: unit);
}

class ProgressOverview {
  const ProgressOverview({
    required this.days,
    required this.records,
    required this.weightUnit,
  });
  final List<DailyTrainingVolume> days;
  final List<PersonalLoadRecord> records;
  final Weights weightUnit;
}

/// Volume and load records use performed, positive weight-and-repetition sets.
/// A load record is the highest load; ties prefer more repetitions. Repeating
/// the same performance retains the date when that record was first achieved.
ProgressOverview buildProgressOverview(
  List<Workout> history, {
  required DateTime now,
  required Weights weightUnit,
  required int firstDayOfWeek,
}) {
  assert(
    firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday,
  );
  final localNow = now.toLocal();
  final offset = (localNow.weekday - firstDayOfWeek + 7) % 7;
  final start = DateTime(localNow.year, localNow.month, localNow.day - offset);
  final days = List.generate(
    7,
    (i) => DateTime(start.year, start.month, start.day + i),
  );
  final startCalendar = DateTime.utc(start.year, start.month, start.day);
  final volumes = List<double>.filled(7, 0);
  final records = <String, PersonalLoadRecord>{};
  final seen = <String>{};
  final dated =
      history
          .where(
            (workout) =>
                workout.isConcrete &&
                workout.startingDate != null &&
                !workout.startingDate!.isAfter(now),
          )
          .toList()
        ..sort((a, b) => a.startingDate!.compareTo(b.startingDate!));

  for (final workout in dated) {
    if (!seen.add(workout.id)) continue;
    final date = workout.startingDate!.toLocal();
    // Calendar dates keep day indices correct over daylight-saving changes.
    final dayIndex = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(startCalendar).inDays;
    for (final exercise in workout.flattenedExercises.whereType<Exercise>()) {
      for (final set in exercise.sets) {
        final load = set.weight;
        final reps = set.reps;
        if (!set.done ||
            set.parameters != GTSetParameters.repsWeight ||
            load == null ||
            !load.isFinite ||
            load <= 0 ||
            reps == null ||
            reps <= 0) {
          continue;
        }
        final weightKg = Weights.convert(
          value: load,
          from: workout.weightUnit,
          to: Weights.kg,
        );
        if (dayIndex >= 0 && dayIndex < days.length) {
          volumes[dayIndex] +=
              Weights.convert(
                value: load,
                from: workout.weightUnit,
                to: weightUnit,
              ) *
              reps;
        }
        final key = exercise.parentID ?? exercise.id;
        final previous = records[key];
        final difference = previous == null ? 0 : weightKg - previous.weightKg;
        if (previous == null ||
            difference > 1e-6 ||
            (difference.abs() <= 1e-6 && reps > previous.reps)) {
          records[key] = PersonalLoadRecord(
            exercise: exercise,
            date: date,
            weightKg: weightKg,
            reps: reps,
          );
        }
      }
    }
  }
  final latest = records.entries.toList()
    ..sort((a, b) {
      final dateOrder = b.value.date.compareTo(a.value.date);
      return dateOrder != 0 ? dateOrder : a.key.compareTo(b.key);
    });
  return ProgressOverview(
    days: List.unmodifiable([
      for (var i = 0; i < days.length; i++)
        DailyTrainingVolume(days[i], volumes[i]),
    ]),
    records: List.unmodifiable(latest.map((entry) => entry.value)),
    weightUnit: weightUnit,
  );
}
