import 'dart:async';
import 'package:gymtracker/struct/request_cache.dart';

import 'package:flutter/foundation.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/utils.dart' show isNetworkError;
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class OnlineAccount {
  final String id;
  final String name;
  final String? email;
  final String? fullName;
  final String? updatedAt;

  OnlineAccount({
    required this.id,
    required this.name,
    this.email,
    this.fullName,
    this.updatedAt,
  });
}

abstract class OnlineService with ChangeNotifier {
  OnlineAccount? get account;
  DateTime? get nextFriendsFeedDate => null;
  List<Map<String, dynamic>> get feedProfiles => const [];

  Future<OnlineAccount?> getAccount();
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String email,
    required String password,
    required String username,
  });
  Future<void> requestPasswordRecovery({
    required String email,
    required String locale,
  });
  Future<void> updateAccount({required String email, required String username});
  Future<void> updateProfile({String? fullName});
  Future<void> uploadAvatar(Uint8List bytes);
  Future<void> removeAvatar();
  Future<void> logout();
  Future<Uri?> getAvatarUrl(String id);
  Future<bool> getHasOnlinePrivileges();

  Future<Map<String, dynamic>?> getSnapshot();
  Future<void> uploadSnapshot(
    DatabaseSnapshot snapshot, {
    DateTime? timestamp,
    required String version,
  });
  Future<void> deleteSnapshot();

  Future<({List<FeedItem> feed, bool hasMore})> getFriendsFeed({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> deleteAccount();

  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  });
}

class OnlineServiceImpl with ChangeNotifier implements OnlineService {
  final GoTrueClient _client;
  final SupabaseClient _db;
  late final StreamSubscription<AuthState> _authSubscription;
  bool _disposed = false;
  int _authGeneration = 0;
  int _lastSignOutGeneration = -1;
  String? _authUserId;

  @override
  DateTime? nextFriendsFeedDate;
  @override
  List<Map<String, dynamic>> feedProfiles = [];
  final _accounts = RequestCache<String, OnlineAccount?>(
    const Duration(minutes: 30),
  );
  OnlineAccount? _account;
  @override
  OnlineAccount? get account => _account;

  @visibleForTesting
  set account(OnlineAccount? value) => _account = value;

  final Map<String, Achievement> Function() _achievementCatalog;

  OnlineServiceImpl([SupabaseClient? client])
    : this.withAchievementCatalog(
        achievementCatalog: () => achievements,
        client: client,
      );

  OnlineServiceImpl.withAchievementCatalog({
    required Map<String, Achievement> Function() achievementCatalog,
    SupabaseClient? client,
  }) : _achievementCatalog = achievementCatalog,
       _db = client ?? Supabase.instance.client,
       _client = (client ?? Supabase.instance.client).auth {
    _authUserId = _client.currentUser?.id;
    _authSubscription = _client.onAuthStateChange.listen(
      (event) {
        if (_disposed) return;
        logger.d("Auth state changed: ${event.event.name}");
        final userId = event.session?.user.id;
        if (userId != _authUserId || event.event == AuthChangeEvent.signedOut) {
          _authGeneration++;
          _accounts.clear();
        }
        if (event.event == AuthChangeEvent.signedOut) {
          _lastSignOutGeneration = _authGeneration;
        }
        _authUserId = userId;
        if (event.session == null) {
          _setAccount(null);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (_disposed) return;
        if (error is AuthRetryableFetchException) {
          logger.w(
            "Session refresh temporarily failed; recovery remains managed by Supabase",
            error: error,
            stackTrace: stack,
          );
          return;
        }
        Error.throwWithStackTrace(error, stack);
      },
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_authSubscription.cancel());
    super.dispose();
  }

  void _setAccount(OnlineAccount? account, {bool cache = true}) {
    if (_disposed) return;
    if (_account?.id != account?.id) _accounts.clear();
    _account = account;
    if (cache && account != null) _accounts.put(account.id, account);
    notifyListeners();
  }

  void _ensureSession(String? userId, int generation) {
    if (_disposed ||
        _authGeneration != generation ||
        _client.currentUser?.id != userId) {
      throw StateError('The account changed during the request');
    }
  }

  void _ensureAuthenticationResult(User user, int generation) {
    // Signing in can itself advance the identity once; other transitions
    // invalidate the request, including logout followed by the same login.
    if (_disposed ||
        _client.currentUser?.id != user.id ||
        _lastSignOutGeneration > generation ||
        _authGeneration < generation ||
        _authGeneration > generation + 1) {
      throw StateError('The account changed during authentication');
    }
    // The SDK saves currentUser before its asynchronous signedIn event arrives.
    // Adopt that verified identity now so the event cannot invalidate the
    // profile request belonging to this very sign-in. Real logout/account
    // changes still advance the generation and fence pending requests.
    if (_authUserId != user.id) {
      _authGeneration++;
      _accounts.clear();
      _authUserId = user.id;
    }
  }

  OnlineAccount? _mapAccount(User? user, Map<String, dynamic> data) {
    if (user == null) {
      return null;
    }
    return OnlineAccount(
      id: user.id,
      name: data["username"] ?? user.email,
      email: user.email,
      fullName: data["full_name"],
      updatedAt: data["updated_at"] as String?,
    );
  }

  @override
  Future<OnlineAccount?> getAccount() async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      _setAccount(null);
      return null;
    }

