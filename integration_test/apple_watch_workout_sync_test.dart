import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

class _PhoneCallbacks implements GymBroNativeFlutterAPI {
  @override
  Future<bool> importWaterEntry(
    String id,
    double milliliters,
    int timeMilliseconds,
    String ownerScope,
  ) async => false;

  @override
  void requestTrainingData() {}
  @override
  void handleWorkoutMetrics(double? energy, double? heartRate) {}
  @override
  void markThisSetAsDone() {}
  @override
  bool moveWorkoutCursorNext() => false;
  @override
  bool moveWorkoutCursorPrevious() => false;
  @override
  void updateSetParameters(
    double? weight,
    double? timeSeconds,
    int? reps,
    double? distance,
  ) {}
}

/// The runner verifies actual receipt on Watch, not only Pigeon's acknowledgement.
/// This does not assert real HealthKit sensor values or hardware gestures.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  testWidgets('two consecutive workouts preserve the shared Watch snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Watch workout sync'))),
    );
    GymBroNativeFlutterAPI.setUp(_PhoneCallbacks());
    final host = GymBroNativeHostAPI();
    const token = String.fromEnvironment(
      'WATCH_SYNC_RUN_ID',
      defaultValue: 'manual',
    );
    final split = NativeFoodNutritionSplit(
      protein: 25,
      proteinGoal: 120,
      carbs: 60,
      carbsGoal: 300,
      fats: 15,
      fatsGoal: 80,
    );
    await host.updateFoodParameters(
      NativeFoodStateMessage(
        calorieGoal: 2400,
        calorieIntake: 525,
        categories: [
          NativeFoodCategory(name: token, emoji: '🍴', nutritionSplit: split),
        ],
        totalNutritionSplit: split,
      ).toJson(),
    );
    final acknowledgements = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/watch-sync-$token',
    );
    await acknowledgements.create(recursive: true);
    Future<void> received(String stage) async {
      final ack = File('${acknowledgements.path}/$stage');
      final deadline = DateTime.now().add(const Duration(seconds: 90));
      while (!await ack.exists()) {
        if (DateTime.now().isAfter(deadline)) {
          fail('Watch receipt was not confirmed for $stage');
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }

    // The runner reinstalls the companion, then acknowledges actual receipt of
    // each stage. No transition is sent until its predecessor was observed.
    await received('ready');
    Future<void> start(String suffix) async {
      final id = '$token-$suffix';
      final start = DateTime.now().millisecondsSinceEpoch;
      await host.startWorkout(id, start);
      await host.setExerciseParameters({
        'workoutId': id,
        'hasExercise': true,
        'exerciseName': 'Workout $suffix',
        'exerciseColor': 0xffc44040,
        'exerciseParameters': '10 reps',
        'setTypeLabel': '',
        'startingTime': start,
        'percentageDone': 0.0,
      });
    }

    await start('A');
    await received('A-running');
    await host.stopWorkout('$token-A', true);
    await received('A-ended');
    await start('B');
    await received('B-running');
    await host.stopWorkout('$token-B', false);
    await received('B-cancelled');
    expect(tester.takeException(), isNull);
    GymBroNativeFlutterAPI.setUp(null);
    await acknowledgements.delete(recursive: true);
  });
}
