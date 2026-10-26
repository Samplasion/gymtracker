import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/provider/plateau.dart';
import 'package:gymtracker/service/plateau_analysis.dart';
import 'package:gymtracker/view/me/plateau.dart';
import 'package:m3e_core/m3e_core.dart';
import '../service/plateau_analysis_test.dart' as fixture;
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  Future<void> show(WidgetTester tester, List<PlateauResult> results) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: MockServices.container,
        child: ProviderScope(
          overrides: [
            plateauAnalysisProvider.overrideWithValue(AsyncData(results)),
          ],
          child: const WidgetTestApp(child: PlateauStatisticsTab()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> openExercise(WidgetTester tester) async {
    await tester.tap(find.text('Possible plateaus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exercise'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'only criteria start open and collapsed exercises show only their title',
    (tester) async {
      await show(tester, analyzePlateaus(fixture.history(), now: fixture.now));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Requires 6 comparable sessions'),
        findsOneWidget,
      );
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Possible plateau'), findsNothing);
      expect(find.textContaining('Normal sets per session:'), findsNothing);
      final exerciseCard = find.byWidgetPredicate(
        (widget) => widget is M3EExpandableItem && widget.index == 1,
      );
      final collapsedHeight = tester.getSize(exerciseCard).height;
      await openExercise(tester);
      expect(find.text('Possible plateau'), findsOneWidget);
      await tester.tap(find.text('Exercise'));
      await tester.pumpAndSettle();
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Possible plateau').hitTestable(), findsNothing);
      expect(
        find.textContaining('Normal sets per session:').hitTestable(),
        findsNothing,
      );
      expect(tester.getSize(exerciseCard).height, closeTo(collapsedHeight, .5));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('empty history explains that more data is needed', (
    tester,
  ) async {
    await show(tester, []);
    expect(find.textContaining('More data needed.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('weighted evidence renders with metrics and session links', (
    tester,
  ) async {
    final results = analyzePlateaus(fixture.history(), now: fixture.now);
    await show(tester, results);
    await openExercise(tester);
    expect(find.text('Possible plateau'), findsOneWidget);
    expect(find.textContaining('Normal sets per session: 3'), findsOneWidget);
    expect(find.textContaining('Session volume'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('bodyweight evidence omits load and volume charts', (
    tester,
  ) async {
    await show(
      tester,
      analyzePlateaus(
        fixture.history(parameters: GTSetParameters.freeBodyReps),
        now: fixture.now,
      ),
    );
    await openExercise(tester);
    expect(find.textContaining('Maximum reps per set'), findsWidgets);
    expect(find.textContaining('Total reps'), findsWidgets);
    expect(find.textContaining('Session volume'), findsNothing);
    expect(find.textContaining('Maximum load'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  test('Italian and English include criteria and exclusions', () {
    for (final locale in [AppLocale.en, AppLocale.it]) {
      expect(locale.translations.plateau.criteria, contains('28'));
      expect(locale.translations.plateau.unsupported, isNotEmpty);
    }
  });
}
