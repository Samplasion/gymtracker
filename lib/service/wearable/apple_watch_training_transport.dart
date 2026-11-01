import 'package:flutter/services.dart';
import 'package:gymtracker/service/wearable/training_transport.dart';

/// Keeps the existing iOS wire protocol unchanged. No method waits for a Watch
/// acknowledgement: the native phone bridge persists and queues deliveries.
class AppleWatchTrainingTransport implements WearableTrainingTransport {
  static const channel = MethodChannel('gymbro/training');
  static const responseTimeout = Duration(seconds: 5);

  @override
  bool get isSupported => true;

  @override
  void setReceiver(TrainingReceiver receiver) {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'receiveTraining') return null;
      return receiver(Map<String, dynamic>.from(call.arguments as Map));
    });
  }

  @override
  Future<List<TrainingDocument>> exchange(TrainingDocument state) async {
    final entries = await channel
        .invokeListMethod<dynamic>('exchange', state)
        .timeout(responseTimeout);
    return [
      for (final entry in entries ?? [])
        Map<String, dynamic>.from(entry as Map),
    ];
  }

  @override
  Future<void> acknowledge(
    TrainingDocument source,
    TrainingDocument response,
  ) => channel
      .invokeMethod<void>('acknowledge', {
        'source': source,
        'response': response,
      })
      .timeout(responseTimeout);

  @override
  Future<void> adoptSensors(TrainingDocument session) => channel
      .invokeMethod<void>('adoptSensors', session)
      .timeout(responseTimeout);

  @override
  Future<void> publishTerminal(TrainingDocument session) =>
      channel.invokeMethod<void>('terminal', session).timeout(responseTimeout);

  @override
  void dispose() => channel.setMethodCallHandler(null);
}
