import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart' hide Value;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/struct/cache.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

export 'package:gymtracker/service/online.dart' show AuthException;

part 'online.g.dart';

class _SharedPrefsStorage extends SyncTimestampStorage {
  final SharedPreferences _prefs;

  _SharedPrefsStorage(this._prefs);

  @override
  DateTime? getSyncTimestamp(String key) {
    final timestamp = _prefs.getInt(key);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
  }

  @override
  Future<void> setSyncTimestamp(String key, DateTime timestamp) {
    return _prefs.setInt(key, timestamp.millisecondsSinceEpoch);
  }
}

@Riverpod(keepAlive: true)
class Online extends _$Online {
  late final DatabaseService _databaseService;
  late final OnlineService _service;
  late SharedPreferences _prefs;
  late final SyncManager _syncManager;

  SyncManager get syncManager => _syncManager;
  OnlineService get onlineService => _service;

  OnlineAccount? get accountSync => state.value;

  final Map<String, CachedData<Uri?>> _avatarCache = {};

  bool _isInit = false;

  Online() {
    _databaseService = Get.find<DatabaseService>();
    if (TestService().isTest) {
      _service = TestOnlineServiceImpl();
    } else {
      _service = OnlineServiceImpl();
    }
  }

  bool get isSyncing =>
      syncManager.isSyncingFromBackend || syncManager.isSyncingToBackend;

  @override
  FutureOr<OnlineAccount?> build() async {
    if (!_isInit) {
      await _runOneTimeAsyncBoot();
    }

    final eventBus = ref.watch(eventBusProvider);
    ref.listen<AsyncValue<bool>>(networkConnectivityProvider, (previous, next) {
      final isOnline = next.value ?? false;
      _onNetworkStatusChanged(isOnline);
    });

    final userDidLoginSub = eventBus.on<GBUserDidLoginEvent>().listen(
      _onUserDidLogin,
    );
    final userWillLogoutSub = eventBus.on<GBUserWillLogoutEvent>().listen(
      _onUserWillLogout,
    );

    ref.onDispose(userDidLoginSub.cancel);
    ref.onDispose(userWillLogoutSub.cancel);

    return _getAccountAndDoStuff();
  }

  Future<void> login({required String email, required String password}) async {
    try {
      globalContainer.read(eventBusProvider).emit(GBUserWillLoginEvent());
      await _service.login(email: email, password: password);
      globalContainer
          .read(eventBusProvider)
          .emit(GBUserDidLoginEvent(await onlineService.getAccount()));
    } on AuthApiException {
      rethrow;
    } catch (e, s) {
      logger.e("An error occurred while logging in", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      globalContainer.read(eventBusProvider).emit(GBUserWillLoginEvent());
      await _service.register(
        email: email,
        password: password,
        username: username,
      );
      globalContainer
          .read(eventBusProvider)
          .emit(GBUserDidLoginEvent(await onlineService.getAccount()));
    } catch (e, s) {
      logger.e("An error occurred while signing up", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {
    try {
      await _service.updateAccount(email: email, username: username);
      // Fetch the updated account to refresh state
      final updated = await _service.getAccount();
      state = AsyncValue.data(updated);
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
    _avatarCache.remove(userID);
    try {
      ref.read(friendProvider.notifier).invalidateAvatarCache(userID);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      globalContainer
          .read(eventBusProvider)
          .emit(GBUserWillLogoutEvent(onlineService.account));
      await _service.logout();
      globalContainer.read(eventBusProvider).emit(GBUserDidLogoutEvent());
    } catch (e, s) {
      logger.e("An error occurred while logging out", error: e, stackTrace: s);
      rethrow;
    }
  }

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
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
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
    if (_avatarCache.containsKey(id)) {
      final cached = _avatarCache[id]!;
      if (DateTime.now().difference(cached.downloaded) <
          const Duration(hours: 1)) {
        return cached.data;
      }
    }
    final time = DateTime.now();
    return _service.getAvatarUrl(id).then((uri) {
      if (uri == null) {
        _avatarCache.remove(id);
      } else {
        _avatarCache[id] = CachedData(time, uri);
      }
      return uri;
    });
  }

  void _onUserDidLogin(GBUserDidLoginEvent event) async {
    _getAccountAndDoStuff(accountFromEvents: event.account);
  }

  Future<void> _fillMissingUserIdAndTouchStaleTimestamps(String userId) async {
    await _syncManager.fillMissingUserIdForLocalTables();
    await _databaseService.db.touchStaleTimestamps(userId);
  }

  void _onUserWillLogout(GBUserWillLogoutEvent event) async {
    state = const AsyncValue.data(null);
    _syncManager.disableSync();
    _databaseService.setCurrentUserId(null);
  }

  Future<void> deleteAccount() async {
    await Get.find<DatabaseService>().db
        .clearTheWholeThingIAmAbsolutelySureISwear();
    return _service.deleteAccount().then((_) {
      globalContainer.read(eventBusProvider).emit(GBUserDidLogoutEvent());
    });
  }

  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) async {
    return _service.checkEmailVerificationAndLogIn(
      email: email,
      password: password,
    );
  }

  Future<void> _runOneTimeAsyncBoot() async {
    _prefs = await SharedPreferences.getInstance();
    _syncManager = SyncManager(
      localDatabase: _databaseService.db,
      supabaseClient: Supabase.instance.client,
      syncTimestampStorage: _SharedPrefsStorage(_prefs),
      syncInterval: const Duration(minutes: 5),
    );

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

    final account = await _service.getAccount();
    // Emit login event at app start
    if (account != null) {
      globalContainer.read(eventBusProvider).emit(GBUserDidLoginEvent(account));
    }

    _isInit = true;
  }

  // Handle network changes without re-running build()
  void _onNetworkStatusChanged(bool isOnline) {
    if (isOnline) {
      // Avoid double-enabling sync if already enabled.
      if (!_syncManager.syncingEnabled) {
        _syncManager.enableSync();
      }
      _getAccountAndDoStuff();
    } else {
      if (_syncManager.syncingEnabled) {
        _syncManager.disableSync();
      }
    }
  }

  Future<OnlineAccount?> _getAccountAndDoStuff({
    OnlineAccount? accountFromEvents,
  }) async {
    state = const AsyncValue.loading();
    final account = accountFromEvents ?? await _service.getAccount();
    state = AsyncValue.data(account);
    if (account != null) {
      _syncManager.setUserId(account.id);
      if (ref.read(networkConnectivityProvider).value ?? false) {
        _syncManager.enableSync();
      }
      _databaseService.setCurrentUserId(account.id);
      await _fillMissingUserIdAndTouchStaleTimestamps(account.id);
    }
    return account;
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
