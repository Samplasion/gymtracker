import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/model/api/set.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum GTSetKind {
  warmUp,
  normal,
  drop,
  failure(shouldKeepInRoutine: false),
  failureStripping(shouldKeepInRoutine: false);

  const GTSetKind({this.shouldKeepInRoutine = true});

  final bool shouldKeepInRoutine;
}

@JsonEnum()
enum GTSetParameters {
  repsWeight,
  timeWeight,
  freeBodyReps,
  time,
  distance,
}

class GTSetListConverter extends TypeConverter<List<GTSet>, String> {
  const GTSetListConverter();

  @override
  List<GTSet> fromSql(String fromDb) => jsonDecode(fromDb)
      .map<GTSet>((e) => GTSet.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  String toSql(List<GTSet> value) => jsonEncode(value);
}
