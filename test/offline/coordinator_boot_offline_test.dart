import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

import '../test_helpers/mock_services.dart';

class MockNotificationController extends Mock
    implements NotificationController {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

class MockPurchasesService extends Mock implements PurchasesService {}

class _FailingOfflineOnlineNotifier extends Online {
  @override
  FutureOr<OnlineAccount?> build() async {
    // Simulates onlineProvider failing due to no internet during app boot
    throw ClientException('Failed to connect to Supabase: No internet');
  }
}

class _SlowOnline extends Online {
  @override
  FutureOr<OnlineAccount?> build() => Completer<OnlineAccount?>().future;
}

class _BootCoordinator extends Coordinator {
  @override
  void loadColdbootDeeplink() {}
  @override
  void schedulePeriodicBackup() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Coordinator coordinator;
  late MockNotificationController mockNotificationController;
  late MockPurchasesService mockPurchasesService;

  setUp(() {
    MockServices.setup();
    mockNotificationController = MockNotificationController();
    mockPurchasesService = MockPurchasesService();

    when(
      () => MockServices.databaseService.prefs$,
    ).thenAnswer((_) => BehaviorSubject<Prefs>.seeded(Prefs.defaultValue));
    when(
      () => MockServices.settingsController.awaitInitialized(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationController.initialize(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationController.showSettingsTileStream,
    ).thenAnswer((_) => BehaviorSubject<bool>.seeded(false));
    when(() => mockPurchasesService.init()).thenAnswer((_) async {});

    Get.put<NotificationController>(mockNotificationController);
    Get.put<PurchasesService>(mockPurchasesService);
    Get.put(HealthController());

    // Override onlineProvider in globalContainer with an instance that fails on network
    globalContainer = ProviderContainer(
      retry: (_, __) => null,
      overrides: [
        onlineProvider.overrideWith(() => _FailingOfflineOnlineNotifier()),
        showFoodPermissionsSettingsTileProvider.overrideWith((_) => false),
      ],
    );

    coordinator = _BootCoordinator();
  });

  tearDown(() async {
    globalContainer.dispose();
    await MockServices.database.close();
    Get.reset();
  });

  group('Coordinator Offline Boot Tests', () {
    testWidgets('remote error does not block local initialization', (
      tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
      await tester.runAsync(() async {
        await expectLater(
          coordinator.awaitInitialized().timeout(const Duration(seconds: 3)),
          completes,
        );
      });
    });

    testWidgets('online timeout still completes local initialization', (
      tester,
    ) async {
      globalContainer.dispose();
      globalContainer = ProviderContainer(
        retry: (_, __) => null,
        overrides: [
          onlineProvider.overrideWith(_SlowOnline.new),
          showFoodPermissionsSettingsTileProvider.overrideWith((_) => false),
        ],
      );
      await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
      await tester.runAsync(() async {
        await expectLater(
          coordinator.awaitInitialized().timeout(const Duration(seconds: 12)),
          completes,
        );
      });
    });
  });
}
