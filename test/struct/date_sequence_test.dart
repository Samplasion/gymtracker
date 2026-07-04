import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/optional.dart';

void main() {
  group("DateSequence tests", () {
    final d1 = DateTime(2026, 1, 1);
    final d2 = DateTime(2026, 1, 10);
    final d3 = DateTime(2026, 1, 20);

    test("fromList and toMap", () {
      final seq = DateSequence.fromList([
        DateTagged(date: d2, value: "B"),
        DateTagged(date: d1, value: "A"),
        DateTagged(date: d3, value: "C"),
      ]);

      expect(seq.length, 3);
      expect(seq.isEmpty, false);
      expect(seq.isNotEmpty, true);

      final map = seq.toMap();
      expect(map[d1], "A");
      expect(map[d2], "B");
      expect(map[d3], "C");
    });

    test("fromDatesAndValues", () {
      final seq = DateSequence.fromDatesAndValues({
        d2: "B",
        d1: "A",
        d3: "C",
      });

      expect(seq.length, 3);
      expect(seq[d1], "A");
      expect(seq[d2], "B");
      expect(seq[d3], "C");
    });

    test("operator [] with missing date returns closest previous", () {
      final seq = DateSequence.fromDatesAndValues({
        d1: "A",
        d3: "C",
      });

      // exact matches
      expect(seq[d1], "A");
      expect(seq[d3], "C");

      // middle date (returns closest previous: A)
      expect(seq[DateTime(2026, 1, 10)], "A");

      // before first date (returns first: A)
      expect(seq[DateTime(2025, 12, 31)], "A");

      // after last date (returns last: C)
      expect(seq[DateTime(2026, 1, 25)], "C");
    });

    test("surroundingDates", () {
      final seq = DateSequence.fromDatesAndValues({
        d1: "A",
        d2: "B",
        d3: "C",
      });

      // before first date
      final rangeBefore = seq.surroundingDates(DateTime(2025, 12, 31));
      expect(rangeBefore.from, null);
      expect(rangeBefore.to, d1);
      expect(rangeBefore.duration, Duration.zero);

      // exact first date (treated as on/after last, wait: key.isAfterOrAtSameMomentAs(keys.last) is checked for d3, key.isBefore(keys.first) for d1)
      // d1 is keys.first, so it falls to else block, but keys[0] is d1 and keys[1] is d2.
      // key (d1) isBeforeOrAtSameMomentAs(key) && keys[1].isAfter(key) -> returns (d1, d2)
      final rangeFirst = seq.surroundingDates(d1);
      expect(rangeFirst.from, d1);
      expect(rangeFirst.to, d2);

      // between d1 and d2
      final rangeMid = seq.surroundingDates(DateTime(2026, 1, 5));
      expect(rangeMid.from, d1);
      expect(rangeMid.to, d2);
      expect(rangeMid.duration, const Duration(days: 9));

      // on/after last date
      final rangeAfter = seq.surroundingDates(DateTime(2026, 1, 25));
      expect(rangeAfter.from, d3);
      expect(rangeAfter.to, null);
    });

    test("normalize", () {
      final seq = DateSequence.fromList([
        DateTagged(date: d1, value: "A"),
        DateTagged(date: d2, value: "A"), // consecutive duplicates
        DateTagged(date: d3, value: "B"),
      ]).normalize();

      expect(seq.length, 2);
      // "In case of collisions, the last value in the list is kept, even if it is not the last value chronologically."
      expect(seq.toMap()[d1], null);
      expect(seq.toMap()[d2], "A");
      expect(seq.toMap()[d3], "B");
    });

    test("DateRange copyWith", () {
      final seq = DateSequence.fromDatesAndValues({d1: "A", d2: "B"});
      final range = seq.surroundingDates(DateTime(2026, 1, 5));

      expect(range.from, d1);
      expect(range.to, d2);

      final range2 = range.copyWith(from: const None(), to: Some(d3));
      expect(range2.from, null);
      expect(range2.to, d3);
    });
  });
}
