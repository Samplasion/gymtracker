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

  @override
  Widget build(BuildContext context) {
    final notificationController = ref.read(notificationControllerProvider);
    ref.watch(notificationPermissionsProvider);
    final foodPerms =
        ref.watch(foodPermissionsProvider).asData?.value ??
        (camera: false, gallery: false);

    nextButton(bool enabled) => ElevatedButton(
      onPressed: () {
        _introKey.currentState?.next();
      },
      child: Text(context.t.onboarding.buttons.next),
    );
    permIcon(IconData defaultValue, bool granted) =>
        Icon(granted ? Icons.check_rounded : defaultValue, size: 24);
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
                  children: [nextButton(true)],
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
                    ElevatedButton.icon(
                      icon: permIcon(
                        Icons.notifications,
                        notificationController.hasPermission,
                      ),
                      label: Text(
                        context.t.onboarding.notifications.notifications,
                      ),
                      onPressed: notificationController.hasPermission
                          ? null
                          : () {
                              // Request permission
                              notificationController.requestPermission();
                            },
                    ),
                    if (notificationController.usesAndroidExactAlarmPermission)
                      ElevatedButton.icon(
                        icon: permIcon(
                          Icons.notifications_active,
                          notificationController
                              .hasAndroidScheduleExactAlarmPermission,
                        ),
                        label: Text(
                          context.t.onboarding.notifications.exactAlarm,
                        ),
                        onPressed:
                            !notificationController
                                .shouldShowAndroidExactAlarmPermissionRequest
                            ? null
                            : () {
                                // Request permission
                                notificationController
                                    .androidRequestExactAlarmsPermission();
                              },
                      ),
                    nextButton(true),
                  ],
                ),
              ),
            ),
            PageViewModel(
              title: context.t.onboarding.camera.title,
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
                    ElevatedButton.icon(
                      icon: permIcon(Icons.camera_alt, foodPerms.camera),
                      label: Text(context.t.onboarding.camera.camera),
                      onPressed: foodPerms.camera
                          ? null
                          : () {
                              // Request permission
                              ref
                                  .read(foodPermissionsProvider.notifier)
                                  .requestPermission(Permission.camera);
                            },
                    ),
                    ElevatedButton.icon(
                      icon: permIcon(Icons.photo, foodPerms.gallery),
                      label: Text(context.t.onboarding.camera.gallery),
                      onPressed: foodPerms.gallery
                          ? null
                          : () {
                              // Request permission
                              ref
                                  .read(foodPermissionsProvider.notifier)
                                  .requestPermission(Permission.photos);
                            },
                    ),
                    nextButton(true),
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
                    OverflowBar(
                      alignment: MainAxisAlignment.center,
                      overflowAlignment: OverflowBarAlignment.center,
                      spacing: 8,
                      overflowSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: permIcon(
                            GTIcons.account,
                            onlineAccount != null,
                          ),
                          label: Text(context.t.login.title),
                          onPressed: onlineAccount != null
                              ? null
                              : () {
                                  Go.to(() => AuthScreen());
                                },
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        _introKey.currentState?.next();
                      },
                      child: Text(context.t.onboarding.buttons.next),
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
          freeze: false,
          showNextButton: false,
          showDoneButton: false,
          isProgressTap: false,
        );
      },
    );
  }
}
