import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/diagnostics.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingTransport implements Transport {
  int sent = 0;

  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    sent++;
    return SentryId.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  late DiagnosticsService service;
  late int starts;
  late int stops;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    service = DiagnosticsService();
    starts = 0;
    stops = 0;
    await service.initialize(
      preferences: preferences,
      start: () async {
        starts++;
      },
      stop: () async {
        stops++;
      },
    );
  });

  tearDown(() => service.dispose());

  test(
    'opt-out persists locally and closes SDK before reporting completion',
    () async {
      expect(service.enabled, isTrue);
      await service.setEnabled(false);
      expect(stops, 1);
      expect(service.enabled, isFalse);
      expect(preferences.getBool(DiagnosticsService.preferenceKey), isFalse);

      final restarted = DiagnosticsService();
      addTearDown(restarted.dispose);
      await restarted.initialize(
        preferences: preferences,
        start: () async {
          starts++;
        },
        stop: () async {
          stops++;
        },
      );
      expect(restarted.enabled, isFalse);
      expect(starts, 0);

      await service.setEnabled(true);
      expect(starts, 1);
      expect(preferences.getBool(DiagnosticsService.preferenceKey), isTrue);
    },
  );

  test('queued envelopes are dropped during opt-out shutdown', () async {
    final delegate = RecordingTransport();
    final transport = DiagnosticsTransport(delegate, service);
    final envelope = SentryEnvelope.fromEvent(
      SentryEvent(),
      SdkVersion(name: 'test', version: '1'),
    );
    await transport.send(envelope);
    expect(delegate.sent, 1);
    await service.setEnabled(false);
    await transport.send(envelope);
    expect(delegate.sent, 1);
    await service.setEnabled(true);
    await transport.send(envelope);
    expect(delegate.sent, 2);
  });

  testWidgets('settings switch updates the service and survives rebuilding', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [diagnosticsServiceProvider.overrideWithValue(service)],
        child: TranslationProvider(
          child: const MaterialApp(
            home: Scaffold(body: DiagnosticsSettingsTile()),
          ),
        ),
      ),
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(service.enabled, isFalse);
    expect(stops, 1);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(service.enabled, isTrue);
    expect(starts, 1);
  });

  test('failed SDK activation returns to a persisted disabled state', () async {
    await service.setEnabled(false);
    await service.initialize(
      preferences: preferences,
      start: () async => throw StateError('SDK failed'),
      stop: () async {
        stops++;
      },
    );
    await expectLater(service.setEnabled(true), throwsStateError);
    expect(service.enabled, isFalse);
    expect(service.busy, isFalse);
    expect(preferences.getBool(DiagnosticsService.preferenceKey), isFalse);
    expect(stops, 2);
  });

  test(
    'concurrent toggles are ignored while SDK shutdown is pending',
    () async {
      final closed = Completer<void>();
      await service.initialize(
        preferences: preferences,
        start: () async {
          starts++;
        },
        stop: () => closed.future,
      );
      final disabling = service.setEnabled(false);
      // Wait for the asynchronous preference write.
      while (!service.busy || service.enabled) {
        await Future<void>.delayed(Duration.zero);
      }
      await service.setEnabled(true);
      expect(service.enabled, isFalse);
      expect(starts, 0);
      closed.complete();
      await disabling;
      expect(service.busy, isFalse);
    },
  );
}
