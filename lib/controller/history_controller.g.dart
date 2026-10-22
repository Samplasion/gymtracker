// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historyController)
final historyControllerProvider = HistoryControllerProvider._();

final class HistoryControllerProvider
    extends
        $FunctionalProvider<
          HistoryController,
          HistoryController,
          HistoryController
        >
    with $Provider<HistoryController> {
  HistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyControllerHash();

  @$internal
  @override
  $ProviderElement<HistoryController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoryController create(Ref ref) {
    return historyController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryController>(value),
    );
  }
}

String _$historyControllerHash() => r'157437cbab854d31e95bf0a96fe2cd3173d1697d';
