import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:gymtracker/view/utils/sync_recovery.dart';
import 'package:get/get.dart' hide Value;
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/utils.dart' show isNetworkError;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

export 'package:gymtracker/service/online.dart' show AuthException;

part 'online.g.dart';

class _SharedPrefsStorage extends SyncTimestampStorage {
  final SharedPreferences _prefs;
  final EventBus? _eventBus;

  _SharedPrefsStorage(this._prefs, [this._eventBus]);

  @override
  DateTime? getSyncTimestamp(String key) {
    final timestamp = _prefs.getInt(key);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
  }

  @override
  Future<void> setSyncTimestamp(String key, DateTime timestamp) async {
    await _prefs.setInt(key, timestamp.millisecondsSinceEpoch);
    _eventBus?.emit(GBSyncTimestampUpdatedEvent(timestamp));
  }
}

class GBSyncManager extends SyncManager<GTDatabase> {
  final EventBus eventBus;
  final Duration drainCheckInterval;
  int successfulSyncs = 0;
  String? _cycleUserId;

  GBSyncManager({
    required super.localDatabase,
    required super.supabaseClient,
    required this.eventBus,
    super.useProtocolV2,
    super.syncInterval,
    this.drainCheckInterval = const Duration(milliseconds: 100),
    super.syncTimestampStorage,
    super.otherDevicesConsideredInactiveAfter,
    super.maxRows,
  });

  bool get isSyncingTables => isSyncing;
  bool get isSyncingAny =>
      isSyncing || isSyncingFromBackend || isSyncingToBackend;

  Future<void> waitForAllTables({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (isSyncingAny) {
      if (stopwatch.elapsed >= timeout) {
        throw TimeoutException('Sync queue drain timed out', timeout);
      }
      await Future<void>.delayed(drainCheckInterval);
    }
  }

  @override
  void onSyncStarted() {
    _cycleUserId = userId;
    eventBus.emit(
      GBSyncStartedEvent(userId: _cycleUserId, cycleId: activeCycleId),
    );
  }

  @override
  void onSyncError(Object error, StackTrace stack) {
    final safe = useProtocolV2
        ? StateError(
            'Synchronization failed (${error is PostgrestException ? error.code : error.runtimeType})',
          )
        : error;
    super.onSyncError(safe, stack);
    eventBus.emit(GBSyncErrorEvent(safe, stack, _cycleUserId ?? userId));
  }

  @override
  void onSyncFinished({required bool success}) {
    if (success) successfulSyncs++;
    eventBus.emit(
      GBSyncFinishedEvent(
        lastSync: success ? DateTime.now() : null,
        userId: _cycleUserId,
        cycleId: activeCycleId,
        result: lastResult,
      ),
    );
    _cycleUserId = null;
  }

  @override
  Future<void> syncTables() async {
    try {
      await super.syncTables();
    } catch (e) {
      if (useProtocolV2 || !isNetworkError(e)) rethrow;
      logger.i('Sync deferred: $e');
    }
  }
}

@Riverpod(keepAlive: true)
String? currentUserId(Ref ref) {
  return ref.watch(onlineProvider).value?.id;
}

@Riverpod(keepAlive: true)
class Online extends _$Online {
  late final DatabaseService _databaseService;
  late final OnlineService _service;
  late SharedPreferences _prefs;
  late final GBSyncManager _syncManager;

  GBSyncManager get syncManager => _syncManager;
  OnlineService get onlineService => _service;

  OnlineAccount? get accountSync => state.value;

  Future<void> _transition = Future.value();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _transition.then((_) => action());
    _transition = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  void _resumeSync() {
    if ((ref.read(networkConnectivityProvider).value ?? false) &&
        _service.account?.id == _databaseService.db.currentUserId &&
        _service.account != null) {
      syncManager.enableSync();
    }
  }

  Future<T> _changeAuthentication<T>(Future<T> Function() action) =>
      _serialize(() async {
        await syncManager.suspend();
        try {
          final result = await action();
          await _applyAccount(_service.account);
          return result;
        } catch (_) {
          _resumeSync();
          rethrow;
        }
      });

  bool _isInit = false;
  bool get isInit => _isInit;

