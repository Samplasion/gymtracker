import 'dart:convert';

List<T> maybeJsonString<T>(dynamic value) {
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded.cast<T>();
    }
  }
  return value as List<T>;
}
