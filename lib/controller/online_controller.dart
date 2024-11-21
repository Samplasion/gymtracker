import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:gymtracker/service/online.dart' show AuthException;

enum SyncMode {
  download,
  upload,
  conflict,
  allSynced,
}

class _CachedData<T> {
  final DateTime downloaded;
  final T data;

  const _CachedData(this.downloaded, this.data);
}

class OnlineController extends GetxController with ServiceableController {
  bool _isInit = false;

  final OnlineService _service = OnlineServiceImpl();
  late SharedPreferences _prefs;

  final _account$ = BehaviorSubject<OnlineAccount?>.seeded(null);
  Stream<OnlineAccount?> get account => _account$.stream;
  OnlineAccount? get accountSync => _account$.value;

  final _isOnlineServiceEnabled$ = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get isOnlineServiceEnabled => _isOnlineServiceEnabled$.stream;
  bool get isOnlineServiceEnabledSync => _isOnlineServiceEnabled$.value;

  DateTime get _lastModified => DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt("last_modified") ?? 0,
        isUtc: true,
      );
  set _lastModified(DateTime value) =>
      _prefs.setInt("last_modified", value.millisecondsSinceEpoch);
  DateTime get _lastSuccessfulSync => DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt("last_successful_sync") ??
            _lastModified.millisecondsSinceEpoch,
        isUtc: true,
      );
  set _lastSuccessfulSync(DateTime value) =>
      _prefs.setInt("last_successful_sync", value.millisecondsSinceEpoch);

  final Map<String, _CachedData<Uri?>> _avatarCache = {};

  /// Disabled if the remote data was synced using a newer version of the app
  bool _isSyncEnabled = true;

  static SyncMode getSyncMode({
    required DateTime localLastModified,
    required DateTime remoteLastModified,
    required DateTime lastSuccessfulSync,
  }) {
    if (lastSuccessfulSync.millisecondsSinceEpoch >=
            localLastModified.millisecondsSinceEpoch &&
        lastSuccessfulSync.millisecondsSinceEpoch >=
            remoteLastModified.millisecondsSinceEpoch) {
      if (localLastModified.millisecondsSinceEpoch ==
          remoteLastModified.millisecondsSinceEpoch) {
        globalLogger.i("Local and remote databases are in sync");
        return SyncMode.allSynced;
      } else if (localLastModified.millisecondsSinceEpoch >
          remoteLastModified.millisecondsSinceEpoch) {
        globalLogger.i("Local database is newer than remote");
        return SyncMode.upload;
      } else if (remoteLastModified.millisecondsSinceEpoch >
          localLastModified.millisecondsSinceEpoch) {
        globalLogger.i("Remote database is newer than local");
        return SyncMode.download;
      }
    }

    globalLogger.d((lastSuccessfulSync.millisecondsSinceEpoch <
        localLastModified.millisecondsSinceEpoch));

    if (lastSuccessfulSync.millisecondsSinceEpoch <
        localLastModified.millisecondsSinceEpoch) {
      if (localLastModified.millisecondsSinceEpoch >
          remoteLastModified.millisecondsSinceEpoch) {
        globalLogger.i("Local database is newer than remote");
        return SyncMode.upload;
      } else if (lastSuccessfulSync.millisecondsSinceEpoch <
          remoteLastModified.millisecondsSinceEpoch) {
        globalLogger.i("Remote database is newer than local");
        return SyncMode.conflict;
      }
    } else if (lastSuccessfulSync.millisecondsSinceEpoch <
        remoteLastModified.millisecondsSinceEpoch) {
      if (localLastModified.millisecondsSinceEpoch >
          lastSuccessfulSync.millisecondsSinceEpoch) {
        globalLogger.i(
            "Conflicting snapshots, local and remote both newer than last successful sync");
        return SyncMode.conflict;
      } else {
        globalLogger.i("Local database is older than remote");
        return SyncMode.download;
      }
    }

    globalLogger.e(
        "Unknown sync mode (local: $localLastModified, remote: $remoteLastModified, lastSuccessfulSync: $lastSuccessfulSync)");

    return SyncMode.allSynced;
  }

  Future<void> init() async {
    _isInit = true;
    _prefs = await SharedPreferences.getInstance();
    _service.addListener(() async {
      var acc = _service.account;
      _isOnlineServiceEnabled$
          .add(acc != null && await _service.getHasOnlinePrivileges());
      _account$.add(_service.account);
      _isSyncEnabled = true;
    });
    await _service.getAccount();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _service.login(email: email, password: password);
      coordinator.onSuccessfulLogin();
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
      await _service.register(
          email: email, password: password, username: username);
      coordinator.onSuccessfulLogin();
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
    } catch (e, s) {
      logger.e("An error occurred while updating account",
          error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
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

    bool usernameError = username.length < 3 ||
        username.length > 20 ||
        username.contains(RegExp(r'[^a-zA-Z0-9_-]'));

    return CredentialsState.invalid(
      emailError: emailError,
      passwordErrors: passwordErrors,
      usernameError: usernameError,
    );
  }

  Future<void> checkLocalAndRemoteDatabases({
    required DatabaseSnapshot currentSnapshot,
  }) async {
    if (!isOnlineServiceEnabledSync) {
      logger.i("User doesn't have online privileges; skipping");
      return;
    }

    final currentVersion = Version.parse(VersionService().packageInfo.version);

    final localLastModified = _lastModified;
    final remoteSnapshot = await _service.getSnapshot();
    if (remoteSnapshot == null) {
      await _service.uploadSnapshot(
        currentSnapshot,
        timestamp: localLastModified,
        version: currentVersion.canonicalizedVersion,
      );
      _lastSuccessfulSync = localLastModified;
      return;
    }

    final remoteVersion =
        Version.parse(remoteSnapshot["version"] as String? ?? "0.0.0");

    if (remoteVersion > currentVersion) {
      _isSyncEnabled = false;
      logger.w(
          "Remote database was synced using a newer version of the app (local: $currentVersion, remote: $remoteVersion)");
      return;
    }

    final luaRaw = remoteSnapshot["updated_at"] as String?;
    final remoteLastModified = luaRaw != null ? DateTime.parse(luaRaw) : null;
    if (remoteLastModified == null) {
      logger.w("Remote snapshot has no lastModified field");
      return;
    }

    logger.i(
        "Remote last modified: $remoteLastModified, local: $localLastModified");
    logger.d((
      remoteLastModified.millisecondsSinceEpoch,
      localLastModified.millisecondsSinceEpoch
    ));
    if (remoteLastModified.millisecondsSinceEpoch >
        localLastModified.millisecondsSinceEpoch) {
      return _onConflictingSnapshots(
        remoteSnapshot,
        currentSnapshot,
        localLastModified,
        currentVersion.canonicalizedVersion,
      );
    }

    if (remoteLastModified.millisecondsSinceEpoch <
        localLastModified.millisecondsSinceEpoch) {
      final action = await Go.confirm(
          "sync.overwrite.title".t, "sync.overwrite.message".t);
      if (action) {
        await Go.futureDialog(
          future: () => _service.uploadSnapshot(
            currentSnapshot,
            timestamp: localLastModified,
            version: currentVersion.canonicalizedVersion,
          ),
          title: 'sync.inProgress',
        );
        _lastSuccessfulSync = localLastModified;
      }
    }
  }

  Future<void> sync({required DatabaseSnapshot currentSnapshot}) async {
    try {
      if (accountSync == null) return;

      if (!isOnlineServiceEnabledSync) {
        logger.i("User doesn't have online privileges; skipping");
        return;
      }

      if (!_isSyncEnabled) {
        logger.w("Sync is disabled, skipping");
        return;
      }

      final currentVersion =
          Version.parse(VersionService().packageInfo.version);

      final lastSuccessfulSync = _lastSuccessfulSync;
      final localLastModified = _lastModified;

      final remoteSnapshot = await _service.getSnapshot();
      if (remoteSnapshot == null) {
        await _service.uploadSnapshot(
          currentSnapshot,
          timestamp: localLastModified,
          version: currentVersion.canonicalizedVersion,
        );
        _lastSuccessfulSync = localLastModified;
        return;
      }

      final remoteVersion =
          Version.parse(remoteSnapshot["version"] as String? ?? "0.0.0");

      if (remoteVersion > currentVersion) {
        _isSyncEnabled = false;
        logger.w(
            "Remote database was synced using a newer version of the app (local: $currentVersion, remote: $remoteVersion)");
        return;
      }

      final luaRaw = remoteSnapshot["updated_at"] as String?;
      final remoteLastModified = luaRaw != null ? DateTime.parse(luaRaw) : null;
      if (remoteLastModified == null) {
        logger.w("Remote snapshot has no lastModified field");
        await _service.uploadSnapshot(
          currentSnapshot,
          timestamp: localLastModified,
          version: currentVersion.canonicalizedVersion,
        );
        _lastSuccessfulSync = localLastModified;
        return;
      }

      logger.d((
        remoteLastModified.millisecondsSinceEpoch,
        localLastModified.millisecondsSinceEpoch,
        lastSuccessfulSync.millisecondsSinceEpoch,
      ));

      final syncMode = getSyncMode(
        localLastModified: localLastModified,
        remoteLastModified: remoteLastModified,
        lastSuccessfulSync: lastSuccessfulSync,
      );

      switch (syncMode) {
        case SyncMode.download:
          return _doDownload(
            currentSnapshot: currentSnapshot,
            remoteSnapshot: remoteSnapshot,
          );
        case SyncMode.upload:
          await _service.uploadSnapshot(
            currentSnapshot,
            timestamp: localLastModified,
            version: currentVersion.canonicalizedVersion,
          );
          _lastSuccessfulSync = localLastModified;
          return;
        case SyncMode.conflict:
          return _onConflictingSnapshots(
            remoteSnapshot,
            currentSnapshot,
            localLastModified,
            currentVersion.canonicalizedVersion,
          );
        case SyncMode.allSynced:
          return;
      }
    } catch (e, s) {
      logger.e("An error occurred while syncing", error: e, stackTrace: s);
    }
  }

  Future<void> _onConflictingSnapshots(
    Map<String, dynamic> remoteSnapshot,
    DatabaseSnapshot currentSnapshot,
    DateTime localLastModified,
    String version,
  ) async {
    final (DatabaseSnapshot? remoteObject, bool isValid) =
        await compute((json) async {
      final converter = getConverter(json['version']);
      final isValid =
          !throws(() => converter.validate(converter.process(json)));
      if (!isValid) {
        return (null, false);
      }
      return (converter.process(json), true);
    }, remoteSnapshot['data']);

    if (!isValid) {
      _service.deleteSnapshot();
      return;
    }

    // Pressing "Yes" downloads the remote snapshot and overwrites the local one
    // Pressing "No" uploads the local snapshot to the remote database
    final action =
        await Go.confirm("sync.conflict.title".t, "sync.conflict.message".t);

    await Go.futureDialog(
      future: () async {
        if (action) {
          await coordinator.overrideDatabase(remoteObject!);
          _lastSuccessfulSync = DateTime.parse(
              remoteSnapshot["updated_at"] as String? ?? "19700101");
          _lastModified = _lastSuccessfulSync;
        } else {
          await _service.uploadSnapshot(
            currentSnapshot,
            timestamp: localLastModified,
            version: version,
          );
          _lastSuccessfulSync = localLastModified;
        }
      },
      title: "sync.inProgress".t,
    );
  }

  Future<bool> getShouldShowManualSync() async {
    if (accountSync == null) return false;

    if (!isOnlineServiceEnabledSync) {
      logger.i("User doesn't have online privileges; skipping");
      return false;
    }

    if (!_isSyncEnabled) {
      logger.w("Sync is disabled, skipping");
      return false;
    }

    try {
      final localSync = DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt("last_modified") ?? 0,
        isUtc: true,
      );
      final remoteSync = await _service.getSnapshot();

      if (remoteSync == null) {
        return true;
      }

      if (remoteSync["updated_at"] == null) {
        return true;
      }

      final remoteSyncDate = DateTime.parse(remoteSync["updated_at"] as String);

      return remoteSyncDate.millisecondsSinceEpoch !=
          localSync.millisecondsSinceEpoch;
    } catch (e, s) {
      logger.e(null, error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> manualSync() async {
    final shouldSync = await getShouldShowManualSync();
    if (shouldSync) {
      return sync(currentSnapshot: service.currentSnapshot);
    }
  }

  Future<void> _doDownload({
    required DatabaseSnapshot currentSnapshot,
    required Map<String, dynamic> remoteSnapshot,
  }) async {
    final remoteLastModified =
        DateTime.parse(remoteSnapshot["updated_at"] as String? ?? "19700101");
    await Go.futureDialog(
      future: () async {
        final (DatabaseSnapshot? remoteObject, bool isValid) =
            await compute((arg) async {
          final (json, currentSnapshot) = arg;
          final converter = getConverter(json['version']);
          final isValid =
              !throws(() => converter.validate(converter.process(json)));
          if (!isValid) {
            return (null, false);
          }
          final snapshot = converter.process(json);

          if (deepEquals(snapshot, currentSnapshot)) {
            return (null, true);
          }

          return (snapshot, true);
        }, (remoteSnapshot['data'], currentSnapshot));

        if (!isValid) {
          _service.deleteSnapshot();
          return;
        }

        if (remoteObject == null) {
          logger.w("Remote snapshot is null");
          return;
        }
        logger.f(remoteObject.historyWorkouts.length);
        await coordinator.overrideDatabase(remoteObject);
        _lastSuccessfulSync = remoteLastModified;
        _lastModified = remoteLastModified;
      },
      title: 'sync.inProgress',
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
        _avatarCache[id] = _CachedData(time, uri);
      }
      return uri;
    });
  }

  @override
  void onServiceChange() {
    if (!_isInit) {
      logger.w("Service not initialized yet");
      return;
    }

    // Mark dirty
    _lastModified = DateTime.now().toUtc();
    logger.i("Marked database as dirty");
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
  }) =>
      CredentialsState(
        emailError: emailError,
        passwordErrors: passwordErrors,
        usernameError: usernameError,
      );

  bool get hasError => emailError || passwordErrors.isNotEmpty || usernameError;
  bool get hasErrorWithoutUsername => emailError || passwordErrors.isNotEmpty;

  T when<T>({
    T Function(bool emailError, Set<PasswordValidationErrors> passwordErrors,
            bool usernameError)?
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
