import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/service/plateau_analysis.dart';
import '../helpers.dart';

final now = DateTime(2026, 10, 25, 12);
List<Workout> history({
  List<int> days = const [35, 28, 21, 14, 7, 0],
  double weight = 50,
  int reps = 10,
  GTSetParameters parameters = GTSetParameters.repsWeight,
}) => [
  for (final day in days)
    Workout(
      id: 'w$day',
      name: 'Workout',
      startingDate: now.subtract(Duration(days: day)),
      duration: const Duration(minutes: 30),
      exercises: [
        exerciseHelper(
          'e$day',
          'Exercise',
          sets: [
            for (var i = 0; i < 3; i++)
              GTSet(
                kind: GTSetKind.normal,
                parameters: parameters,
                weight: weight,
                reps: reps,
                done: true,
              ),
          ],
        ).copyWith(parentID: 'parent', workoutID: 'w$day'),
      ],
    ),
];
PlateauResult analyze(List<Workout> workouts) =>
    analyzePlateaus(workouts, now: now).single;
List<Workout> changeLast(
  List<Workout> workouts,
  GTSet Function(GTSet) change,
) => [
  ...workouts.take(workouts.length - 1),
  workouts.last.copyWith(
    exercises: [
      workouts.last.exercises.first.asExercise.copyWith(
        sets: workouts.last.exercises.first.asExercise.sets
            .map(change)
            .toList(),
      ),
    ],
  ),
];

