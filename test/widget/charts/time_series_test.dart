import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/charts/line_charts_time_series.dart';

final end = DateTime(2026, 10, 20);
LineChartPoint point(int days, double value) => LineChartPoint(
  date: end.subtract(Duration(days: days)),
  value: value,
);

Future<void> mount(
  WidgetTester tester,
  Map<String, List<LineChartPoint>> data, {
  bool pro = true,
  bool concurrent = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        historyWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        subscriptionInfoProvider.overrideWith(
          (ref) => Stream.value(
            SubscriptionInfo(
              isPro: pro,
              isTrial: false,
              isForcedPro: false,
              isAboutToExpire: false,
            ),
          ),
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          navigatorKey: Go.navigatorKey,
          theme: ThemeData(
            extensions: [
              MoreColors.fromColorScheme(
                ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
            ],
          ),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppLocaleUtils.supportedLocales,
          home: Scaffold(
            body: LineChartTimeSeries<String>(
              concurrent: concurrent,
              categories: {
                for (final key in data.keys)
                  key: LineChartCategory(
                    title: key,
                    icon: const Icon(Icons.fitness_center),
                  ),
              },
              data: data,
              currentValueBuilder: (category, index, point, predicted) =>
                  Text('$category: ${point.value}'),
              nullCurrentValueBuilder: (category) => Text('$category: ---'),
              leftTitleBuilder: (_, value) => value.toStringAsFixed(0),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LineChartData chart(WidgetTester tester) =>
    tester.widget<LineChart>(find.byType(LineChart)).data;
double minutes(DateTime date) =>
    (date.millisecondsSinceEpoch ~/ 60000).toDouble();
Future<void> interval(
  WidgetTester tester,
  String current,
  String next, {
  bool cancel = false,
}) async {
  await tester.tap(find.widgetWithText(TextButton, current));
  await tester.pumpAndSettle();
  final option = find.text(next, findRichText: true).last;
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
  final labels = MaterialLocalizations.of(
    tester.element(find.byType(LineChart)),
  );
  await tester.tap(
    find.text(cancel ? labels.cancelButtonLabel : labels.okButtonLabel),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => LocaleSettings.setLocale(AppLocale.en));
  final data = {
    'Bench': [point(500, 50), point(200, 60), point(0, 70)],
    'Squat': [point(450, 80), point(30, 100)],
    'Deadlift': <LineChartPoint>[],
  };

  testWidgets(
    'concurrent chart keeps all series, latest values and right padding',
    (tester) async {
      await mount(tester, data);
      expect(chart(tester).lineBarsData.map((bar) => bar.spots.length), [
        3,
        2,
        0,
      ]);
      expect(find.text('Bench: 70.0'), findsOneWidget);
      expect(find.text('Squat: 100.0'), findsOneWidget);
      expect(find.text('Deadlift: ---'), findsOneWidget);
      expect(chart(tester).maxX, minutes(end.add(const Duration(days: 2))));
      expect(chart(tester).minY, lessThan(50));
      expect(chart(tester).maxY, greaterThan(100));
    },
  );

  testWidgets('3, 6 and 12 months share the same right edge', (tester) async {
    await mount(tester, data);
    final right = end.add(const Duration(days: 2));
    expect(
      chart(tester).minX,
      minutes(right.subtract(const Duration(days: 90))),
    );
    await interval(tester, '3 months', '6 months');
    expect(
      chart(tester).minX,
      minutes(right.subtract(const Duration(days: 180))),
    );
    expect(chart(tester).maxX, minutes(right));
    await interval(tester, '6 months', '1 year');
    expect(
      chart(tester).minX,
      minutes(right.subtract(const Duration(days: 365))),
    );
    expect(chart(tester).maxX, minutes(right));
  });

  testWidgets('range ignores input order and updates with new history', (
    tester,
  ) async {
    await mount(tester, {
      for (final entry in data.entries)
        entry.key: entry.value.reversed.toList(),
    });
    expect(
      chart(tester).minX,
      minutes(
        end.add(const Duration(days: 2)).subtract(const Duration(days: 90)),
      ),
    );
    await interval(tester, '3 months', '6 months');
    await mount(tester, {
      ...data,
      'Bench': [...data['Bench']!, point(-10, 75)],
    });
    final right = end.add(const Duration(days: 12));
    expect(chart(tester).maxX, minutes(right));
    expect(
      chart(tester).minX,
      minutes(right.subtract(const Duration(days: 180))),
    );
    expect(find.text('Bench: 75.0'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '6 months'), findsOneWidget);
  });

  testWidgets('short history never extends before the first point', (
    tester,
  ) async {
    await mount(tester, {
      'Bench': [point(20, 50), point(0, 70)],
    });
    final left = chart(tester).minX;
    expect(left, minutes(end.subtract(const Duration(days: 20))));
    await interval(tester, '3 months', '1 year');
    expect(chart(tester).minX, left);
  });

  testWidgets('cancelling interval selection restores the previous range', (
    tester,
  ) async {
    await mount(tester, data);
    final left = chart(tester).minX;
    await interval(tester, '3 months', '6 months', cancel: true);
    expect(chart(tester).minX, left);
    expect(find.widgetWithText(TextButton, '3 months'), findsOneWidget);
  });

  testWidgets('panning stays within history and is disabled without Pro', (
    tester,
  ) async {
    await mount(tester, data);
    final initial = chart(tester);
    await tester.drag(find.byType(LineChart), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(chart(tester).minX, lessThan(initial.minX));
    await tester.drag(find.byType(LineChart), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(chart(tester).maxX, initial.maxX);
    await tester.drag(find.byType(LineChart), const Offset(20000, 0));
    await tester.pumpAndSettle();
    expect(
      chart(tester).minX,
      minutes(end.subtract(const Duration(days: 500))),
    );
    await tester.pumpWidget(const SizedBox());
    await mount(tester, data, pro: false);
    final freeLeft = chart(tester).minX;
    await tester.drag(find.byType(LineChart), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(chart(tester).minX, freeLeft);
  });

  testWidgets('empty history shows the placeholder without interval controls', (
    tester,
  ) async {
    await mount(tester, {'Bench': []});
    expect(find.widgetWithText(TextButton, '3 months'), findsNothing);
    expect(chart(tester).lineTouchData.enabled, isFalse);
  });

  testWidgets('single-series chart preserves its existing date anchor', (
    tester,
  ) async {
    await mount(tester, {'Bench': data['Bench']!}, concurrent: false);
    expect(chart(tester).minX, minutes(end.subtract(const Duration(days: 90))));
    expect(chart(tester).maxX, minutes(end.add(const Duration(days: 2))));
  });
}
