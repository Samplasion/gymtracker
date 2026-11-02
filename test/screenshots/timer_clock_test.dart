import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/view/utils/timer.dart';
import '../test_helpers/widget_test_app.dart';

class _Clock extends WorkoutClock {
  @override
  DateTime now() => DateTime(2026, 11, 1, 9, 41);
}

void main() {
  testWidgets('visible workout timer uses the injected clock across ticks', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutClockProvider.overrideWithValue(_Clock())],
        child: WidgetTestApp(
          child: TimerView(
            startingTime: DateTime(2026, 11, 1, 9, 17),
            builder: (_, time) => time,
          ),
        ),
      ),
    );
    expect(find.textContaining('24:00', findRichText: true), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('24:00', findRichText: true), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
