import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:gymtracker/view/actions/notifications.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:rxdart/rxdart.dart';

import '../test_helpers/mock_services.dart';

class _Online extends Mock implements OnlineService {}

class _Health extends Mock implements Health {}

class _Boutique extends Mock implements BoutiqueRepository {}

class _Purchases extends Mock implements PurchasesService {}

class _PurchaseResult extends Mock implements rc.PurchaseResult {}

class _CustomerInfo extends Mock implements rc.CustomerInfo {}

Future<void> _flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(<AchievementCompletion>[]);
    registerFallbackValue(<HealthDataType>[]);
    registerFallbackValue(
      const Subscription(
        productId: 's',
        price: '1',
        displayName: 'S',
        duration: SubscriptionPeriod.month,
      ),
    );
  });
  setUp(MockServices.setup);
  tearDown(() {
    MockServices.tearDown();
  });

  group('Achievement unlock behavior', () {
    late AchievementsController c;
    late BehaviorSubject<List<AchievementCompletion>> completions;
    late Achievement achievement;
    late List<Map<Achievement, List<AchievementCompletion>>> presented;
    setUp(() {
      final online = _Online();
      when(() => online.account).thenReturn(OnlineAccount(id: 'A', name: 'A'));
      completions = BehaviorSubject.seeded([]);
      addTearDown(completions.close);
      when(
        () => MockServices.databaseService.completions$,
      ).thenAnswer((_) => completions);
      when(
        () => MockServices.databaseService.insertAchievementCompletions(any()),
      ).thenAnswer((inv) async {
        completions.add([
          ...completions.value,
          ...inv.positionalArguments.single as List<AchievementCompletion>,
        ]);
      });
      achievement = Achievement(
        id: 'test',
        nameKey: 'test',
        iconKey: 'test',
        levels: [
          for (var level = 1; level <= 2; level++)
            AchievementLevel(
              achievementID: 'test',
              level: level,
              nameKey: 'n',
              descriptionKey: 'd',
              trigger: AchievementTrigger.workout,
              checkCompletion: (_) => true,
            ),
        ],
      );
      presented = [];
      c = AchievementsController(
        online,
        service: MockServices.databaseService,
        events: MockServices.container.read(eventBusProvider),
        isSyncing: () => false,
        catalog: {'test': achievement},
        unlocksEnabled: () => true,
        present: presented.add,
      );
    });
    test('unlocks consecutive levels and persists owner once', () {
      final result = c.maybeUnlockAchievements(AchievementTrigger.workout);
      expect(result[achievement]!.map((e) => e.level), [1, 2]);
      expect(completions.value.map((e) => e.userId), ['A', 'A']);
      expect(presented.single, same(result));
      expect(c.maybeUnlockAchievements(AchievementTrigger.workout), isEmpty);
      expect(completions.value, hasLength(2));
    });
    test('different trigger cannot unlock initial level', () {
      expect(c.maybeUnlockAchievements(AchievementTrigger.food), isEmpty);
      expect(completions.value, isEmpty);
    });
    test(
      'disposed achievements ignore late login events and further commands',
      () async {
        c.init();
        c.dispose();
        MockServices.container
            .read(eventBusProvider)
            .emit(GBUserWillLoginEvent());
        await _flush();
        expect(
          c.maybeUnlockAchievements(AchievementTrigger.workout)[achievement],
          isNull,
        );
        expect(completions.value, isEmpty);
      },
    );
    testWidgets('login event suppresses unlocks for thirty seconds', (
      tester,
    ) async {
      c.init();
      MockServices.container
          .read(eventBusProvider)
          .emit(GBUserWillLoginEvent());
      await tester.pump();
      expect(c.maybeUnlockAchievements(AchievementTrigger.workout), isEmpty);
      await tester.pump(const Duration(seconds: 30));
      expect(
        c.maybeUnlockAchievements(AchievementTrigger.workout)[achievement],
        hasLength(2),
      );
      c.dispose();
    });
  });

  group('Boutique contract', () {
    late _Boutique repository;
    late BoutiqueController c;
    setUp(() {
      repository = _Boutique();
      when(() => repository.getSettings()).thenAnswer(
        (_) async => const BoutiqueSettings(
          compatibility: '>=0.1.0 <1.0.0',
          enabled: true,
        ),
      );
      when(() => repository.getCategories()).thenAnswer((_) async => []);
      when(
        () => repository.getPackages(any(), language: any(named: 'language')),
      ).thenAnswer((_) async => []);
      c = BoutiqueController(
        installRoutines: (_) {},
        repository: repository,
        version: () => '0.15.1',
      );
    });
    test('caches settings and categories until invalidated', () async {
      expect((await c.getCategories()).isSuccess, isTrue);
      await c.getCategories();
      verify(() => repository.getSettings()).called(1);
      verify(() => repository.getCategories()).called(1);
      c.invalidateCache();
      await c.getCategories();
      verify(() => repository.getCategories()).called(1);
    });
    test('package cache is partitioned by category and language', () async {
      await c.getPackages('a', language: 'it');
      await c.getPackages('a', language: 'it');
      await c.getPackages('a', language: 'en');
      await c.getPackages('b', language: 'it');
      verify(() => repository.getPackages('a', language: 'it')).called(1);
      verify(() => repository.getPackages('a', language: 'en')).called(1);
      verify(() => repository.getPackages('b', language: 'it')).called(1);
    });
    test('incompatible version prevents catalog request', () async {
      c = BoutiqueController(
        installRoutines: (_) {},
        repository: repository,
        version: () => '2.0.0',
      );
      expect((await c.getCategories()).error, BoutiqueError.version);
      verifyNever(() => repository.getCategories());
    });
    test(
      'disabled catalog and unexpected errors return typed failures',
      () async {
        when(() => repository.getSettings()).thenAnswer(
          (_) async =>
              const BoutiqueSettings(compatibility: 'any', enabled: false),
        );
        expect((await c.getCategories()).error, BoutiqueError.unknown);
        c.invalidateCache();
        when(() => repository.getSettings()).thenThrow(StateError('offline'));
        expect(
          (await c.getPackages('a', language: 'it')).error,
          BoutiqueError.unknown,
        );
      },
    );
  });

  group('Health permissions', () {
    test('configure and permission results update observed state', () async {
      final health = _Health();
      when(() => health.configure()).thenAnswer((_) async {});
      when(() => health.hasPermissions(any())).thenAnswer((_) async => false);
      when(
        () => health.requestAuthorization(any()),
      ).thenAnswer((_) async => true);
      final c = HealthController(health: health);
      await c.init();
      await _flush();
      expect(c.hasPermissionStream.value, isFalse);
      c.requestPermission();
      await _flush();
      expect(c.hasPermissionStream.value, isTrue);
      await c.hasPermissionStream.close();
    });
    test('already granted permissions do not trigger authorization', () async {
      final health = _Health();
      when(() => health.hasPermissions(any())).thenAnswer((_) async => true);
      final c = HealthController(health: health);
      c.requestPermission();
      await _flush();
      verifyNever(() => health.requestAuthorization(any()));
      await c.hasPermissionStream.close();
    });
    test('null platform permission is treated as denied', () async {
      final health = _Health();
      when(() => health.configure()).thenAnswer((_) async {});
      when(() => health.hasPermissions(any())).thenAnswer((_) async => null);
      final c = HealthController(health: health);
      await c.init();
      await _flush();
      expect(c.hasPermissionStream.value, isFalse);
      await c.hasPermissionStream.close();
    });
  });

  group('Notification permission state', () {
    test(
      'exact alarm prompt requires notification permission and missing exact permission',
      () {
        final c = NotificationController(service: NotificationsService());
        expect(c.shouldShowAndroidExactAlarmPermissionRequest, isFalse);
        c.hasPermission = true;
        c.usesAndroidExactAlarmPermission = true;
        expect(c.shouldShowAndroidExactAlarmPermissionRequest, isTrue);
        c.hasAndroidScheduleExactAlarmPermission = true;
        expect(c.shouldShowAndroidExactAlarmPermissionRequest, isFalse);
      },
    );
    test(
      'requests with no applicable permission requirement return without UI',
      () async {
        final c = NotificationController(service: NotificationsService());
        await c.androidRequestExactAlarmsPermission();
        c.usesAndroidExactAlarmPermission = true;
        await c.androidRequestExactAlarmsPermission();
        c.hasPermission = true;
        c.hasAndroidScheduleExactAlarmPermission = true;
        await c.androidRequestExactAlarmsPermission();
      },
    );
  });

  group('Purchases behavior', () {
    late _Purchases service;
    late _Online online;
    late PurchasesController c;
    late StreamController<rc.EntitlementInfo?> entitlement;
    const subscription = Subscription(
      productId: 's',
      price: '1',
      displayName: 'S',
      duration: SubscriptionPeriod.month,
    );
    const active = rc.EntitlementInfo(
      'pro',
      true,
      true,
      '2026-01-01',
      '2026-01-01',
      's',
      true,
      periodType: rc.PeriodType.trial,
    );
    setUp(() {
      service = _Purchases();
      online = _Online();
      entitlement = StreamController.broadcast();
      addTearDown(entitlement.close);
      when(
        () => service.entitlementStream,
      ).thenAnswer((_) => entitlement.stream);
      when(
        () => service.isPurchasingEnabled,
      ).thenReturn({PurchasesCheckType.read, PurchasesCheckType.write});
      when(() => service.isInitialized()).thenReturn(true);
      when(() => service.login(any())).thenAnswer((_) async {});
      when(() => service.logout()).thenAnswer((_) async {});
      when(() => service.getCustomerInfo()).thenAnswer((_) async => active);
      when(() => online.account).thenReturn(null);
      c = PurchasesController(
        service,
        online,
        events: MockServices.container.read(eventBusProvider),
      );
      addTearDown(c.dispose);
    });
    for (final native in [true, false]) {
      test(
        '${native ? "native" : "REST"} binds restored account and tracks its ID through updates and logout',
        () async {
          await c.dispose();
          final account = OnlineAccount(id: 'restored-user', name: 'Restored');
          when(() => online.account).thenReturn(account);
          when(() => service.isPurchasingEnabled).thenReturn({
            PurchasesCheckType.read,
            if (native) PurchasesCheckType.write,
          });
          final bus = MockServices.container.read(eventBusProvider);
          // The startup login event has already been delivered before creation.
          bus.emit(GBUserDidLoginEvent(account));
          await _flush();
          final restored = PurchasesController(service, online, events: bus);
          addTearDown(restored.dispose);
          await _flush();

          verify(() => service.login(account.id)).called(1);
          expect(restored.subscriptionInfo.isPro, isTrue);
          expect(restored.subscriptionInfo.userID, account.id);
          expect((await restored.getSubscriptionInfo()).userID, account.id);

          entitlement.add(null);
          await _flush();
          expect(restored.subscriptionInfo.isPro, isFalse);
          expect(restored.subscriptionInfo.userID, account.id);

          when(
            () => service.restorePurchases(),
          ).thenAnswer((_) async => _CustomerInfo());
          await restored.restorePurchases();
          expect(restored.subscriptionInfo.userID, account.id);

          final other = OnlineAccount(id: 'other-user', name: 'Other');
          when(() => online.account).thenReturn(other);
          when(() => service.getCustomerInfo()).thenAnswer((_) async => null);
          bus.emit(GBUserDidLoginEvent(other));
          await _flush();
          verify(() => service.login(other.id)).called(1);
          expect(restored.subscriptionInfo.isPro, isFalse);
          expect(restored.subscriptionInfo.userID, other.id);

          when(() => online.account).thenReturn(null);
          bus.emit(GBUserDidLogoutEvent());
          await _flush();
          expect(restored.subscriptionInfo, SubscriptionInfo.empty);
        },
      );
    }
    test('account switch discards an in-flight subscription read', () async {
      final pending = Completer<rc.EntitlementInfo?>();
      final account = OnlineAccount(id: 'A', name: 'A');
      when(() => online.account).thenReturn(account);
      when(() => service.getCustomerInfo()).thenAnswer((_) => pending.future);
      final result = c.getSubscriptionInfo();
      when(() => online.account).thenReturn(null);
      MockServices.container
          .read(eventBusProvider)
          .emit(GBUserDidLogoutEvent());
      await _flush();
      pending.complete(active);
      expect(await result, SubscriptionInfo.empty);
    });
    for (final native in [true, false]) {
      group(native ? 'native races' : 'REST races', () {
        late EventBus bus;
        late OnlineAccount a;
        late OnlineAccount b;
        setUp(() async {
          when(() => service.isPurchasingEnabled).thenReturn({
            PurchasesCheckType.read,
            if (native) PurchasesCheckType.write,
          });
          bus = MockServices.container.read(eventBusProvider);
          a = OnlineAccount(id: 'A', name: 'A');
          b = OnlineAccount(id: 'B', name: 'B');
          when(() => online.account).thenReturn(a);
          bus.emit(GBUserDidLoginEvent(a));
          await _flush();
          expect(c.subscriptionInfo.isPro, isTrue);
        });

        test(
          'clears old access while login is pending and rejects updates after failure',
          () async {
            final login = Completer<void>();
            when(() => service.login('B')).thenAnswer((_) => login.future);
            when(() => online.account).thenReturn(b);
            bus.emit(GBUserDidLoginEvent(b));
            await _flush();
            expect(c.subscriptionInfo.isPro, isFalse);
            expect(c.subscriptionInfo.userID, 'B');
            entitlement.add(active);
            await _flush();
            expect(c.subscriptionInfo.isPro, isFalse);
            login.completeError(StateError('login failed'));
            await _flush();
            entitlement.add(active);
            await _flush();
            expect(c.subscriptionInfo.isPro, isFalse);
            expect((await c.getSubscriptionInfo()).isPro, isFalse);
          },
        );

        test(
          'reads wait for the pending login instead of using the previous SDK user',
          () async {
            final login = Completer<void>();
            when(() => service.login('B')).thenAnswer((_) => login.future);
            when(() => online.account).thenReturn(b);
            bus.emit(GBUserDidLoginEvent(b));
            await _flush();
            clearInteractions(service);
            final info = c.getSubscriptionInfo();
            await _flush();
            verifyNever(() => service.getCustomerInfo());
            when(() => service.getCustomerInfo()).thenAnswer((_) async => null);
            login.complete();
            final result = await info;
            expect(result.isPro, isFalse);
            expect(result.userID, 'B');
          },
        );

        test(
          'older refresh cannot overwrite a newer response or stream update',
          () async {
            final first = Completer<rc.EntitlementInfo?>();
            final second = Completer<rc.EntitlementInfo?>();
            var reads = 0;
            when(
              () => service.getCustomerInfo(),
            ).thenAnswer((_) => ++reads == 1 ? first.future : second.future);
            bus.emit(
              GBUserDidUpdateSubscriptionEvent(
                user: a,
                subscription: subscription,
              ),
            );
            await _flush();
            bus.emit(
              GBUserDidUpdateSubscriptionEvent(
                user: a,
                subscription: subscription,
              ),
            );
            await _flush();
            second.complete(active);
            await _flush();
            first.complete(null);
            await _flush();
            expect(c.subscriptionInfo.isPro, isTrue);
            expect(c.subscriptionInfo.userID, 'A');
            final third = Completer<rc.EntitlementInfo?>();
            when(
              () => service.getCustomerInfo(),
            ).thenAnswer((_) => third.future);
            bus.emit(
              GBUserDidUpdateSubscriptionEvent(
                user: a,
                subscription: subscription,
              ),
            );
            await _flush();
            entitlement.add(null);
            await _flush();
            third.complete(active);
            await _flush();
            expect(c.subscriptionInfo.isPro, isFalse);
          },
        );

        test(
          'late restore cannot replace the next account subscription',
          () async {
            final restore = Completer<rc.CustomerInfo>();
            when(
              () => service.restorePurchases(),
            ).thenAnswer((_) => restore.future);
            final result = c.restorePurchases();
            await _flush();
            when(() => online.account).thenReturn(b);
            when(() => service.getCustomerInfo()).thenAnswer((_) async => null);
            bus.emit(GBUserDidLoginEvent(b));
            await _flush();
            clearInteractions(service);
            restore.complete(_CustomerInfo());
            await result;
            verifyNever(() => service.getCustomerInfo());
            expect(c.subscriptionInfo.isPro, isFalse);
            expect(c.subscriptionInfo.userID, 'B');
          },
        );
      });
    }
    test('restored account waits for slow service initialization', () async {
      await c.dispose();
      final ready = Completer<void>();
      var initialized = false;
      when(() => service.isInitialized()).thenAnswer((_) => initialized);
      when(() => service.init()).thenAnswer((_) => ready.future);
      when(
        () => service.isPurchasingEnabled,
      ).thenAnswer((_) => initialized ? {PurchasesCheckType.read} : {});
      when(() => online.account).thenReturn(OnlineAccount(id: 'A', name: 'A'));
      final restored = PurchasesController(
        service,
        online,
        events: MockServices.container.read(eventBusProvider),
      );
      addTearDown(restored.dispose);
      await _flush();
      verifyNever(() => service.login(any()));
      initialized = true;
      ready.complete();
      await _flush();
      verify(() => service.login('A')).called(1);
      expect(restored.subscriptionInfo.userID, 'A');
      expect(restored.subscriptionInfo.isPro, isTrue);
    });
    test(
      'purchase completion does not emit an update for a different account',
      () async {
        final bus = MockServices.container.read(eventBusProvider);
        final a = OnlineAccount(id: 'A', name: 'A');
        when(() => online.account).thenReturn(a);
        bus.emit(GBUserDidLoginEvent(a));
        await _flush();
        final pending = Completer<rc.PurchaseResult>();
        when(
          () => service.purchaseSubscription(subscription),
        ).thenAnswer((_) => pending.future);
        final updates = <GBUserDidUpdateSubscriptionEvent>[];
        final listener = bus.on<GBUserDidUpdateSubscriptionEvent>().listen(
          updates.add,
        );
        addTearDown(listener.cancel);
        final purchase = c.purchaseSubscription(subscription);
        await _flush();
        final b = OnlineAccount(id: 'B', name: 'B');
        when(() => online.account).thenReturn(b);
        bus.emit(GBUserDidLoginEvent(b));
        await _flush();
        pending.complete(_PurchaseResult());
        expect(await purchase, SubscriptionPurchaseStatus.success);
        await _flush();
        expect(updates, isEmpty);
        expect(c.subscriptionInfo.userID, 'B');
      },
    );

    test('native paywall waits for account identification', () async {
      final login = Completer<void>();
      when(() => service.login('A')).thenAnswer((_) => login.future);
      when(() => service.presentPaywall()).thenAnswer((_) async {});
      final a = OnlineAccount(id: 'A', name: 'A');
      when(() => online.account).thenReturn(a);
      MockServices.container
          .read(eventBusProvider)
          .emit(GBUserDidLoginEvent(a));
      await _flush();
      final paywall = c.presentNativePaywall();
      await _flush();
      verifyNever(() => service.presentPaywall());
      login.complete();
      await paywall;
      verify(() => service.presentPaywall()).called(1);
    });
    test(
      'customer center waits for login and ignores completion after account switch',
      () async {
        final login = Completer<void>();
        final center = Completer<void>();
        when(() => service.login('A')).thenAnswer((_) => login.future);
        when(
          () => service.presentCustomerCenter(),
        ).thenAnswer((_) => center.future);
        final bus = MockServices.container.read(eventBusProvider);
        final a = OnlineAccount(id: 'A', name: 'A');
        when(() => online.account).thenReturn(a);
        bus.emit(GBUserDidLoginEvent(a));
        await _flush();
        final presentation = c.presentCustomerCenter();
        await _flush();
        verifyNever(() => service.presentCustomerCenter());
        login.complete();
        await _flush();
        verify(() => service.presentCustomerCenter()).called(1);
        final b = OnlineAccount(id: 'B', name: 'B');
        when(() => online.account).thenReturn(b);
        when(() => service.getCustomerInfo()).thenAnswer((_) async => null);
        bus.emit(GBUserDidLoginEvent(b));
        await _flush();
        clearInteractions(service);
        center.complete();
        await presentation;
        await _flush();
        verifyNever(() => service.getCustomerInfo());
        expect(c.subscriptionInfo.userID, 'B');
        expect(c.subscriptionInfo.isPro, isFalse);
      },
    );
    test('maps entitlement active trial and expiration flags', () async {
      final info = await c.getSubscriptionInfo();
      expect(info.isPro, isTrue);
      expect(info.isTrial, isTrue);
      expect(info.isAboutToExpire, isFalse);
      when(() => service.getCustomerInfo()).thenAnswer((_) async => null);
      expect((await c.getSubscriptionInfo()).hasProFeatures, isFalse);
    });
    test('purchase reports success cancellation and other failures', () async {
      when(
        () => service.purchaseSubscription(subscription),
      ).thenAnswer((_) async => _PurchaseResult());
      expect(
        await c.purchaseSubscription(subscription),
        SubscriptionPurchaseStatus.success,
      );
      // Platform APIs return failed futures, rather than throwing before returning.
      when(() => service.purchaseSubscription(subscription)).thenAnswer(
        (_) async =>
            throw PlatformException(code: 'cancel', message: 'cancelled'),
      );
      expect(
        await c.purchaseSubscription(subscription),
        SubscriptionPurchaseStatus.cancelled,
      );
      when(
        () => service.purchaseSubscription(subscription),
      ).thenAnswer((_) async => throw StateError('network'));
      expect(
        await c.purchaseSubscription(subscription),
        SubscriptionPurchaseStatus.error,
      );
    });
    test('restore refreshes state and propagates errors', () async {
      when(
        () => service.restorePurchases(),
      ).thenAnswer((_) async => throw StateError('offline'));
      await expectLater(c.restorePurchases(), throwsStateError);
    });
    test('logout makes in-flight login results obsolete', () async {
      final pending = Completer<void>();
      final a = OnlineAccount(id: 'A', name: 'A');
      when(() => online.account).thenReturn(a);
      when(() => service.login('A')).thenAnswer((_) => pending.future);
      MockServices.container
          .read(eventBusProvider)
          .emit(GBUserDidLoginEvent(a));
      await _flush();
      when(() => online.account).thenReturn(null);
      MockServices.container
          .read(eventBusProvider)
          .emit(GBUserDidLogoutEvent());
      await _flush();
      pending.complete();
      await _flush();
      expect(c.subscriptionInfo, SubscriptionInfo.empty);
      verify(() => service.logout()).called(1);
    });
  });
}
