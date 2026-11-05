import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/view/actions/settings.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.en);
    when(
      () => MockServices.settingsController.service,
    ).thenReturn(MockServices.databaseService);
  });
  tearDown(MockServices.tearDown);
  testWidgets('failed export reports error and leaves settings usable', (
    tester,
  ) async {
    when(
      () => MockServices.databaseService.exportJson(),
    ).thenThrow(StateError('export unavailable'));
    await tester.pumpWidget(
      WidgetTestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                MockServices.settingsController.exportSettings(context),
            child: const Text('Export'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(find.text(t.settings.options.export.failed.title), findsOneWidget);
    expect(find.textContaining('export unavailable'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
