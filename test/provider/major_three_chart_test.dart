import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/stats.dart';

void main() {
  test(
    'weekly aggregation preserves lift separation and highest 1RM',
    () async {
      final container = ProviderContainer(
        overrides: [
          majorThreeDataStreamProvider.overrideWith(
            (ref) async => {
              DateTime(2026, 10, 22): {MajorLiftType.benchPress: 80},
              DateTime(2026, 10, 20): {
                MajorLiftType.benchPress: 90,
                MajorLiftType.squat: 120,
              },
              DateTime(2026, 10, 12): {MajorLiftType.benchPress: 70},
            },
          ),
        ],
      );
      addTearDown(container.dispose);
      final result = await container.read(
        majorThreeChartDataProvider(1).future,
      );
      expect(result[MajorLiftType.benchPress], {
        DateTime(2026, 10, 19): 90,
        DateTime(2026, 10, 12): 70,
      });
      expect(result[MajorLiftType.benchPress]!.keys.toList(), [
        DateTime(2026, 10, 12),
        DateTime(2026, 10, 19),
      ]);
      expect(result[MajorLiftType.squat], {DateTime(2026, 10, 19): 120});
      expect(result.containsKey(MajorLiftType.deadlift), isFalse);
    },
  );

  test('empty history produces no lift points', () async {
    final container = ProviderContainer(
      overrides: [majorThreeDataStreamProvider.overrideWith((ref) async => {})],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(majorThreeChartDataProvider(1).future),
      isEmpty,
    );
  });
}
