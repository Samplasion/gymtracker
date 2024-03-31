import 'package:gymtracker/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group("getLastDayOfWeek -", () {
    final DateTime today = DateTime(2024, 1, 1);
    test("should return today if today's day of week is the one provided", () {
      expect(getLastDayOfWeek(today, DateTime.monday), DateTime(2024, 1, 1));
    });
    test("should return a day in the last week otherwise", () {
      expect(getLastDayOfWeek(today, DateTime.tuesday), DateTime(2023, 12, 26));
      expect(
          getLastDayOfWeek(today, DateTime.wednesday), DateTime(2023, 12, 27));
      expect(
          getLastDayOfWeek(today, DateTime.thursday), DateTime(2023, 12, 28));
      expect(getLastDayOfWeek(today, DateTime.friday), DateTime(2023, 12, 29));
      expect(
          getLastDayOfWeek(today, DateTime.saturday), DateTime(2023, 12, 30));
      expect(getLastDayOfWeek(today, DateTime.sunday), DateTime(2023, 12, 31));
    });
  });
}
