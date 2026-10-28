import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  group('fixed-clock calendar boundaries', () {
    for (final (year, days) in [(2023, 28), (2024, 29)]) {
      test('February $year requires all $days distinct days', () {
        final rows = [
          for (var day = 1; day <= days; day++)
            workout(id: 'day-$day', date: DateTime(year, 2, day)),
        ];
        final fixture = AchievementFixture(
          now: DateTime(year, 2, days, 12),
          history: rows,
        );
        final level = fixture.rules.catalog['workoutFreak']!.levels.first;
        expect(level.progressMax!(), days);
        expect(level.progress!(), days);
        expect(level.checkCompletion(level.progress!()), isTrue);

        final incomplete = AchievementFixture(
          now: fixture.now,
          history: [...rows.skip(1), rows.last],
        ).rules.catalog['workoutFreak']!.levels.first;
        expect(incomplete.progress!(), days - 1);
        expect(incomplete.checkCompletion(incomplete.progress!()), isFalse);
      });
    }

    for (final (year, days) in [(2023, 365), (2024, 366)]) {
      test('year $year requires $days days and ignores other years', () {
        final rows = [
          for (var day = 1; day <= days; day++)
            workout(id: 'day-$day', date: DateTime(year, 1, day)),
        ];
        final fixture = AchievementFixture(
          now: DateTime(year, 12, 31),
          history: rows,
        );
        final level = fixture.rules.catalog['workoutFreak']!.levels[1];
        expect(level.progressMax!(), days);
        expect(level.checkCompletion(level.progress!()), isTrue);

        final incomplete = AchievementFixture(
          now: fixture.now,
          history: [
            ...rows.skip(1),
            workout(id: 'other-year', date: DateTime(year - 1, 1, 1)),
          ],
        ).rules.catalog['workoutFreak']!.levels[1];
        expect(incomplete.progress!(), days - 1);
        expect(incomplete.checkCompletion(incomplete.progress!()), isFalse);
      });
    }

    for (final end in [
      DateTime(2024, 4, 1),
      DateTime(2024, 10, 28),
      DateTime(2025, 1, 1),
    ]) {
      test(
        'meal streak includes its first day across calendar boundary $end',
        () {
          final level = AchievementFixture(
            now: end,
            foods: [
              meal(DateTime(end.year, end.month, end.day - 1)),
              meal(end),
              meal(end),
              meal(DateTime(end.year, end.month, end.day + 1)),
            ],
          ).rules.catalog['foodWatcher']!.levels.first;
          expect(level.progress!(), 2);
          expect(level.checkCompletion(level.progress!()), isTrue);
        },
      );
    }
  });
}
