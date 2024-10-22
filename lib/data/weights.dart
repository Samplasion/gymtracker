import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Weights {
  kg([1.25, 2.5, 5, 10, 15, 20]),
  lb([2.5, 5, 10, 25, 35, 50]);

  const Weights(this.weights);

  final List<double> weights;

  stringify(double weight) {
    switch (this) {
      case Weights.kg:
        return "${stringifyDouble(weight)} kg";
      case Weights.lb:
        return "${stringifyDouble(weight)} lb";
    }
  }

  static double convert({
    required double value,
    required Weights from,
    required Weights to,
  }) {
    if (from == to) return value;
    if (from == kg && to == lb) {
      return value * 2.20462262185;
    }
    if (from == lb && to == kg) {
      return value / 2.20462262185;
    }
    // Unreachable
    return -1;
  }

  String format(double value) => "exerciseList.fields.weight".tParams({
        "weight": value.localized,
        "unit": "units.$name".t,
      });
}

enum Bars {
  normal(weightKg: 20, weightLb: 45),
  short(weightKg: 15, weightLb: 35),
  ezBar(weightKg: 10, weightLb: 25),
  none(weightKg: 0, weightLb: 0);

  const Bars({required this.weightKg, required this.weightLb});

  final double weightKg;
  final double weightLb;
}
