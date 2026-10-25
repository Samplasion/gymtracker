import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/intents_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:gymtracker/service/push.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/routines.dart';

/// Delays backup writes while a burst of user edits is in progress.
class BackupScheduler {
  BackupScheduler(this.database);
  final DatabaseService database;
  Timer? _pending;

  void schedule() {
    _pending?.cancel();
    _pending = Timer(const Duration(minutes: 1), () => database.createBackup());
  }

  void cancel() {
    _pending?.cancel();
    _pending = null;
  }

  void dispose() => cancel();
}

final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final scheduler = BackupScheduler(ref.watch(databaseServiceProvider));
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Explicit workout hand-off used by the database's serialized account changes.
class AccountWorkoutLifecycle {
  AccountWorkoutLifecycle(this.ref);
  final Ref ref;

  Future<void> suspend() {
    ref.read(backupSchedulerProvider).cancel();
    return ref.read(workoutControllerProvider.notifier).suspend();
  }

  Future<void> restore() async {
    final database = ref.read(databaseServiceProvider).db;
    final owner = database.currentUserId;
    final data = await database.watchOngoing().first;
    if (!ref.mounted ||
        database.currentUserId != owner ||
        data == null ||
        ref.read(workoutControllerProvider) != null) {
      return;
    }
    ref.read(workoutControllerProvider.notifier).restore(data);
  }
}

final accountWorkoutLifecycleProvider = Provider<AccountWorkoutLifecycle>((
  ref,
) {
  final lifecycle = AccountWorkoutLifecycle(ref);
  final database = ref.watch(databaseServiceProvider);
  database.beforeUserChange = lifecycle.suspend;
  database.afterUserChange = lifecycle.restore;
  ref.onDispose(() {
    database.beforeUserChange = null;
    database.afterUserChange = null;
  });
  return lifecycle;
});

Future<void> awaitRemoteInitialization(Future<dynamic> operation) async {
  try {
    await operation.timeout(const Duration(seconds: 10));
  } catch (error, stack) {
    globalLogger.w(
      'Remote initialization deferred; local data remains available',
      error: error,
      stackTrace: stack,
    );
  }
}

final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(translationsProvider.notifier).loadExercises();
  if (!ref.mounted) return;
  final database = ref.read(databaseServiceProvider);
  if (!database.isInitialized) {
    final ready = Completer<void>();
    await database.ensureInitialized(onDone: ready.complete);
    await ready.future;
  }
  ref.read(settingsControllerProvider);
  ref.read(pushServiceProvider);
  ref.watch(socialAccessListenerProvider);
  ref.watch(catalogWorkerProvider);
  ref.watch(hydrationWorkerProvider);
  Timer? socialSync;
  database.onSocialDataSaved = () {
    socialSync?.cancel();
    socialSync = Timer(const Duration(milliseconds: 100), () {
      if (ref.mounted && ref.read(currentUserIdProvider) != null) {
        unawaited(
          ref.read(onlineProvider.notifier).syncManager.syncTables().catchError(
            (Object error, StackTrace stack) {
              globalLogger.w(
                'Social publication deferred',
                error: error,
                stackTrace: stack,
              );
            },
          ),
        );
      }
    });
  };
  ref.onDispose(() {
    socialSync?.cancel();
    database.onSocialDataSaved = null;
  });
  ref.read(errorControllerProvider);
  ref.listen(foodNativeSyncProvider, (_, _) {});
  ref.read(routinesControllerProvider);
  // Keep the native shadow-routine and home-widget observers active even
  // while their screens have no consumers (Riverpod pauses unused listeners).
  ref.listen(routinesPresentationProvider, (_, _) {});
  ref.listen(historyControllerProvider, (_, _) {});
  // Cross-feature commands and achievement rules also read custom exercises
  // while the library screen is absent.
  ref.listen(exercisesControllerProvider, (_, _) {});
  final lifecycle = ref.read(accountWorkoutLifecycleProvider);
  final native = ref.read(nativeServiceProvider);
  final workout = ref.read(workoutControllerProvider.notifier);
  native.onMarkSetDone = () {
    if (ref.read(workoutControllerProvider) != null) {
      workout.autoMarkNextSetDone();
    }
  };
  native.onCursorNext = () =>
      ref.read(workoutControllerProvider) != null &&
      workout.moveSetCursorToNext();
  native.onCursorPrevious = () =>
      ref.read(workoutControllerProvider) != null &&
      workout.moveSetCursorToPrevious();
  native.onRequestTrainingData = () {
    if (ref.read(workoutControllerProvider) != null) {
      workout.refreshWatchData(
        primaryColor: Go.context == null
            ? null
            : Theme.of(Go.context!).colorScheme.primary,
      );
    }
  };
  native.onUpdateSetParameters = (weight, time, reps, distance) {
    if (ref.read(workoutControllerProvider) != null) {
      workout.updateSetParameters(weight, time, reps, distance);
    }
  };
  ref.onDispose(native.clearCallbacks);
  ref.listen(countdownControllerProvider, (_, _) {
    if (ref.read(workoutControllerProvider) != null) {
      workout.refreshWatchData(
        primaryColor: Go.context == null
            ? null
            : Theme.of(Go.context!).colorScheme.primary,
      );
    }
  });
  await Future.wait([
    lifecycle.restore(),
    ref.read(notificationControllerProvider).initialize(),
    ref.read(healthControllerProvider).init(),
    awaitRemoteInitialization(ref.read(onlineProvider.future)),
    awaitRemoteInitialization(ref.read(purchasesServiceProvider).init()),
  ]);
  if (!ref.mounted) return;
  ref.read(purchasesControllerProvider);
  ref.read(achievementsControllerProvider);
  final releaseIntents = IntentsController.initialize(
    start: (id, _) {
      final controller = ref.read(routinesControllerProvider);
      if (Go.context != null) {
        controller.startRoutine(Go.context!, controller.getRoutine(id));
      }
    },
  );
  ref.onDispose(releaseIntents);
  database.schedulePeriodicBackup();
  await ref.read(protocolServiceProvider).initialize();
});
