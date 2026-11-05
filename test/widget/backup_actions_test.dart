import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  final backup = DatabaseBackup(
    DateTime(2026, 11, 4),
    File('/tmp/test-backup.db'),
    1024,
  );
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });
  tearDown(MockServices.tearDown);
  Future<void> open(
    WidgetTester tester,
    Stream<List<DatabaseBackup>> stream,
  ) async {
    when(
      () => MockServices.databaseService.listBackups(),
    ).thenAnswer((_) => stream);
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: BackupListView()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'backup list reports load errors without offering destructive actions',
    (tester) async {
      await open(tester, Stream.error(StateError('backup unavailable')));
      expect(find.textContaining('backup unavailable'), findsOneWidget);
      expect(find.byIcon(GTIcons.delete), findsNothing);
    },
  );
  testWidgets('empty backup list still offers creation', (tester) async {
    await open(tester, Stream.value([]));
    expect(
      find.text(t.settings.advanced.options.backups.create),
      findsOneWidget,
    );
    expect(find.byIcon(GTIcons.delete), findsNothing);
  });
  for (final failCreate in [false, true]) {
    testWidgets(
      'create backup ${failCreate ? 'reports failure' : 'succeeds'}',
      (tester) async {
        when(() => MockServices.databaseService.createBackup()).thenAnswer((
          _,
        ) async {
          if (failCreate) throw StateError('disk full');
        });
        await open(tester, Stream.value([]));
        await tester.tap(find.text(t.settings.advanced.options.backups.create));
        await tester.pumpAndSettle();
        verify(() => MockServices.databaseService.createBackup()).called(1);
        expect(
          find.textContaining('disk full'),
          failCreate ? findsWidgets : findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('cancel backup deletion leaves the backup untouched', (
    tester,
  ) async {
    await open(tester, Stream.value([backup]));
    await tester.tap(find.byIcon(GTIcons.delete));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => MockServices.databaseService.deleteBackup(backup));
    expect(find.byIcon(GTIcons.delete), findsOneWidget);
  });
}
