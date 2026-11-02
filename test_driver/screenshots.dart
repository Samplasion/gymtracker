import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final output = Platform.environment['SCREENSHOT_RAW_DIR'];
    if (output == null) {
      throw StateError('SCREENSHOT_RAW_DIR is required');
    }
    if (!RegExp(r'^0[1-9]-[a-z]+$').hasMatch(name)) {
      throw StateError('Invalid screenshot name: $name');
    }
    final file = File('$output/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return true;
  },
);
