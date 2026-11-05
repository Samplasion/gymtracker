import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/notifications.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  bool _busy = false;

  Future<void> _advance() async {
    final intro = _introKey.currentState;
    if (intro == null) return;
    await intro.animateScroll(intro.getCurrentPage() + 1);
  }

  Future<void> _next({Future<void> Function()? requestPermissions}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await requestPermissions?.call();
      if (!mounted) return;
      await _advance();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestNotifications() async {
    final controller = ref.read(notificationControllerProvider);
    await controller.requestPermission();
    if (!mounted) return;
    await controller.androidRequestExactAlarmsPermission();
  }

  Future<void> _requestCameraAndPhotos() async {
    final permissions = await ref.read(foodPermissionsProvider.future);
    if (!mounted) return;
    final controller = ref.read(foodPermissionsProvider.notifier);
    if (!permissions.camera) {
      await controller.requestPermission(Permission.camera);
    }
    if (!mounted) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        !permissions.gallery) {
      await controller.requestPermission(Permission.photos);
    }
  }

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Go.to(() => AuthScreen());
      if (!mounted) return;
      if (ref.read(onlineProvider).value != null) {
        await _advance();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the permission provider alive while native permission dialogs are open.
    ref.watch(foodPermissionsProvider);

    Widget nextButton({Future<void> Function()? requestPermissions}) =>
        ElevatedButton(
          onPressed: _busy
              ? null
              : () => _next(requestPermissions: requestPermissions),
          child: Text(context.t.onboarding.buttons.next),
        );
    return Builder(
      builder: (context) {
        final onlineAccount = ref.watch(onlineProvider).value;
        return IntroductionScreen(
          key: _introKey,
          pages: [
            PageViewModel(
              title: context.t.onboarding.welcome.title,
              image: const InAppIcon.proportional(size: 96),
              body: context.t.onboarding.welcome.text,
              footer: Padding(
                padding: const EdgeInsets.all(16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.center,
                  overflowAlignment: OverflowBarAlignment.center,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [nextButton()],
                ),
              ),
            ),
            PageViewModel(
              title: context.t.onboarding.notifications.title,
              image: const Icon(GTIcons.notification_dialog, size: 64),
              body: context.t.onboarding.notifications.text,
              footer: Padding(
                padding: const EdgeInsets.all(16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.center,
                  overflowAlignment: OverflowBarAlignment.center,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    nextButton(requestPermissions: _requestNotifications),
                  ],
                ),
              ),
            ),
            PageViewModel(
              title: defaultTargetPlatform == TargetPlatform.android
                  ? context.t.onboarding.camera.camera
                  : context.t.onboarding.camera.title,
              image: const Icon(GTIcons.camera, size: 64),
              body: context.t.onboarding.camera.text,
              footer: Padding(
                padding: const EdgeInsets.all(16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.center,
                  overflowAlignment: OverflowBarAlignment.center,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    nextButton(requestPermissions: _requestCameraAndPhotos),
                  ],
                ),
              ),
            ),
            PageViewModel(
              title: context.t.onboarding.login.title,
              image: const Icon(GTIcons.account, size: 64),
              body: context.t.onboarding.login.text,
              footer: Padding(
                padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: Icon(
                          onlineAccount != null
                              ? Icons.check_rounded
                              : GTIcons.account,
                        ),
                        label: Text(
                          onlineAccount != null
                              ? context.t.onboarding.buttons.next
                              : context.t.login.title,
                        ),
                        onPressed: _busy
                            ? null
                            : onlineAccount != null
                            ? () => _next()
                            : _signIn,
                      ),
                    ),
                    if (onlineAccount == null)
                      TextButton(
                        onPressed: _busy ? null : () => _next(),
                        child: Text(context.t.onboarding.buttons.skip),
                      ),
                  ],
                ),
              ),
            ),
            PageViewModel(
              title: context.t.onboarding.done.title,
              image: const Icon(GTIcons.checkbox_on, size: 64),
              body: context.t.onboarding.done.text,
              footer: Padding(
                padding: const EdgeInsets.all(16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.center,
                  overflowAlignment: OverflowBarAlignment.center,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Done
                        final service = ref.read(databaseServiceProvider);
                        await service.writeSettings(
                          service.prefs$.value.copyWithOnboardingComplete(),
                        );
                        if (context.mounted) context.go('/feed');
                      },
                      child: Text(context.t.onboarding.buttons.done),
                    ),
                  ],
                ),
              ),
            ),
          ],
          freeze: _busy,
          showNextButton: false,
          showDoneButton: false,
          isProgressTap: false,
        );
      },
    );
  }
}
