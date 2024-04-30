import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsService extends GetxService {
  final plugin = FlutterLocalNotificationsPlugin();

  @override
  onInit() {
    super.onInit();

    const androidInit = AndroidInitializationSettings('ic_launcher_foreground');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        macOS: darwinInit,
        iOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onTapNotification,
    );
  }

  Future<bool> hasPermission() async {
    final hasPermission = await Permission.notification.status;
    final hasExactPermission = (await plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications()) ??
        true;

    return hasPermission.isGranted && hasExactPermission;
  }

  _onTapNotification(NotificationResponse response) {
    logger.i('Notification tapped: ${response.id}');
    Get.find<Coordinator>().onNotificationTapped(response);
  }
}
