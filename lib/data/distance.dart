import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/utils/extensions.dart';

enum Distance {
  km,
  mi;

  static double convert({
    required double value,
    required Distance from,
    required Distance to,
  }) {
    if (from == to) return value;
    if (from == mi && to == km) {
      return value * 1.609344;
    }
    if (from == km && to == mi) {
      return value / 1.609344;
    }
    // Unreachable
    return -1;
  }

  String format(Translations t, double value) => t.exerciseList.fields.distance(
    distance: value.localizedWith(t),
    unit: t.units[name] ?? "UNKNOWN",
  );
}
