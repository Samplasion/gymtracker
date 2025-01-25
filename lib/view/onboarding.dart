import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final foodController = Get.find<FoodController>();

    nextButton(bool enabled) => ElevatedButton(
          onPressed: () {
            _introKey.currentState?.next();
          },
          child: Text('onboarding.buttons.next'.t),
        );
    permIcon(IconData defaultValue, bool granted) => Icon(
          granted ? Icons.check_rounded : defaultValue,
          size: 24,
        );
    return StreamBuilder<void>(
      stream: notificationController.status,
      builder: (context, snapshot) {
        return StreamBuilder<({bool camera, bool gallery})>(
          stream: foodController.permission$,
          initialData: (camera: false, gallery: false),
          builder: (context, snapshot) {
            final foodPerms = snapshot.data ?? (camera: false, gallery: false);
            return IntroductionScreen(
              key: _introKey,
              pages: [
                PageViewModel(
                  title: 'onboarding.welcome.title'.t,
                  image: const InAppIcon.proportional(size: 96),
                  body: 'onboarding.welcome.text'.t,
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
                  title: 'onboarding.notifications.title'.t,
                  image: const Icon(GTIcons.notification_dialog, size: 64),
                  body: 'onboarding.notifications.text'.t,
                  footer: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OverflowBar(
                      alignment: MainAxisAlignment.center,
                      overflowAlignment: OverflowBarAlignment.center,
                      spacing: 8,
                      overflowSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: permIcon(Icons.notifications,
                              notificationController.hasPermission),
                          label:
                              Text('onboarding.notifications.notifications'.t),
                          onPressed: notificationController.hasPermission
                              ? null
                              : () {
                                  // Request permission
                                  notificationController.requestPermission();
                                },
                        ),
                        if (notificationController
                            .usesAndroidExactAlarmPermission)
                          ElevatedButton.icon(
                            icon: permIcon(
                                Icons.notifications_active,
                                notificationController
                                    .hasAndroidScheduleExactAlarmPermission),
                            label:
                                Text('onboarding.notifications.exactAlarm'.t),
                            onPressed: !notificationController
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
                  title: 'onboarding.camera.title'.t,
                  image: const Icon(GTIcons.camera, size: 64),
                  body: 'onboarding.camera.text'.t,
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
                          label: Text('onboarding.camera.camera'.t),
                          onPressed: foodPerms.camera
                              ? null
                              : () {
                                  // Request permission
                                  foodController
                                      .requestPermission(Permission.camera);
                                },
                        ),
                        ElevatedButton.icon(
                          icon: permIcon(Icons.photo, foodPerms.gallery),
                          label: Text('onboarding.camera.gallery'.t),
                          onPressed: foodPerms.gallery
                              ? null
                              : () {
                                  // Request permission
                                  foodController
                                      .requestPermission(Permission.photos);
                                },
                        ),
                        nextButton(true),
                      ],
                    ),
                  ),
                ),
                PageViewModel(
                  title: 'onboarding.done.title'.t,
                  image: const Icon(GTIcons.checkbox_on, size: 64),
                  body: 'onboarding.done.text'.t,
                  footer: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OverflowBar(
                      alignment: MainAxisAlignment.center,
                      overflowAlignment: OverflowBarAlignment.center,
                      spacing: 8,
                      overflowSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Done
                            Get.find<Coordinator>().onFinishedOnboarding();
                          },
                          child: Text('onboarding.buttons.done'.t),
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
      },
    );
  }
}
