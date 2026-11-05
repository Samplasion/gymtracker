import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:integration_test/integration_test.dart';

/// Run on an iOS simulator paired with a running Watch companion app.
/// This test verifies native-channel acceptance. Verify companion receipt
/// separately using its persisted foodParameters (see IOS_PENDING_TESTS.md).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  testWidgets('send updated nutrition snapshots to the paired Apple Watch', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Watch nutrition sync'))),
    );
    final host = GymBroNativeHostAPI();
    NativeFoodStateMessage snapshot(double intake) {
      final split = NativeFoodNutritionSplit(
        protein: 25,
        proteinGoal: 120,
        carbs: 60,
        carbsGoal: 300,
        fats: 15,
        fatsGoal: 80,
      );
      return NativeFoodStateMessage(
        calorieGoal: 2400,
        calorieIntake: intake,
        categories: [
          NativeFoodCategory(
            name:
                'Simulator sync verification ${const String.fromEnvironment('WATCH_SYNC_RUN_ID', defaultValue: 'manual')}',
            emoji: '🍴',
            nutritionSplit: split,
          ),
        ],
        totalNutritionSplit: split,
      );
    }

    await host.updateFoodParameters(snapshot(475).toJson());
    await host.updateFoodParameters(snapshot(525).toJson());
    // Allow native activation/transport to progress before Flutter exits.
    await Future<void>.delayed(const Duration(seconds: 30));
    expect(tester.takeException(), isNull);
  }, skip: Platform.isMacOS);
}
