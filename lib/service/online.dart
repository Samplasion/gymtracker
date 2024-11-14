import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

class OnlineServiceImpl with ChangeNotifier implements OnlineService {
  final _client = Supabase.instance.client.auth;

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
}
