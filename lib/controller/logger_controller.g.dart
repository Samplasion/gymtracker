// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loggerControllerInstance)
final loggerControllerInstanceProvider = LoggerControllerInstanceProvider._();

final class LoggerControllerInstanceProvider
    extends
        $FunctionalProvider<
          LoggerController,
          LoggerController,
          LoggerController
        >
    with $Provider<LoggerController> {
  LoggerControllerInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerControllerInstanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerControllerInstanceHash();

  @$internal
  @override
  $ProviderElement<LoggerController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerController create(Ref ref) {
    return loggerControllerInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerController>(value),
    );
  }
}

String _$loggerControllerInstanceHash() =>
    r'86055c9c0e8c0f4c124b600f05e829a7fea18366';

@ProviderFor(logSnapshot)
final logSnapshotProvider = LogSnapshotProvider._();

final class LogSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<LogSnapshot>,
          LogSnapshot,
          Stream<LogSnapshot>
        >
    with $FutureModifier<LogSnapshot>, $StreamProvider<LogSnapshot> {
  LogSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logSnapshotHash();

  @$internal
  @override
  $StreamProviderElement<LogSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LogSnapshot> create(Ref ref) {
    return logSnapshot(ref);
  }
}

String _$logSnapshotHash() => r'626fc94a25ec0cc5ff332e99a54f8a757fd3be50';
