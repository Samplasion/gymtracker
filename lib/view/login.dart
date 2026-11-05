import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/email_confirmation.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' show isNetworkError;
import 'package:gymtracker/view/components/section_card.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LoginPhase { empty, loading, success, error }

class _LoginStatus {
  const _LoginStatus(this.phase, [this.errorMessage]);
  final _LoginPhase phase;
  final String? errorMessage;
  bool get isLoading => phase == _LoginPhase.loading;
  bool get isError => phase == _LoginPhase.error;
  bool get isSuccess => phase == _LoginPhase.success;
  bool get isEmpty => phase == _LoginPhase.empty;
}

final _loginControllerProvider =
    NotifierProvider.autoDispose<_LoginController, _LoginStatus>(
      _LoginController.new,
    );

class _LoginController extends Notifier<_LoginStatus> {
  Online get _controller => ref.read(onlineProvider.notifier);
  _LoginStatus get status => state;
  @override
  _LoginStatus build() {
    ref.onDispose(_credentials$.close);
    return const _LoginStatus(_LoginPhase.empty);
  }

  void change(Object? _, {required _LoginStatus status}) {
    if (ref.mounted) state = status;
  }

  final _credentials$ = BehaviorSubject<CredentialsState>.seeded(
    CredentialsState.empty(),
  );

  void checkCredentials(String email, String password, String username) {
    _credentials$.add(
      _controller.checkCredentials(
        email: email,
        password: password,
        username: username,
      ),
    );
  }

