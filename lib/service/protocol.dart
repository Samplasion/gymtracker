import 'dart:collection';

import 'package:app_links/app_links.dart';

class ProtocolService {
  static final ProtocolService _protocolService = ProtocolService._();
  ProtocolService._() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      final url = uri.toString();
      for (final listener in _listeners) {
        listener.onProtocolUrlReceived(url);
      }
    });
  }

  factory ProtocolService() {
    return _protocolService;
  }

  late final AppLinks _appLinks;
  final List<ProtocolListener> _listeners = [];

  UnmodifiableListView<ProtocolListener> get listeners =>
      UnmodifiableListView(_listeners);
  void addListener(ProtocolListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ProtocolListener listener) {
    _listeners.remove(listener);
  }

  Future<String?> getInitialUrl() {
    return _appLinks.getInitialLinkString();
  }
}

mixin ProtocolListener {
  void onProtocolUrlReceived(String url);
}
