import '../utils/utils.dart';

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
