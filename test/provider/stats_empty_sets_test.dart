import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final date = DateTime(2026, 10, 20);
  final squatSet = GTSet(
    kind: GTSetKind.normal,
    parameters: GTSetParameters.repsWeight,
    reps: 5,
    weight: 100,
    done: true,
  );
  Exercise exercise(String parentId, List<GTSet> sets) =>
      getStandardExerciseByID(parentId)!.makeChild().copyWith(sets: sets);

  Future<Map<DateTime, Map<MajorLiftType, double>>> fromWorkouts(
    List<Workout> workouts,
  ) async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        workoutsStreamProvider.overrideWith((ref) => Stream.value(workouts)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(majorThreeDataStreamProvider, (_, _) {});
    return container.read(majorThreeDataStreamProvider.future);
  }

  test(
    'aggregation ignores empty set lists without inventing zero points',
    () async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          exerciseDataStreamProvider(
            GTStandardLibrary.chest.barbellBenchPressFlat,
          ).overrideWith((ref) async => {date: <GTSet>[]}),
          exerciseDataStreamProvider(
            GTStandardLibrary.quadriceps.squatsBarbell,
          ).overrideWith(
            (ref) async => {
              date: [squatSet],
            },
          ),
          exerciseDataStreamProvider(
            GTStandardLibrary.back.deadlift,
          ).overrideWith((ref) async => {}),
        ],
      );
      addTearDown(container.dispose);
      container.listen(majorThreeDataStreamProvider, (_, _) {});

      expect(await container.read(majorThreeDataStreamProvider.future), {
        date: {MajorLiftType.squat: squatSet.oneRepMax},
      });
    },
  );

  test('empty workout contributes no major lift point', () async {
    expect(
      await fromWorkouts([
        Workout(name: 'Empty', exercises: [], startingDate: date),
      ]),
      isEmpty,
    );
  });

  test(
    'empty bench exercise does not discard valid squat on same date',
    () async {
      expect(
        await fromWorkouts([
          Workout(
            name: 'Mixed',
            startingDate: date,
            exercises: [
              exercise(GTStandardLibrary.chest.barbellBenchPressFlat, []),
              exercise(GTStandardLibrary.quadriceps.squatsBarbell, [squatSet]),
            ],
          ),
        ]),
        {
          date: {MajorLiftType.squat: squatSet.oneRepMax},
        },
      );
    },
  );

  test('workout with only unfinished sets contributes no point', () async {
    expect(
      await fromWorkouts([
        Workout(
          name: 'Planned',
          startingDate: date,
          exercises: [
            exercise(GTStandardLibrary.chest.barbellBenchPressFlat, [
              squatSet.copyWith(done: false),
            ]),
          ],
        ),
      ]),
      isEmpty,
    );
  });
}
