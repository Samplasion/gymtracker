import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/barcode_scan_gate.dart';

void main() {
  test(
    'first valid match is immediate and continuous frames cannot repeat it',
    () {
      final gate = BarcodeScanGate();
      expect(gate.take([null, '', 'bad', ' 8000965154468 ']), '8000965154468');
      for (var frame = 0; frame < 100; frame++) {
        expect(gate.take(['8000965154468']), isNull);
      }
      expect(gate.completed, isTrue);
    },
  );
  test('invalid frames do not consume scanner or manual entry', () {
    final gate = BarcodeScanGate();
    expect(gate.take(['', ' ', null, 'abc', '12']), isNull);
    expect(gate.completed, isFalse);
    expect(gate.take(['00123456']), '00123456');
    expect(gate.take(['12345678']), isNull);
    expect(BarcodeScanGate().take(['12345678']), '12345678');
  });
}
