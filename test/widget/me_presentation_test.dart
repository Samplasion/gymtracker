import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:gymtracker/view/components/section_card.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/utils/online_profile_card.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Account extends Online {
  @override
  FutureOr<OnlineAccount?> build() => OnlineAccount(
    id: 'user',
    name: 'a_long_username_for_the_profile',
    fullName: 'A very long full name that should wrap without clipping',
  );
}

Widget page({
  required Brightness brightness,
  double scale = 1,
  bool populated = true,
  Stream<List<WeightMeasurement>>? measurements,
}) => ProviderScope(
  overrides: [
    ...MockServices.defaultOverrides,
    onlineProvider.overrideWith(_Account.new),
    currentUserIdProvider.overrideWithValue('user'),
    userAvatarProvider('user').overrideWith((ref) async => null),
    weightMeasurementsProvider.overrideWith(
      (ref) =>
          measurements ??
          Stream.value([
            if (populated)
              for (var i = 0; i < 3; i++)
                WeightMeasurement(
                  id: '$i',
                  weight: 80 - i.toDouble(),
                  time: DateTime(2026, 10, 25 + i),
                  weightUnit: Weights.kg,
                ),
          ]),
    ),
  ],
  child: TranslationProvider(
    child: Builder(
      builder: (context) => MaterialApp(
        navigatorKey: Go.navigatorKey,
        theme: getGymTrackerThemeFor(context, Colors.teal, brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: GTExpressiveTheme(child: child!),
        ),
        home: const MeView(),
      ),
    ),
  ),
);

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  for (final brightness in Brightness.values) {
    for (final width in [360.0, 430.0, 1200.0]) {
      testWidgets('profile $brightness at $width with large text', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        when(() => MockServices.historyController.history).thenReturn([
          Workout(
            name: 'Training',
            exercises: [],
            startingDate: DateTime(2026, 10, 1),
          ),
        ]);
        await tester.pumpWidget(
          page(brightness: brightness, scale: width == 360 ? 1.6 : 1),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(OnlineProfileCard)).width,
          lessThanOrEqualTo(728),
        );
        expect(find.byType(GTSectionCard), findsWidgets);
        await tester.scrollUntilVisible(
          find.byType(WeightCard),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.byType(WeightCard));
        await tester.pumpAndSettle();
        expect(find.textContaining('78'), findsWidgets);
        final allData = find.widgetWithText(
          OutlinedButton,
          t.me.weight.allData.label,
        );
        expect(tester.widget<OutlinedButton>(allData).onPressed, isNotNull);
        await tester.scrollUntilVisible(
          find.text(t.me.trainer.title),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets('empty measurements keep add enabled and all data disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      page(brightness: Brightness.light, populated: false),
    );
    await tester.pumpAndSettle();
    expect(find.text(t.me.weight.none), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, t.me.weight.allData.label),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, t.me.weight.addMeasurement),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('measurement error offers retry without claiming no data', (
    tester,
  ) async {
    var reads = 0;
    final container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        weightMeasurementsProvider.overrideWith((ref) {
          reads++;
          return Stream<List<WeightMeasurement>>.error(
            StateError('load failed'),
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WidgetTestApp(child: WeightCard()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(t.me.weight.none), findsNothing);
    await tester.tap(find.text(t.error.retry));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
