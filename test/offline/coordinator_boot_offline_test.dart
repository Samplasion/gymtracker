import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
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

    // Override onlineProvider in globalContainer with an instance that fails on network
    globalContainer = ProviderContainer(
      overrides: [
        onlineProvider.overrideWith(() => _FailingOfflineOnlineNotifier()),
      ],
    );

    coordinator = Coordinator();
  });

  tearDown(() {
    Get.reset();
  });

  group('Coordinator Offline Boot Tests', () {
    testWidgets(
      'awaitInitialized() should complete without throwing when offline so cold boot does not hang',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(home: const Scaffold(body: Text('Loaded'))),
        );

        // Expected behavior for offline resilience:
        Object? bootError;
        bool bootCompleted = false;
        coordinator.awaitInitialized().then(
          (_) {
            bootCompleted = true;
          },
          onError: (e) {
            bootError = e;
          },
        );

        // Advance timers so Go.awaitInitialization() ticks and settles
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pump(const Duration(milliseconds: 2000));

        expect(
          bootCompleted,
          isTrue,
          reason:
              'Coordinator.awaitInitialized() hangs on onlineProvider offline failure, preventing bootProcedure() from ever executing',
        );
      },
    );
  });
}
