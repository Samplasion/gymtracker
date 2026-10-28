import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/stats.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ids = {
    MajorLiftType.benchPress: GTStandardLibrary.chest.barbellBenchPressFlat,
    MajorLiftType.squat: GTStandardLibrary.quadriceps.squatsBarbell,
    MajorLiftType.deadlift: GTStandardLibrary.back.deadlift,
  };
  Workout workout(int day, double kg, Weights unit) => Workout(
    name: 'Main lifts',
    startingDate: DateTime(2026, 10, day),
    duration: const Duration(minutes: 10),
    weightUnit: unit,
    exercises: [
      for (final id in ids.values)
        getStandardExerciseByID(id)!.makeChild().copyWith(
          sets: [
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsWeight,
              reps: 1,
              weight: Weights.convert(value: kg, from: Weights.kg, to: unit),
              done: true,
            ),
          ],
        ),
    ],
  );

  for (final includeGreater in [false, true]) {
    test(
      'all lifts compare equivalent kg/lb loads physically (greater=$includeGreater)',
      () async {
        final pounds = workout(21, 100, Weights.lb);
        final container = ProviderContainer(
          overrides: [
            workoutsStreamProvider.overrideWith(
              (ref) => Stream.value([
                workout(20, 100, Weights.kg),
                pounds,
                if (includeGreater) workout(22, 110, Weights.kg),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(majorThreeChartDataProvider(1), (_, _) {});
        final chart = await container.read(
          majorThreeChartDataProvider(1).future,
        );
        for (final lift in ids.keys) {
          expect(
            chart[lift]!.values.single,
            closeTo(includeGreater ? 110 : 100, 1e-8),
          );
        }
        expect(pounds.allSets.first.weight, greaterThan(220));
      },
    );
  }
  test(
    'display values follow kg/lb preference changes without changing canonical maxima',
    () async {
      final preferences = BehaviorSubject<Prefs>.seeded(
        Prefs.defaultValue.copyWith(weightUnit: Weights.kg),
      );
      var historyReads = 0;
      final container = ProviderContainer(
        overrides: [
          workoutsStreamProvider.overrideWith((ref) {
            historyReads++;
            return Stream.value([
              workout(20, 100, Weights.kg),
              workout(21, 100, Weights.lb),
            ]);
          }),
          appPreferencesProvider.overrideWith((ref) => preferences.stream),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await preferences.close();
      });
      container.listen(majorThreeDisplayChartDataProvider(1), (_, _) {});
      final initial = await container.read(
        majorThreeDisplayChartDataProvider(1).future,
      );
      for (final lift in ids.keys) {
        expect(initial[lift]!.values.single, closeTo(100, 1e-8));
      }
      for (final unit in [Weights.lb, Weights.kg]) {
        preferences.add(Prefs.defaultValue.copyWith(weightUnit: unit));
        await container.pump();
        final display = await container.read(
          majorThreeDisplayChartDataProvider(1).future,
        );
        expect(container.read(statsWeightUnitProvider), unit);
        final expected = Weights.convert(
          value: 100,
          from: Weights.kg,
          to: unit,
        );
        for (final lift in ids.keys) {
          expect(display[lift]!.values.single, closeTo(expected, 1e-8));
        }
        final canonical = await container.read(
          majorThreeChartDataProvider(1).future,
        );
        expect(
          canonical[MajorLiftType.benchPress]!.values.single,
          closeTo(100, 1e-8),
        );
      }
      expect(historyReads, 1);
    },
  );
}