    OnlineAccount? currentAccount() =>
        !_disposed && _account?.id == _client.currentUser?.id ? _account : null;

    try {
      Future<List<Map<String, dynamic>>> fetchProfile() async {
        return await _db.from("profiles").select().eq('id', user.id).limit(1);
      }

      final account = await _accounts.get(user.id, () async {
        final row = await fetchProfile().timeout(const Duration(seconds: 8));
        return _mapAccount(user, row.single);
      });
      if (_disposed ||
          generation != _authGeneration ||
          _client.currentUser?.id != user.id)
        return currentAccount();
      _setAccount(account);
      return _account;
    } catch (e) {
      if (_disposed ||
          generation != _authGeneration ||
          _client.currentUser?.id != user.id)
        return currentAccount();
      if (!isNetworkError(e)) rethrow;
      logger.w("[OnlineService] Offline during getAccount(): $e");
      if (_account?.id == user.id) return _account;
      // Synthesize fallback account from offline cached session
      _setAccount(
        OnlineAccount(
          id: user.id,
          email: user.email ?? '',
          name:
              (user.userMetadata?['username'] as String?) ??
              user.email ??
              'Offline User',
        ),
        cache: false,
      );
      return _account;
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final generation = _authGeneration;
    final response = await _client.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    _ensureAuthenticationResult(response.user!, generation);
    final profileGeneration = _authGeneration;
    // Reuse startup's bounded profile load and session-backed offline fallback.
    // A profile network failure must not turn a successful login into an error.
    await getAccount();
    _ensureSession(response.user!.id, profileGeneration);
  }

  @override
  Future<void> requestPasswordRecovery({
    required String email,
    required String locale,
  }) {
    final language = locale == 'it' ? 'it' : 'en';
    // Same recovery destination as the website. The existing Supabase auth
    // provider sends the email; the website verifies it and updates the password.
    return _client.resetPasswordForEmail(
      email,
      redirectTo:
          'https://gym-bro.techtonicfault.com/$language/auth/reset-password',
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final owner = _client.currentUser?.id;
    final generation = _authGeneration;
    final existing = await _db
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    _ensureSession(owner, generation);
    if (existing != null) {
      throw const AuthException("login.errors.usernameTaken");
    }

    final response = await _client.signUp(
      email: email,
      password: password,
      data: {"username": username},
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    if (response.session == null) {
      _ensureSession(owner, generation);
      _setAccount(null);
      return;
    }
    _ensureAuthenticationResult(response.user!, generation);
    final profileGeneration = _authGeneration;
    await getAccount();
    _ensureSession(response.user!.id, profileGeneration);
  }

  @override
  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      return;
    }

    final row = await _db
        .from("profiles")
        .update({"username": username})
        .eq('id', user.id)
        .select()
        .limit(1);
    _ensureSession(user.id, generation);
    final response = await _client.updateUser(
      UserAttributes(
        email: email,
        data: {...?user.userMetadata, "username": username},
      ),
    );
    _ensureSession(user.id, generation);
    if (response.user == null || response.user!.id != user.id) {
      throw const AuthException("No user found");
    }

    _setAccount(_mapAccount(response.user, row.first));
  }

