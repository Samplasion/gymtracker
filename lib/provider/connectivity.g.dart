// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NetworkConnectivityNotifier)
final networkConnectivityProvider = NetworkConnectivityNotifierProvider._();

final class NetworkConnectivityNotifierProvider
    extends $StreamNotifierProvider<NetworkConnectivityNotifier, bool> {
  NetworkConnectivityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkConnectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkConnectivityNotifierHash();

  @$internal
  @override
  NetworkConnectivityNotifier create() => NetworkConnectivityNotifier();
}

String _$networkConnectivityNotifierHash() =>
    r'62b3458cbbb34c9343467b24e965fe56c01d77b5';

abstract class _$NetworkConnectivityNotifier extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
