// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationController)
final notificationControllerProvider = NotificationControllerProvider._();

final class NotificationControllerProvider
    extends
        $FunctionalProvider<
          NotificationController,
          NotificationController,
          NotificationController
        >
    with $Provider<NotificationController> {
  NotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationControllerHash();

  @$internal
  @override
  $ProviderElement<NotificationController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationController create(Ref ref) {
    return notificationController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationController>(value),
    );
  }
}

String _$notificationControllerHash() =>
    r'77ba2ee7617b1927e768814b302b16e695ae6c6b';

@ProviderFor(notificationPermissions)
final notificationPermissionsProvider = NotificationPermissionsProvider._();

final class NotificationPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPermissions>,
          NotificationPermissions,
          Stream<NotificationPermissions>
        >
    with
        $FutureModifier<NotificationPermissions>,
        $StreamProvider<NotificationPermissions> {
  NotificationPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionsHash();

  @$internal
  @override
  $StreamProviderElement<NotificationPermissions> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationPermissions> create(Ref ref) {
    return notificationPermissions(ref);
  }
}

String _$notificationPermissionsHash() =>
    r'1edec54cf86d6b5cbdc118b3c71b2792917e33c6';
