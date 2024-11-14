part of 'me.dart';

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth / 2;
          return Icon(
            GTIcons.account,
            size: size,
          );
        },
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    const height = 348.0;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SizedBox(
            height: height - 48,
            child: IconGrid(
              bigScale: 2,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: const Icon(GTIcons.app_icon),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 32,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const _UserAvatar(),
            ),
          ),
        ],
      ),
    );
  }
}

class MeProfilePage extends ControlledWidget<OnlineController> {
  const MeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("me.profile.title".t),
        actions: [
          IconButton(
            onPressed: () {
              Go.to(() => const _ProfileEditPage());
            },
            icon: const Icon(GTIcons.edit),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: controller.account,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          if (snapshot.data == null) {
            return _buildLoggedOut(context);
          }

          return _buildLoggedIn(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoggedOut(BuildContext context) => Container();

  Widget _buildLoggedIn(BuildContext context, OnlineAccount account) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UserHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: context.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (account.email != null)
                  Text(
                    account.email!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.logout().then((_) {
                      Get.back();
                    });
                  },
                  child: Text("me.profile.logout".t),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditPage extends StatefulWidget {
  const _ProfileEditPage();

  @override
  State<_ProfileEditPage> createState() => __ProfileEditPageState();
}

class __ProfileEditPageState
    extends ControlledState<_ProfileEditPage, OnlineController> {
  var _state = CredentialsState.empty();

  late final TextEditingController _usernameController = TextEditingController(
    text: controller.accountSync?.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: controller.accountSync?.email,
  );

  var isLoading = false;

  void _checkCredentials() {
    final state = controller.checkCredentials(
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
      await controller.updateAccount(
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
          title: Text("me.profile.edit.title".t),
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
                  labelText: "login.fields.username.label".t,
                  errorText: _state.usernameError
                      ? "login.errors.username".t
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                onChanged: (_) => _checkCredentials(),
                decoration: InputDecoration(
                  labelText: "login.fields.email.label".t,
                  errorText: _state.emailError
                      ? "login.errors.email".t
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
