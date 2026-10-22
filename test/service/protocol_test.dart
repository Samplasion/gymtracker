import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:mocktail/mocktail.dart';

class _Links extends Mock implements AppLinks {}

class _Listener with ProtocolListener {
  final received = <String>[];
  @override
  void onProtocolUrlReceived(String url) => received.add(url);
}

void main() {
  test(
    'initial and warm links wait for readiness and startup duplicates dispatch once',
    () async {
      final links = _Links();
      final stream = StreamController<Uri>.broadcast(sync: true);
      final initial = Completer<String?>();
      when(() => links.uriLinkStream).thenAnswer((_) => stream.stream);
      when(
        () => links.getInitialLinkString(),
      ).thenAnswer((_) => initial.future);
      final service = ProtocolService(appLinks: links);
      final listener = _Listener();
      service.addListener(listener);
      service.addListener(listener);
      final boot = service.initialize();
      stream.add(Uri.parse('gymbro://routine/cold'));
      stream.add(Uri.parse('gymbro://routine/warm-before-ready'));
      initial.complete('gymbro://routine/cold');
      await boot;
      expect(listener.received, isEmpty);
      service.markReady();
      expect(listener.received, [
        'gymbro://routine/cold',
        'gymbro://routine/warm-before-ready',
      ]);
      stream.add(Uri.parse('gymbro://routine/hot'));
      stream.add(Uri.parse('gymbro://routine/cold'));
      expect(listener.received, [
        'gymbro://routine/cold',
        'gymbro://routine/warm-before-ready',
        'gymbro://routine/hot',
        'gymbro://routine/cold',
      ]);
      service.removeListener(listener);
      stream.add(Uri.parse('gymbro://routine/removed'));
      expect(listener.received, hasLength(4));
      service.dispose();
      await stream.close();
    },
  );

  test(
    'scope disposal cancels listeners and ignores a late initial link',
    () async {
      final links = _Links();
      final stream = StreamController<Uri>.broadcast(sync: true);
      final initial = Completer<String?>();
      when(() => links.uriLinkStream).thenAnswer((_) => stream.stream);
      when(
        () => links.getInitialLinkString(),
      ).thenAnswer((_) => initial.future);
      final container = ProviderContainer(
        overrides: [
          protocolServiceProvider.overrideWith((ref) {
            final service = ProtocolService(appLinks: links);
            ref.onDispose(service.dispose);
            return service;
          }),
        ],
      );
      final service = container.read(protocolServiceProvider);
      final listener = _Listener();
      service.addListener(listener);
      final boot = service.initialize();
      expect(stream.hasListener, isTrue);
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(stream.hasListener, isFalse);
      initial.complete('gymbro://routine/late');
      await boot;
      service.markReady();
      expect(listener.received, isEmpty);
      await stream.close();
    },
  );
}
