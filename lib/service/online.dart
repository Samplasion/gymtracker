import 'package:flutter/foundation.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class OnlineAccount {
  final String id;
  final String name;
  final String? email;

  OnlineAccount({
    required this.id,
    required this.name,
    this.email,
  });
}

abstract class OnlineService with ChangeNotifier {
  OnlineAccount? get account;

  Future<OnlineAccount?> getAccount();
  Future<void> login({required String email, required String password});
  Future<void> register(
      {required String email,
      required String password,
      required String username});
  Future<void> updateAccount({required String email, required String username});
  Future<void> logout();
  Future<Uri?> getAvatarUrl(String id);

  Future<Map<String, dynamic>?> getSnapshot();
  Future<void> uploadSnapshot(
    DatabaseSnapshot snapshot, {
    DateTime? timestamp,
    required String version,
  });
  Future<void> deleteSnapshot();
}

class OnlineServiceImpl with ChangeNotifier implements OnlineService {
  final _client = Supabase.instance.client.auth;
  final _db = Supabase.instance.client;

  OnlineAccount? _account;
  @override
  OnlineAccount? get account => _account;

  _setAccount(OnlineAccount? account) {
    _account = account;
    notifyListeners();
  }

  _mapAccount(User? user, Map<String, dynamic> data) {
    if (user == null) {
      return null;
    }
    return OnlineAccount(
      id: user.id,
      name: data["username"]!,
      email: user.email,
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
    _setAccount(_mapAccount(user, row.single));
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
    _setAccount(_mapAccount(response.user, row.single));
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.signUp(
      email: email,
      password: password,
      data: {
        "username": username,
      },
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    final row = await _db
        .from("profiles")
        .select()
        .eq('id', response.user!.id)
        .limit(1);
    _setAccount(_mapAccount(response.user, row.single));
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
        .update({
          "username": username,
        })
        .eq('id', user.id)
        .select()
        .limit(1);
    final response = await _client.updateUser(
      UserAttributes(
        email: email,
        data: {
          ...?user.userMetadata,
          "username": username,
        },
      ),
    );
    if (response.user == null) {
      throw const AuthException("No user found");
    }

    _setAccount(_mapAccount(response.user, row.single));
  }

  @override
  Future<void> logout() async {
    await _client.signOut();
    _setAccount(null);
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
    await _db.from("user_sync_data").upsert(
      {
        "data": snapshot.toJson(),
        "user_id": user.id,
        "updated_at":
            (timestamp?.toUtc() ?? DateTime.now().toUtc()).toIso8601String(),
        "version": version,
      },
      onConflict: "user_id",
    );
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
      final response =
          await _db.storage.from("profile_pictures").createSignedUrl(
                id,
                const Duration(hours: 1).inSeconds,
                transform: const TransformOptions(
                  resize: ResizeMode.cover,
                  width: 256,
                  height: 256,
                ),
              );
      return Uri.parse(response);
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
