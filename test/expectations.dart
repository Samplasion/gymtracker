import 'package:test/test.dart';

void expectDouble(double actual, double expected, {double epsilon = 0.0001}) {
  expect((actual - expected).abs() < epsilon, true);
}
