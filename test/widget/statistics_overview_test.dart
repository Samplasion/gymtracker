import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/me/statistics.dart';
import 'package:gymtracker/view/me/statistics_overview.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

List<Workout> overviewHistory() {
  Workout workout(
    int day,
    String parent,
    String name,
    double weight,
    int reps, {
    int sets = 1,
  }) => Workout(
    id: '$parent-$day',
    name: name,
    startingDate: DateTime(2026, 10, day, 10),
    duration: const Duration(minutes: 30),
    exercises: [
      exerciseHelper(
        '$parent-$day',
        name,
        sets: [
          for (var i = 0; i < sets; i++)
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsWeight,
              weight: weight,
              reps: reps,
              done: true,
            ),
        ],
      ).copyWith(parentID: parent),
    ],
  );
  return [
    workout(25, 'squat', 'Barbell squat', 92.5, 8),
    workout(26, 'bench', 'Panca piana', 72.5, 8),
    workout(27, 'squat', 'Barbell squat', 80, 8),
    workout(29, 'bench', 'Panca piana', 60, 10),
    workout(30, 'squat', 'Barbell squat', 80, 9),
    workout(
      31,
      'bench',
      'Panca piana',
      60,
      10,
      sets: 2,
    ).copyWith(startingDate: DateTime(2026, 10, 31, 10)),
    workout(32, 'squat', 'Barbell squat', 80, 10),
  ];
}

void main() {
  late ProviderContainer container;
  var disposed = false;
  late BehaviorSubject<List<Workout>> history;
  late BehaviorSubject<Prefs> preferences;
  final captureKey = GlobalKey();
  final now = DateTime(2026, 11, 1, 18);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('it');
    if (Platform.environment['PROGRESS_OVERVIEW_PREVIEW'] != null) {
      final font = FontLoader('Manrope')
        ..addFont(rootBundle.load('fonts/Manrope.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });
  setUp(() async {
    MockServices.setup();
    disposed = false;
    await initTestLocalizations();
    history = BehaviorSubject.seeded(overviewHistory());
    preferences = BehaviorSubject.seeded(Prefs.defaultValue);
    when(
      () => MockServices.historyController.history,
    ).thenReturn(overviewHistory());
    when(() => MockServices.exercisesController.exercises).thenReturn([]);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        ...MockServices.defaultOverrides.where(
          (override) => override.origin != appPreferencesProvider,
        ),
        historyWorkoutsProvider.overrideWith((ref) => history.stream),
        appPreferencesProvider.overrideWith((ref) => preferences.stream),
        trainingClockProvider.overrideWithValue(() => now),
      ],
    );
  });
  tearDown(() async {
    if (!disposed) container.dispose();
    await history.close();
    await preferences.close();
    MockServices.tearDown();
  });

  Future<void> mount(
    WidgetTester tester, {
    bool page = false,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: WidgetTestApp(
          child: Builder(
            builder: (context) {
              final theme = getGymTrackerThemeFor(
                context,
                const Color(0xff244a9e),
                brightness,
              );
              return Theme(
                data: theme,
                child: RepaintBoundary(
                  key: captureKey,
                  child: Material(
                    color: theme.scaffoldBackgroundColor,
                    child: page
                        ? const MeStatisticsPage()
                        : const StatisticsOverviewTab(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    disposed = true;
  }

  testWidgets(
    'At a glance is the weekly overview; the existing dashboard is the next Metrics tab',
    (tester) async {
      await mount(tester, page: true);
      final bar = tester.widget<TabBar>(find.byType(TabBar));
      expect(bar.tabs.whereType<Tab>().map((tab) => tab.text).take(2), [
        'At a glance',
        'Metrics',
      ]);
      expect(bar.tabs.length, 6);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Personal records'), findsOneWidget);
      expect(find.byType(SpeedDial), findsNothing);
      await tester.tap(find.text('Metrics'));
      await tester.pumpAndSettle();
      expect(find.byType(SpeedDial), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<TimeFrame>), findsOneWidget);
      await tester.tap(find.text('At a glance'));
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'records show actual load, reps and dates; changes to units update them',
    (tester) async {
      await mount(tester);
      expect(find.text('72.5 kg × 8'), findsOneWidget);
      expect(find.text('92.5 kg × 8'), findsOneWidget);
      expect(find.text('Oct 26, 2026'), findsOneWidget);
      preferences.add(Prefs.defaultValue.copyWith(weightUnit: Weights.lb));
      await tester.pumpAndSettle();
      expect(find.text('159.84 lbs × 8'), findsOneWidget);
      expect(find.text('203.93 lbs × 8'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'empty history retains seven baseline bars and useful empty states',
    (tester) async {
      history.add([]);
      await mount(tester);
      expect(find.text('No volume recorded this week.'), findsOneWidget);
      expect(
        find.text(
          'Complete a set with weight and repetitions to see your personal records.',
        ),
        findsOneWidget,
      );
      expect(find.text('Panca piana'), findsNothing);
      final bars = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'weekly-volume-',
            ),
      );
      expect(bars, findsNWidgets(7));
      for (final element in bars.evaluate()) {
        expect(tester.getSize(find.byWidget(element.widget)).height, 6);
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'load errors hide technical details and retry reloads the overview',
    (tester) async {
      container.dispose();
      var attempts = 0;
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          ...MockServices.defaultOverrides,
          trainingClockProvider.overrideWithValue(() => now),
          historyWorkoutsProvider.overrideWith((ref) {
            attempts++;
            return attempts == 1
                ? Stream.error(StateError('private database detail'))
                : Stream.value(overviewHistory());
          }),
        ],
      );
      await mount(tester);
      expect(find.text('Unable to load progress'), findsOneWidget);
      expect(find.textContaining('private'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Personal records'), findsOneWidget);
      expect(find.text('Unable to load progress'), findsNothing);
      expect(attempts, 2);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 390.0, 800.0]) {
      testWidgets(
        'overview fits $width in $brightness with large text and safe areas',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(
            left: 12,
            right: 12,
            bottom: 34,
          );
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await mount(tester, brightness: brightness);
          final scroll = find.byKey(
            const PageStorageKey('statistics-overview-scroll'),
          );
          expect(tester.getRect(scroll).left, 12);
          expect(tester.getRect(scroll).right, width - 12);
          await tester.drag(scroll, const Offset(0, -600));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await unmount(tester);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets('preview $brightness', (tester) async {
      tester.view.physicalSize = const Size(390, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      LocaleSettings.setLocaleSync(AppLocale.it);
      addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
      await mount(tester, brightness: brightness);
      final output = Platform.environment['PROGRESS_OVERVIEW_PREVIEW'];
      if (output != null) {
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$output-${brightness.name}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
