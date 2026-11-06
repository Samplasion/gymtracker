import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _TestClock extends WorkoutClock {
  DateTime time = DateTime.utc(2026, 11, 5, 12);
  @override
  DateTime now() => time;
  void advance(Duration duration) => time = time.add(duration);
}

void main() {
  late WorkoutController controller;
  late _TestClock clock;
  late StreamController<double?> heart;
  late StreamController<double?> energy;
  final captureKey = GlobalKey();

  setUpAll(() async {
    registerFallbackValue(exerciseHelper('fallback', 'Fallback'));
    if (Platform.environment['WORKOUT_SIMPLE_PREVIEW'] != null) {
      final appIcons = FontLoader('GymTracker')
        ..addFont(rootBundle.load('fonts/GymTracker.ttf'));
      await appIcons.load();
      for (final entry in {
        'Roboto': 'Roboto-Regular.ttf',
        'MaterialIcons': 'MaterialIcons-Regular.otf',
      }.entries) {
        final font = FontLoader(entry.key)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File(
                  '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/${entry.value}',
                ).readAsBytes(),
              ),
            ),
          );
        await font.load();
      }
    }
  });
  setUp(() async {
    MockServices.setup();
    MockServices.container.dispose();
    clock = _TestClock();
    heart = StreamController<double?>.broadcast();
    energy = StreamController<double?>.broadcast();
    MockServices.container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        workoutClockProvider.overrideWithValue(clock),
        healthHeartRateProvider.overrideWith((ref) => heart.stream),
        healthEnergyProvider.overrideWith((ref) => energy.stream),
      ],
    );
    when(() => MockServices.exercisesController.exercises).thenReturn([]);
    when(
      () => MockServices.historyController.getHistoryOf(any()),
    ).thenReturn([]);
    await initTestLocalizations();
    controller = MockServices.createWorkout('Push · Strength', null, null);
    controller.setExercises([
      exerciseHelper(
        'bench',
        'Bench press',
        sets: [
          for (var i = 0; i < 3; i++)
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsWeight,
              weight: 72.5,
              reps: 8,
            ),
        ],
      ),
      exerciseHelper('squat', 'Barbell squat'),
    ]);
  });
  tearDown(() async {
    MockServices.tearDown();
    unawaited(heart.close());
    unawaited(energy.close());
  });

  Future<void> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    final theme = ThemeData(
      platform: platform,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff2854b2),
        brightness: brightness,
      ),
    );
    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: Theme(
          data: theme.copyWith(
            extensions: [MoreColors.fromColorScheme(theme.colorScheme)],
          ),
          child: RepaintBoundary(
            key: captureKey,
            child: const WorkoutSimpleView(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  GTSet getSet([int index = 0]) =>
      (controller.exercises.first as Exercise).sets[index];

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<void> unmount(WidgetTester tester) async {
    MockServices.container
        .read(countdownControllerProvider.notifier)
        .removeCountdown();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets(
    'real title, exercise count and health metrics including absent and failed data',
    (tester) async {
      await mount(tester);
      expect(find.text('Push · Strength'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(2));
      heart.add(132);
      energy.add(164);
      await tester.pump();
      await tester.pump();
      expect(find.text('132'), findsOneWidget);
      expect(find.text('164'), findsOneWidget);
      heart.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.text('—'), findsOneWidget);
      energy.addError(StateError('unavailable'));
      await tester.pump();
      await tester.pump();
      expect(find.text('—'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  for (final unit in Weights.values) {
    testWidgets(
      'quick edits use ${unit.name} and keep precise editor accessible',
      (tester) async {
        controller.weightUnit = unit;
        await mount(tester);
        await tapVisible(tester, find.byTooltip('Increase Weight'));
        expect(getSet().weight, unit == Weights.kg ? 75 : 77.5);
        await tapVisible(tester, find.byTooltip('Decrease Weight'));
        expect(getSet().weight, 72.5);
        await tapVisible(tester, find.byTooltip('Increase Reps'));
        expect(getSet().reps, 9);
        await tapVisible(tester, find.byTooltip('Decrease Reps'));
        expect(getSet().reps, 8);
        expect(find.text('Edit set parameters'), findsNothing);
        await tapVisible(
          tester,
          find.byKey(const ValueKey('simple-weight-value')),
        );
        expect(find.byType(TextField), findsWidgets);
        await tester.enterText(find.byType(TextField).first, '80');
        expect(getSet().weight, 80);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );
  }

  testWidgets(
    'zero values cannot be decremented and assisted weight keeps its sign',
    (tester) async {
      controller.setExercises([
        exerciseHelper(
          'assisted',
          'Assisted',
          sets: [
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsNegWeight,
              weight: 0,
              reps: 0,
            ),
          ],
        ),
      ]);
      await mount(tester);
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byTooltip('Decrease Weight'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byTooltip('Decrease Reps'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
      await tapVisible(tester, find.byTooltip('Increase Weight'));
      expect(getSet().weight, 2.5);
      expect(getSet().effectiveWeight, -2.5);
      await tapVisible(tester, find.byTooltip('Decrease Weight'));
      expect(getSet().weight, 0);
      await unmount(tester);
    },
  );

  testWidgets(
    'select, complete and edit the next set during rest; skip and expiry',
    (tester) async {
      await mount(tester);
      await tapVisible(tester, find.byKey(const ValueKey('simple-set-1')));
      expect(controller.currentSetCursor?.setIndex, 1);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('complete-simple-set')),
      );
      expect(getSet(1).done, isTrue);
      expect(controller.currentSetCursor?.setIndex, 2);
      final countdown = MockServices.container.read(
        countdownControllerProvider.notifier,
      );
      expect(countdown.isActive, isTrue);
      expect(find.byKey(const ValueKey('complete-simple-set')), findsOneWidget);
      await tapVisible(tester, find.byTooltip('Increase Weight'));
      expect(getSet(2).weight, 75);
      final target = countdown.targetTime!;
      await tapVisible(tester, find.text('+15s'));
      expect(countdown.targetTime, target.add(const Duration(seconds: 15)));
      await tapVisible(tester, find.text('-15s'));
      expect(countdown.targetTime, target);
      await tapVisible(tester, find.text('Skip'));
      expect(countdown.isActive, isFalse);
      countdown.setCountdown(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(countdown.isActive, isFalse);
      expect(find.byKey(const ValueKey('complete-simple-set')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'expanded notes survive set changes and rest, reset for another exercise',
    (tester) async {
      await mount(tester);
      final notes = find.widgetWithText(ExpansionTile, 'Notes');
      await tapVisible(tester, notes);
      expect(find.text('Some notes'), findsNWidgets(2));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('complete-simple-set')),
      );
      expect(find.text('Some notes'), findsNWidgets(2));
      controller.selectSetCursorByIndex((
        exerciseIndex: 1,
        supersetIndex: null,
      ), 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Some notes'), findsOneWidget); // collapsed preview only
      expect(find.text('2 of 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'superset members count separately and special set types render',
    (tester) async {
      controller.setExercises([
        supersetHelper(
          'group',
          exercises: [
            exerciseHelper(
              'warm',
              'Warm up',
              sets: [
                GTSet.empty(
                  kind: GTSetKind.warmUp,
                  parameters: GTSetParameters.repsWeight,
                ),
              ],
            ),
            exerciseHelper(
              'drop',
              'Drop',
              sets: [
                GTSet.empty(
                  kind: GTSetKind.drop,
                  parameters: GTSetParameters.repsWeight,
                ),
              ],
            ),
          ],
        ),
      ]);
      await mount(tester);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('Superset notes'), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('complete-simple-set')),
      );
      expect(find.text('2 of 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  for (final parameters in GTSetParameters.values) {
    testWidgets('supports ${parameters.name} without irrelevant controls', (
      tester,
    ) async {
      controller.setExercises([
        exerciseHelper('alternative', 'Alternative', parameters: parameters),
      ]);
      await mount(tester);
      if (!parameters.isSetless) {
        expect(
          find.byTooltip('Increase Weight'),
          parameters.hasWeight && !parameters.hasTime
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.byTooltip('Increase Reps'),
          parameters.hasReps ? findsOneWidget : findsNothing,
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('complete-simple-set')),
        );
        expect(find.byKey(const ValueKey('complete-simple-set')), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 390.0, 800.0]) {
      testWidgets('responsive $brightness layout at $width and enlarged text', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        controller.setName('Push · Strength · A long workout title that wraps');
        controller.setExercises([
          exerciseHelper(
            'long',
            'An exercise with a very long descriptive name',
          ),
        ]);
        await mount(tester, brightness: brightness);
        final countdown = MockServices.container.read(
          countdownControllerProvider.notifier,
        );
        countdown.setCountdown(const Duration(seconds: 60));
        await tester.pump();
        await tester.ensureVisible(
          find.byKey(const ValueKey('complete-simple-set')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
  }

  testWidgets(
    'empty workout, fallback title and completion have dedicated actions',
    (tester) async {
      controller.setName('');
      controller.setExercises([]);
      await mount(tester);
      expect(find.text('Ready to train?'), findsOneWidget);
      expect(find.text('Workout'), findsNWidgets(2));
      controller.setExercises([exerciseHelper('last', 'Last exercise')]);
      await tester.pump();
      await tapVisible(
        tester,
        find.byKey(const ValueKey('complete-simple-set')),
      );
      expect(find.text('Workout complete'), findsOneWidget);
      expect(find.text('Finish workout'), findsOneWidget);
      expect(find.byKey(const ValueKey('complete-simple-set')), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'RPE icon uses the selected effort color and navigation uses tonal buttons',
    (tester) async {
      controller.onSetChangeRPE((exerciseIndex: 0, supersetIndex: null), 0, 8);
      await mount(tester);
      final icon = find.descendant(
        of: find.widgetWithText(TextButton, 'RPE 8'),
        matching: find.byType(Icon),
      );
      final context = tester.element(icon);
      expect(IconTheme.of(context).color, rpeColor(context, 8));
      for (final label in ['Previous set', 'Next set']) {
        final navigation = find.descendant(
          of: find.byTooltip(label),
          matching: find.byType(FilledButton),
        );
        expect(navigation, findsOneWidget);
      }
      await unmount(tester);
    },
  );

  testWidgets('set strip scrolls and accepts taps outside the content inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester);
    final strip = find.byKey(const ValueKey('simple-set-strip'));
    expect(tester.getRect(strip).left, 0);
    expect(tester.getRect(strip).width, 390);
    await tester.drag(strip, const Offset(-60, 0));
    await tester.pump();
    final button = find.byKey(const ValueKey('simple-set-0'));
    expect(tester.getRect(button).left, lessThan(0));
    final edge = Offset(8, tester.getCenter(strip).dy);
    final target = tester.renderObject(button);
    expect(
      tester.hitTestOnBinding(edge).path.any((entry) => entry.target == target),
      isTrue,
    );
    await tester.tapAt(edge);
    await tester.pump();
    expect(controller.currentSetCursor?.setIndex, 0);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      '$platform overscroll keeps cards rigid and preserves native physics',
      (tester) async {
        await mount(tester, platform: platform);
        final scroll = find.byKey(const ValueKey('simple-workout-scroll'));
        final scrollable = find
            .descendant(of: scroll, matching: find.byType(Scrollable))
            .first;
        final state = tester.state<ScrollableState>(scrollable);
        expect(
          state.position.physics.applyBoundaryConditions(state.position, -20),
          platform == TargetPlatform.iOS ? 0 : -20,
        );
        expect(find.byType(StretchingOverscrollIndicator), findsNothing);
        final card = find.byKey(const ValueKey('complete-simple-set'));
        final size = tester.getSize(card);
        await tester.drag(scroll, const Offset(0, 160));
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getSize(card), size);
        var previous = state.position.pixels;
        for (var frame = 0; frame < 60; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(state.position.pixels, greaterThanOrEqualTo(previous - .01));
          previous = state.position.pixels;
        }
        expect(state.position.pixels, closeTo(0, .1));
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );
  }

  for (final locale in [AppLocale.en, AppLocale.it]) {
    for (final width in [320.0, 390.0, 800.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '1000-hour recovery has stable controls: $locale, width $width, text $scale',
          (tester) async {
            LocaleSettings.setLocaleSync(locale);
            addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            await mount(tester);
            final countdown = MockServices.container.read(
              countdownControllerProvider.notifier,
            );
            for (final hours in [1000, 9999]) {
              countdown.setCountdown(Duration(hours: hours, seconds: 5));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 250));
              final buttons = [
                for (final action in ['subtract', 'add', 'skip'])
                  find.byKey(ValueKey('simple-rest-$action')),
              ];
              final before = [
                for (final button in buttons) tester.getRect(button),
              ];
              expect(find.text('$hours:00:06'), findsOneWidget);
              clock.advance(const Duration(seconds: 7));
              await tester.pump(const Duration(seconds: 7));
              expect(find.text('${hours - 1}:59:59'), findsOneWidget);
              for (var i = 0; i < buttons.length; i++) {
                final rect = tester.getRect(buttons[i]);
                expect(rect, before[i]);
                expect(rect.left, greaterThanOrEqualTo(0));
                expect(rect.right, lessThanOrEqualTo(width));
                expect(rect.bottom, lessThanOrEqualTo(1000));
                expect(buttons[i].hitTestable(), findsOneWidget);
              }
              await tester.tap(buttons[1]);
              await tester.pump();
              await tester.tap(buttons[0]);
              await tester.pump();
              expect(tester.takeException(), isNull);
            }
            await tester.tap(find.byKey(const ValueKey('simple-rest-skip')));
            await tester.pump();
            expect(countdown.isActive, isFalse);
            await unmount(tester);
          },
        );
      }
    }
  }

  SlideTransition setSlide(WidgetTester tester) =>
      tester.widget<SlideTransition>(
        find
            .descendant(
              of: find.byKey(const ValueKey('simple-set-transition')),
              matching: find.byType(SlideTransition),
            )
            .first,
      );

  FadeTransition setFade(WidgetTester tester) => tester.widget<FadeTransition>(
    find
        .descendant(
          of: find.byKey(const ValueKey('simple-set-transition')),
          matching: find.byType(FadeTransition),
        )
        .first,
  );

  double workoutProgress(WidgetTester tester) => tester
      .widget<LinearProgressIndicator>(
        find.descendant(
          of: find.byKey(const ValueKey('simple-workout-progress')),
          matching: find.byType(LinearProgressIndicator),
        ),
      )
      .value!;

  testWidgets(
    'set changes animate in the navigation direction without outgoing controls',
    (tester) async {
      await mount(tester);
      expect(setSlide(tester).position.value, Offset.zero);
      controller.moveSetCursorToNext();
      await tester.pump();
      final start = setSlide(tester).position.value.dx;
      expect(start, greaterThan(0));
      expect(setFade(tester).opacity.value, lessThan(1));
      expect(find.byKey(const ValueKey('complete-simple-set')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 110));
      expect(setSlide(tester).position.value.dx, inExclusiveRange(0, start));
      await tester.pump(const Duration(milliseconds: 150));
      expect(setSlide(tester).position.value, Offset.zero);
      controller.moveSetCursorToPrevious();
      await tester.pump();
      expect(setSlide(tester).position.value.dx, lessThan(0));
      controller.moveSetCursorToNext();
      controller.moveSetCursorToNext();
      await tester.pump();
      expect(find.text('Set 3 of 3'), findsOneWidget);
      expect(find.byKey(const ValueKey('complete-simple-set')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      expect(setSlide(tester).position.value, Offset.zero);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('transition direction follows interleaved superset order', (
    tester,
  ) async {
    controller.setExercises([
      supersetHelper(
        'group',
        exercises: [
          for (final id in ['a', 'b'])
            exerciseHelper(
              id,
              'Exercise $id',
              sets: [
                for (var i = 0; i < 2; i++)
                  GTSet.empty(
                    kind: GTSetKind.normal,
                    parameters: GTSetParameters.repsWeight,
                  ),
              ],
            ),
        ],
      ),
    ]);
    await mount(tester);
    controller.selectSetCursorByIndex((exerciseIndex: 1, supersetIndex: 0), 0);
    await tester.pump();
    expect(setSlide(tester).position.value.dx, greaterThan(0));
    controller.selectSetCursorByIndex((exerciseIndex: 0, supersetIndex: 0), 1);
    await tester.pump();
    expect(setSlide(tester).position.value.dx, greaterThan(0));
    controller.selectSetCursorByIndex((exerciseIndex: 1, supersetIndex: 0), 0);
    await tester.pump();
    expect(setSlide(tester).position.value.dx, lessThan(0));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
    'completion progress and edited values animate without delaying their data',
    (tester) async {
      await mount(tester);
      expect(workoutProgress(tester), 0);
      controller.autoMarkNextSetDone();
      await tester.pump();
      expect(getSet().done, isTrue);
      expect(controller.currentSetCursor?.setIndex, 1);
      expect(workoutProgress(tester), lessThan(controller.progress));
      await tester.pump(const Duration(milliseconds: 110));
      expect(workoutProgress(tester), inExclusiveRange(0, controller.progress));
      await tester.pump(const Duration(milliseconds: 150));
      expect(workoutProgress(tester), closeTo(controller.progress, .0001));
      controller.onSetValueChange(
        (exerciseIndex: 0, supersetIndex: null),
        1,
        getSet(1).copyWith(weight: 75),
      );
      await tester.pump();
      final fade = find.descendant(
        of: find.byKey(const ValueKey('simple-weight-value')),
        matching: find.byType(FadeTransition),
      );
      expect(getSet(1).weight, 75);
      expect(tester.widget<FadeTransition>(fade).opacity.value, lessThan(1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'rest expands and collapses while retaining its bottom safe area',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await mount(tester);
      final panel = find.byKey(const ValueKey('simple-rest-panel'));
      expect(tester.getSize(panel).height, 34);
      final countdown = MockServices.container.read(
        countdownControllerProvider.notifier,
      );
      countdown.setCountdown(const Duration(minutes: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final middle = tester.getSize(panel).height;
      expect(middle, greaterThan(34));
      expect(
        tester
            .getRect(find.byKey(const ValueKey('simple-workout-scroll')))
            .bottom,
        lessThanOrEqualTo(810),
      );
      final skip = find.byKey(const ValueKey('simple-rest-skip'));
      final unsafePoint = Offset(tester.getCenter(skip).dx, 830);
      expect(
        tester
            .hitTestOnBinding(unsafePoint)
            .path
            .any((entry) => entry.target == tester.renderObject(skip)),
        isFalse,
      );
      await tester.pump(const Duration(milliseconds: 150));
      final expanded = tester.getSize(panel).height;
      expect(expanded, greaterThan(middle));
      expect(tester.getRect(skip).bottom, lessThanOrEqualTo(810));
      countdown.removeCountdown();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      expect(tester.getSize(panel).height, inExclusiveRange(34, expanded));
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.getSize(panel).height, 34);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('simple-workout-scroll')))
            .bottom,
        810,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'reduced motion presents new sets, progress and rest immediately',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await mount(tester);
      controller.moveSetCursorToNext();
      await tester.pump();
      expect(setSlide(tester).position.value, Offset.zero);
      expect(setFade(tester).opacity.value, 1);
      controller.autoMarkNextSetDone();
      await tester.pump();
      expect(workoutProgress(tester), controller.progress);
      expect(setSlide(tester).position.value, Offset.zero);
      expect(setFade(tester).opacity.value, 1);
      final panel = find.byKey(const ValueKey('simple-rest-panel'));
      expect(tester.getSize(panel).height, greaterThan(48));
      final countdown = MockServices.container.read(
        countdownControllerProvider.notifier,
      );
      countdown.removeCountdown();
      await tester.pump();
      expect(tester.getSize(panel).height, 0);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('enabling reduced motion finishes an in-flight transition', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await mount(tester);
    controller.moveSetCursorToNext();
    await tester.pump();
    expect(setFade(tester).opacity.value, lessThan(1));
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    expect(setFade(tester).opacity.value, 1);
    expect(setSlide(tester).position.value, Offset.zero);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  for (final landscape in [false, true]) {
    testWidgets(
      'safe areas protect content before, during and after rest (${landscape ? 'landscape' : 'portrait'})',
      (tester) async {
        final size = landscape ? const Size(844, 390) : const Size(390, 844);
        final insets = landscape
            ? const FakeViewPadding(left: 44, right: 44, bottom: 21)
            : const FakeViewPadding(top: 47, bottom: 34);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = insets;
        tester.view.viewPadding = insets;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        controller.setExercises([exerciseHelper('safe', 'Exercise')]);
        await mount(tester, platform: TargetPlatform.iOS);
        final scroll = find.byKey(const ValueKey('simple-workout-scroll'));
        final strip = find.byKey(const ValueKey('simple-set-strip'));
        final safeBottom = size.height - insets.bottom;
        void expectScrollSafe({required bool rest}) {
          final rect = tester.getRect(scroll);
          expect(rect.top, greaterThanOrEqualTo(insets.top));
          expect(rect.left, closeTo(insets.left, .01));
          expect(rect.right, closeTo(size.width - insets.right, .01));
          expect(
            rect.bottom,
            rest ? lessThan(safeBottom) : closeTo(safeBottom, .01),
          );
          final stripRect = tester.getRect(strip);
          expect(stripRect.left, closeTo(insets.left, .01));
          expect(stripRect.right, closeTo(size.width - insets.right, .01));
        }

        expectScrollSafe(rest: false);
        final context = tester.element(find.byType(WorkoutSimpleView));
        final add = find.widgetWithText(
          TextButton,
          context.t.ongoingWorkout.exercises.add,
        );
        await tester.ensureVisible(add);
        await tester.pump();
        expect(tester.getRect(add).bottom, lessThanOrEqualTo(safeBottom));
        expect(add.hitTestable(), findsOneWidget);
        final countdown = MockServices.container.read(
          countdownControllerProvider.notifier,
        );
        countdown.setCountdown(const Duration(minutes: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expectScrollSafe(rest: true);
        for (final action in ['subtract', 'add', 'skip']) {
          final rect = tester.getRect(
            find.byKey(ValueKey('simple-rest-$action')),
          );
          expect(rect.left, greaterThanOrEqualTo(insets.left));
          expect(rect.right, lessThanOrEqualTo(size.width - insets.right));
          expect(rect.bottom, lessThanOrEqualTo(safeBottom));
        }
        await tester.tap(find.byKey(const ValueKey('simple-rest-skip')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expectScrollSafe(rest: false);
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('representative ${brightness.name} view', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final output = Platform.environment['WORKOUT_SIMPLE_PREVIEW'];
      if (output != null) {
        LocaleSettings.setLocaleSync(AppLocale.it);
        addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
      }
      await mount(tester, brightness: brightness);
      heart.add(132);
      energy.add(164);
      MockServices.container
          .read(countdownControllerProvider.notifier)
          .setCountdown(const Duration(seconds: 60));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      if (output != null) {
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$output-${brightness.name}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
