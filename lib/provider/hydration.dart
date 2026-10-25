import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/preferences.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/service/hydration_sync.dart';

final hydrationRepositoryProvider = Provider(
  (ref) => HydrationRepository(ref.watch(appDatabaseProvider)),
);
final waterEntriesProvider = StreamProvider<List<WaterEntry>>(
  (ref) => ref
      .watch(hydrationRepositoryProvider)
      .watch(ref.watch(currentUserIdProvider)),
);
final selectedWaterEntriesProvider = Provider((ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return (ref.watch(waterEntriesProvider).asData?.value ?? [])
      .where(
        (e) =>
            e.time.year == date.year &&
            e.time.month == date.month &&
            e.time.day == date.day,
      )
      .toList();
});
final foodWaterProvider = Provider<double>(
  (ref) => ref
      .watch(foodsForSelectedDateProvider)
      .fold(0.0, (total, food) => total + (food.nutritionalValues.water ?? 0)),
);
final hydrationSyncProvider = Provider((ref) {
  final service = HydrationSync(ref.watch(appDatabaseProvider));
  ref.onDispose(service.dispose);
  return service;
});
final hydrationStatusProvider = StreamProvider(
  (ref) => ref.watch(hydrationSyncProvider).status.stream,
);
final hydrationPermissionProvider = StreamProvider(
  (ref) => ref.watch(hydrationSyncProvider).permissionStatus.stream,
);
final hydrationNeedsPermissionProvider = Provider<bool>((ref) {
  final permission = ref.watch(hydrationPermissionProvider).asData?.value;
  return ref.watch(hydrationSyncProvider).health.supported &&
      (permission == HydrationPermission.denied ||
          permission == HydrationPermission.unknown);
});

/// Show a denied-permission explanation only on the first visit on this device.
final hydrationPageVisitProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final owner = ref.watch(currentUserIdProvider);
  final service = ref.watch(hydrationSyncProvider);
  if (!service.health.supported) return false;
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  if (!ref.mounted || ref.read(currentUserIdProvider) != owner) return false;
  final key = 'hydration.diaryVisited.${owner ?? 'guest'}';
  final firstVisit = !(prefs.getBool(key) ?? false);
  if (firstVisit) await prefs.setBool(key, true);
  if (!ref.mounted || ref.read(currentUserIdProvider) != owner) return false;
  final permission = await service.connectAutomatically(
    requestPermission: firstVisit,
  );
  return firstVisit && permission == HydrationPermission.denied;
});

final hydrationWorkerProvider = Provider<void>((ref) {
  final service = ref.watch(hydrationSyncProvider);
  ref.watch(currentUserIdProvider);
  void process() {
    unawaited(service.connectAutomatically());
  }

  ref.listen(waterEntriesProvider, (_, _) => process());
  ref.listen(foodLogsStreamProvider, (_, _) => process());
  final timer = Timer.periodic(const Duration(seconds: 30), (_) => process());
  final lifecycle = AppLifecycleListener(onResume: process);
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
  process();
});
