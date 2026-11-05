import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/actions/routines.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.en);
  });
  tearDown(MockServices.tearDown);
  final controllerProvider = Provider((ref) {
    ref.keepAlive();
    return RoutinesController(ref);
  });
  Future<RoutinesController> open(WidgetTester tester) async {
    late RoutinesController controller;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...MockServices.defaultOverrides],
        child: WidgetTestApp(
          child: Consumer(
            builder: (context, ref, _) {
              controller = ref.watch(controllerProvider);
              return const Text('Home');
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  for (final entry in [
    (
      'missing payload',
      Uri.parse('gymtracker://routine'),
      () => t.importRoutine.errors.noJson.title,
    ),
    (
      'corrupt payload',
      Uri.parse('gymtracker://routine?json=broken'),
      () => t.importRoutine.errors.badJson.title,
    ),
    (
      'invalid workout',
      Uri(
        scheme: 'gymtracker',
        host: 'routine',
        queryParameters: {'json': jsonEncode(42).compressed},
      ),
      () => t.importRoutine.errors.badWorkout.title,
    ),
  ]) {
    testWidgets('routine link rejects ${entry.$1} without opening import', (
      tester,
    ) async {
      final controller = await open(tester);
      controller.onRoutineUrlReceived(entry.$2);
      await tester.pumpAndSettle();
      expect(find.text(entry.$3()), findsOneWidget);
      expect(find.byType(ImportRoutineModal), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  test('shared routine payload survives compression and serialization', () {
    final routine = Workout(
      name: 'Shared routine',
      exercises: [],
      infobox: 'Notes',
    );
    final link = Uri(
      scheme: 'gymtracker',
      host: 'routine',
      queryParameters: {'json': jsonEncode(routine.shareWorkout()).compressed},
    );
    final decoded = Workout.fromJson(
      jsonDecode(
        Uri.parse(link.toString()).queryParameters['json']!.uncompressed,
      ),
    );
    expect(decoded.name, routine.name);
    expect(decoded.infobox, routine.infobox);
    expect(decoded.parentID, isNull);
    expect(decoded.folder, isNull);
  });
  testWidgets(
    'email confirmation link does not open a routine or unknown-link error',
    (tester) async {
      final controller = await open(tester);
      controller.onProtocolUrlReceived('gymtracker://auth/email-confirmed');
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ImportRoutineModal), findsNothing);
    },
  );
}
