import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/suggested_routines_carousel.dart';

import '../helpers.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  final captureKey = GlobalKey();
  final routines = [
    exerciseRoutine('push', 'Push · Strength'),
    exerciseRoutine(
      'pull',
      'Pull · Control',
      description: '[{"insert":"Technique and control\\n"}]',
    ),
    exerciseRoutine('legs', 'Legs · Power'),
  ];
  const trainer = TrainerState(
    controls: {'push'},
    link: {'trainer_name': 'Alex Morgan'},
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (Platform.environment['FEED_CAROUSEL_PREVIEW'] != null) {
      final font = FontLoader('Manrope')
        ..addFont(rootBundle.load('fonts/Manrope.ttf'));
      await font.load();
    }
  });
  setUp(initTestLocalizations);

  Future<void> mount(
    WidgetTester tester, {
    List<Workout>? items,
    TrainerState assigned = trainer,
    ValueChanged<Workout>? onStart,
    ValueChanged<Workout>? onOpen,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      WidgetTestApp(
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
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SuggestedRoutinesCarousel(
                          routines: items ?? routines,
                          trainer: assigned,
                          onStart: onStart ?? (_) {},
                          onOpen: onOpen ?? (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'assigned trainer, rich description and emphasis use real routine data',
    (tester) async {
      await mount(tester);
      expect(find.text('Suggested routines'), findsOneWidget);
      expect(find.text('Assigned by Alex Morgan'), findsOneWidget);
      expect(find.text('Technique and control'), findsOneWidget);
      expect(find.textContaining('"insert"'), findsNothing);
      final first = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const ValueKey('suggested-routine-push')),
              matching: find.byType(Material),
            )
            .first,
      );
      final next = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const ValueKey('suggested-routine-pull')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(first.color, isNot(next.color));
    },
  );

  testWidgets(
    'Start uses the matching routine and the card opens its details',
    (tester) async {
      final started = <Workout>[];
      final opened = <Workout>[];
      await mount(tester, onStart: started.add, onOpen: opened.add);
      await tester.tap(
        find.byKey(const ValueKey('start-suggested-routine-push')),
      );
      expect(started, [routines.first]);
      expect(opened, isEmpty);
      await tester.tap(find.text('Pull · Control'));
      expect(opened, [routines[1]]);
      final strip = find.byKey(
        const PageStorageKey('suggested-routines-carousel'),
      );
      await tester.drag(strip, const Offset(-350, 0));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('start-suggested-routine-legs')),
      );
      expect(started, [routines.first, routines.last]);
    },
  );

  testWidgets(
    'empty suggestions hide the section; missing trainer name has a truthful fallback',
    (tester) async {
      await mount(tester, items: []);
      expect(find.text('Suggested routines'), findsNothing);
      await mount(tester, assigned: const TrainerState(controls: {'push'}));
      expect(find.text('Assigned by your trainer'), findsOneWidget);
      expect(find.textContaining('Alex'), findsNothing);
    },
  );

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 390.0, 800.0]) {
      testWidgets(
        'carousel fits $width in $brightness with enlarged text and safe insets',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          tester.view.padding = const FakeViewPadding(left: 12, right: 12);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await mount(
            tester,
            brightness: brightness,
            items: [
              exerciseRoutine(
                'push',
                'A long suggested workout title that should stay readable',
              ),
              routines[1],
            ],
          );
          expect(tester.takeException(), isNull);
          final strip = tester.getRect(
            find.byKey(const PageStorageKey('suggested-routines-carousel')),
          );
          expect(strip.left, 12);
          expect(strip.right, width - 12);
          await tester.drag(
            find.byKey(const PageStorageKey('suggested-routines-carousel')),
            const Offset(-300, 0),
          );
          await tester.pumpAndSettle();
          expect(
            find
                .byKey(const ValueKey('start-suggested-routine-pull'))
                .hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets('preview $brightness', (tester) async {
      tester.view.physicalSize = const Size(390, 270);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      LocaleSettings.setLocaleSync(AppLocale.it);
      addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
      await mount(tester, brightness: brightness);
      await tester.pumpAndSettle();
      final output = Platform.environment['FEED_CAROUSEL_PREVIEW'];
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
    });
  }
}

Workout exerciseRoutine(String id, String name, {String? description}) =>
    Workout(
      id: id,
      name: name,
      infobox: description,
      exercises: [exerciseHelper('exercise-$id', 'Bench press')],
    );
