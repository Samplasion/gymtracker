import 'package:collection/collection.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';

/// A structure that represents a date-tagged value.
class DateTagged<T> {
  /// The date.
  final DateTime date;

  /// The value.
  final T value;

  const DateTagged._({
    required this.date,
    required this.value,
  });

  /// Creates a date-tagged value.
  factory DateTagged({
    required DateTime date,
    required T value,
  }) {
    return DateTagged._(date: date.startOfDay, value: value);
  }

  @override
  String toString() {
    return 'DateTagged{date: $date, value: $value}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DateTagged<T> && other.date == date && other.value == value;
  }

  @override
  int get hashCode {
    return date.hashCode ^ value.hashCode;
  }

  DateTagged<T> copyWith(T value) {
    return DateTagged._(date: date, value: value);
  }
}

/// A structure that represents a range of time.
class DateRange {
  /// The start of the range, inclusive.
  final DateTime? from;

  /// The end of the range, exclusive.
  final DateTime? to;

  const DateRange._({
    required this.from,
    required this.to,
  });

  Duration get duration {
    if (from == null || to == null) {
      return Duration.zero;
    }
    return to!.difference(from!);
  }

  DateRange copyWith({
    Optional<DateTime>? from,
    Optional<DateTime>? to,
  }) {
    return DateRange._(
      from: from == null ? this.from : from.safeUnwrap(),
      to: to == null ? this.to : to.safeUnwrap(),
    );
  }
}

class DateSequence<T> {
  final Map<DateTime, DateTagged<T>> _map;

  const DateSequence._(this._map);

  /// Creates an empty date sequence.
  factory DateSequence.empty() => const DateSequence._({});

  /// Creates a date sequence from a list of date-tagged values.
  ///
  /// If a date appears multiple times, the last value is kept.
  factory DateSequence.fromList(List<DateTagged<T>> list) {
    list.sort((a, b) => a.date.compareTo(b.date));
    return DateSequence._({
      for (final tagged in list) tagged.date.startOfDay: tagged,
    });
  }

  /// Creates a date sequence from a list of dates and values.
  ///
  /// If a date appears multiple times, the **first** value is kept.
  /// Null values are ignored.
  factory DateSequence.fromDatesAndValues(
    Map<DateTime, T> values,
  ) {
    final keys = (values.keys.toList()..sort()).reversed;
    final map = <DateTime, DateTagged<T>>{
      for (final key in keys)
        if (values[key] != null)
          key.startOfDay: DateTagged<T>(date: key, value: values[key] as T),
    };
    return DateSequence._(map);
  }

  /// Creates a new DateSequence where all consecutive equal values are
  /// replaced by a single value.
  ///
  /// In case of collisions, the last value in the list is kept, even if it is
  /// not the last value chronologically.
  factory DateSequence.normalized(List<DateTagged<T>> rawList) {
    final list = rawList.toList();
    final normalized = <DateTagged<T>>[];
    final lastIndices = <DateTime, int>{
      for (var i = 0; i < list.length; i++) list[i].date: i,
    };
    // list.sort((a, b) => a.date.compareTo(b.date));
    bool equality(DateTagged<T> a, DateTagged<T> b) {
      if (a.value is List) {
        // print((
        //   a,
        //   b,
        //   const ListEquality().equals(a.value as List, b.value as List)
        // ));
        return const ListEquality().equals(a.value as List, b.value as List);
      } else if (a.value is Map) {
        // print(
        //     (a, b, const MapEquality().equals(a.value as Map, b.value as Map)));
        return const MapEquality().equals(a.value as Map, b.value as Map);
      }
      return a.value == b.value;
    }

    for (var i = 0; i < list.length; i++) {
      if (i == 0) {
        normalized.add(list[i]);
        continue;
      }
      print((i - 1, i, equality(list[i], list[i - 1])));
      if (equality(list[i], list[i - 1])) {
        // normalized[normalized.length - 1] = rawList[lastIndices[list[i].date]!];
        normalized[normalized.length - 1] = list[i];
      } else {
        normalized.add(list[i]);
      }
    }
    print("$rawList\n$list\n$lastIndices\n$normalized");
    return DateSequence.fromList(normalized);
  }

  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;

  int get length => _map.length;

  /// Returns the value for a given date.
  ///
  /// If the date is not present, this returns the most recent value.
  /// If the date is before the first date, this returns the first value.
  T operator [](DateTime date) {
    if (isEmpty) {
      throw StateError('DateSequence is empty');
    }

    final key = date.startOfDay;
    if (_map.containsKey(key)) {
      return _map[key]!.value;
    }
    final keys = _map.keys.toList();
    keys.sort();

    if (key.isBefore(keys.first)) {
      return _map[keys.first]!.value;
    }

    for (var i = keys.length - 1; i >= 0; i--) {
      if (keys[i].isBeforeOrAtSameMomentAs(key)) {
        return _map[keys[i]]!.value;
      }
    }

    throw StateError('DateSequence is empty');
  }

  @override
  String toString() {
    return 'DateSequence<$T>(items: ${_map.length})';
  }

  /// Returns a new DateSequence where all consecutive equal values are
  /// replaced by a single value, as per [DateSequence.normalized].
  DateSequence<T> normalize() {
    return DateSequence.normalized(_map.values.toList());
  }

  /// Returns the values in the sequence.
  Iterable<DateTagged<T>> get values => _map.values;

  /// Returns the surrounding dates for a given date.
  ///
  /// If the date is either the first or the last, the [DateRange.from] and
  /// [DateRange.to] values will be null, respectively.
  /// If the date is not present, the [DateRange.from] and [DateRange.to] values
  /// will be the closest dates before and after the given date, with either
  /// field being null if [date] is before the first date or after the last date.
  DateRange surroundingDates(DateTime date) {
    final key = date.startOfDay;
    final keys = _map.keys.toList()..sort();

    if (keys.isEmpty) {
      throw StateError('DateSequence is empty');
    }

    if (key.isBefore(keys.first)) {
      return DateRange._(from: null, to: keys.first);
    } else if (key.isAfterOrAtSameMomentAs(keys.last)) {
      return DateRange._(from: keys.last, to: null);
    } else {
      for (var i = 0; i < keys.length - 1; i++) {
        if (keys[i].isBeforeOrAtSameMomentAs(key) && keys[i + 1].isAfter(key)) {
          return DateRange._(from: keys[i], to: keys[i + 1]);
        }
      }
    }

    throw StateError('DateSequence is empty');
  }

  /// Maps the values in the sequence.
  List<S> map<S>(S Function(DateTagged<T>) f) {
    return _map.values.map(f).toList();
  }

  /// Returns the keys in the sequence.
  Iterable<DateTime> get keys => _map.keys.toList()..sort();

  /// Returns a map representation of the sequence.
  Map<DateTime, T> toMap() => {
        for (final entry in _map.entries) entry.key: entry.value.value,
      };
}
