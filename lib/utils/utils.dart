bool doubleIsActuallyInt(double double, [double epsilon = 0.001]) {
  return (double - double.floor()).abs() < epsilon;
}

String stringifyDouble(double double, [double epsilon = 0.001]) {
  if (doubleIsActuallyInt(double, epsilon)) {
    return double.floor().toString();
  }
  return double.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), "");
}

void reorder<T>(List<T> list, int oldIndex, int newIndex) {
  if (newIndex > oldIndex) newIndex -= 1;
  list.insert(newIndex, list.removeAt(oldIndex));
}
