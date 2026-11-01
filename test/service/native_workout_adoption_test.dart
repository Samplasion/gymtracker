import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/native.g.dart';

class _Host extends GymBroNativeHostAPI {
  final updates = <Map<String?, Object?>>[];
  int starts = 0;
  @override
  Future<void> setExerciseParameters(Map<String?, Object?> parameters) async {
    updates.add(parameters);
  }

  @override
  Future<void> startWorkout(String workoutId, int startMilliseconds) async {
    starts++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'adopted ID labels initial and subsequent native updates without starting sensors',
    () {
      final host = _Host();
      final service = NativeService.withHost(host);
      addTearDown(service.dispose);
      final message = NativeWorkoutStateMessage(
        hasExercise: true,
        exerciseName: 'Bench',
        exerciseColor: Colors.blue,
        exerciseParameters: '10 × 20 kg',
        setTypeLabel: '1',
        startingTime: DateTime(2026),
        percentageDone: 0,
        set: null,
      );
      service.adoptWorkoutIdentity('from-watch');
      service.setExerciseParameters(message);
      service.setExerciseParameters(message);
      expect(host.starts, 0);
      expect(host.updates, hasLength(2));
      expect(
        host.updates.every((update) => update['workoutId'] == 'from-watch'),
        true,
      );
      service.adoptWorkoutIdentity('second-watch-session');
      service.setExerciseParameters(message);
      expect(host.updates.last['workoutId'], 'second-watch-session');
      expect(host.starts, 0);
    },
  );
}