  Future<SyncResult> synchronize() async {
    final owner = state.value?.id ?? '';
    if (!syncManager.syncingEnabled)
      return SyncResult(SyncOutcome.disabled, userId: owner, cycleId: '');
    try {
      await syncManager.retryPending();
    } catch (e) {
      return SyncResult(
        isNetworkError(e) ? SyncOutcome.offline : SyncOutcome.partial,
        userId: owner,
        cycleId: syncManager.lastResult?.cycleId ?? '',
        pending: syncManager.lastResult?.pending ?? 0,
        error: e,
      );
    }
    return syncManager.lastResult ??
        SyncResult(SyncOutcome.cancelled, userId: owner, cycleId: '');
  }

  Future<bool> sync() async {
    if (syncManager.useProtocolV2) return (await synchronize()).completed;
    if (!syncManager.syncingEnabled) return false;
    final previous = syncManager.successfulSyncs;
    await syncManager.syncTables();
    return syncManager.successfulSyncs > previous;
  }

  Online({OnlineService? service}) {
    _databaseService = Get.find<DatabaseService>();
    if (service != null) {
      _service = service;
    } else if (TestService().isTest) {
      _service = TestOnlineServiceImpl();
    } else {
      _service = OnlineServiceImpl();
    }
  }

  bool get isSyncing => _syncManager.isSyncingAny;

  @override
  FutureOr<OnlineAccount?> build() async {
    if (!_isInit) {
      await _runOneTimeAsyncBoot();
    }

    ref.listen<AsyncValue<bool>>(networkConnectivityProvider, (previous, next) {
      _onNetworkStatusChanged(next.value ?? false);
    });
    ref.onDispose(() {
      _syncManager.dispose();
      _databaseService.runWithSyncPaused = null;
    });

    return _getAccountAndDoStuff();
  }

