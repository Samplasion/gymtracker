part of 'me.dart';

class _ProfileEditPage extends ConsumerStatefulWidget {
  const _ProfileEditPage();

  @override
  ConsumerState<_ProfileEditPage> createState() => __ProfileEditPageState();
}

class __ProfileEditPageState extends ConsumerState<_ProfileEditPage> {
  var _state = CredentialsState.empty();

  late final TextEditingController _usernameController = TextEditingController(
    text: ref.read(onlineProvider).value?.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: ref.read(onlineProvider).value?.email,
  );

  var isLoading = false;

  void _checkCredentials() {
    final state = ref
        .read(onlineProvider.notifier)
        .checkCredentials(
          email: _emailController.text,
          password: "",
          username: _usernameController.text,
        );
    setState(() {
      _state = state;
    });
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    try {
      await ref
          .read(onlineProvider.notifier)
          .updateAccount(
            username: _usernameController.text,
            email: _emailController.text,
          );
    } finally {
      setState(() {
        isLoading = false;
      });
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.me.profile.edit.title),
          leading: IconButton(
            icon: const Icon(GTIcons.close),
            onPressed: isLoading ? null : Get.back,
          ),
          actions: [
            IconButton(
              onPressed: !_state.hasError && !isLoading
                  ? () {
                      _submit();
                    }
                  : null,
              icon: const Icon(GTIcons.done),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _usernameController,
                onChanged: (_) => _checkCredentials(),
                decoration: InputDecoration(
                  labelText: context.t.login.fields.username.label,
                  errorText: _state.usernameError
                      ? context.t.login.errors.username
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                onChanged: (_) => _checkCredentials(),
                decoration: InputDecoration(
                  labelText: context.t.login.fields.email.label,
                  errorText: _state.emailError
                      ? context.t.login.errors.email
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
