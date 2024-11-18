import 'package:flutter/foundation.dart';
import 'package:gymtracker/db/imports/types.dart';
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

  _mapAccount(User? user) {
    if (user == null) {
      return null;
    }
    return OnlineAccount(
      id: user.id,
      name: user.userMetadata?["username"] ?? "",
      email: user.email,
    );
  }

  @override
  Future<OnlineAccount?> getAccount() async {
    final user = _client.currentUser;
    _setAccount(_mapAccount(user));
    return _account;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final response =
        await _client.signInWithPassword(email: email, password: password);
    _setAccount(_mapAccount(response.user));
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
    _setAccount(_mapAccount(response.user));
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
    final response = await _client.updateUser(
      UserAttributes(
        email: email,
        data: {
          ...?user.userMetadata,
          "username": username,
        },
      ),
    );
    _setAccount(_mapAccount(response.user));
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
  Future<void> uploadSnapshot(DatabaseSnapshot snapshot,
      {DateTime? timestamp,required String version,}) async {
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
}
