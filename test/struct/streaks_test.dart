import 'package:gymtracker/struct/streaks.dart';
import 'package:test/test.dart';

void main() {
  group("Streaks -", () {
    test("should return Streaks.zero for an empty map", () {
      expect(
        Streaks.fromMappedDays({}, firstDayOfWeek: 1, today: DateTime.now()),
        Streaks.zero,
      );
    });
    group("should return sensible values", () {
      test("when the first dow is Monday", () {
        // January 1, 2024 is a Monday.
        final today = DateTime(2024, 1, 1);
        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 7)): [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 14)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.monday,
            today: today,
          ),
          const Streaks(
            weekStreak: 3,
            restDays: 0,
          ),
        );
        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.monday,
            today: today,
          ),
          const Streaks(
            weekStreak: 1,
            restDays: 0,
          ),
        );
        expect(
          Streaks.fromMappedDays(
            {
              today.subtract(const Duration(days: 5)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.monday,
            today: today,
          ),
          const Streaks(
            weekStreak: 1,
            restDays: 5,
          ),
        );

        final wednesday = today.add(const Duration(days: 2));

        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 7)): [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 14)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.monday,
            today: wednesday,
          ),
          const Streaks(
            weekStreak: 3,
            restDays: 2,
          ),
        );
      });

      test("when the first dow is Sunday", () {
        // January 1, 2023 is a Sunday.
        final today = DateTime(2023, 1, 1);
        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 7)): [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 14)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.sunday,
            today: today,
          ),
          const Streaks(
            weekStreak: 3,
            restDays: 0,
          ),
        );
        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.sunday,
            today: today,
          ),
          const Streaks(
            weekStreak: 1,
            restDays: 0,
          ),
        );
        expect(
          Streaks.fromMappedDays(
            {
              today.subtract(const Duration(days: 5)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.sunday,
            today: today,
          ),
          const Streaks(
            weekStreak: 1,
            restDays: 5,
          ),
        );

        final wednesday = today.add(const Duration(days: 2));

        expect(
          Streaks.fromMappedDays(
            {
              today: [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 7)): [1, 2, 3, 4, 5],
              today.subtract(const Duration(days: 14)): [1, 2, 3, 4, 5],
            },
            firstDayOfWeek: DateTime.sunday,
            today: wednesday,
          ),
          const Streaks(
            weekStreak: 3,
            restDays: 2,
          ),
        );
      });
    });
  });
}
