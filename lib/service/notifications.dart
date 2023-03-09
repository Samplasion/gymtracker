import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

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
    plugin.initialize(const InitializationSettings(
      android: androidInit,
      macOS: darwinInit,
      iOS: darwinInit,
    ));
  }
}
