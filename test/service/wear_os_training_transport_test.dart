import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/wearable/wear_os_training_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('gymbro/training');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('Android transport preserves the durable channel contract', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'exchange'
          ? [
              {'version': 1, 'id': 'offline'},
            ]
          : null;
    });
    final transport = WearOsTrainingTransport();
    expect(transport.isSupported, isTrue);
    expect(await transport.exchange({'ownerScope': 'guest'}), [
      {'version': 1, 'id': 'offline'},
    ]);
    await transport.acknowledge({'id': 'offline'}, {'accepted': true});
    await transport.adoptSensors({'id': 'offline'});
    await transport.publishTerminal({'id': 'offline', 'status': 'completed'});
    expect(calls.map((call) => call.method), [
      'exchange',
      'acknowledge',
      'adoptSensors',
      'terminal',
    ]);
    expect(calls[1].arguments, {
      'source': {'id': 'offline'},
      'response': {'accepted': true},
    });
    transport.dispose();
  });
}