  Future<void> login({required String email, required String password}) =>
      _changeAuthentication(() async {
        ref.read(eventBusProvider).emit(GBUserWillLoginEvent());
        await _service.login(email: email, password: password);
      });

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) => _changeAuthentication(() async {
    ref.read(eventBusProvider).emit(GBUserWillLoginEvent());
    await _service.register(
      email: email,
      password: password,
      username: username,
    );
  });

  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {
    try {
      await _service.updateAccount(email: email, username: username);
      // Fetch the updated account to refresh state
      final updated = _service.account;
      state = AsyncValue.data(updated);
      if (updated != null)
        ref.read(friendProvider.notifier).invalidateProfile(updated.id);
    } catch (e, s) {
      logger.e(
        "An error occurred while updating account",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> updateProfile({String? fullName}) async {
    try {
      await _service.updateProfile(fullName: fullName);
      state = AsyncValue.data(_service.account);
    } catch (e, s) {
      logger.e(
        "An error occurred while updating profile",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> uploadAvatar(Uint8List bytes) async {
    try {
      await _service.uploadAvatar(bytes);
      state = AsyncValue.data(_service.account);
      final user = _service.account;
      if (user != null) {
        invalidateAvatarCache(user.id);
      }
    } catch (e, s) {
      logger.e(
        "An error occurred while uploading avatar",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> removeAvatar() async {
    try {
      await _service.removeAvatar();
      state = AsyncValue.data(_service.account);
      final user = _service.account;
      if (user != null) {
        invalidateAvatarCache(user.id);
      }
    } catch (e, s) {
      logger.e(
        "An error occurred while removing avatar",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  void invalidateAvatarCache(String userID) {
    try {
      ref.read(friendProvider.notifier).invalidateAvatarCache(userID);
    } catch (_) {}
  }

  Future<void> logout() => _changeAuthentication(() async {
    ref.read(eventBusProvider).emit(GBUserWillLogoutEvent(_service.account));
    await _service.logout();
  });

  CredentialsState checkCredentials({
    required String email,
    required String password,
    required String username,
  }) {
    final emailError =
        !email.contains('@') || !email.split("@")[1].contains('.');
    final passwordErrors = <PasswordValidationErrors>{};

    if (password.isNotEmpty) {
      if (password.length < 8) {
        passwordErrors.add(PasswordValidationErrors.length);
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        passwordErrors.add(PasswordValidationErrors.uppercase);
      }
      if (!password.contains(RegExp(r'[a-z]'))) {
        passwordErrors.add(PasswordValidationErrors.lowercase);
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        passwordErrors.add(PasswordValidationErrors.number);
      }
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) {
        passwordErrors.add(PasswordValidationErrors.specialCharacter);
      }
    }

    bool usernameError =
        username.length < 3 ||
        username.length > 20 ||
        username.contains(RegExp(r'[^a-zA-Z0-9_-]'));

    return CredentialsState.invalid(
      emailError: emailError,
      passwordErrors: passwordErrors,
      usernameError: usernameError,
    );
  }

  Future<Uri?> getAvatarUrl(String id) async {
    final url = await ref.read(friendProvider.notifier).getAvatar(id);
    return url == null ? null : Uri.parse(url);
  }

  Future<void> deleteAccount() => _serialize(() async {
    final account = _service.account;
    if (account == null) throw StateError('No account to delete');
    final manager = syncManager;
    final wasEnabled = manager.syncingEnabled;
    await manager.suspend();
    try {
      // A failed remote deletion must never erase the local copy.
      await _service.deleteAccount();
      manager.setUserId('');
      globalContainer
          .read(eventBusProvider)
          .emit(GBUserWillLogoutEvent(account));
      await _databaseService.setCurrentUserId(null);
      // Account-switch hooks may persist its active workout. Purge afterwards.
      await _databaseService.db.clearUserData(account.id);
      state = const AsyncValue.data(null);
      globalContainer.read(eventBusProvider).emit(GBUserDidLogoutEvent());
    } catch (_) {
      if (wasEnabled && _service.account?.id == account.id) {
        manager.enableSync();
      }
      rethrow;
    }
  });

  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) => _changeAuthentication(
    () => _service.checkEmailVerificationAndLogIn(
      email: email,
      password: password,
    ),
  );

  Future<void> _runOneTimeAsyncBoot() async {
    _prefs = await SharedPreferences.getInstance();
    _syncManager = GBSyncManager(
      localDatabase: _databaseService.db,
      supabaseClient: Supabase.instance.client,
      eventBus: ref.read(eventBusProvider),
      syncTimestampStorage: _SharedPrefsStorage(
        _prefs,
        ref.read(eventBusProvider),
      ),
      useProtocolV2: true,
      syncInterval: const Duration(seconds: 2),
      drainCheckInterval: const Duration(milliseconds: 100),
    );
    _isInit = true;

    _syncManager.registerSyncable<AchievementCompletion>(
      backendTable: 'achievements_v2',
      fromJson: AchievementCompletion.fromJson,
      companionConstructor:
          ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> achievementID = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AchievementsCompanion(
            userId: userId,
            updatedAt: updatedAt,
            deleted: deleted,
            achievementID: achievementID,
            level: level,
            completedAt: completedAt,
            rowid: rowid,
          ),
    );

    _syncManager.registerSyncable<RoutineFolder>(
      backendTable: 'routine_folders',
      fromJson: RoutineFolder.fromJson,
      companionConstructor: RoutineFoldersCompanion.new,
    );

    _syncManager.registerSyncable<Routine>(
      backendTable: 'routines',
      fromJson: Routine.fromJson,
      companionConstructor: RoutinesCompanion.new,
    );

    _syncManager.registerSyncable<HistoryWorkout>(
      backendTable: 'history_workouts',
      fromJson: HistoryWorkout.fromJson,
      companionConstructor: HistoryWorkoutsCompanion.new,
    );

    _syncManager.registerSyncable<CustomExercise>(
      backendTable: 'custom_exercises',
      fromJson: CustomExercise.fromJson,
      companionConstructor: CustomExercisesCompanion.new,
    );

    _syncManager.registerSyncable<RoutineExercise>(
      backendTable: 'routine_exercises',
      fromJson: RoutineExercise.fromJson,
      companionConstructor: RoutineExercisesCompanion.new,
    );

    _syncManager.registerSyncable<HistoryWorkoutExercise>(
      backendTable: 'history_workout_exercises',
      fromJson: HistoryWorkoutExercise.fromJson,
      companionConstructor: HistoryWorkoutExercisesCompanion.new,
    );

    _syncManager.registerSyncable<WeightMeasurement>(
      backendTable: 'weight_measurements',
      fromJson: WeightMeasurement.fromJson,
      companionConstructor: WeightMeasurementsCompanion.new,
    );

    _syncManager.registerSyncable<BodyMeasurement>(
      backendTable: 'body_measurements',
      fromJson: BodyMeasurement.fromJson,
      companionConstructor: BodyMeasurementsCompanion.new,
    );

    _syncManager.registerSyncable<DBFood>(
      backendTable: 'foods',
      fromJson: DBFood.fromJson,
      companionConstructor: FoodsCompanion.new,
    );

    _syncManager.registerSyncable<DBCustomBarcodeFood>(
      backendTable: 'custom_barcode_foods',
      fromJson: DBCustomBarcodeFood.fromJson,
      companionConstructor: CustomBarcodeFoodsCompanion.new,
    );

    _syncManager.registerSyncable<DBFavoriteFood>(
      backendTable: 'favorite_foods',
      fromJson: DBFavoriteFood.fromJson,
      companionConstructor: FavoriteFoodsCompanion.new,
    );

    _syncManager.registerSyncable<DBNutritionCategory>(
      backendTable: 'nutrition_categories',
      fromJson: DBNutritionCategory.fromJson,
      companionConstructor: NutritionCategoriesCompanion.new,
    );

    _syncManager.registerSyncable<DBNutritionGoal>(
      backendTable: 'nutrition_goals',
      fromJson: DBNutritionGoal.fromJson,
      companionConstructor: NutritionGoalsCompanion.new,
    );

    _databaseService.runWithSyncPaused = (action) => _serialize(() async {
      final wasEnabled = _syncManager.syncingEnabled;
      var drained = false;
      try {
        await _syncManager.runPaused(
          () async {
            drained = true;
            await action();
          },
          discardPendingOnSuccess: true,
          resume: false,
        );
      } finally {
        if (drained && wasEnabled) _resumeSync();
      }
    });
  }

  void _onNetworkStatusChanged(bool isOnline) {
    if (!isOnline) _syncManager.disableSync();
    if (isOnline) {
      unawaited(
        _getAccountAndDoStuff().catchError((Object e, StackTrace s) {
          logger.e('Unable to resume sync', error: e, stackTrace: s);
          return null;
        }),
      );
    }
  }

  Future<OnlineAccount?> _getAccountAndDoStuff() => _serialize(() async {
    final account = await _service.getAccount();
    await _applyAccount(account);
    return account;
  });

  Future<void> _applyAccount(OnlineAccount? account) async {
    final previous = _databaseService.db.currentUserId;
    final changed =
        previous != account?.id || _syncManager.userId != (account?.id ?? '');
    if (changed) {
      await _syncManager.suspend();
      _syncManager.setUserId(account?.id ?? '');
      await _databaseService.setCurrentUserId(account?.id);
      if (account != null) {
        final context = navigatorKey.currentContext;
        final key = 'guest_import_offered_${account.id}';
        if (context != null &&
            context.mounted &&
            !(_prefs.getBool(key) ?? false)) {
          await offerGuestImport(context, _databaseService, account.id);
          await _prefs.setBool(key, true);
        }
      }
    }
    state = AsyncValue.data(account);
    _resumeSync();
    if (changed) {
      final bus = ref.read(eventBusProvider);
      if (account != null) {
        bus.emit(GBUserDidLoginEvent(account));
      } else {
        bus.emit(GBUserDidLogoutEvent());
      }
    }
  }
}

class CredentialsState {
  final bool emailError;
  final Set<PasswordValidationErrors> passwordErrors;
  final bool usernameError;

  CredentialsState({
    required this.emailError,
    required this.passwordErrors,
    required this.usernameError,
  });

  factory CredentialsState.empty() => CredentialsState(
    emailError: false,
    passwordErrors: {},
    usernameError: false,
  );

  factory CredentialsState.invalid({
    required bool emailError,
    required Set<PasswordValidationErrors> passwordErrors,
    required bool usernameError,
  }) => CredentialsState(
    emailError: emailError,
    passwordErrors: passwordErrors,
    usernameError: usernameError,
  );

  bool get hasError => emailError || passwordErrors.isNotEmpty || usernameError;
  bool get hasErrorWithoutUsername => emailError || passwordErrors.isNotEmpty;

  T when<T>({
    T Function(
      bool emailError,
      Set<PasswordValidationErrors> passwordErrors,
      bool usernameError,
    )?
    invalid,
    T Function()? empty,
    required T Function() orElse,
  }) {
    if (emailError || passwordErrors.isNotEmpty || usernameError) {
      return invalid?.call(emailError, passwordErrors, usernameError) ??
          orElse();
    } else {
      return empty?.call() ?? orElse();
    }
  }
}

enum PasswordValidationErrors {
  length,
  uppercase,
  lowercase,
  number,
  specialCharacter,
}
