import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/service/progress_overview.dart';

import '../helpers.dart';

GTSet performed(
  double weight,
  int reps, {
  bool done = true,
  GTSetParameters parameters = GTSetParameters.repsWeight,
}) => GTSet(
  kind: GTSetKind.normal,
  parameters: parameters,
  weight: weight,
  reps: reps,
  done: done,
);

Workout session(
  String id,
  DateTime date,
  List<Exercise> exercises, {
  Weights unit = Weights.kg,
  bool superset = false,
}) => Workout(
  id: id,
  name: id,
  startingDate: date,
  duration: const Duration(minutes: 30),
  weightUnit: unit,
  exercises: [
    if (superset)
      supersetHelper('group-$id', exercises: exercises)
    else
      ...exercises,
  ],
);

Exercise lift(String id, String parent, List<GTSet> sets) =>
    exerciseHelper(id, parent, sets: sets).copyWith(parentID: parent);

void main() {
  final now = DateTime(2026, 11, 5, 18);
  ProgressOverview overview(
    List<Workout> history, {
    Weights unit = Weights.kg,
    int firstDay = DateTime.monday,
  }) => buildProgressOverview(
    history,
    now: now,
    weightUnit: unit,
    firstDayOfWeek: firstDay,
  );

  test(
    'seven calendar days aggregate performed volume and retain zero days',
    () {
      final monday = DateTime(2026, 11, 2);
      final data = overview([
        session('a', monday, [
          lift('a', 'bench', [
            performed(50, 10),
            performed(999, 10, done: false),
          ]),
        ]),
        session('b', DateTime(2026, 11, 2, 20), [
          lift('b', 'squat', [performed(60, 5)]),
        ], superset: true),
        session('c', DateTime(2026, 11, 4), [
          lift('c', 'bench', [performed(55, 10)]),
        ]),
        session('old', DateTime(2026, 11, 1), [
          lift('old', 'bench', [performed(30, 10)]),
        ]),
        session('future', DateTime(2026, 11, 6), [
          lift('future', 'bench', [performed(1000, 10)]),
        ]),
      ]);
      expect(
        data.days.map((day) => day.date).toList(),
        List.generate(7, (i) => DateTime(2026, 11, 2 + i)),
      );
      expect(data.days.map((day) => day.volume).toList(), [
        800,
        0,
        550,
        0,
        0,
        0,
        0,
      ]);
      expect(
        data.records.any(
          (record) => record.weightKg == 999 || record.weightKg == 1000,
        ),
        isFalse,
      );
    },
  );

  test(
    'English week starts on Sunday and month/year boundaries are calendar-safe',
    () {
      final data = overview([], firstDay: DateTime.sunday);
      expect(data.days.first.date, DateTime(2026, 11, 1));
      final newYear = buildProgressOverview(
        [],
        now: DateTime(2027, 1, 1),
        weightUnit: Weights.kg,
        firstDayOfWeek: DateTime.monday,
      );
      expect(newYear.days.first.date, DateTime(2026, 12, 28));
      expect(newYear.days.last.date, DateTime(2027, 1, 3));
      final dstWeek = buildProgressOverview(
        [],
        now: DateTime(2026, 10, 25, 18),
        weightUnit: Weights.kg,
        firstDayOfWeek: DateTime.monday,
      );
      expect(dstWeek.days.map((day) => day.date.day), [
        19,
        20,
        21,
        22,
        23,
        24,
        25,
      ]);
    },
  );

  test(
    'records compare physical loads, then repetitions, and keep the first achievement date',
    () {
      final first = session('first', DateTime(2026, 10, 20), [
        lift('a', 'bench', [performed(100, 5)]),
      ]);
      final equivalent = Weights.convert(
        value: 100,
        from: Weights.kg,
        to: Weights.lb,
      );
      final tie = session('tie', DateTime(2026, 10, 23), [
        lift('b', 'bench', [performed(equivalent, 5)]),
      ], unit: Weights.lb);
      final data = overview([tie, first]);
      expect(data.records.single.date, first.startingDate);
      final moreReps = session('more', DateTime(2026, 11, 3), [
        lift('c', 'bench', [performed(equivalent, 6)]),
      ], unit: Weights.lb);
      final updated = overview([moreReps, tie, first]);
      expect(updated.records.single.reps, 6);
      expect(updated.records.single.date, moreReps.startingDate);
      expect(updated.records.single.weightKg, closeTo(100, 1e-8));
      final higher = overview([
        first,
        moreReps,
        session('heavier', DateTime(2026, 11, 4), [
          lift('d', 'bench', [performed(105, 1)]),
        ]),
      ]);
      expect(higher.records.single.weightKg, 105);
      expect(higher.records.single.reps, 1);
    },
  );

  test(
    'records are all-time, grouped by parent, ordered by achievement and display units convert',
    () {
      final data = overview([
        session('bench', DateTime(2026, 10, 26), [
          lift('a', 'bench', [performed(72.5, 8)]),
        ]),
        session('squat', DateTime(2026, 10, 25), [
          lift('b', 'squat', [performed(92.5, 8)]),
        ]),
        session('deadlift', DateTime(2026, 11, 3), [
          lift('c', 'deadlift', [performed(100, 5)]),
        ]),
      ], unit: Weights.lb);
      expect(data.records.map((record) => record.exercise.parentID), [
        'deadlift',
        'bench',
        'squat',
      ]);
      expect(data.records[1].weightIn(Weights.lb), closeTo(159.8358, .001));
      expect(
        data.days[1].volume,
        closeTo(
          Weights.convert(value: 500, from: Weights.kg, to: Weights.lb),
          1e-8,
        ),
      );
    },
  );

  test(
    'duplicate sessions, routines, future dates and unsupported parameters do not invent records',
    () {
      final valid = session('valid', DateTime(2026, 11, 2), [
        lift('a', 'bench', [performed(50, 8)]),
      ]);
      final data = overview([
        valid,
        valid,
        Workout(
          id: 'routine',
          name: 'Routine',
          startingDate: now,
          exercises: [
            lift('r', 'bench', [performed(999, 5)]),
          ],
        ),
        session('unsupported', DateTime(2026, 11, 4), [
          lift('free', 'free', [
            performed(0, 10, parameters: GTSetParameters.freeBodyReps),
          ]),
          lift('assisted', 'assisted', [
            performed(50, 10, parameters: GTSetParameters.repsNegWeight),
          ]),
          lift('zero', 'zero', [performed(0, 10)]),
          lift('negative', 'negative', [performed(-50, 10)]),
          lift('no-reps', 'no-reps', [performed(100, 0)]),
          lift('invalid', 'invalid', [performed(double.nan, 10)]),
        ]),
      ]);
      expect(data.days.first.volume, 400);
      expect(data.days[2].volume, 0);
      expect(data.records.length, 1);
      expect(valid.allSets.single.weight, 50);
    },
  );

  test(
    'empty history produces an empty week without placeholder personal records',
    () {
      final data = overview([]);
      expect(data.days.length, 7);
      expect(data.days.every((day) => day.volume == 0), isTrue);
      expect(data.records, isEmpty);
    },
  );
}
