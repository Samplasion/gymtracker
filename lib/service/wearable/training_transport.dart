import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/service/wearable/apple_watch_training_transport.dart';

typedef TrainingDocument = Map<String, dynamic>;
typedef TrainingReceiver = Future<TrainingDocument> Function(TrainingDocument);

final wearableTrainingTransportProvider = Provider<WearableTrainingTransport>(
  (_) => WearableTrainingTransport.forPlatform(),
);

/// Device communication only. Reconciliation, persistence and progression belong
/// to WearableTrainingService and are shared by all companion implementations.
abstract class WearableTrainingTransport {
  static WearableTrainingTransport forPlatform() => Platform.isIOS
      ? AppleWatchTrainingTransport()
      : const UnsupportedTrainingTransport();

  bool get isSupported;
  void setReceiver(TrainingReceiver receiver);
  Future<List<TrainingDocument>> exchange(TrainingDocument state);
  Future<void> acknowledge(TrainingDocument source, TrainingDocument response);
  Future<void> adoptSensors(TrainingDocument session);
  Future<void> publishTerminal(TrainingDocument session);
  void dispose();
}

/// No channels, timers or pending replies on platforms without a companion.
class UnsupportedTrainingTransport implements WearableTrainingTransport {
  const UnsupportedTrainingTransport();
  @override
  bool get isSupported => false;
  @override
  void setReceiver(TrainingReceiver receiver) {}
  @override
  Future<List<TrainingDocument>> exchange(TrainingDocument state) async => [];
  @override
  Future<void> acknowledge(
    TrainingDocument source,
    TrainingDocument response,
  ) async {}
  @override
  Future<void> adoptSensors(TrainingDocument session) async {}
  @override
  Future<void> publishTerminal(TrainingDocument session) async {}
  @override
  void dispose() {}
}
