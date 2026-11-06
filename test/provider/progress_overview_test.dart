import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/progress_overview.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:rxdart/rxdart.dart';

import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final date = DateTime(2026, 11, 1, 18);
  final workout = Workout(
    id: 'session',
    name: 'Session',
    startingDate: date,
    duration: const Duration(minutes: 20),
    exercises: [
      exerciseHelper(
        'bench',
        'Bench',
        sets: [
          GTSet(
            kind: GTSetKind.normal,
            parameters: GTSetParameters.repsWeight,
            weight: 50,
            reps: 10,
            done: true,
          ),
        ],
      ),
    ],
  );

  test(
    'preference changes update volume and record units without re-reading history',
    () async {
      final preferences = BehaviorSubject.seeded(Prefs.defaultValue);
      var reads = 0;
      final container = ProviderContainer(
        overrides: [
          trainingClockProvider.overrideWithValue(() => date),
          appPreferencesProvider.overrideWith((ref) => preferences.stream),
          historyWorkoutsProvider.overrideWith((ref) {
            reads++;
            return Stream.value([workout]);
          }),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await preferences.close();
      });
      final provider = progressOverviewProvider(DateTime.monday);
      container.listen(provider, (_, _) {});
      await container.pump();
      await container.pump();
      expect(container.read(provider).requireValue.days.last.volume, 500);
      preferences.add(Prefs.defaultValue.copyWith(weightUnit: Weights.lb));
      await container.pump();
      expect(container.read(provider).requireValue.weightUnit, Weights.lb);
      expect(
        container.read(provider).requireValue.days.last.volume,
        closeTo(1102.3113, .001),
      );
      expect(container.read(provider).requireValue.records.single.weightKg, 50);
      expect(reads, 1);
    },
  );

  testWidgets('the open summary advances to a new week at local midnight', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 1, 23, 59, 50);
    final container = ProviderContainer(
      overrides: [
        trainingClockProvider.overrideWithValue(() => now),
        appPreferencesProvider.overrideWith(
          (ref) => Stream.value(Prefs.defaultValue),
        ),
        historyWorkoutsProvider.overrideWith((ref) => Stream.value([workout])),
      ],
    );
    final provider = progressOverviewProvider(DateTime.monday);
    container.listen(provider, (_, _) {});
    await tester.pump();
    await tester.pump();
    expect(container.read(provider).requireValue.days.last.volume, 500);
    now = DateTime(2026, 11, 2, 0, 0, 1);
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    final next = container.read(provider).requireValue;
    expect(next.days.first.date, DateTime(2026, 11, 2));
    expect(next.days.every((day) => day.volume == 0), isTrue);
    expect(next.records.length, 1);
    container.dispose();
  });
}
