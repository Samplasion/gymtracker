import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group("getLastDayOfWeek -", () {
    final DateTime today = DateTime(2024, 1, 1);
    test("should return today if today's day of week is the one provided", () {
      expect(
        getLastFirstDayOfWeek(today, DateTime.monday),
        DateTime(2024, 1, 1),
      );
    });
    test("should return a day in the last week otherwise", () {
      expect(
        getLastFirstDayOfWeek(today, DateTime.tuesday),
        DateTime(2023, 12, 26),
      );
      expect(
        getLastFirstDayOfWeek(today, DateTime.wednesday),
        DateTime(2023, 12, 27),
      );
      expect(
        getLastFirstDayOfWeek(today, DateTime.thursday),
        DateTime(2023, 12, 28),
      );
      expect(
        getLastFirstDayOfWeek(today, DateTime.friday),
        DateTime(2023, 12, 29),
      );
      expect(
        getLastFirstDayOfWeek(today, DateTime.saturday),
        DateTime(2023, 12, 30),
      );
      expect(
        getLastFirstDayOfWeek(today, DateTime.sunday),
        DateTime(2023, 12, 31),
      );
    });
  });
  test('generateWorkoutTitle works correctly', () {
    final title1 = generateWorkoutTitle({GTMuscleCategory.chest});
    expect(title1.contains('Chest'), true);

    final title2 = generateWorkoutTitle({
      GTMuscleCategory.chest,
      GTMuscleCategory.shoulders,
    });
    expect(title2.contains('Chest'), true);
    expect(title2.contains('Shoulders'), true);
  });
}
