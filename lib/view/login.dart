import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/online_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:rxdart/rxdart.dart';

class _LoginController extends GetxController
    with ServiceableController, StateMixin {
  final OnlineController _controller;

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
    _credentials$.add(_controller.checkCredentials(
      email: email,
      password: password,
      username: username,
    ));
  }

  void signIn(String email, String password) {
    if (status.isLoading) return;
    if (_credentials$.value.emailError) return;
    if (password.isEmpty) return;
    change(null, status: RxStatus.loading());
    _controller.login(email: email, password: password).then((_) {
      change(null, status: RxStatus.success());
      Get.back();
    }).catchError((e) {
      String message = e.toString();
      if (e is AuthException) {
        if (e.message.contains("Socket")) {
          message = "login.errors.noInternet".t;
        } else {
          message = e.message;
        }
      }
      change(null, status: RxStatus.error(message));
    });
  }

  void signUp(String email, String password, String username) {
    if (status.isLoading) return;
    if (_credentials$.value.hasError) return;
    if (password.isEmpty) return;
    change(null, status: RxStatus.loading());
    _controller
        .register(
      email: email,
      password: password,
      username: username,
    )
        .then((_) {
      change(null, status: RxStatus.success());
      Get.back();
    }).catchError((e) {
      String message = e.toString();
      if (e is AuthException) {
        if (e.message.contains("Socket")) {
          message = "login.errors.noInternet".t;
        } else {
          message = e.message;
        }
      }
      change(null, status: RxStatus.error(message));
    });
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ControlledState<AuthScreen, OnlineController>
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
        init: _LoginController(controller),
        builder: (controller) => _buildPage(context, controller),
      );

  Widget _buildPage(BuildContext context, _LoginController loginController) {
    final fieldsEnabled = loginController.status.isError ||
        loginController.status.isSuccess ||
        loginController.status.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("login.title".t),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'login.tabs.signIn'.t),
            Tab(text: 'login.tabs.signUp'.t),
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

  ListView _signInTree(BuildContext context, _LoginController loginController,
      bool fieldsEnabled) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (loginController.status.isError)
          Text(loginController.status.errorMessage?.toString() ??
              'login.errors.generic'.t),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'login.fields.email.label'.t,
            hintText: 'login.fields.email.hint'.t,
          ),
          enabled: fieldsEnabled,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'login.fields.password.label'.t,
            hintText: 'login.fields.password.hint'.t,
            suffixIcon: IconButton(
              icon:
                  Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          enabled: fieldsEnabled,
          obscureText: !_showPassword,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: fieldsEnabled ? _submitSignIn : null,
          label: Text('login.buttons.signIn'.t),
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

  ListView _signUpTree(BuildContext context, _LoginController loginController,
      bool fieldsEnabled) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (loginController.status.isError)
          Text(loginController.status.errorMessage?.toString() ??
              'login.errors.generic'.t),
        const SizedBox(height: 16),
        StreamBuilder<CredentialsState>(
          stream: loginController._credentials$,
          builder: (context, snapshot) {
            return TextField(
              controller: usernameController,
              onChanged: (_) => _checkCredentials(),
              decoration: InputDecoration(
                labelText: 'login.fields.username.label'.t,
                hintText: 'login.fields.username.hint'.t,
                errorText: snapshot.data?.when(
                  invalid: (_, __, usernameError) {
                    if (!usernameError) return null;
                    return 'login.errors.username'.t;
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
                labelText: 'login.fields.email.label'.t,
                hintText: 'login.fields.email.hint'.t,
                errorText: snapshot.data?.when(
                  invalid: (emailError, _, __) {
                    if (!emailError) return null;
                    return 'login.errors.email'.t;
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
                labelText: 'login.fields.password.label'.t,
                hintText: 'login.fields.password.hint'.t,
                error: snapshot.data?.when(
                  invalid: (_, passwordErrors, __) {
                    if (passwordErrors.isEmpty) return null;
                    var _error = Theme.of(context).colorScheme.error;
                    var _text = Theme.of(context).textTheme.bodySmall!.color;
                    return Text.rich(TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: _error),
                      children: [
                        TextSpan(
                            text:
                                '${'login.errors.password.invalid.header'.t}\n'),
                        TextSpan(
                          text: '${'login.errors.password.invalid.length'.t}\n',
                          style: TextStyle(
                            color: (passwordErrors
                                    .contains(PasswordValidationErrors.length))
                                ? _error
                                : _text,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${'login.errors.password.invalid.uppercase'.t}\n',
                          style: TextStyle(
                            color: (passwordErrors.contains(
                                    PasswordValidationErrors.uppercase))
                                ? _error
                                : _text,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${'login.errors.password.invalid.lowercase'.t}\n',
                          style: TextStyle(
                            color: (passwordErrors.contains(
                                    PasswordValidationErrors.lowercase))
                                ? _error
                                : _text,
                          ),
                        ),
                        TextSpan(
                          text: '${'login.errors.password.invalid.number'.t}\n',
                          style: TextStyle(
                            color: (passwordErrors
                                    .contains(PasswordValidationErrors.number))
                                ? _error
                                : _text,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${'login.errors.password.invalid.specialCharacter'.t}\n',
                          style: TextStyle(
                            color: (passwordErrors.contains(
                                    PasswordValidationErrors.specialCharacter))
                                ? _error
                                : _text,
                          ),
                        ),
                      ],
                    ));
                  },
                  orElse: () => null,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
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
            stream: loginController._credentials$
                .map((state) => state.passwordErrors),
            builder: (context, snapshot) {
              return ElevatedButton.icon(
                onPressed: fieldsEnabled && (snapshot.data?.isEmpty ?? true)
                    ? _submitSignUp
                    : null,
                label: Text('login.buttons.signUp'.t),
                icon: loginController.status.isLoading
                    ? SizedBox(
                        height: IconTheme.of(context).size,
                        width: IconTheme.of(context).size,
                        child: const CircularProgressIndicator(),
                      )
                    : const Icon(Icons.login),
              );
            }),
      ],
    );
  }

  void _submitSignIn() async {
    _checkCredentials();

    Get.find<_LoginController>().signIn(
      emailController.text,
      passwordController.text,
    );
  }

  void _submitSignUp() async {
    _checkCredentials();

    Get.find<_LoginController>().signUp(
      emailController.text,
      passwordController.text,
      usernameController.text,
    );
  }

  void _checkCredentials() {
    Get.find<_LoginController>().checkCredentials(
      emailController.text,
      passwordController.text,
      usernameController.text,
    );
  }
}
