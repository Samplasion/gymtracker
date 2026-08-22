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

String _$onlineHash() => r'a3222173eb0e6debc266aca163b3da9835331dfd';

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
