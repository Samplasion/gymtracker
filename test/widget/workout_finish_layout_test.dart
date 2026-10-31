import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../test_helpers/mock_services.dart';

void main() {
  for (final locale in [AppLocale.en, AppLocale.it]) {
    for (final size in [const Size(320, 740), const Size(1024, 768)]) {
      testWidgets('finish form fits $locale at $size with enlarged text', (
        tester,
      ) async {
        MockServices.setup();
        addTearDown(MockServices.tearDown);
        await initializeDateFormatting(locale.languageCode, null);
        LocaleSettings.setLocale(locale);
        addTearDown(() => LocaleSettings.setLocale(AppLocale.en));
        MockServices.createWorkout('Workout', null, null).time = DateTime.now()
            .subtract(const Duration(minutes: 10));
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = ThemeData(useMaterial3: true);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: MockServices.container,
            child: TranslationProvider(
              child: MaterialApp(
                theme: theme.copyWith(
                  extensions: [MoreColors.fromColorScheme(theme.colorScheme)],
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.5)),
                  child: child!,
                ),
                home: const WorkoutFinishPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(locale.translations.ongoingWorkout.finish.save),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}
