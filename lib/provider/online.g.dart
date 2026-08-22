// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Online)
final onlineProvider = OnlineProvider._();

final class OnlineProvider
    extends $AsyncNotifierProvider<Online, OnlineAccount?> {
  OnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineHash();

  @$internal
  @override
  Online create() => Online();
}

String _$onlineHash() => r'5b3c877a27144fbc70f77f7c15792d7e9008f8dc';

abstract class _$Online extends $AsyncNotifier<OnlineAccount?> {
  FutureOr<OnlineAccount?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OnlineAccount?>, OnlineAccount?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OnlineAccount?>, OnlineAccount?>,
              AsyncValue<OnlineAccount?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
