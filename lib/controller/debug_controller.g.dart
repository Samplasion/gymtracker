// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DebugController)
final debugControllerProvider = DebugControllerProvider._();

final class DebugControllerProvider
    extends $NotifierProvider<DebugController, DebugState> {
  DebugControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugControllerHash();

  @$internal
  @override
  DebugController create() => DebugController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebugState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebugState>(value),
    );
  }
}

String _$debugControllerHash() => r'282f225770aad8aab55dc3e8199db9a2761e51b1';

abstract class _$DebugController extends $Notifier<DebugState> {
  DebugState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DebugState, DebugState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DebugState, DebugState>,
              DebugState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
