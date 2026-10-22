import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

class _Health extends Mock implements HealthController {}

class _Native extends Mock implements NativeService {}

class _Protocol extends Mock implements ProtocolService {}

class _Purchases extends Mock implements PurchasesService {}

class _FailingOfflineOnlineNotifier extends Online {
  @override
  FutureOr<OnlineAccount?> build() async =>
      throw ClientException('Failed to connect to Supabase: No internet');
}

class _SlowOnline extends Online {
  @override
  FutureOr<OnlineAccount?> build() => Completer<OnlineAccount?>().future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Health health;
  late _Protocol protocol;
  late _Purchases purchases;

  setUp(() {
    MockServices.setup();
    health = _Health();
    protocol = _Protocol();
    purchases = _Purchases();
    when(() => MockServices.databaseService.isInitialized).thenReturn(true);
    when(
      () => MockServices.notifications.initialize(),
    ).thenAnswer((_) async {});
    when(() => health.init()).thenAnswer((_) async {});
    when(() => protocol.initialize()).thenAnswer((_) async {});
    when(() => purchases.init()).thenAnswer((_) async {});
    MockServices.container.dispose();
    MockServices.container = ProviderContainer(
      retry: (_, __) => null,
      overrides: [
        ...MockServices.defaultOverrides,
        onlineProvider.overrideWith(_FailingOfflineOnlineNotifier.new),
        healthControllerProvider.overrideWithValue(health),
        nativeServiceProvider.overrideWithValue(_Native()),
        protocolServiceProvider.overrideWithValue(protocol),
        purchasesServiceProvider.overrideWithValue(purchases),
        foodNativeSyncProvider.overrideWith((ref) {}),
      ],
    );
  });
  tearDown(MockServices.tearDown);

  group('Application offline boot', () {
    testWidgets('remote error does not block local initialization', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await expectLater(
          MockServices.container
              .read(appStartupProvider.future)
              .timeout(const Duration(seconds: 3)),
          completes,
        );
      });
      verify(() => MockServices.notifications.initialize()).called(1);
      verify(() => health.init()).called(1);
      verify(() => protocol.initialize()).called(1);
    });

    testWidgets('online timeout still completes local initialization', (
      tester,
    ) async {
      MockServices.container.updateOverrides([
        ...MockServices.defaultOverrides,
        onlineProvider.overrideWith(_SlowOnline.new),
        healthControllerProvider.overrideWithValue(health),
        nativeServiceProvider.overrideWithValue(_Native()),
        protocolServiceProvider.overrideWithValue(protocol),
        purchasesServiceProvider.overrideWithValue(purchases),
        foodNativeSyncProvider.overrideWith((ref) {}),
      ]);
      await tester.runAsync(() async {
        await expectLater(
          MockServices.container
              .read(appStartupProvider.future)
              .timeout(const Duration(seconds: 12)),
          completes,
        );
      });
      verify(() => MockServices.notifications.initialize()).called(1);
      verify(() => protocol.initialize()).called(1);
    });
  });
}
