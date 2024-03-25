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
}
