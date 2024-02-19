import 'package:hive/hive.dart';

void registerAll() {
  Hive.registerAdapter(SetAdapter());
  Hive.registerAdapter(DateTimeAdapter());
  Hive.registerAdapter(DurationAdapter());
}

class SetAdapter extends TypeAdapter<Set> {
  @override
  final int typeId = 7;

  @override
  Set read(BinaryReader reader) {
    final length = reader.readInt();
    final set = <dynamic>{};
    for (var i = 0; i < length; i++) {
      set.add(reader.read());
    }
    return set;
  }

  @override
  void write(BinaryWriter writer, Set obj) {
    writer.writeInt(obj.length);
    for (var item in obj) {
      writer.write(item);
    }
  }
}

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 8;

  @override
  DateTime read(BinaryReader reader) {
    return DateTime.parse(reader.read());
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.write(obj.toIso8601String());
  }
}

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 9;

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}
