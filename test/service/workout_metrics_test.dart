import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:mocktail/mocktail.dart';

class _Host extends Mock implements GymBroNativeHostAPI {}

void main() {
  test(
    'unavailable heart rate clears only HR while cumulative calories survive',
    () async {
      final service = NativeService.withHost(_Host());
      final callbacks = service as GymBroNativeFlutterAPI;
      final energy = <double?>[];
      final heartRate = <double?>[];
      final energySub = service.energyStream.listen(energy.add);
      final heartSub = service.heartRateStream.listen(heartRate.add);
      callbacks.handleWorkoutMetrics(80, 120);
      callbacks.handleWorkoutMetrics(null, 0);
      callbacks.handleWorkoutMetrics(95, null);
      await Future<void>.delayed(Duration.zero);
      expect(energy, [80, 95]);
      expect(heartRate, [120, null]);
      callbacks.handleWorkoutMetrics(null, 130);
      await Future<void>.delayed(Duration.zero);
      expect(energy.last, 95);
      expect(heartRate.last, 130);
      callbacks.handleWorkoutMetrics(null, null);
      await Future<void>.delayed(Duration.zero);
      expect(energy.last, isNull);
      expect(heartRate.last, isNull);
      await energySub.cancel();
      await heartSub.cancel();
      service.dispose();
    },
  );
}
