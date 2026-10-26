import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/training_data.dart';

void main() {
  test('daily grouping is cached and follows history changes', () async {
    final source = StreamController<List<Workout>>();
    final container = ProviderContainer(
      overrides: [historyWorkoutsProvider.overrideWith((ref) => source.stream)],
    );
    addTearDown(() async {
      container.dispose();
      await source.close();
    });
    container.listen(workoutsByDayProvider, (_, _) {});

    expect(container.read(workoutsByDayProvider), isEmpty);
    final morning = Workout(
      id: 'morning',
      name: 'Morning',
      exercises: [],
      startingDate: DateTime(2026, 10, 25, 8),
    );
    final evening = morning.copyWith(
      id: 'evening',
      startingDate: DateTime(2026, 10, 25, 18),
    );
    final undated = Workout(id: 'undated', name: 'Undated', exercises: []);
    final continuation = morning.copyWith(
      id: 'continuation',
      completes: morning.id,
    );
    source.add([morning, evening, undated, continuation]);
    await container.read(historyWorkoutsProvider.future);
    final grouped = container.read(workoutsByDayProvider);
    final day = DateTime(2026, 10, 25);
    expect(grouped.keys, [day]);
    expect(grouped[day], [morning, evening, if (kDebugMode) continuation]);
    expect(identical(grouped, container.read(workoutsByDayProvider)), isTrue);
    expect(() => grouped.clear(), throwsUnsupportedError);
    expect(() => grouped[day]!.clear(), throwsUnsupportedError);

    source.add([evening.copyWith(startingDate: DateTime(2026, 10, 26))]);
    await container.pump();
    final updated = container.read(workoutsByDayProvider);
    expect(updated.keys, [DateTime(2026, 10, 26)]);
    expect(updated.values.single.single.id, 'evening');
    expect(identical(grouped, updated), isFalse);

    source.add([]);
    await container.pump();
    expect(container.read(workoutsByDayProvider), isEmpty);
  });
}
