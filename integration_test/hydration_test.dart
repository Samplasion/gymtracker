import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:integration_test/integration_test.dart';
import '../test/hydration/card_scenarios.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  testWidgets(
    'hydration diary on iOS simulator: presets, shared goals and history',
    exerciseHydrationCard,
  );
  testWidgets(
    'native HealthKit channel handles hydration writes or denied permission',
    (tester) async {
      final health = DeviceHydrationHealth();
      expect(health.supported, isTrue);
      expect(await health.permission(), isNot(HydrationPermission.unavailable));
      final id =
          'gymbro:integration:water:${DateTime.now().microsecondsSinceEpoch}';
      var saved = false;
      try {
        await health.write(
          id,
          1,
          1,
          DateTime.now().subtract(const Duration(minutes: 1)),
        );
        saved = true;
        await health.write(
          id,
          2,
          2,
          DateTime.now().subtract(const Duration(minutes: 1)),
        );
      } on PlatformException catch (error) {
        expect(
          error.code,
          'permission',
          reason:
              'Missing HealthKit water permission must be handled explicitly',
        );
      } finally {
        if (saved) await health.remove(id);
      }
    },
    skip: !Platform.isIOS,
  );
}
