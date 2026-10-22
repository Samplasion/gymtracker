import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/timer.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    MockServices.createWorkout('Workout', null, null);
  });
  tearDown(MockServices.tearDown);

  for (final locale in [AppLocale.en, AppLocale.it]) {
    for (final width in [320.0, 393.0, 600.0, 720.0, 1280.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'right-aligned actions fit at width $width, text scale $scale, locale ${locale.name}',
          (tester) async {
            await LocaleSettings.setLocale(locale);
            tester.view.physicalSize = Size(width, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            var opened = 0;
            await tester.pumpWidget(
              WidgetTestApp(
                wrapWithProviderScope: true,
                child: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 800),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: OngoingWorkoutBar(open: () => opened++),
                  ),
                ),
              ),
            );
            await tester.pump();
            final timer = tester.getRect(find.byType(TimerView));
            final resume = tester.getRect(find.byIcon(GTIcons.resume));
            final cancel = tester.getRect(
              find
                  .ancestor(
                    of: find.byIcon(GTIcons.close),
                    matching: find.byWidgetPredicate(
                      (widget) => widget is IconButton || widget is TextButton,
                    ),
                  )
                  .first,
            );
            // Anchor the actions to the trailing content edge at every size.
            expect(timer.left, 24);
            expect(resume.left, greaterThanOrEqualTo(timer.right + 8));
            expect(cancel.right, closeTo(width - 24, 0.01));
            expect(resume.top, greaterThanOrEqualTo(0));
            expect(tester.takeException(), isNull);
            await tester.tap(find.byIcon(GTIcons.resume));
            expect(opened, 1);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          },
        );
      }
    }
  }
}
