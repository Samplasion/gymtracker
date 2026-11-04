import 'package:gymtracker/service/wearable/apple_watch_training_transport.dart';

/// Android implements the same durable inbox/channel contract as iOS.
/// No call waits for the companion to become reachable.
class WearOsTrainingTransport extends AppleWatchTrainingTransport {}
