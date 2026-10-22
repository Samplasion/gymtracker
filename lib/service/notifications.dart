import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications.g.dart';

class NotificationsService {
  NotificationsService({
    FlutterLocalNotificationsPlugin? plugin,
    void Function(NotificationResponse)? onResponse,
  }) : plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _onResponse = onResponse;
  final FlutterLocalNotificationsPlugin plugin;
  final void Function(NotificationResponse)? _onResponse;
  bool _disposed = false;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('ic_notifications');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        macOS: darwinInit,
        iOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        if (_disposed) return;
        logger.i('Notification tapped: ${response.id}');
        _onResponse?.call(response);
      },
    );
  }

  void dispose() => _disposed = true;
}

@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin notificationsPlugin(Ref ref) =>
    FlutterLocalNotificationsPlugin();

@Riverpod(keepAlive: true)
StreamController<NotificationResponse> notificationEvents(Ref ref) {
  final events = StreamController<NotificationResponse>.broadcast();
  ref.onDispose(events.close);
  return events;
}

@Riverpod(keepAlive: true)
void Function(NotificationResponse) notificationResponse(Ref ref) =>
    (response) {
      final events = ref.read(notificationEventsProvider);
      if (!events.isClosed) events.add(response);
    };

@Riverpod(keepAlive: true)
NotificationsService notificationsService(Ref ref) {
  final service = NotificationsService(
    plugin: ref.watch(notificationsPluginProvider),
    onResponse: ref.watch(notificationResponseProvider),
  );
  ref.onDispose(service.dispose);
  unawaited(service.initialize());
  return service;
}
