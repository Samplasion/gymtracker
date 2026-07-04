import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/utils/time.dart';

void main() {
  group("Time utilities", () {
    test("stringifyTime", () {
      expect(stringifyTime(120), "1:20");
      expect(stringifyTime(60), "1:00");
      expect(stringifyTime(65), "1:05");
      expect(stringifyTime(1005), "10:05");
    });

    test("parseTime", () {
      expect(parseTime("01:20"), 120);
      expect(parseTime("10:05"), 1005);
      expect(() => parseTime("1:20"), throwsAssertionError);
    });

    test("timeToDuration", () {
      expect(timeToDuration(120), const Duration(minutes: 1, seconds: 20));
      expect(timeToDuration(1005), const Duration(minutes: 10, seconds: 5));
    });
  });
}
