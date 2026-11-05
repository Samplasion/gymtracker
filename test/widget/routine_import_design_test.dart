import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:gymtracker/view/components/routine_import_content.dart';

import '../helpers.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final captureImages = Platform.environment['GYM_BRO_CAPTURE_IMPORT'] == '1';
  setUpAll(() async {
    if (!captureImages) return;
    final directory = '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts';
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            await File('$directory/${entry.value}').readAsBytes(),
          ),
        ),
      );
      await loader.load();
    }
  });
  setUp(() async {
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.it);
  });
  for (final brightness in Brightness.values) {
    for (final scenario in [
      ('phone', 390.0, 844.0, 1.0),
      ('large-text', 360.0, 820.0, 1.6),
      ('desktop', 1200.0, 900.0, 1.0),
    ]) {
      testWidgets(
        'import design ${brightness.name} ${scenario.$1} preserves scrolling and action',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(scenario.$2, scenario.$3));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final capture = GlobalKey();
          final programNotes = List.filled(
            12,
            'Alterna le giornate e lascia almeno un giorno di recupero tra gli allenamenti.',
          ).join(' ');
          var selected = 0;
          var imports = 0;
          final exercises = [
            exerciseHelper(
              'press',
              'Distensioni su panca inclinata con manubri',
              sets: [
                for (var i = 0; i < 3; i++)
                  GTSet(
                    parameters: GTSetParameters.repsWeight,
                    kind: GTSetKind.normal,
                    reps: 10,
                    weight: 22.5,
                    rpe: 8,
                  ),
              ],
            ).copyWith(
              notes:
                  '[{"insert":"Mantieni il movimento controllato e le scapole stabili.\\n"}]',
            ),
            supersetHelper(
              'group',
              exercises: [
                exerciseHelper('row', 'Rematore al cavo'),
                exerciseHelper('curl', 'Curl con manubri'),
              ],
            ),
          ];
          final routines = [
            Workout(name: 'Giornata A · Parte superiore', exercises: exercises),
            Workout(name: 'Giornata B · Recupero e mobilità', exercises: []),
          ];
          await tester.pumpWidget(
            WidgetTestApp(
              child: Builder(
                builder: (context) => Theme(
                  data: _previewTheme(context, brightness, captureImages),
                  child: GTExpressiveTheme(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scenario.$4)),
                      child: RepaintBoundary(
                        key: capture,
                        child: StatefulBuilder(
                          builder: (context, setState) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Programma forza e mobilità'),
                            ),
                            body: RoutineImportContent(
                              routines: routines,
                              notes: programNotes,
                              selectedDay: selected,
                              onDayChanged: (day) =>
                                  setState(() => selected = day),
                            ),
                            bottomNavigationBar: RoutineImportActionBar(
                              isPro: false,
                              onPressed: () => imports++,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AppBar), findsOneWidget);
          expect(find.byType(SliverAppBar), findsNothing);
          expect(tester.takeException(), isNull);
          final action = find.byType(FilledButton);
          expect(action, findsOneWidget);
          await tester.tap(action);
          expect(imports, 1);
          await tester.pumpAndSettle();
          if (Platform.environment['GYM_BRO_CAPTURE_IMPORT'] == '1' &&
              scenario.$1 == 'phone') {
            await tester.runAsync(() async {
              final boundary =
                  capture.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 2);
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '/tmp/gymbro-import-${brightness.name}.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.scrollUntilVisible(
            find.text('Distensioni su panca inclinata con manubri'),
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(
            find.text('Distensioni su panca inclinata con manubri'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          if (Platform.environment['GYM_BRO_CAPTURE_IMPORT'] == '1' &&
              scenario.$1 == 'phone') {
            await tester.runAsync(() async {
              final boundary =
                  capture.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 2);
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '/tmp/gymbro-import-${brightness.name}-exercises.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.scrollUntilVisible(
            find.text('Note del programma'),
            -300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text('Note del programma'));
          await tester.pumpAndSettle();
          expect(find.text(programNotes), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Note del programma'));
          await tester.pumpAndSettle();
          expect(find.text(programNotes), findsNothing);
        },
      );
    }
  }
}

ThemeData _previewTheme(
  BuildContext context,
  Brightness brightness,
  bool capture,
) {
  final theme = getGymTrackerThemeFor(context, Colors.teal, brightness);
  return capture
      ? theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
          primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto'),
        )
      : theme;
}
