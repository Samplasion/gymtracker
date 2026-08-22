import 'dart:async';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/online.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events.def.dart';
part 'events.g.dart';

/// Base class for all game engine events
abstract class GBEvent {
  const GBEvent();
}

/// Manages the stream of events across the app.
class EventBus {
  final _controller = StreamController<GBEvent>.broadcast();

  /// Dispatch an event to all listeners.
  void emit(GBEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Listen exclusively to a specific subtype of [GBEvent].
  Stream<T> on<T extends GBEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void dispose() {
    _controller.close();
  }
}

@Riverpod(keepAlive: true)
EventBus eventBus(Ref ref) {
  final bus = EventBus();
  ref.onDispose(bus.dispose);
  return bus;
}
