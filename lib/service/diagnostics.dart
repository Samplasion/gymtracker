import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local preference: restoring a backup or logging in must not change it.
class DiagnosticsService extends ChangeNotifier {
  static const preferenceKey = 'sentry.enabled';

  SharedPreferences? _preferences;
  late Future<void> Function() _start;
  late Future<void> Function() _stop;
  bool _enabled = true;
  bool _busy = false;

  bool get enabled => _enabled;
  bool get busy => _busy;
  bool get initialized => _preferences != null;

  Future<void> initialize({
    required SharedPreferences preferences,
    required Future<void> Function() start,
    required Future<void> Function() stop,
  }) async {
    _preferences = preferences;
    _start = start;
    _stop = stop;
    // Preserve the existing behavior until the user changes the preference.
    _enabled = preferences.getBool(preferenceKey) ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (!initialized || _busy || value == _enabled) return;
    _busy = true;
    notifyListeners();
    try {
      // Persist first, so an interrupted shutdown still respects the opt-out
      // on the next launch. A failed write must not look like a saved choice.
      if (!await _preferences!.setBool(preferenceKey, value)) {
        throw StateError('Could not save diagnostics preference');
      }
      _enabled = value;
      notifyListeners();
      if (value) {
        await _start();
      } else {
        await _stop();
      }
    } catch (_) {
      // Fail closed if starting the SDK fails.
      if (value && _enabled) {
        _enabled = false;
        await _preferences!.setBool(preferenceKey, false);
        await _stop();
      }
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

final diagnosticsService = DiagnosticsService();
final diagnosticsServiceProvider = Provider<DiagnosticsService>(
  (ref) => diagnosticsService,
);

class DiagnosticsIntegration extends Integration<SentryOptions> {
  DiagnosticsIntegration(this.service);

  final DiagnosticsService service;

  @override
  void call(Hub hub, SentryOptions options) {
    // Install after the SDK has selected the platform's actual transport.
    options.transport = DiagnosticsTransport(options.transport, service);
  }
}

/// Also blocks envelopes already queued when shutdown flushes telemetry.
class DiagnosticsTransport implements Transport {
  DiagnosticsTransport(this.delegate, this.service);

  final Transport delegate;
  final DiagnosticsService service;

  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    if (!service.enabled) return null;
    return delegate.send(envelope);
  }
}
