// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stopwatch_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StopwatchController)
final stopwatchControllerProvider = StopwatchControllerProvider._();

final class StopwatchControllerProvider
    extends $NotifierProvider<StopwatchController, StopwatchState> {
  StopwatchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stopwatchControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stopwatchControllerHash();

  @$internal
  @override
  StopwatchController create() => StopwatchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StopwatchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StopwatchState>(value),
    );
  }
}

String _$stopwatchControllerHash() =>
    r'b19c21ec180f7e4899a1976b869d69277fe477e7';

abstract class _$StopwatchController extends $Notifier<StopwatchState> {
  StopwatchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StopwatchState, StopwatchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StopwatchState, StopwatchState>,
              StopwatchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
