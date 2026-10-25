import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/preferences.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hydration_test.dart' show FakeHydrationHealth;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late FakeHydrationHealth health;
  late HydrationSync service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    health = FakeHydrationHealth();
    service = HydrationSync(db, health: health);
    container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => null),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        hydrationSyncProvider.overrideWithValue(service),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    service.dispose();
    await db.close();
  });

  test('existing write permission starts export silently', () async {
    health.currentPermission = HydrationPermission.granted;
    await HydrationRepository(db).save(
      milliliters: 250,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect(await service.connectAutomatically(), HydrationPermission.granted);
    expect(health.authorizationRequests, 0);
    expect(health.records.values, [250]);
  });

  test(
    'first visit requests once and shows denial only for that visit',
    () async {
      health.authorized = false;
      expect(await service.connectAutomatically(), HydrationPermission.unknown);
      expect(health.authorizationRequests, 0);
      final subscription = container.listen(
        hydrationPageVisitProvider,
        (_, _) {},
      );
      expect(await container.read(hydrationPageVisitProvider.future), isTrue);
      expect(health.authorizationRequests, 1);
      container.invalidate(hydrationPageVisitProvider);
      expect(await container.read(hydrationPageVisitProvider.future), isFalse);
      expect(health.authorizationRequests, 1);
      subscription.close();
    },
  );

  test('known denial is explained without re-requesting access', () async {
    health.currentPermission = HydrationPermission.denied;
    final subscription = container.listen(
      hydrationPageVisitProvider,
      (_, _) {},
    );
    expect(await container.read(hydrationPageVisitProvider.future), isTrue);
    expect(health.authorizationRequests, 0);
    subscription.close();
  });

  test(
    'a permission granted in system Settings is picked up without a prompt',
    () async {
      health.currentPermission = HydrationPermission.denied;
      await service.connectAutomatically();
      final subscription = container.listen(
        hydrationNeedsPermissionProvider,
        (_, _) {},
      );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(hydrationNeedsPermissionProvider), isTrue);
      health.currentPermission = HydrationPermission.granted;
      await service.connectAutomatically();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(hydrationNeedsPermissionProvider), isFalse);
      expect(health.authorizationRequests, 0);
      subscription.close();
    },
  );

  test('unavailable services do not prompt or show a denial banner', () async {
    health.supported = false;
    final subscription = container.listen(
      hydrationPageVisitProvider,
      (_, _) {},
    );
    expect(await container.read(hydrationPageVisitProvider.future), isFalse);
    expect(health.authorizationRequests, 0);
    subscription.close();
  });
}
