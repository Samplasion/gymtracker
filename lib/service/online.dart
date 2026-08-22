import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class OnlineAccount {
  final String id;
  final String name;
  final String? email;
  final String? fullName;

  OnlineAccount({
    required this.id,
    required this.name,
    this.email,
    this.fullName,
  });
}

abstract class OnlineService with ChangeNotifier {
  OnlineAccount? get account;

  Future<OnlineAccount?> getAccount();
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String email,
    required String password,
    required String username,
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
  final _client = Supabase.instance.client.auth;
  final _db = Supabase.instance.client;

  OnlineAccount? _account;
  @override
  OnlineAccount? get account => _account;

  OnlineServiceImpl() {
    _client.onAuthStateChange.listen((event) {
      logger.d("Auth state changed: $event");
      if (event.session == null) {
        _setAccount(null);
      }
    });
  }

  void _setAccount(OnlineAccount? account) {
    _account = account;
    notifyListeners();
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
    );
  }

  @override
  Future<OnlineAccount?> getAccount() async {
    final user = _client.currentUser;
    if (user == null) {
      _setAccount(null);
      return null;
    }

    final row = await _db.from("profiles").select().eq('id', user.id).limit(1);
    _setAccount(_mapAccount(user, row.first));
    return _account;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final response = await _client.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    final row = await _db
        .from("profiles")
        .select()
        .eq('id', response.user!.id)
        .limit(1);
    _setAccount(_mapAccount(response.user, row.first));
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final existing = await _db
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
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

    final row = await _db
        .from("profiles")
        .select()
        .eq('id', response.user!.id)
        .limit(1);
    _setAccount(_mapAccount(response.user, row.first));
  }

  @override
  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {
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
    final response = await _client.updateUser(
      UserAttributes(
        email: email,
        data: {...?user.userMetadata, "username": username},
      ),
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    _setAccount(_mapAccount(response.user, row.first));
  }

  @override
  Future<void> updateProfile({String? fullName}) async {
    final user = _client.currentUser;
    if (user == null) {
      return;
    }

    await _db
        .from("profiles")
        .update({
          "full_name": fullName,
          "updated_at": DateTime.now().toUtc().toIso8601String(),
        })
        .eq("id", user.id);
  }

  @override
  Future<void> uploadAvatar(Uint8List bytes) async {
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
  }

  @override
  Future<void> removeAvatar() async {
    final user = _client.currentUser;
    if (user == null) {
      throw const AuthException("No user found");
    }

    await _db.storage.from("profile_pictures").remove([user.id]);
  }

  @override
  Future<void> logout() async {
    await _client.signOut();
    _setAccount(null);
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
    // Avatar is stored in the public storage in the profile_pictures bucket
    // as <user-id>
    try {
      final response = await _db.storage
          .from("profile_pictures")
          .createSignedUrl(
            id,
            60 * 60, // 1 hour
            // transform: const TransformOptions(
            //   resize: ResizeMode.cover,
            //   width: 256,
            //   height: 256,
            // ),
          );
      return Uri.parse(response);
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  @override
  Future<({List<FeedItem> feed, bool hasMore})> getFriendsFeed({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _client.currentUser;
    if (user == null) {
      return (feed: <FeedItem>[], hasMore: false);
    }

    final feedItems = <FeedItem>[];
    bool hasMore = false;

    final friendsRes = await _db
        .from("friends")
        .select("sender_id,receiver_id")
        .or("sender_id.eq.${user.id},receiver_id.eq.${user.id}")
        .eq("status", "accepted");
    final friendIDs = <String>{
      for (final row in friendsRes as List)
        if (row["sender_id"] != user.id) row["sender_id"] as String,
      for (final row in friendsRes as List)
        if (row["receiver_id"] != user.id) row["receiver_id"] as String,
    };

    if (sources.contains(FeedSource.friendsHistory)) {
      try {
        final workoutsResponse = await _db
            .from("history_workouts")
            .select()
            .inFilter("user_id", friendIDs.toList())
            .eq("deleted", false)
            .gte("starting_date", startDate.toUtc().toIso8601String())
            .lte("starting_date", endDate.toUtc().toIso8601String());

        final List<String> workoutIds = (workoutsResponse as List)
            .map((w) => w["id"] as String)
            .toList();

        final exercisesResponse = workoutIds.isEmpty
            ? []
            : await _db
                  .from("history_workout_exercises")
                  .select()
                  .inFilter("user_id", friendIDs.toList())
                  .eq("deleted", false)
                  .inFilter("routine_id", workoutIds);

        final exercisesByWorkout = <String, List<ConcreteExercise>>{};
        for (final row in exercisesResponse as List) {
          final exercise = HistoryWorkoutExercise.fromJson(
            row as Map<String, dynamic>,
          );
          exercisesByWorkout
              .putIfAbsent(exercise.routineId, () => <ConcreteExercise>[])
              .add(exercise);
        }

        for (final row in workoutsResponse) {
          final historyWorkout = HistoryWorkout.fromJson(
            row as Map<String, dynamic>,
          );
          final exercises =
              exercisesByWorkout[historyWorkout.id] ?? <ConcreteExercise>[];
          final workout = historyWorkoutFromDatabase(
            historyWorkout,
            exercises,
          ).copyWith.parentID(null);
          final userId = historyWorkout.userId;
          if (userId == null) {
            logger.w("History workout ${historyWorkout.id} has no user_id");
            continue;
          }
          feedItems.add(
            FeedItemWorkout(
              workout: workout,
              authorship: FeedAuthorshipFriend(userID: userId),
            ),
          );
        }

        final countResponse = await _db
            .from("history_workouts")
            .select("id")
            .inFilter("user_id", friendIDs.toList())
            .eq("deleted", false)
            .lt("starting_date", startDate.toUtc().toIso8601String())
            .limit(1);
        hasMore = hasMore || countResponse.isNotEmpty;
      } catch (e, s) {
        logger.e(
          "Error fetching friends history from Supabase",
          error: e,
          stackTrace: s,
        );
      }
    }

    if (sources.contains(FeedSource.friendsAchievements)) {
      try {
        final completionsResponse = await _db
            .from("achievements_v2")
            .select()
            .inFilter("user_id", friendIDs.toList())
            .eq("deleted", false)
            .gte("completed_at", startDate.toUtc().toIso8601String())
            .lte("completed_at", endDate.toUtc().toIso8601String());

        for (final row in completionsResponse as List) {
          final completion = AchievementCompletion.fromJson(
            row as Map<String, dynamic>,
          );
          final achievement = achievements[completion.achievementID];
          if (achievement != null) {
            final userId = completion.userId;
            if (userId == null) {
              logger.w(
                "Achievement completion ${completion.id} has no user_id",
              );
              continue;
            }
            feedItems.add(
              FeedItemAchievement(
                achievement: achievement,
                completion: completion,
                authorship: FeedAuthorshipFriend(userID: userId),
              ),
            );
          }
        }

        final countResponse = await _db
            .from("achievements_v2")
            .select("id")
            .inFilter("user_id", friendIDs.toList())
            .eq("deleted", false)
            .lt("completed_at", startDate.toUtc().toIso8601String())
            .limit(1);
        hasMore = hasMore || countResponse.isNotEmpty;
      } catch (e, s) {
        logger.e(
          "Error fetching friends achievements from Supabase",
          error: e,
          stackTrace: s,
        );
      }
    }

    return (feed: feedItems, hasMore: hasMore);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _client.currentUser;
    if (user == null) {
      return;
    }

    await Supabase.instance.client.functions.invoke(
      'delete-user-complete',
      body: {'target_user_id': user.id},
    );
    await _client.signOut();
    _setAccount(null);
  }

  @override
  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null || response.user?.emailConfirmedAt == null) {
        return false;
      }
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
