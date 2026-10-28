// Run with TZ=Europe/Rome to exercise daylight-saving transitions.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    container.listen(foodSelectedDateProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  final cases = [
    (DateTime(2026, 10, 25), DateTime(2026, 10, 26)),
    (DateTime(2026, 3, 29), DateTime(2026, 3, 30)),
    (DateTime(2026, 1, 31), DateTime(2026, 2, 1)),
    (DateTime(2026, 12, 31), DateTime(2027, 1, 1)),
    (DateTime(2028, 2, 28), DateTime(2028, 2, 29)),
    (DateTime(2028, 2, 29), DateTime(2028, 3, 1)),
  ];

  for (final (before, after) in cases) {
    test('nextDay: $before -> $after', () {
      final notifier = container.read(foodSelectedDateProvider.notifier);
      notifier.setDate(before);
      notifier.nextDay();
      expect(container.read(foodSelectedDateProvider), after);
    });

    test('previousDay: $after -> $before', () {
      final notifier = container.read(foodSelectedDateProvider.notifier);
      notifier.setDate(after);
      notifier.previousDay();
      expect(container.read(foodSelectedDateProvider), before);
    });
  }
}
