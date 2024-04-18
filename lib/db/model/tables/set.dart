import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/model/set.dart';

export 'package:gymtracker/model/set.dart' show GTSetKind, GTSetParameters;

class GTSetListConverter extends TypeConverter<List<GTSet>, String> {
  const GTSetListConverter();

  @override
  List<GTSet> fromSql(String fromDb) => jsonDecode(fromDb)
      .map<GTSet>((e) => GTSet.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  String toSql(List<GTSet> value) => jsonEncode(value);
}
