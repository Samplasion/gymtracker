import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/version.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'flows/create_routine.dart';
import 'flows/workout_from_routine.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseService databaseService;
  final l = GTLocalizations();

  setUp(() async {
    databaseService = DatabaseService();
    await databaseService.ensureInitializedForTests();

    await ColorService().init();
    await VersionService().init();

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    await l.initTests(const [Locale("en")]);
  });

  tearDown(() => databaseService.teardown());

  group('end-to-end test', () {
    testWidgets(
      'create routine',
      (tester) => testCreateRoutineFlow(tester, l, databaseService),
    );
    testWidgets(
      'create workout from routine and save it back',
      (tester) => testWorkoutFromRoutineFlow(tester, l, databaseService),
    );
  });
}
