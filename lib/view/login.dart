import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _LoginController extends GetxController
    with ServiceableController, StateMixin {
  final Online _controller;

  _LoginController(this._controller);

  @override
  onInit() {
    super.onInit();
    change(null, status: RxStatus.empty());
  }

  final _credentials$ = BehaviorSubject<CredentialsState>.seeded(
    CredentialsState.empty(),
  );

  @override
  void onServiceChange() {}

  void checkCredentials(String email, String password, String username) {
    _credentials$.add(
      _controller.checkCredentials(
        email: email,
        password: password,
        username: username,
      ),
    );
  }

  Future<void> signIn(
    String email,
    String password, {
    required BuildContext context,
  }) async {
    if (status.isLoading) return;
    if (_credentials$.value.emailError) return;
    if (password.isEmpty) return;
    change(null, status: RxStatus.loading());
    try {
      await _controller.login(email: email, password: password);
      change(null, status: RxStatus.success());
      // TODO: Custom error type
    } catch (e) {
      String message = e.toString();
      if (e is AuthException && e is! AuthApiException) {
        if (e.message.contains("Socket")) {
          message = context.t.login.errors.noInternet;
          change(null, status: RxStatus.error(message));
        } else {
          message = e.message;
          change(null, status: RxStatus.error(message));
        }
      } else {
        RxStatus.error(message);
      }
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String username, {
    required BuildContext context,
  }) async {
    if (status.isLoading) return false;
    if (_credentials$.value.hasError) return false;
    if (password.isEmpty) return false;
    change(null, status: RxStatus.loading());
    return _controller
        .register(email: email, password: password, username: username)
        .then((_) {
          change(null, status: RxStatus.success());
          return true;
        })
        .catchError((e) {
          String message = e.toString();
          if (e is AuthException) {
            if (e.message.contains("Socket")) {
              message = context.t.login.errors.noInternet;
            } else if (e.message == "login.errors.usernameTaken") {
              message = context.t.login.errors.usernameTaken;
            } else {
              message = e.message;
            }
          }
          change(null, status: RxStatus.error(message));
          return false;
        });
  }

  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) async {
    return _controller.checkEmailVerificationAndLogIn(
      email: email,
      password: password,
    );
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<_LoginController>(
    init: _LoginController(ref.read(onlineProvider.notifier)),
    builder: (controller) => _buildPage(context, controller),
  );

  Widget _buildPage(BuildContext context, _LoginController loginController) {
    final fieldsEnabled =
        loginController.status.isError ||
        loginController.status.isSuccess ||
        loginController.status.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.login.title),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: context.t.login.tabs.signIn),
            Tab(text: context.t.login.tabs.signUp),
          ],
        ),
      ),
      body: Form(
        onChanged: () => _checkCredentials(),
        child: TabBarView(
          controller: tabController,
          children: [
            _signInTree(context, loginController, fieldsEnabled),
            _signUpTree(context, loginController, fieldsEnabled),
          ],
        ),
      ),
    );
  }

  ListView _signInTree(
    BuildContext context,
    _LoginController loginController,
    bool fieldsEnabled,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (loginController.status.isError)
          Text(
            loginController.status.errorMessage?.toString() ??
                context.t.login.errors.generic,
          ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: context.t.login.fields.email.label,
            hintText: context.t.login.fields.email.hint,
          ),
          enabled: fieldsEnabled,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: context.t.login.fields.password.label,
            hintText: context.t.login.fields.password.hint,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          enabled: fieldsEnabled,
          obscureText: !_showPassword,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: fieldsEnabled ? _submitSignIn : null,
          label: Text(context.t.login.buttons.signIn),
          icon: () {
            if (loginController.status.isLoading) {
              return SizedBox(
                height: IconTheme.of(context).size,
                width: IconTheme.of(context).size,
                child: const CircularProgressIndicator(),
              );
            } else {
              return const Icon(Icons.login);
            }
          }(),
        ),
      ],
    );
  }

  ListView _signUpTree(
    BuildContext context,
    _LoginController loginController,
    bool fieldsEnabled,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (loginController.status.isError)
          Text(
            loginController.status.errorMessage?.toString() ??
                context.t.login.errors.generic,
          ),
        const SizedBox(height: 16),
        StreamBuilder<CredentialsState>(
          stream: loginController._credentials$,
          builder: (context, snapshot) {
            return TextField(
              controller: usernameController,
              onChanged: (_) => _checkCredentials(),
              decoration: InputDecoration(
                labelText: context.t.login.fields.username.label,
                hintText: context.t.login.fields.username.hint,
                errorText: snapshot.data?.when(
                  invalid: (_, __, usernameError) {
                    if (!usernameError) return null;
                    return context.t.login.errors.username;
                  },
                  orElse: () => null,
                ),
              ),
              enabled: fieldsEnabled,
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<CredentialsState>(
          stream: loginController._credentials$,
          builder: (context, snapshot) {
            return TextField(
              controller: emailController,
              onChanged: (_) => _checkCredentials(),
              decoration: InputDecoration(
                labelText: context.t.login.fields.email.label,
                hintText: context.t.login.fields.email.hint,
                errorText: snapshot.data?.when(
                  invalid: (emailError, _, __) {
                    if (!emailError) return null;
                    return context.t.login.errors.email;
                  },
                  orElse: () => null,
                ),
              ),
              enabled: fieldsEnabled,
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<CredentialsState>(
          stream: loginController._credentials$,
          builder: (context, snapshot) {
            return TextField(
              controller: passwordController,
              onChanged: (_) => _checkCredentials(),
              decoration: InputDecoration(
                labelText: context.t.login.fields.password.label,
                hintText: context.t.login.fields.password.hint,
                error: snapshot.data?.when(
                  invalid: (_, passwordErrors, __) {
                    if (passwordErrors.isEmpty) return null;
                    var _error = Theme.of(context).colorScheme.error;
                    var _text = Theme.of(context).textTheme.bodySmall!.color;
                    return Text.rich(
                      TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: _error),
                        children: [
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.header}\n',
                          ),
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.length}\n',
                            style: TextStyle(
                              color:
                                  (passwordErrors.contains(
                                    PasswordValidationErrors.length,
                                  ))
                                  ? _error
                                  : _text,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.uppercase}\n',
                            style: TextStyle(
                              color:
                                  (passwordErrors.contains(
                                    PasswordValidationErrors.uppercase,
                                  ))
                                  ? _error
                                  : _text,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.lowercase}\n',
                            style: TextStyle(
                              color:
                                  (passwordErrors.contains(
                                    PasswordValidationErrors.lowercase,
                                  ))
                                  ? _error
                                  : _text,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.number}\n',
                            style: TextStyle(
                              color:
                                  (passwordErrors.contains(
                                    PasswordValidationErrors.number,
                                  ))
                                  ? _error
                                  : _text,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${context.t.login.errors.password.invalid.specialCharacter}\n',
                            style: TextStyle(
                              color:
                                  (passwordErrors.contains(
                                    PasswordValidationErrors.specialCharacter,
                                  ))
                                  ? _error
                                  : _text,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  orElse: () => null,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              enabled: fieldsEnabled,
              obscureText: !_showPassword,
            );
          },
        ),
        const SizedBox(height: 16),
        StreamBuilder<Set<PasswordValidationErrors>>(
          stream: loginController._credentials$.map(
            (state) => state.passwordErrors,
          ),
          builder: (context, snapshot) {
            return ElevatedButton.icon(
              onPressed: fieldsEnabled && (snapshot.data?.isEmpty ?? true)
                  ? _submitSignUp
                  : null,
              label: Text(context.t.login.buttons.signUp),
              icon: loginController.status.isLoading
                  ? SizedBox(
                      height: IconTheme.of(context).size,
                      width: IconTheme.of(context).size,
                      child: const CircularProgressIndicator(),
                    )
                  : const Icon(Icons.login),
            );
          },
        ),
      ],
    );
  }

  void _submitSignIn() async {
    _checkCredentials();

    try {
      await Get.find<_LoginController>().signIn(
        emailController.text,
        passwordController.text,
        context: context,
      );
    } on AuthApiException catch (e) {
      if (e.code == "email_not_confirmed") {
        Go.off(
          () => _AuthVerifyEmailString(
            email: emailController.text,
            password: passwordController.text,
          ),
        );
      }
      logger.e("AuthApiException: ${e.code} - ${e.message}");
      return;
    }
    Get.back();
  }

  void _submitSignUp() async {
    _checkCredentials();

    final isOk = await Get.find<_LoginController>().signUp(
      emailController.text,
      passwordController.text,
      usernameController.text,
      context: context,
    );
    if (isOk) {
      Go.off(
        () => _AuthVerifyEmailString(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
    }
  }

  void _checkCredentials() {
    Get.find<_LoginController>().checkCredentials(
      emailController.text,
      passwordController.text,
      usernameController.text,
    );
  }
}

class _AuthVerifyEmailString extends ConsumerStatefulWidget {
  const _AuthVerifyEmailString({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  ConsumerState<_AuthVerifyEmailString> createState() =>
      _AuthVerifyEmailStringState();
}

class _AuthVerifyEmailStringState
    extends ConsumerState<_AuthVerifyEmailString> {
  bool loading = false;
  bool emailVerified = false;

  @override
  Widget build(BuildContext context) => GetBuilder<_LoginController>(
    init: _LoginController(ref.read(onlineProvider.notifier)),
    builder: (controller) => _buildPage(context, controller),
  );

  Widget _buildPage(BuildContext context, _LoginController loginController) {
    return PopScope(
      canPop: emailVerified,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  context.t.login.verifyEmail.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.login.verifyEmail.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => _checkEmailVerification(loginController),
                  icon: const Icon(Icons.check),
                  label: Text(context.t.login.verifyEmail.done),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkEmailVerification(_LoginController loginController) async {
    setState(() => loading = true);
    try {
      final notConfirmedString = context.t.login.verifyEmail.notVerified;
      final isVerified = await loginController.checkEmailVerificationAndLogIn(
        email: widget.email,
        password: widget.password,
      );
      if (isVerified) {
        setState(() => emailVerified = true);
        await loginController.signIn(
          widget.email,
          widget.password,
          context: context,
        );
        Get.back();
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text(notConfirmedString)));
      }
    } finally {
      setState(() => loading = false);
    }
  }
}
