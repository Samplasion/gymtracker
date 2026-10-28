import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final benchId = GTStandardLibrary.chest.barbellBenchPressFlat;
  final date = DateTime(2026, 10, 20);
  final done = GTSet(
    id: 'performed',
    kind: GTSetKind.normal,
    parameters: GTSetParameters.repsWeight,
    reps: 5,
    weight: 100,
    done: true,
  );
  final planned = done.copyWith(id: 'planned', weight: 200, done: false);

  for (final inSuperset in [false, true]) {
    for (final includeCompleted in [false, true]) {
      test(
        'only performed sets contribute to 1RM (superset=$inSuperset, completed=$includeCompleted)',
        () async {
          final exercise = getStandardExerciseByID(
            benchId,
          )!.makeChild().copyWith(sets: [if (includeCompleted) done, planned]);
          final workout = Workout(
            name: 'Bench workout',
            exercises: [
              if (inSuperset)
                Superset(
                  workoutID: null,
                  id: 'superset',
                  exercises: [exercise],
                  restTime: Duration.zero,
                )
              else
                exercise,
            ],
            startingDate: date,
            duration: const Duration(minutes: 10),
          );
          final container = ProviderContainer(
            retry: (_, _) => null,
            overrides: [
              workoutsStreamProvider.overrideWith(
                (ref) => Stream.value([workout]),
              ),
            ],
          );
          addTearDown(container.dispose);
          container.listen(exerciseDataStreamProvider(benchId), (_, _) {});
          container.listen(majorThreeDataStreamProvider, (_, _) {});
          container.listen(majorThreeChartDataProvider(1), (_, _) {});
          final sets = await container.read(
            exerciseDataStreamProvider(benchId).future,
          );
          final maxima = await container.read(
            majorThreeDataStreamProvider.future,
          );
          final chart = await container.read(
            majorThreeChartDataProvider(1).future,
          );
          if (includeCompleted) {
            expect(sets[date], [done]);
            expect(maxima[date]?[MajorLiftType.benchPress], done.oneRepMax);
            expect(
              chart[MajorLiftType.benchPress]?.values.single,
              done.oneRepMax,
            );
          } else {
            expect(sets, isEmpty);
            expect(maxima, isEmpty);
            expect(chart, isEmpty);
          }
        },
      );
    }
  }
}
