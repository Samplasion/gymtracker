import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

const lipsum =
    """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras ut tristique arcu. Donec porta congue orci at rutrum. Sed non leo iaculis, viverra ligula vel, euismod libero. Pellentesque a risus egestas, malesuada diam at, commodo mauris. Donec id dolor mattis, lacinia ante nec, mattis orci. Fusce aliquet ligula nec urna gravida, at egestas urna hendrerit. Ut vel erat dictum, scelerisque augue in, semper lorem. Aenean turpis odio, tincidunt sit amet interdum at, porttitor et urna. Nam feugiat nulla tempus viverra condimentum.
Pellentesque sed venenatis urna. Nunc at diam vel lectus ornare scelerisque. Aliquam id arcu at ligula gravida rutrum. Sed non interdum quam. Pellentesque ut maximus dui. Nullam sed arcu nisl. Aliquam cursus mollis justo, eget auctor augue. Morbi tincidunt erat sit amet mi dictum ultrices.
Cras posuere, magna in commodo molestie, nisl eros porttitor erat, id consectetur ex justo quis nisi. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam feugiat gravida tortor, eget tempus velit tempor ac. Etiam tincidunt ullamcorper nisi, eu commodo nulla tincidunt ac. Donec et condimentum est. In sollicitudin erat id elit condimentum pretium. Quisque elementum leo nec faucibus elementum. Duis et turpis ut turpis ultricies rutrum.
Nunc sollicitudin fringilla blandit. Proin at interdum eros, consectetur gravida nunc. Morbi semper, dui id tincidunt pulvinar, metus odio blandit odio, quis pharetra erat enim vel libero. Aenean porta lacus eu lacus sollicitudin, quis ultrices dui cursus. Nunc non dui tincidunt, auctor nulla et, ornare eros. Donec nec tempor ipsum. Praesent nec nisl vitae nisi consequat viverra sed eget lacus. Phasellus at justo diam. Mauris rutrum, nisl egestas vulputate imperdiet, metus dolor rutrum diam, vel condimentum ipsum ligula in neque. Vestibulum quis ex ac metus aliquam lacinia id in ipsum. Nulla facilisi. Curabitur ultrices libero non urna congue sodales. Aenean condimentum accumsan ipsum vitae ullamcorper.
Nam ultricies sed tortor eu consequat. Nullam consectetur, neque sed venenatis cursus, velit risus vestibulum ipsum, ut malesuada mi tortor suscipit lectus. Etiam interdum consectetur neque. Aliquam placerat lacus eget nunc tristique semper. Integer lorem risus, consectetur at dapibus in, fringilla quis lorem. Donec vel felis ipsum. Integer nec semper nisi. Suspendisse ut malesuada magna, cursus tincidunt nunc. Aenean ullamcorper varius magna, ut sagittis velit molestie vel.""";
final encodedLipsum = base64.encode(gzip.encode(utf8.encode(lipsum)));

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('StringCompression extension', () {
    test("compressed", () {
      const testCompressed = "H4sIAAAAAAAAAwtJLS4BADLRTXgEAAAA";
      expect(
          [testCompressed, testCompressed.replaceRange(12, 13, "E")]
              .contains("Test".compressed),
          true);
      expect(
          [encodedLipsum, encodedLipsum.replaceRange(12, 13, "E")]
              .contains(lipsum.compressed),
          true);
    });
    test("uncompressed", () {
      expect("H4sIAAAAAAAAEwtJLS4BADLRTXgEAAAA".uncompressed, "Test");
      expect(encodedLipsum.uncompressed, lipsum);
    });
  });

  group('NumGenericUtils extension', () {
    group("localized", () {
      test("en-US", () {
        Get.updateLocale(const Locale("en", "US"));
        expect(1.234.localized, "1.23");
        expect(1.239.localized, "1.24");
        expect(12.localized, "12");
        expect(1234.localized, "1,234");
        expect(1234.567.localized, "1,234.57");
        expect(123456789.012.localized, "123,456,789.01");
      });

      test("it-IT", () {
        Get.updateLocale(const Locale("it", "IT"));
        expect(1.234.localized, "1,23");
        expect(1.239.localized, "1,24");
        expect(12.localized, "12");
        expect(1234.localized, "1.234");
        expect(1234.567.localized, "1.234,57");
        expect(123456789.012.localized, "123.456.789,01");
      });

      // To update if we support new languages
    });
  });

  group('StringUtils extension', () {
    test('tryParseJson', () {
      expect('{"a": 1}'.tryParseJson(), {'a': 1});
      expect('[1, 2]'.tryParseJson(), [1, 2]);
      expect('invalid json'.tryParseJson(), null);
    });
  });

  group('DateUtils extension', () {
    test('startOfDay', () {
      final date = DateTime(2026, 7, 4, 15, 30, 45);
      final expected = DateTime(2026, 7, 4, 0, 0, 0);
      expect(date.startOfDay, expected);
    });

    test('isAfterOrAtSameMomentAs / isBeforeOrAtSameMomentAs', () {
      final d1 = DateTime(2026, 7, 4);
      final d2 = DateTime(2026, 7, 5);

      expect(d2.isAfterOrAtSameMomentAs(d1), true);
      expect(d1.isAfterOrAtSameMomentAs(d1), true);
      expect(d1.isAfterOrAtSameMomentAs(d2), false);

      expect(d1.isBeforeOrAtSameMomentAs(d2), true);
      expect(d1.isBeforeOrAtSameMomentAs(d1), true);
      expect(d2.isBeforeOrAtSameMomentAs(d1), false);
    });
  });

  group('NumIterableUtils extension', () {
    test('sum, min, max, safeMin, safeMax', () {
      final list = [1.0, 2.0, 3.0, 4.0];
      expect(list.sum, 10.0);
      expect(list.min, 1.0);
      expect(list.max, 4.0);
      expect(list.safeMin, 1.0);
      expect(list.safeMax, 4.0);

      final empty = <double>[];
      expect(empty.sum, 0.0);
      expect(empty.safeMin, null);
      expect(empty.safeMax, null);
    });
  });

  group('IntUtils extension', () {
    test('toRomanNumeral', () {
      expect(1.toRomanNumeral(), 'I');
      expect(4.toRomanNumeral(), 'IV');
      expect(9.toRomanNumeral(), 'IX');
      expect(49.toRomanNumeral(), 'XLIX');
      expect(3999.toRomanNumeral(), 'MMMCMXCIX');
      expect(() => 0.toRomanNumeral(), throwsArgumentError);
      expect(() => 4000.toRomanNumeral(), throwsArgumentError);
    });
  });

  group('FileFormatter extension', () {
    test('readableFileSize', () {
      expect(0.readableFileSize(), '0');
      expect(1024.readableFileSize(base1024: true), '1 kB');
      expect(1000.readableFileSize(base1024: false), '1 kB');
      expect((1024 * 1024).readableFileSize(base1024: true), '1 MB');
    });
  });

  group('ListUtils extension', () {
    test('getAt', () {
      final list = ['a', 'b', 'c'];
      expect(list.getAt(0), 'a');
      expect(list.getAt(2), 'c');
      expect(list.getAt(3), null);
      expect(list.getAt(-1), 'c');
      expect(list.getAt(-3), 'a');
      expect(list.getAt(-4), null);
    });
  });

  group('IterableUtils extension', () {
    test('partition', () {
      final list = [1, 2, 3, 4, 5];
      final res = list.partition((x) => x.isEven);
      expect(res.matching, [2, 4]);
      expect(res.rest, [1, 3, 5]);
    });

    test('firstWhereOrNull', () {
      final list = [1, 2, 3];
      expect(list.firstWhereOrNull((x) => x == 2), 2);
      expect(list.firstWhereOrNull((x) => x == 4), null);
    });
  });

  group('MapOfListUtils extension', () {
    test('combinedWith', () {
      final m1 = {
        'a': [1, 2],
        'b': [3]
      };
      final m2 = {
        'b': [4],
        'c': [5]
      };
      final res = m1.combinedWith(m2);
      expect(res, {
        'a': [1, 2],
        'b': [3, 4],
        'c': [5],
      });
    });
  });

  group('ColorUtils extension', () {
    test('isGray, hexValue, estimateForegroundBrightness', () {
      const red = Colors.red;
      const gray = Colors.grey;
      expect(gray.isGray, true);
      expect(red.isGray, false);
      expect(Colors.white.hexValue, 0xFFFFFFFF);
      expect(Colors.black.estimateForegroundBrightness(), Brightness.light);
      expect(Colors.white.estimateForegroundBrightness(), Brightness.dark);
    });
  });

  group('Workout and Exercise extensions', () {
    test('flattenedExercises', () {
      final w = Workout(
        name: 'Test',
        exercises: [
          exerciseHelper('1', 'E1'),
          supersetHelper('ss', exercises: [
            exerciseHelper('2', 'E2'),
            exerciseHelper('3', 'E3'),
          ]),
        ],
      );
      final flat = w.flattenedExercises;
      expect(flat.length, 4);
      expect(flat[0].id, '1');
      expect(flat[1] is Superset, true);
      expect(flat[2].id, '2');
      expect(flat[3].id, '3');
    });

    test('exerciseAt', () {
      final exercises = [
        exerciseHelper('1', 'E1'),
        supersetHelper('ss', exercises: [
          exerciseHelper('2', 'E2'),
          exerciseHelper('3', 'E3'),
        ]),
      ];
      expect(exercises.exerciseAt((exerciseIndex: 0, supersetIndex: null))?.id,
          '1');
      expect(
          exercises.exerciseAt((exerciseIndex: 0, supersetIndex: 1))?.id, '2');
      expect(
          exercises.exerciseAt((exerciseIndex: 1, supersetIndex: 1))?.id, '3');
    });
  });

  group('GTSetUtils extension', () {
    test('getHumanReadableDescription repsWeight', () {
      final set = GTSet(
        reps: 10,
        weight: 80.0,
        time: Duration.zero,
        parameters: GTSetParameters.repsWeight,
        kind: GTSetKind.normal,
      );
      final desc = set.getHumanReadableDescription(
        weightUnit: Weights.kg,
        distanceUnit: Distance.km,
      );
      expect(desc.contains('10 reps'), true);
      expect(desc.contains('80 kg') || desc.contains('80'), true);
    });
  });
}
