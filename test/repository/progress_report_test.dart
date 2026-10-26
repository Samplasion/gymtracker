import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/repository/progress_report.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../service/progress_report_test.dart' show reportRequest;

void main() {
  setUpAll(() => initializeDateFormatting());
  late GTDatabaseImpl db;
  setUp(() => db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());
  test(
    'snapshot reads active owner records and excludes deleted entries',
    () async {
      for (final owner in ['a', 'b']) {
        db.setCurrentUserId(owner);
        await db.insertBodyMeasurement(
          BodyMeasurement.generateID(
            value: owner == 'a' ? 90 : 80,
            time: DateTime(2026, 10, 2),
            type: BodyMeasurementPart.waist,
          ),
        );
      }
      db.setCurrentUserId('a');
      final report = await ProgressReportRepository(db).load(
        reportRequest(sections: {ReportSection.measurements}),
        translations: AppLocale.it.buildSync(),
        locale: 'it',
        preferences: Prefs.defaultValue.copyWith(
          color: const Color(0xff7e57c2),
        ),
        generatedAt: DateTime(2026, 10, 25),
        owner: 'a',
      );
      expect(report.accentColor, 0xff7e57c2);
      expect(report.days[1].measurementCount, 1);
      expect(report.days[1].tables.single.rows.single.last, '90 cm');
    },
  );
  test(
    'rejects account mismatch rather than exporting another account',
    () async {
      db.setCurrentUserId('b');
      await expectLater(
        ProgressReportRepository(db).load(
          reportRequest(),
          translations: AppLocale.en.buildSync(),
          locale: 'en',
          preferences: Prefs.defaultValue,
          generatedAt: DateTime(2026, 10, 25),
          owner: 'a',
        ),
        throwsStateError,
      );
    },
  );
  test(
    'account transitions include returning to the original identity',
    () async {
      final events = <String?>[];
      final subscription = db.watchCurrentUserId().listen(events.add);
      db.setCurrentUserId('a');
      db.setCurrentUserId('b');
      db.setCurrentUserId('a');
      await Future<void>.delayed(Duration.zero);
      expect(events, [null, 'a', 'b', 'a']);
      await subscription.cancel();
    },
  );
  test(
    'rejects an account switch even when the original account returns',
    () async {
      db.setCurrentUserId('a');
      final pending = ProgressReportRepository(db).load(
        reportRequest(),
        translations: AppLocale.en.buildSync(),
        locale: 'en',
        preferences: Prefs.defaultValue,
        generatedAt: DateTime(2026, 10, 25),
        owner: 'a',
      );
      db.setCurrentUserId('b');
      db.setCurrentUserId('a');
      await expectLater(pending, throwsStateError);
    },
  );
}
