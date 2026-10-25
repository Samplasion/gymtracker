import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/mcp_catalog_migrations.dart';

void main() {
  late Directory directory;
  setUp(() => directory = Directory.systemTemp.createTempSync('mcp-catalog-'));
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'migration name uses current date converted to UTC and padded fields',
    () {
      expect(
        catalogMigrationPath(DateTime.parse('2026-10-25T09:03:04+02:00')),
        'supabase/migrations/20261025070304_mcp_catalog.sql',
      );
    },
  );

  test(
    'check selects latest generated catalog regardless of filename suffix',
    () {
      File(
        '${directory.path}/20261023101000_mcp_catalog.sql',
      ).writeAsStringSync('$catalogMigrationHeader\noriginal');
      final latest = File('${directory.path}/20261025170000_upright_bike.sql')
        ..writeAsStringSync('$catalogMigrationHeader\nlatest');
      File(
        '${directory.path}/20261026170000_unrelated.sql',
      ).writeAsStringSync('-- unrelated migration');
      expect(
        latestCatalogMigration(directory: directory.path).path,
        latest.path,
      );
    },
  );

  test(
    'export never overwrites an existing migration with different content',
    () {
      final file = File('${directory.path}/20261025170000_mcp_catalog.sql');
      writeCatalogMigration(file, 'original');
      writeCatalogMigration(file, 'original');
      expect(() => writeCatalogMigration(file, 'changed'), throwsStateError);
      expect(file.readAsStringSync(), 'original');
    },
  );

  test('check fails when no generated catalog migration exists', () {
    expect(
      () => latestCatalogMigration(directory: directory.path),
      throwsStateError,
    );
  });
}
