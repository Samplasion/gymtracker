import 'package:gymtracker/view/trainer.dart';
import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/social.dart';
import 'package:gymtracker/view/social_notifications.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

FirebaseOptions? pushFirebaseOptions() {
  if (kIsWeb) return null;
  final (apiKey, appId) = switch (defaultTargetPlatform) {
    TargetPlatform.android => (
      Env.firebaseAndroidApiKey,
      Env.firebaseAndroidAppId,
    ),
    TargetPlatform.iOS => (Env.firebaseIosApiKey, Env.firebaseIosAppId),
    _ => ('', ''),
  };
  if ([
    apiKey,
    appId,
    Env.firebaseMessagingSenderId,
    Env.firebaseProjectId,
  ].any((value) => value.isEmpty)) {
    return null;
  }
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    iosBundleId: Env.firebaseIosBundleId.isEmpty
        ? null
        : Env.firebaseIosBundleId,
  );
}

@pragma('vm:entry-point')
Future<void> pushBackgroundMessage(RemoteMessage message) async {
  final options = pushFirebaseOptions();
  if (options != null && Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
  }
  // The OS displays the localized notification payload. No account data is
  // fetched or persisted by the background isolate.
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(ref);
  ref.listen(currentUserIdProvider, (_, _) => unawaited(service.refresh()));
  ref.listen(appPreferencesProvider, (_, _) => unawaited(service.refresh()));
  // Reuse the app's existing system-permission flow (onboarding/settings).
  // There is no separate push opt-in stored in the app.
  ref.listen(
    notificationPermissionsProvider.select(
      (state) => state.value?.hasPermission,
    ),
    (_, permission) {
      if (permission != null) unawaited(service.refresh());
    },
  );
  ref.onDispose(service.dispose);
  unawaited(service.initialize());
  return service;
});

