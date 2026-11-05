import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late List<String> calls;
  var status = 0;
  var failRequest = false;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    container = ProviderContainer();
    calls = [];
    status = 0;
    failRequest = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          switch (call.method) {
            case 'checkPermissionStatus':
              return status;
            case 'requestPermissions':
              if (failRequest) throw PlatformException(code: 'unavailable');
              return {for (final p in call.arguments as List) p: status};
            case 'openAppSettings':
              return true;
          }
          throw StateError('Unexpected ${call.method}');
        });
  });
  tearDown(() {
    container.dispose();
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  for (final result in [0, 1, 4]) {
    test(
      'camera permission outcome $result preserves gallery and opens settings only for permanent denial',
      () async {
        final keep = container.listen(foodPermissionsProvider, (_, _) {});
        addTearDown(keep.close);
        await container.read(foodPermissionsProvider.future);
        status = result;
        await container
            .read(foodPermissionsProvider.notifier)
            .requestPermission(Permission.camera);
        await Future<void>.delayed(Duration.zero);
        expect(container.read(foodPermissionsProvider).requireValue, (
          camera: result == 1,
          gallery: false,
        ));
        expect(
          calls.where((c) => c == 'openAppSettings').length,
          result == 4 ? 1 : 0,
        );
      },
    );
  }
  test('native permission failure preserves the previous state', () async {
    final keep = container.listen(foodPermissionsProvider, (_, _) {});
    addTearDown(keep.close);
    await container.read(foodPermissionsProvider.future);
    failRequest = true;
    await container
        .read(foodPermissionsProvider.notifier)
        .requestPermission(Permission.camera);
    expect(container.read(foodPermissionsProvider).requireValue, (
      camera: false,
      gallery: false,
    ));
    expect(calls, isNot(contains('openAppSettings')));
  });
  test(
    'return from settings rechecks camera and gallery without requesting permission',
    () async {
      final keep = container.listen(foodPermissionsProvider, (_, _) {});
      addTearDown(keep.close);
      await container.read(foodPermissionsProvider.future);
      status = 1;
      await container.read(foodPermissionsProvider.notifier).recheck();
      expect(container.read(foodPermissionsProvider).requireValue, (
        camera: true,
        gallery: true,
      ));
      expect(calls, isNot(contains('requestPermissions')));
    },
  );
}
