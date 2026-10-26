import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageByteFormat;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/repository/progress_report.dart';
import 'package:gymtracker/service/progress_report_export.dart';
import 'package:gymtracker/service/progress_report_pdf.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/progress_reports.dart';
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';
import '../service/progress_report_test.dart' show reportBuilder;
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Printing extends PrintingPlatform {
  @override
  Future<PrintingInfo> info() async => const PrintingInfo(canRaster: true);
  @override
  Stream<PdfRaster> raster(
    Uint8List document,
    List<int>? pages,
    double dpi,
  ) async* {
    yield PdfRaster(1, 1, Uint8List.fromList([255, 255, 255, 255]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repository extends ProgressReportRepository {
  _Repository() : super(MockServices.database);
  final completer = Completer<void>();
  bool fail = false;
  int calls = 0;
  @override
  Future<ProgressReport> load(
    ReportRequest request, {
    required Translations translations,
    required String locale,
    required Prefs preferences,
    required DateTime generatedAt,
    required String? owner,
  }) async {
    calls++;
    await completer.future;
    if (fail) throw StateError('test');
    return reportBuilder(
      AppLocale.en,
    ).build(request, generatedAt: generatedAt, timeZone: 'Europe/Rome');
  }
}

class _Pdf extends ProgressReportPdf {
  @override
  Future<Uint8List> generate(ProgressReport report, Translations t) async =>
      Uint8List.fromList([37, 80, 68, 70]);
}

class _Export extends ProgressReportExport {
  int saves = 0, shares = 0;
  Uint8List? savedBytes, sharedBytes;
  bool fail = false;
  @override
  Future<bool> save(Uint8List bytes, String filename) async {
    saves++;
    savedBytes = bytes;
    if (fail) throw StateError('test');
    return false;
  }

  @override
  Future<void> share(Uint8List bytes, String filename, Rect origin) async {
    shares++;
    sharedBytes = bytes;
  }
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    final originalPrinting = PrintingPlatform.instance;
    PrintingPlatform.instance = _Printing();
    addTearDown(() => PrintingPlatform.instance = originalPrinting);
  });
  tearDown(MockServices.tearDown);
  testWidgets(
    'all selected by default, all seven combinations and empty validation',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(MockServices.database),
            appPreferencesProvider.overrideWith(
              (ref) => Stream.value(Prefs.defaultValue),
            ),
            reportOwnerProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const WidgetTestApp(child: ProgressReportsView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<ReportPeriodKind>>(
              find.byType(SegmentedButton<ReportPeriodKind>),
            )
            .selected,
        {ReportPeriodKind.month},
      );
      final chips = find.byType(FilterChip);
      for (var mask = 1; mask < 8; mask++) {
        for (var i = 0; i < 3; i++) {
          final desired = (mask & (1 << i)) != 0;
          if (tester.widget<FilterChip>(chips.at(i)).selected != desired) {
            await tester.ensureVisible(chips.at(i));
            await tester.tap(chips.at(i));
            await tester.pump();
          }
        }
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
      }
      for (var i = 0; i < 3; i++) {
        await tester.ensureVisible(chips.at(i));
        await tester.tap(chips.at(i));
        await tester.pump();
      }
      expect(find.text('Select at least one section.'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'loading errors can retry and option changes discard in-flight work',
    (tester) async {
      final repository = _Repository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(MockServices.database),
            appPreferencesProvider.overrideWith(
              (ref) => Stream.value(Prefs.defaultValue),
            ),
            reportOwnerProvider.overrideWith((ref) => Stream.value(null)),
            progressReportRepositoryProvider.overrideWithValue(repository),
            progressReportPdfProvider.overrideWithValue(_Pdf()),
          ],
          child: const WidgetTestApp(child: ProgressReportsView()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Preview report'));
      await tester.tap(find.text('Preview report'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.ensureVisible(find.text('Training'));
      await tester.tap(find.text('Training'));
      await tester.pump();
      repository.completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Save PDF'), findsNothing);
      repository.fail = true;
      await tester.ensureVisible(find.text('Preview report'));
      await tester.tap(find.text('Preview report'));
      await tester.pumpAndSettle();
      expect(
        find.text('Unable to generate the report. Please retry.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    },
  );
  testWidgets(
    'preview reuses bytes, save cancellation, export error and account invalidation',
    (tester) async {
      final repository = _Repository()..completer.complete();
      final exporter = _Export();
      final owners = StreamController<String?>();
      addTearDown(owners.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(MockServices.database),
            appPreferencesProvider.overrideWith(
              (ref) => Stream.value(Prefs.defaultValue),
            ),
            reportOwnerProvider.overrideWith((ref) => owners.stream),
            progressReportRepositoryProvider.overrideWithValue(repository),
            progressReportPdfProvider.overrideWithValue(_Pdf()),
            progressReportExportProvider.overrideWithValue(exporter),
          ],
          child: const WidgetTestApp(child: ProgressReportsView()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      owners.add(null);
      await tester.pump();
      await tester.ensureVisible(find.text('Preview report'));
      await tester.tap(find.text('Preview report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PdfPreview), findsOneWidget);
      await tester.ensureVisible(find.text('Save PDF'));
      await tester.tap(find.text('Save PDF'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(exporter.saves, 1);
      expect(find.text('PDF saved'), findsNothing);
      await tester.ensureVisible(find.text('Share'));
      await tester.tap(find.text('Share'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(exporter.shares, 1);
      expect(identical(exporter.savedBytes, exporter.sharedBytes), isTrue);
      exporter.fail = true;
      await tester.ensureVisible(find.text('Save PDF'));
      await tester.tap(find.text('Save PDF'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Unable to export the PDF. Please retry.'),
        findsOneWidget,
      );
      owners.add('another-account');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PdfPreview), findsNothing);
      expect(find.text('Save PDF'), findsNothing);
    },
  );
  testWidgets('compact landscape controls scroll without overflowing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(568, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWith(
            (ref) => Stream.value(Prefs.defaultValue),
          ),
          reportOwnerProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const WidgetTestApp(child: ProgressReportsView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('reference date is editable and determines day, week and month', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWith(
            (ref) => Stream.value(Prefs.defaultValue),
          ),
          reportOwnerProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const WidgetTestApp(child: ProgressReportsView()),
      ),
    );
    await tester.pumpAndSettle();
    final dateField = find.byKey(const ValueKey('report-reference-date'));
    await tester.ensureVisible(dateField);
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(DateTime(2025, 2, 12));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('February 12, 2025'), findsOneWidget);
    String range() => tester
        .widget<Text>(find.byKey(const ValueKey('report-period-range')))
        .data!;
    expect(range(), 'Feb 1, 2025 – Feb 28, 2025');
    await tester.ensureVisible(find.text('Week'));
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(range(), 'Feb 9, 2025 – Feb 15, 2025');
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(range(), 'Feb 12, 2025');
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      DateTime(2025, 2, 12),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(range(), 'Feb 12, 2025');
  });
  testWidgets('configuration fits mobile and wide layouts', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      final font = FontLoader('ReportPreview')
        ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    await LocaleSettings.setLocale(AppLocale.it);
    addTearDown(() => LocaleSettings.setLocale(AppLocale.en));
    for (final size in [const Size(430, 1000), const Size(1200, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesProvider.overrideWith(
              (ref) => Stream.value(Prefs.defaultValue),
            ),
            reportOwnerProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: RepaintBoundary(
            key: const ValueKey('report-config-capture'),
            child: TranslationProvider(
              child: Builder(
                builder: (context) {
                  final theme = getGymTrackerThemeFor(
                    context,
                    const Color(0xff2196f3),
                    Brightness.light,
                  );
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    locale: const Locale('it'),
                    supportedLocales: const [Locale('it'), Locale('en')],
                    localizationsDelegates:
                        GlobalMaterialLocalizations.delegates,
                    theme: theme.copyWith(
                      chipTheme: theme.chipTheme.copyWith(
                        labelStyle: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: 'ReportPreview',
                        ),
                      ),
                      textTheme: theme.textTheme.apply(
                        fontFamily: 'ReportPreview',
                      ),
                      primaryTextTheme: theme.primaryTextTheme.apply(
                        fontFamily: 'ReportPreview',
                      ),
                    ),
                    home: const ProgressReportsView(),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(3));
      expect(tester.takeException(), isNull);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('report-config-capture')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.5);
        final data = await image.toByteData(format: ImageByteFormat.png);
        await File(
          '/tmp/gymbro-report-qa/config-${size.width.toInt()}.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
