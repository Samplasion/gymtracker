import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/service/online.dart';
import 'package:rxdart/rxdart.dart';

class OnlineController extends GetxController with ServiceableController {
  final OnlineService _service = OnlineServiceImpl();

  final _account$ = BehaviorSubject<OnlineAccount?>.seeded(null);
  Stream<OnlineAccount?> get account => _account$.stream;
  OnlineAccount? get accountSync => _account$.value;

  Future<void> init() async {
    _service.addListener(() {
      _account$.add(_service.account);
    });
    await _service.getAccount();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _service.login(email: email, password: password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await _service.register(
        email: email, password: password, username: username);
  }

  Future<void> updateAccount({
    required String email,
    required String username,
  }) async {
    await _service.updateAccount(email: email, username: username);
  }

  Future<void> logout() async {
    await _service.logout();
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

  @override
  void onServiceChange() {}
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
