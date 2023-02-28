String stringifyDouble(double double, [double epsilon = 0.001]) {
  if ((double - double.floor()).abs() < epsilon) {
    return double.floor().toString();
  }
  return double.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), "");
}

void reorder<T>(List<T> list, int oldIndex, int newIndex) {
  if (newIndex > oldIndex) newIndex -= 1;
  list.insert(newIndex, list.removeAt(oldIndex));
}