void main() {
  test('stable recent sessions flag with reference and evidence', () {
    final r = analyze(history());
    expect(r.status, PlateauStatus.possiblePlateau);
    expect(r.sessions.length, 6);
    expect(r.baseline!.volumeKg, 1500);
  });
  test('weight, repetition and volume gains prevent a flag', () {
    expect(
      analyze(changeLast(history(), (s) => s.copyWith(weight: 51.25))).status,
      PlateauStatus.progressing,
    );
    expect(
      analyze(changeLast(history(), (s) => s.copyWith(reps: 11))).status,
      PlateauStatus.progressing,
    );
    expect(
      analyze(
        changeLast(history(), (s) => s.copyWith(weight: 55, reps: 9)),
      ).status,
      PlateauStatus.possiblePlateau,
    );
    // Higher volume despite fewer reps at the heaviest load.
    expect(
      analyze(
        changeLast(history(), (s) => s.copyWith(weight: 60, reps: 9)),
      ).status,
      PlateauStatus.progressing,
    );
  });
  test('bodyweight has no load or volume and detects rep gains', () {
    final h = history(parameters: GTSetParameters.freeBodyReps);
    expect(analyze(h).status, PlateauStatus.possiblePlateau);
    expect(analyze(h).sessions.first.volumeKg, isNull);
    expect(
      analyze(changeLast(h, (s) => s.copyWith(reps: 11))).status,
      PlateauStatus.progressing,
    );
  });
  test('kg and lb produce equivalent evidence', () {
    final h = history();
    final converted = h
        .map(
          (w) => w.copyWith(
            weightUnit: Weights.lb,
            exercises: [
              w.exercises.first.asExercise.copyWith(
                sets: w.exercises.first.asExercise.sets
                    .map(
                      (s) => s.copyWith(
                        weight: Weights.convert(
                          value: s.weight!,
                          from: Weights.kg,
                          to: Weights.lb,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        )
        .toList();
    expect(analyze(converted).status, PlateauStatus.possiblePlateau);
    expect(analyze(converted).baseline!.volumeKg, closeTo(1500, 1e-7));
  });
  test('insufficient span, sessions, gaps and recency are not plateaus', () {
    expect(
      analyze(history(days: [28, 21, 14, 7, 0])).status,
      PlateauStatus.insufficientData,
    );
    expect(
      analyze(history(days: [5, 4, 3, 2, 1, 0])).status,
      PlateauStatus.insufficientData,
    );
    expect(
      analyze(history(days: [56, 49, 42, 35, 28, 0])).status,
      PlateauStatus.insufficientData,
    );
    expect(
      analyze(history(days: [50, 43, 36, 29, 22, 15])).status,
      PlateauStatus.stale,
    );
    expect(
      analyze(history(days: [49, 42, 35, 28, 21, 14])).status,
      PlateauStatus.possiblePlateau,
    );
    expect(
      analyze(history(days: [28, 21, 14, 7, 3, 0])).status,
      PlateauStatus.possiblePlateau,
    );
  });
  test(
    'incomplete, warmup and invalid observations cannot create evidence',
    () {
      expect(
        analyze(changeLast(history(), (s) => s.copyWith(done: false))).status,
        PlateauStatus.insufficientData,
      );
      expect(
        analyze(
          changeLast(history(), (s) => s.copyWith(kind: GTSetKind.warmUp)),
        ).status,
        PlateauStatus.insufficientData,
      );
      expect(
        analyze(
          changeLast(history(), (s) => s.copyWith(weight: double.nan)),
        ).status,
        PlateauStatus.insufficientData,
      );
      expect(
        analyze(changeLast(history(), (s) => s.copyWith(reps: 0))).status,
        PlateauStatus.insufficientData,
      );
    },
  );
  test(
    'changed prescription, definition and identity cannot join old evidence',
    () {
      final h = history();
      final ex = h.last.exercises.first.asExercise;
      for (final changed in [
        ex.copyWith(sets: ex.sets.take(2).toList()),
        ex.copyWith(name: 'Changed'),
      ]) {
        expect(
          analyze([
            ...h.take(5),
            h.last.copyWith(exercises: [changed]),
          ]).status,
          PlateauStatus.insufficientData,
        );
      }
      expect(
        analyzePlateaus([
          ...h.take(5),
          h.last.copyWith(exercises: [ex.copyWith(parentID: 'new')]),
        ], now: now).every((r) => r.status != PlateauStatus.possiblePlateau),
        isTrue,
      );
    },
  );
  test('unsupported assistance is explicitly excluded', () {
    expect(
      analyze(history(parameters: GTSetParameters.repsNegWeight)).status,
      PlateauStatus.unsupported,
    );
  });
  test(
    'duplicate workout is ignored; same-day separate sessions are ambiguous',
    () {
      final h = history();
      expect(analyze([...h, h.last]).sessions.length, 6);
      expect(
        analyze([...h, h.last.copyWith(id: 'duplicate-day')]).status,
        PlateauStatus.incomparable,
      );
    },
  );
  test(
    'supersets and repeated exercise entries aggregate once per workout',
    () {
      final h = history().map((w) {
        final ex = w.exercises.first.asExercise;
        return w.copyWith(
          exercises: [
            supersetHelper('superset', exercises: [ex], workoutID: w.id),
            ex.copyWith(id: 'extra'),
          ],
        );
      }).toList();
      final r = analyze(h);
      expect(r.status, PlateauStatus.possiblePlateau);
      expect(r.sessions.length, 6);
      expect(r.sessions.first.setCount, 6);
      expect(r.baseline!.volumeKg, 3000);
    },
  );
  test('additional unfinished or special sets do not change volume', () {
    final h = history().map((w) {
      final ex = w.exercises.first.asExercise;
      return w.copyWith(
        exercises: [
          ex.copyWith(
            sets: [
              ...ex.sets,
              ex.sets.first.copyWith(weight: 1000, done: false),
              ex.sets.first.copyWith(weight: 1000, kind: GTSetKind.warmUp),
              ex.sets.first.copyWith(weight: 1000, kind: GTSetKind.drop),
              ex.sets.first.copyWith(weight: 1000, kind: GTSetKind.failure),
            ],
          ),
        ],
      );
    }).toList();
    expect(analyze(h).baseline!.volumeKg, 1500);
    expect(analyze(h).status, PlateauStatus.possiblePlateau);
  });
  test('future and abstract workouts are ignored', () {
    expect(
      analyzePlateaus([
        history().last.copyWith(startingDate: now.add(const Duration(days: 1))),
      ], now: now),
      isEmpty,
    );
    expect(
      analyzePlateaus([
        Workout(name: 'Routine', exercises: history().last.exercises),
      ], now: now),
      isEmpty,
    );
  });
}