class PushService with WidgetsBindingObserver {
  PushService(this.ref);
  final Ref ref;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  bool ready = false, disposed = false;
  String? installation;
  Future<void> initialize() async {
    if (kIsWeb ||
        !(defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      return;
    }
    try {
      final options = pushFirebaseOptions();
      if (options == null) return;
      if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
      if (disposed) return;
      final prefs = await SharedPreferences.getInstance();
      installation = prefs.getString('push_installation') ?? const Uuid().v4();
      await prefs.setString('push_installation', installation!);
      FirebaseMessaging.onBackgroundMessage(pushBackgroundMessage);
      final local = ref.read(notificationsPluginProvider);
      await local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              'social',
              t.social.notifications,
              importance: Importance.high,
            ),
          );
      subscriptions.add(
        ref.read(notificationEventsProvider).stream.listen((response) {
          unawaited(openLocal(response.payload));
        }),
      );
      final launch = await local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        unawaited(openLocal(launch?.notificationResponse?.payload));
      }
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
      subscriptions.add(
        // HTTP v1 delivery still uses the registration token API.
        // ignore: deprecated_member_use
        FirebaseMessaging.instance.onTokenRefresh.listen((_) {
          unawaited(refresh());
        }),
      );
      subscriptions.add(
        FirebaseMessaging.onMessage.listen((message) {
          if (!disposed) {
            ref.invalidate(socialNotificationsProvider);
            ref.invalidate(notificationSummaryProvider);
            if (defaultTargetPlatform == TargetPlatform.android &&
                message.data['recipient_id'] ==
                    ref.read(currentUserIdProvider)) {
              final notification = message.notification;
              if (notification != null) {
                unawaited(
                  ref
                      .read(notificationsPluginProvider)
                      .show(
                        id:
                            (int.tryParse(
                                  message.data['notification_id'] ?? '',
                                ) ??
                                0) &
                            0x7fffffff,
                        title: notification.title,
                        body: notification.body,
                        notificationDetails: NotificationDetails(
                          android: AndroidNotificationDetails(
                            'social',
                            t.social.notifications,
                            importance: Importance.high,
                            priority: Priority.high,
                          ),
                        ),
                        payload: 'social:' + jsonEncode(message.data),
                      ),
                );
              }
            }
          }
        }),
      );
      subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          unawaited(open(message));
        }),
      );
      WidgetsBinding.instance.addObserver(this);
      ready = true;
      await refresh();
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) await open(message);
    } catch (error, stack) {
      logger.w('Push initialization deferred', error: error, stackTrace: stack);
    }
  }

  Future<bool> enable() async {
    if (!ready) await initialize();
    if (!ready) return false;
    final settings = await FirebaseMessaging.instance.requestPermission();
    await refresh();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _registration = Future.value();
  Future<void> refresh() {
    final work = _registration.then((_) => _refresh());
    _registration = work.catchError((Object error, StackTrace stack) {
      globalLogger.w('Push refresh deferred', error: error, stackTrace: stack);
    });
    return work;
  }

  Future<void> _refresh() async {
    if (!ready || disposed) return;
    try {
      final owner = ref.read(currentUserIdProvider);
      if (owner == null) return;
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        await unregister();
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          await FirebaseMessaging.instance.getAPNSToken() == null) {
        return;
      }
      // HTTP v1 expects a registration token rather than an installation ID.
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null ||
          disposed ||
          ref.read(currentUserIdProvider) != owner) {
        return;
      }
      final locale = ref.read(appPreferencesProvider).value?.locale;
      final language = locale == null || locale.languageCode == 'SYSTEM'
          ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
          : locale.languageCode;
      await ref
          .read(socialClientProvider)
          .rpc(
            'register_push_device',
            params: {
              'device': installation,
              'device_token': token,
              'device_platform': defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android',
              'device_locale': language,
            },
          );
    } catch (error, stack) {
      logger.w('Push registration deferred', error: error, stackTrace: stack);
    }
  }

  Future<void> unregister() async {
    if (installation != null) {
      await Supabase.instance.client
          .from('push_devices')
          .delete()
          .eq('id', installation!);
    }
  }

  Future<void> logout() async {
    await _registration;
    try {
      await unregister().timeout(const Duration(seconds: 5));
    } catch (error, stack) {
      globalLogger.w(
        'Push deregistration deferred',
        error: error,
        stackTrace: stack,
      );
    }
    if (ready) {
      try {
        await FirebaseMessaging.instance.unregister().timeout(
          const Duration(seconds: 5),
        );
      } catch (_) {}
    }
  }

  Future<void> openLocal(String? payload) async {
    if (payload == null || !payload.startsWith('social:')) return;
    try {
      await open(
        RemoteMessage(
          data: Map<String, dynamic>.from(
            jsonDecode(payload.substring(7)) as Map,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> open(RemoteMessage message) async {
    if (disposed) return;
    // Wait for startup/navigation, but do not open data for a different account.
    for (
      var attempt = 0;
      attempt < 40 && Go.context == null && !disposed;
      attempt++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (disposed || Go.context == null) return;
    final owner = ref.read(currentUserIdProvider);
    if (owner == null || message.data['recipient_id'] != owner) return;
    try {
      final notification = await ref
          .read(socialClientProvider)
          .from('notifications')
          .select()
          .eq('id', message.data['notification_id']!)
          .maybeSingle();
      if (notification == null) {
        Go.to(() => const SocialNotificationsPage());
        return;
      }
      if (notification['kind'] == 'trainer_plan') {
        Go.to(() => const TrainerView());
        return;
      }
      final post = notification['post_id'] as String?;
      if (post != null) {
        await ref
            .read(socialClientProvider)
            .rpc('get_social_post', params: {'post': post});
        if (!disposed && ref.read(currentUserIdProvider) == owner) {
          Go.to(() => SocialPostPage(postId: post));
        }
      } else if (notification['report_id'] != null) {
        Go.to(() => const SocialSettingsPage(reports: true));
      } else if (notification['actor_id'] != null) {
        Go.to(
          () => UserProfilePage(userID: notification['actor_id'] as String),
        );
      }
      ref.invalidate(socialNotificationsProvider);
    } catch (_) {
      if (!disposed) Go.to(() => const SocialNotificationsPage());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
      ref.invalidate(socialNotificationsProvider);
    }
  }

  void dispose() {
    disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
  }
}