  @override
  Future<void> updateProfile({String? fullName}) async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      return;
    }

    final row = await _db
        .from("profiles")
        .update({
          "full_name": fullName,
          "updated_at": DateTime.now().toUtc().toIso8601String(),
        })
        .eq("id", user.id)
        .select()
        .single();
    _ensureSession(user.id, generation);
    _setAccount(_mapAccount(user, row));
  }

  @override
  Future<void> uploadAvatar(Uint8List bytes) async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      throw const AuthException("No user found");
    }

    await _db.storage
        .from("profile_pictures")
        .uploadBinary(
          user.id,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/png',
          ),
        );
    _ensureSession(user.id, generation);
    await _touchProfile(user, generation);
  }

  Future<void> _touchProfile(User user, int generation) async {
    _ensureSession(user.id, generation);
    final revision = DateTime.now().toUtc().toIso8601String();
    Map<String, dynamic>? row;
    try {
      row = await _db
          .from('profiles')
          .update({'updated_at': revision})
          .eq('id', user.id)
          .select()
          .single();
    } catch (error, stack) {
      // Storage has already committed. Do not report the avatar as unsaved or
      // keep displaying its old cached version if the metadata request fails.
      _ensureSession(user.id, generation);
      logger.w(
        'Avatar saved; profile timestamp refresh failed',
        error: error,
        stackTrace: stack,
      );
    }
    _ensureSession(user.id, generation);
    final previous = _account?.id == user.id ? _account : null;
    _setAccount(
      row != null
          ? _mapAccount(user, row)
          : OnlineAccount(
              id: user.id,
              name:
                  previous?.name ??
                  user.userMetadata?['username'] as String? ??
                  user.email ??
                  user.id,
              email: user.email,
              fullName: previous?.fullName,
              updatedAt: revision,
            ),
    );
  }

  @override
  Future<void> removeAvatar() async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      throw const AuthException("No user found");
    }

    await _db.storage.from("profile_pictures").remove([user.id]);
    _ensureSession(user.id, generation);
    await _touchProfile(user, generation);
  }

  @override
  Future<void> logout() async {
    await _client.signOut();
    if (!_disposed && _client.currentUser == null) _setAccount(null);
  }

  @override
  Future<bool> getHasOnlinePrivileges() async {
    return _client.currentUser != null;
    // final user = _client.currentUser;
    // if (user == null) {
    //   return false;
    // }

    // final response = await _db
    //     .from("profiles")
    //     .select()
    //     .eq('id', user.id)
    //     .limit(1);
    // return response.single['has_online'] as bool? ?? false;
  }

  @override
  Future<Map<String, dynamic>?> getSnapshot() async {
    final response = await _db.from("user_sync_data").select().limit(1);
    return response.isNotEmpty ? response[0] : null;
  }

  @override
  Future<void> uploadSnapshot(
    DatabaseSnapshot snapshot, {
    DateTime? timestamp,
    required String version,
  }) async {
    final user = ArgumentError.checkNotNull(_client.currentUser);

    // await _db.from("user_sync_data").delete().eq("user_id", user.id);
    // await _db.from("user_sync_data").insert(
    await _db.from("user_sync_data").upsert({
      "data": snapshot.toJson(),
      "user_id": user.id,
      "updated_at": (timestamp?.toUtc() ?? DateTime.now().toUtc())
          .toIso8601String(),
      "version": version,
    }, onConflict: "user_id");
  }

  @override
  Future<void> deleteSnapshot() async {
    final user = ArgumentError.checkNotNull(_client.currentUser);
    await _db.from("user_sync_data").delete().eq("user_id", user.id);
  }

  @override
  Future<Uri?> getAvatarUrl(String id) async {
    return Uri.parse(
      await _db.storage.from('profile_pictures').createSignedUrl(id, 60),
    );
  }

  @override
  Future<({List<FeedItem> feed, bool hasMore})> getFriendsFeed({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_client.currentUser == null)
      return (feed: <FeedItem>[], hasMore: false);
    final res = Map<String, dynamic>.from(
      await _db.rpc(
            'get_friends_feed',
            params: {
              'start_at': startDate.toUtc().toIso8601String(),
              'end_at': endDate.toUtc().toIso8601String(),
            },
          )
          as Map,
    );
    nextFriendsFeedDate = DateTime.tryParse(
      res['previous_at'] as String? ?? '',
    );
    feedProfiles = (res['profiles'] as List)
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
    final grouped = <String, List<ConcreteExercise>>{};
    for (final row in res['exercises'] as List) {
      final e = HistoryWorkoutExercise.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
      grouped.putIfAbsent('${e.userId}/${e.routineId}', () => []).add(e);
    }
    final items = <FeedItem>[];
    if (sources.contains(FeedSource.friendsHistory)) {
      for (final row in res['workouts'] as List) {
        final w = HistoryWorkout.fromJson(
          Map<String, dynamic>.from(row as Map),
        );
        items.add(
          FeedItemWorkout(
            workout: historyWorkoutFromDatabase(
              w,
              grouped['${w.userId}/${w.id}'] ?? [],
            ).copyWith.parentID(null),
            authorship: FeedAuthorshipFriend(userID: w.userId!),
          ),
        );
      }
    }
    if (sources.contains(FeedSource.friendsAchievements)) {
      for (final row in res['achievements'] as List) {
        final c = AchievementCompletion.fromJson(
          Map<String, dynamic>.from(row as Map),
        );
        final achievement = _achievementCatalog()[c.achievementID];
        if (achievement != null)
          items.add(
            FeedItemAchievement(
              achievement: achievement,
              completion: c,
              authorship: FeedAuthorshipFriend(userID: c.userId!),
            ),
          );
      }
    }
    return (feed: items, hasMore: nextFriendsFeedDate != null);
  }

  @override
  Future<void> deleteAccount() async {
    final generation = _authGeneration;
    final user = _client.currentUser;
    if (user == null) {
      return;
    }

    await Supabase.instance.client.functions.invoke(
      'delete-user-complete',
      body: {'target_user_id': user.id},
    );
    _ensureSession(user.id, generation);
    await _client.signOut();
    if (!_disposed && _client.currentUser == null) _setAccount(null);
  }

  @override
  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) async {
    final generation = _authGeneration;
    try {
      final response = await _client.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null || response.user?.emailConfirmedAt == null) {
        return false;
      }
      _ensureAuthenticationResult(response.user!, generation);
      _setAccount(
        _mapAccount(response.user, response.user?.userMetadata ?? {}),
      );
      return true;
    } on AuthApiException catch (e) {
      if (e.code == "email_not_confirmed") {
        return false;
      }
      rethrow;
    }
  }
}

class TestOnlineServiceImpl extends OnlineService {
  @override
  OnlineAccount? get account => null;

  @override
  Future<void> deleteSnapshot() async {}

  @override
  Future<OnlineAccount?> getAccount() async => null;

  @override
  Future<Uri?> getAvatarUrl(String id) async => null;
  @override
  Future<bool> getHasOnlinePrivileges() async => false;
  @override
  Future<Map<String, dynamic>?> getSnapshot() async => null;
  @override
  Future<void> login({required String email, required String password}) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> requestPasswordRecovery({
    required String email,
    required String locale,
  }) async {}
  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {}
  @override
  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {}
  @override
  Future<void> updateProfile({String? fullName}) async {}
  @override
  Future<void> uploadAvatar(Uint8List bytes) async {}
  @override
  Future<void> removeAvatar() async {}
  @override
  Future<void> uploadSnapshot(
    DatabaseSnapshot snapshot, {
    DateTime? timestamp,
    required String version,
  }) async {}

  @override
  Future<({List<FeedItem> feed, bool hasMore})> getFriendsFeed({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return (feed: <FeedItem>[], hasMore: false);
  }

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) async {
    return true;
  }
}
