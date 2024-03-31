import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';

/// Represents the streaks of the user.
///
/// The [weekStreak] is the number of weeks the user has completed without
/// missing a day.
///
/// The [restDays] is the number of days the user has missed in the current
/// week.
class Streaks {
  /// The number of weeks the user has completed without missing a day.
  final int weekStreak;

  /// The number of days the user has missed in the current week.
  final int restDays;

  const Streaks({required this.weekStreak, required this.restDays});

  /// A streak of zero weeks and zero rest days.
  static const zero = Streaks(weekStreak: 0, restDays: 0);

  static Streaks fromMappedDays<T>(
    Map<DateTime, List<T>> mappedDays, {
    required DateTime today,
    required int firstDayOfWeek,
  }) {
    var (streak, rest) = (0, 0);

    final keys = mappedDays.keys.toList();
    keys.sort();

    keys.logger.t("");

    today = today.startOfDay;
    var lastMonday = getLastDayOfWeek(today, firstDayOfWeek);

    lastMonday.logger.t("");

    while (true) {
      if (keys.any((element) =>
          element.isAfterOrAtSameMomentAs(lastMonday) &&
          element.isBefore(lastMonday.add(const Duration(days: 7))))) {
        streak++;
        lastMonday = lastMonday.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    if (!mappedDays.containsKey(today)) {
      final keys = mappedDays.keys.toList()..sort();
      if (keys.isNotEmpty) {
        rest = today.difference(keys.last).inDays;
      }
    }

    return Streaks(weekStreak: streak, restDays: rest);
  }

  @override
  String toString() {
    return 'Streaks(weekStreak: $weekStreak, restDays: $restDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Streaks &&
        other.weekStreak == weekStreak &&
        other.restDays == restDays;
  }

  @override
  int get hashCode {
    return weekStreak.hashCode ^ restDays.hashCode;
  }
}
