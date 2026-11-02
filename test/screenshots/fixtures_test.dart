// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/service/database.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import '../../integration_test/screenshots/fixtures.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['it', 'en']) {
    test('screenshot fixtures persist a coherent $locale story', () async {
      final temp = await Directory.systemTemp.createTemp(
        'screenshot-fixtures-',
      );
      final originalPaths = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _Paths(temp.path);
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      final service = DatabaseService.withDatabase(db);
      await service.ensureInitialized();
      try {
        final fixture = ScreenshotFixtures(
          locale,
          DateTime(2026, 11, 1, 9, 41),
        );
        await fixture.seed(service);
        final history = await db.getAllHistoryWorkouts().first;
        expect(history, hasLength(36));
        expect(history.map((w) => w.id).toSet(), hasLength(36));
        expect(history.every((w) => w.doneSets.length == 9), isTrue);
        expect(await db.watchWeightMeasurements().first, hasLength(12));
        final measurements = await db.watchBodyMeasurements().first;
        for (final part in BodyMeasurementPart.values) {
          expect(measurements.where((m) => m.type == part), hasLength(12));
        }
        expect(await db.watchRoutineFolders().first, hasLength(2));
        expect(fixture.routines.where((r) => r.folder != null), hasLength(2));
        final foods = await service.foods$.stream.firstWhere(
          (rows) => rows.length == 56,
        );
        final completions = fixture.completions(foods);
        expect(
          completions.where((c) => c.achievementID == 'firstSteps'),
          hasLength(3),
        );
        expect(
          completions
              .where((c) => c.achievementID == 'foodWatcher')
              .map((c) => c.level),
          containsAll([1, 2]),
        );
        expect(fixture.routines, hasLength(3));
        expect(fixture.trainer.controls, contains(fixture.routines.first.id));
      } finally {
        service.dispose();
        await db.close();
        PathProviderPlatform.instance = originalPaths;
        await temp.delete(recursive: true);
      }
    });
  }
}
