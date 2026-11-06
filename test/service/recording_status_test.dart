import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/native.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recording status is bound to the adopted workout identity', () async {
    final native = NativeService.withHost(GymBroNativeHostAPI());
    addTearDown(native.dispose);
    final updates = <RecordingUpdate?>[];
    final subscription = native.recordingStream.listen(updates.add);
    addTearDown(subscription.cancel);
    native.adoptWorkoutIdentity('A');
    final receiver = native as GymBroNativeFlutterAPI;
    receiver.handleRecordingStatus('A', 'pending', null);
    receiver.handleRecordingStatus('A', 'confirmed', null);
    native.adoptWorkoutIdentity('B');
    receiver.handleRecordingStatus('A', 'unavailable', 'Late reply');
    receiver.handleRecordingStatus('B', 'pending', null);
    receiver.handleRecordingStatus('B', 'unknown', null);
    await Future<void>.delayed(Duration.zero);
    expect(updates.whereType<RecordingUpdate>().map((update) => update.state), [
      RecordingState.pending,
      RecordingState.confirmed,
      RecordingState.pending,
    ]);
    expect(updates.whereType<RecordingUpdate>().last.workoutId, 'B');
  });

  test('disposed native service ignores late sensor confirmations', () async {
    final native = NativeService.withHost(GymBroNativeHostAPI());
    native.adoptWorkoutIdentity('A');
    native.dispose();
    expect(
      () => (native as GymBroNativeFlutterAPI).handleRecordingStatus(
        'A',
        'confirmed',
        null,
      ),
      returnsNormally,
    );
  });
}
