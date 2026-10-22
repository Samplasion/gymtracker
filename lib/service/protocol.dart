import 'dart:async';
import 'dart:collection';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Queues links until local initialization and presentation are ready.
class ProtocolService {
  ProtocolService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();
  final AppLinks _appLinks;
  final List<ProtocolListener> _listeners = [];
  final List<String> _pending = [];
  StreamSubscription<Uri>? _subscription;
  bool _ready = false;
  bool _disposed = false;
  String? _initial;

  UnmodifiableListView<ProtocolListener> get listeners =>
      UnmodifiableListView(_listeners);
  void addListener(ProtocolListener listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  void removeListener(ProtocolListener listener) => _listeners.remove(listener);

  Future<void> initialize() async {
    _subscription ??= _appLinks.uriLinkStream.listen((uri) {
      final url = uri.toString();
      if (!_ready && url == _initial) {
        _initial = null;
        return;
      }
      _receive(url);
    });
    final initial = await getInitialUrl();
    if (_disposed || initial == null) return;
    _initial = initial;
    _receive(initial);
  }

  Future<String?> getInitialUrl() => _appLinks.getInitialLinkString();
  void _receive(String url) {
    if (_disposed) return;
    if (!_ready) {
      if (!_pending.contains(url)) _pending.add(url);
      return;
    }
    for (final listener in List<ProtocolListener>.of(_listeners)) {
      listener.onProtocolUrlReceived(url);
    }
  }

  void markReady() {
    _ready = true;
    _initial = null;
    for (final url in List<String>.of(_pending)) {
      _receive(url);
    }
    _pending.clear();
  }

  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    _listeners.clear();
    _pending.clear();
  }
}

final protocolServiceProvider = Provider<ProtocolService>((ref) {
  final service = ProtocolService();
  ref.onDispose(service.dispose);
  return service;
});

mixin ProtocolListener {
  void onProtocolUrlReceived(String url);
}
