// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsPlugin)
final notificationsPluginProvider = NotificationsPluginProvider._();

final class NotificationsPluginProvider
    extends
        $FunctionalProvider<
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin
        >
    with $Provider<FlutterLocalNotificationsPlugin> {
  NotificationsPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsPluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsPluginHash();

  @$internal
  @override
  $ProviderElement<FlutterLocalNotificationsPlugin> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterLocalNotificationsPlugin create(Ref ref) {
    return notificationsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterLocalNotificationsPlugin value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterLocalNotificationsPlugin>(
        value,
      ),
    );
  }
}

String _$notificationsPluginHash() =>
    r'72e9ab2508a411c6fb2e0c7c54e8021857b57564';

@ProviderFor(notificationEvents)
final notificationEventsProvider = NotificationEventsProvider._();

final class NotificationEventsProvider
    extends
        $FunctionalProvider<
          StreamController<NotificationResponse>,
          StreamController<NotificationResponse>,
          StreamController<NotificationResponse>
        >
    with $Provider<StreamController<NotificationResponse>> {
  NotificationEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationEventsHash();

  @$internal
  @override
  $ProviderElement<StreamController<NotificationResponse>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StreamController<NotificationResponse> create(Ref ref) {
    return notificationEvents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamController<NotificationResponse> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<StreamController<NotificationResponse>>(value),
    );
  }
}

String _$notificationEventsHash() =>
    r'70fd530bf69eea2f23aa4734399719eaa4ba6473';

@ProviderFor(notificationResponse)
final notificationResponseProvider = NotificationResponseProvider._();

final class NotificationResponseProvider
    extends
        $FunctionalProvider<
          void Function(NotificationResponse),
          void Function(NotificationResponse),
          void Function(NotificationResponse)
        >
    with $Provider<void Function(NotificationResponse)> {
  NotificationResponseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationResponseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationResponseHash();

  @$internal
  @override
  $ProviderElement<void Function(NotificationResponse)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  void Function(NotificationResponse) create(Ref ref) {
    return notificationResponse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void Function(NotificationResponse) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void Function(NotificationResponse)>(
        value,
      ),
    );
  }
}

String _$notificationResponseHash() =>
    r'86c9ebd0e6cec961dd2b26799b538337fe275d6e';

@ProviderFor(notificationsService)
final notificationsServiceProvider = NotificationsServiceProvider._();

final class NotificationsServiceProvider
    extends
        $FunctionalProvider<
          NotificationsService,
          NotificationsService,
          NotificationsService
        >
    with $Provider<NotificationsService> {
  NotificationsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsService create(Ref ref) {
    return notificationsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsService>(value),
    );
  }
}

String _$notificationsServiceHash() =>
    r'20a16e4e8c26b72372f55fcf93a57e30b5882f68';
