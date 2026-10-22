// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countdown_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CountdownController)
final countdownControllerProvider = CountdownControllerProvider._();

final class CountdownControllerProvider
    extends $NotifierProvider<CountdownController, CountdownState> {
  CountdownControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countdownControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countdownControllerHash();

  @$internal
  @override
  CountdownController create() => CountdownController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CountdownState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CountdownState>(value),
    );
  }
}

String _$countdownControllerHash() =>
    r'62c9d23fcace05862655b2c5bcb98a07ffa14972';

abstract class _$CountdownController extends $Notifier<CountdownState> {
  CountdownState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CountdownState, CountdownState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CountdownState, CountdownState>,
              CountdownState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
