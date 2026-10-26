import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:mocktail/mocktail.dart';

class _Host extends Mock implements GymBroNativeHostAPI {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'acknowledgement waits for the diary commit and missing callback stays pending',
    () async {
      final host = _Host();
      final service = NativeService.withHost(host);
      final api = service as GymBroNativeFlutterAPI;
      expect(await api.importWaterEntry('id', 250, 1, 'guest'), isFalse);
      final commit = Completer<bool>();
      service.onImportWaterEntry = (id, amount, time, scope) {
        expect((id, amount, time, scope), ('id', 250, 1, 'guest'));
        return commit.future;
      };
      var acknowledged = false;
      final operation = api
          .importWaterEntry('id', 250, 1, 'guest')
          .then((result) => acknowledged = result);
      await Future<void>.delayed(Duration.zero);
      expect(acknowledged, isFalse);
      commit.complete(true);
      await operation;
      expect(acknowledged, isTrue);
      service.clearCallbacks();
      expect(await api.importWaterEntry('id', 250, 1, 'guest'), isFalse);
      service.dispose();
    },
  );

  test(
    'receiver readiness is forwarded and disposed services reject import',
    () async {
      final host = _Host();
      when(host.waterReceiverReady).thenAnswer((_) async {});
      final service = NativeService.withHost(host);
      service.waterReceiverReady();
      verify(host.waterReceiverReady).called(1);
      service.onImportWaterEntry = (_, _, _, _) async => true;
      service.dispose();
      expect(service.onImportWaterEntry, isNull);
      expect(
        await (service as GymBroNativeFlutterAPI).importWaterEntry(
          'id',
          250,
          1,
          'guest',
        ),
        isFalse,
      );
    },
  );
}
