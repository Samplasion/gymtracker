import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../test_helpers/widget_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  late List<MethodCall> calls;
  late ProviderContainer container;
  var cameraGranted = false;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls = [];
    cameraGranted = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'checkPermissionStatus') {
            if (call.arguments == Permission.camera.value) {
              return cameraGranted ? 1 : 0;
            }
            return 0; // Photos have previously been denied.
          }
          fail('Unexpected permission operation: ${call.method}');
        });
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'Android gallery is available without checking denied photo permission',
    () async {
      final permissions = await container.read(foodPermissionsProvider.future);
      expect(permissions, (camera: false, gallery: true));
      expect(calls.map((call) => call.arguments), [Permission.camera.value]);
      final count = calls.length;
      await container
          .read(foodPermissionsProvider.notifier)
          .requestPermission(Permission.photos);
      expect(calls, hasLength(count));
      expect(
        container.read(foodPermissionsProvider).requireValue.gallery,
        isTrue,
      );
    },
  );

  test('Android settings depend only on camera permission', () async {
    final subscription = container.listen(foodPermissionsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(foodPermissionsProvider.future);
    expect(container.read(showFoodPermissionsSettingsTileProvider), isTrue);
    cameraGranted = true;
    await container.read(foodPermissionsProvider.notifier).recheck();
    expect(container.read(showFoodPermissionsSettingsTileProvider), isFalse);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('gallery permission UI on $platform', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foodPermissionsProvider.overrideWith(_DeniedPermissions.new),
          ],
          child: const WidgetTestApp(
            child: Scaffold(body: FoodPermissionsSettingsTile()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(t.food.addCustomFood.permission.camera), findsOneWidget);
      expect(
        find.text(t.food.addCustomFood.permission.gallery),
        platform == TargetPlatform.android ? findsNothing : findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    });
  }

  test('iOS still checks the photo library permission', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final permissions = await container.read(foodPermissionsProvider.future);
    expect(permissions.gallery, isFalse);
    expect(
      calls.map((call) => call.arguments),
      contains(Permission.photos.value),
    );
  });
}

class _DeniedPermissions extends FoodPermissionsNotifier {
  @override
  Future<FoodPermissions> build() async => (camera: false, gallery: false);
}