  Future<bool> signIn(
    String email,
    String password, {
    required BuildContext context,
  }) async {
    final errorLabels = context.t.login.errors;
    if (status.isLoading ||
        _credentials$.value.emailError ||
        password.isEmpty) {
      return false;
    }
    change(null, status: const _LoginStatus(_LoginPhase.loading));
    try {
      await _controller.login(email: email, password: password);
      change(null, status: const _LoginStatus(_LoginPhase.success));
      return true;
    } catch (e, stack) {
      logger.w('Unable to complete sign in', error: e, stackTrace: stack);
      final message = isNetworkError(e)
          ? errorLabels.noInternet
          : e is AuthException
          ? e.message
          : errorLabels.generic;
      change(null, status: _LoginStatus(_LoginPhase.error, message));
      if (e is AuthApiException && e.code == 'email_not_confirmed') rethrow;
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String username, {
    required BuildContext context,
  }) async {
    final errorLabels = context.t.login.errors;
    if (status.isLoading) return false;
    if (_credentials$.value.hasError) return false;
    if (password.isEmpty) return false;
    change(null, status: const _LoginStatus(_LoginPhase.loading));
    return _controller
        .register(email: email, password: password, username: username)
        .then((_) {
          change(null, status: const _LoginStatus(_LoginPhase.success));
          return true;
        })
        .catchError((e) {
          String message = e.toString();
          if (e is AuthException) {
            if (e.message.contains("Socket")) {
              message = errorLabels.noInternet;
            } else if (e.message == "login.errors.usernameTaken") {
              message = errorLabels.usernameTaken;
            } else {
              message = e.message;
            }
          }
          change(null, status: _LoginStatus(_LoginPhase.error, message));
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

enum _AuthVariant { signIn, signUp, recovery }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _AuthVariant _variant = _AuthVariant.signIn;
  bool _recoverySent = false;
  bool _requestingRecovery = false;
  String? _recoveryError;
  final _recoveryForm = GlobalKey<FormState>();
  final _signInForm = GlobalKey<FormState>();
  final _signUpForm = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _submitted = false;

  void _switchTo(_AuthVariant variant) {
    FocusScope.of(context).unfocus();
    ref
        .read(_loginControllerProvider.notifier)
        .change(null, status: const _LoginStatus(_LoginPhase.empty));
    setState(() {
      _variant = variant;
      _submitted = false;
      _recoverySent = false;
      _recoveryError = null;
      _showPassword = false;
      _showConfirmation = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  CredentialsState get _credentials => ref
      .read(onlineProvider.notifier)
      .checkCredentials(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: usernameController.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(_loginControllerProvider);
    final busy = status.isLoading || _requestingRecovery;
    final canGoBack =
        _variant != _AuthVariant.signIn || Navigator.of(context).canPop();
    return PopScope(
      canPop: !busy && _variant == _AuthVariant.signIn,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !busy && _variant != _AuthVariant.signIn) {
          _switchTo(_AuthVariant.signIn);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    if (canGoBack)
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: busy
                            ? null
                            : () {
                                if (_variant != _AuthVariant.signIn) {
                                  _switchTo(_AuthVariant.signIn);
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    const Spacer(),
                    if (MediaQuery.viewInsetsOf(context).bottom > 0)
                      IconButton(
                        tooltip: context.t.login.buttons.dismissKeyboard,
                        onPressed: () => FocusScope.of(context).unfocus(),
                        icon: const Icon(Icons.keyboard_hide_rounded),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 56).clamp(
                          0,
                          double.infinity,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: _variant == _AuthVariant.recovery
                              ? _recovery(context)
                              : _form(
                                  context,
                                  status,
                                  signingUp: _variant == _AuthVariant.signUp,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GTSectionIcon(icon),
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _notice(String text, {bool error = false}) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: error ? colors.errorContainer : colors.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: error
                ? colors.onErrorContainer
                : colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _recovery(BuildContext context) {
    final strings = context.t.login;
    return Form(
      key: _recoveryForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _heading(
            icon: _recoverySent
                ? Icons.mark_email_read_outlined
                : Icons.lock_reset_rounded,
            title: _recoverySent
                ? strings.recovery.sentTitle
                : strings.recovery.title,
            subtitle: _recoverySent
                ? strings.recovery.sentDescription
                : strings.recovery.description,
          ),
          if (_recoveryError != null) ...[
            _notice(_recoveryError!, error: true),
            const SizedBox(height: 16),
          ],
          if (_recoverySent) ...[
            _notice(strings.recovery.checkSpam),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _switchTo(_AuthVariant.signIn),
              child: Text(strings.recovery.backToSignIn),
            ),
          ] else ...[
            TextFormField(
              controller: emailController,
              enabled: !_requestingRecovery,
              decoration: _decoration(
                strings.fields.email.label,
                Icons.alternate_email_rounded,
                hint: strings.fields.email.hint,
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: (_) =>
                  emailController.text.trim().isEmpty || _credentials.emailError
                  ? strings.errors.email
                  : null,
              onFieldSubmitted: _requestingRecovery
                  ? null
                  : (_) => _requestRecovery(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _requestingRecovery ? null : _requestRecovery,
              icon: _requestingRecovery
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(strings.recovery.send),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _requestingRecovery
                  ? null
                  : () => _switchTo(_AuthVariant.signIn),
              child: Text(strings.recovery.backToSignIn),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestRecovery() async {
    if (_requestingRecovery ||
        !(_recoveryForm.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _requestingRecovery = true;
      _recoveryError = null;
    });
    try {
      await ref
          .read(onlineProvider.notifier)
          .requestPasswordRecovery(
            email: emailController.text.trim(),
            locale: TranslationProvider.of(context).flutterLocale.languageCode,
          );
      if (mounted) setState(() => _recoverySent = true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _recoveryError = isNetworkError(error)
              ? context.t.login.errors.noInternet
              : context.t.login.recovery.error,
        );
      }
    } finally {
      if (mounted) setState(() => _requestingRecovery = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.all(16),
      errorMaxLines: 4,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    );
  }

  Widget _visibility({required bool confirmation, required bool enabled}) {
    final visible = confirmation ? _showConfirmation : _showPassword;
    return IconButton(
      tooltip: visible
          ? context.t.login.buttons.hidePassword
          : context.t.login.buttons.showPassword,
      onPressed: enabled
          ? () => setState(() {
              if (confirmation) {
                _showConfirmation = !_showConfirmation;
              } else {
                _showPassword = !_showPassword;
              }
            })
          : null,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }

  Widget _form(
    BuildContext context,
    _LoginStatus status, {
    required bool signingUp,
  }) {
    final strings = context.t.login;
    final enabled = !status.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _heading(
          icon: signingUp
              ? Icons.person_add_alt_1_rounded
              : Icons.login_rounded,
          title: signingUp
              ? strings.presentation.signUpTitle
              : strings.presentation.signInTitle,
          subtitle: signingUp
              ? strings.presentation.signUpSubtitle
              : strings.presentation.signInSubtitle,
        ),
        AutofillGroup(
          child: Form(
            key: signingUp ? _signUpForm : _signInForm,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (status.isError) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status.errorMessage ?? strings.errors.generic,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (signingUp) ...[
                  TextFormField(
                    controller: usernameController,
                    enabled: enabled,
                    decoration: _decoration(
                      strings.fields.username.label,
                      Icons.person_outline_rounded,
                      hint: strings.fields.username.hint,
                    ),
                    autofillHints: const [AutofillHints.newUsername],
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: (_) => _credentials.usernameError
                        ? strings.errors.username
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: emailController,
                  enabled: enabled,
                  decoration: _decoration(
                    strings.fields.email.label,
                    Icons.alternate_email_rounded,
                    hint: strings.fields.email.hint,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: (_) =>
                      _credentials.emailError ||
                          emailController.text.trim().isEmpty
                      ? strings.errors.email
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  enabled: enabled,
                  decoration:
                      _decoration(
                        strings.fields.password.label,
                        Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: _visibility(
                          confirmation: false,
                          enabled: enabled,
                        ),
                      ),
                  obscureText: !_showPassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: [
                    signingUp
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  textInputAction: signingUp
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: enabled && !signingUp
                      ? (_) => _submitSignIn()
                      : null,
                  validator: (_) {
                    if (passwordController.text.isEmpty) {
                      return strings.errors.passwordRequired;
                    }
                    if (signingUp && _credentials.passwordErrors.isNotEmpty) {
                      return strings.presentation.passwordRequirements;
                    }
                    return null;
                  },
                ),
                if (!signingUp)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: enabled
                          ? () => _switchTo(_AuthVariant.recovery)
                          : null,
                      child: Text(strings.recovery.forgot),
                    ),
                  ),
                if (signingUp) ...[
                  const SizedBox(height: 8),
                  Text(
                    strings.presentation.passwordRequirements,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    enabled: enabled,
                    decoration:
                        _decoration(
                          strings.fields.confirmPassword.label,
                          Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: _visibility(
                            confirmation: true,
                            enabled: enabled,
                          ),
                        ),
                    obscureText: !_showConfirmation,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: enabled ? (_) => _submitSignUp() : null,
                    validator: (value) => value == null || value.isEmpty
                        ? strings.errors.confirmPasswordRequired
                        : value != passwordController.text
                        ? strings.errors.passwordMismatch
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: enabled
                      ? (signingUp ? _submitSignUp : _submitSignIn)
                      : null,
                  icon: status.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          signingUp
                              ? Icons.person_add_alt_1_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                  label: Text(
                    signingUp ? strings.buttons.signUp : strings.buttons.signIn,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              signingUp
                  ? strings.presentation.haveAccount
                  : strings.presentation.noAccount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: enabled
                  ? () => _switchTo(
                      signingUp ? _AuthVariant.signIn : _AuthVariant.signUp,
                    )
                  : null,
              child: Text(
                signingUp ? strings.buttons.signIn : strings.buttons.signUp,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validate(GlobalKey<FormState> form) {
    if (ref.read(_loginControllerProvider).isLoading) return false;
    setState(() => _submitted = true);
    _checkCredentials();
    return form.currentState?.validate() ?? false;
  }

  void _submitSignIn() async {
    if (!_validate(_signInForm)) return;
    FocusScope.of(context).unfocus();
    try {
      final success = await ref
          .read(_loginControllerProvider.notifier)
          .signIn(
            emailController.text.trim(),
            passwordController.text,
            context: context,
          );
      if (success && mounted) Navigator.of(context).pop();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'email_not_confirmed') {
        Go.off(
          () => AuthVerifyEmailScreen(
            email: emailController.text.trim(),
            password: passwordController.text,
          ),
        );
      }
      logger.e('AuthApiException: ${e.code} - ${e.message}');
    }
  }

  void _submitSignUp() async {
    if (!_validate(_signUpForm)) return;
    FocusScope.of(context).unfocus();
    final isOk = await ref
        .read(_loginControllerProvider.notifier)
        .signUp(
          emailController.text.trim(),
          passwordController.text,
          usernameController.text.trim(),
          context: context,
        );
    if (isOk && mounted) {
      Go.off(
        () => AuthVerifyEmailScreen(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
    }
  }

  void _checkCredentials() {
    ref
        .read(_loginControllerProvider.notifier)
        .checkCredentials(
          emailController.text.trim(),
          passwordController.text,
          usernameController.text.trim(),
        );
  }
}

class AuthVerifyEmailScreen extends ConsumerStatefulWidget {
  const AuthVerifyEmailScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  ConsumerState<AuthVerifyEmailScreen> createState() =>
      _AuthVerifyEmailScreenState();
}

class _AuthVerifyEmailScreenState extends ConsumerState<AuthVerifyEmailScreen> {
  bool loading = false;
  bool emailVerified = false;
  late final ProtocolService _links;
  late final EmailConfirmationListener _confirmationListener;

  @override
  void initState() {
    super.initState();
    _links = ref.read(protocolServiceProvider);
    _confirmationListener = EmailConfirmationListener(() {
      _checkEmailVerification(ref.read(_loginControllerProvider.notifier));
    });
    _links.addListener(_confirmationListener);
  }

  @override
  void dispose() {
    _links.removeListener(_confirmationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_loginControllerProvider);
    return _buildPage(context, ref.read(_loginControllerProvider.notifier));
  }

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
    if (loading || emailVerified || !mounted) return;
    setState(() => loading = true);
    try {
      final notConfirmedString = context.t.login.verifyEmail.notVerified;
      final isVerified = await loginController.checkEmailVerificationAndLogIn(
        email: widget.email,
        password: widget.password,
      );
      if (!mounted) return;
      if (isVerified) {
        setState(() => emailVerified = true);
        if (mounted) Navigator.of(context).pop();
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text(notConfirmedString)));
      }
    } catch (error, stack) {
      logger.w(
        'Email verification check failed',
        error: error,
        stackTrace: stack,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.login.errors.noInternet)),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
