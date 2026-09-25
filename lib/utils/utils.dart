import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/model.dart' show GTMuscleCategory;
import 'package:gymtracker/utils/extensions.dart';
import 'package:share_plus/share_plus.dart';

bool doubleIsActuallyInt(double double, [double epsilon = 0.001]) {
  return doubleEquality(double, double.floorToDouble(), epsilon: epsilon);
}

bool doubleEquality(double a, double b, {required double epsilon}) {
  return (b - a).abs() < epsilon;
}

String stringifyDouble(
  double double, {
  double epsilon = 0.001,
  String decimalSeparator = ".",
}) {
  if (doubleIsActuallyInt(double, epsilon)) {
    return double.floor().toString();
  }
  return double.toStringAsFixed(2)
      .replaceAll(RegExp(r'0+$'), "")
      .replaceAll(RegExp(r'\.$'), "")
      .replaceAll(".", decimalSeparator);
}

void reorder<T>(List<T> list, int oldIndex, int newIndex) {
  if (newIndex > oldIndex) newIndex -= 1;
  list.insert(newIndex, list.removeAt(oldIndex));
}

void reorderNew<T>(List<T> list, int oldIndex, int newIndex) {
  list.insert(newIndex, list.removeAt(oldIndex));
}

Color getThemedColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  final result = ColorScheme.fromSeed(
    seedColor: color.maybeGrayscale(context),
    brightness: theme.brightness,
  ).primary.harmonizeWith(theme.colorScheme.primary).maybeGrayscale(context);
  if (color.isGray) return result.grayscale;
  return result;
}

Color getOnThemedColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  final result = ColorScheme.fromSeed(
    seedColor: color.maybeGrayscale(context),
    brightness: theme.brightness,
  ).onPrimary.harmonizeWith(theme.colorScheme.primary).maybeGrayscale(context);
  if (color.isGray) return result.grayscale;
  return result;
}

Color getContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  final result =
      ColorScheme.fromSeed(
            seedColor: color.maybeGrayscale(context),
            brightness: theme.brightness,
          ).primaryContainer
          .harmonizeWith(theme.colorScheme.primary)
          .maybeGrayscale(context);
  if (color.isGray) return result.grayscale;
  return result;
}

Color getOnContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  final result =
      ColorScheme.fromSeed(
            seedColor: color.maybeGrayscale(context),
            brightness: theme.brightness,
          ).onPrimaryContainer
          .harmonizeWith(theme.colorScheme.primary)
          .maybeGrayscale(context);
  if (color.isGray) return result.grayscale;
  return result;
}

extension GrayscaleColor on Color {
  Color maybeGrayscale(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    if (primary.isGray) {
      return grayscale;
    }
    return this;
  }
}

double oneRepMax({required double weight, required int reps}) {
  return weight / (1.0278 - (0.0278 * reps));
}

double mapRange(
  double value,
  double min,
  double max,
  double newMin,
  double newMax,
) {
  return (((value - min) * (newMax - newMin)) / (max - min)) + newMin;
}

QuillController quillControllerFromText(String? text) {
  return QuillController(
    document: (text ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );
}

// Returns a date such that, if today's day of week is [firstDayOfWeek], then
// the returned date is today. Otherwise, it is the most recent day of the week
// in the past that has [firstDayOfWeek] as its day of week.
DateTime getLastFirstDayOfWeek(DateTime date, int firstDayOfWeek) {
  final today = date.startOfDay;
  var offset = today.weekday - firstDayOfWeek;
  if (offset <= 0) offset += 7;
  final lastMonday = today.weekday == firstDayOfWeek
      ? today
      : today.subtract(Duration(days: offset));
  return lastMonday;
}

DateTime min(DateTime a, DateTime b) {
  return a.isBefore(b) ? a : b;
}

DateTime max(DateTime a, DateTime b) {
  return a.isAfter(b) ? a : b;
}

void shareText(String text) {
  SharePlus.instance.share(ShareParams(text: text));
}

// https://stackoverflow.com/a/52104488
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s], rightStop = stops[s + 1];
    final leftColor = colors[s], rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}

Color rpeColor(BuildContext context, double currentRPE) {
  return lerpGradient(
    [
      context.harmonizeColor(Colors.green),
      context.harmonizeColor(Colors.yellow),
      context.harmonizeColor(Colors.red),
    ],
    [0.2, 0.55, 1],
    currentRPE / 10,
  );
}

Future<T?> timeoutFuture<T>(Duration duration, Future<T> future) {
  return Future.any([Future.delayed(duration), future]);
}

bool setEquality<T>(Set<T> a, Set<T> b) {
  return a.length == b.length && a.every(b.contains);
}

(List<T>, List<T>) partition<T>(List<T> list, bool Function(T) predicate) {
  final first = <T>[];
  final second = <T>[];
  for (final element in list) {
    if (predicate(element)) {
      first.add(element);
    } else {
      second.add(element);
    }
  }
  return (first, second);
}

bool throws<T>(
  T Function() function, {
  void Function(T?, dynamic, StackTrace?)? results,
}) {
  try {
    final value = function();
    results?.call(value, null, null);
    return false;
  } catch (e, s) {
    results?.call(null, e, s);
    return true;
  }
}

String generateWorkoutTitle(
  Translations t,
  Set<GTMuscleCategory> selectedGroups,
) {
  final count = selectedGroups.length;
  final translated = [
    for (final group in selectedGroups)
      t.muscleCategories[group.name] ?? "UNKNOWN",
  ];
  String title = switch (count) {
    0 => t.titleGenerator.title.zero,
    1 => t.titleGenerator.title.one(p0: translated.first),
    2 => t.titleGenerator.title.two(
      p0: translated.elementAt(0),
      p1: translated.elementAt(1),
    ),
    3 => t.titleGenerator.title.three(
      p0: translated.elementAt(0),
      p1: translated.elementAt(1),
      p2: translated.elementAt(2),
    ),
    4 => t.titleGenerator.title.four(
      p0: translated.elementAt(0),
      p1: translated.elementAt(1),
      p2: translated.elementAt(2),
      p3: translated.elementAt(3),
    ),
    5 => t.titleGenerator.title.five(
      p0: translated.elementAt(0),
      p1: translated.elementAt(1),
      p2: translated.elementAt(2),
      p3: translated.elementAt(3),
      p4: translated.elementAt(4),
    ),
    6 => t.titleGenerator.title.six(
      p0: translated.elementAt(0),
      p1: translated.elementAt(1),
      p2: translated.elementAt(2),
      p3: translated.elementAt(3),
      p4: translated.elementAt(4),
      p5: translated.elementAt(5),
    ),
    _ => throw ArgumentError(
      "Cannot generate title for more than 6 muscle groups",
    ),
  };
  return t.titleGenerator.template(muscles: title).trim();
}

DateTime maxDate(DateTime a, DateTime b) {
  return a.isAfter(b) ? a : b;
}

int getWeekNumber(DateTime date) {
  DateTime thursdayOfCurrentWeek = date.add(Duration(days: (4 - date.weekday)));
  DateTime firstThursdayOfYear = DateTime(thursdayOfCurrentWeek.year, 1, 4);
  DateTime firstWeekThursday = firstThursdayOfYear.add(
    Duration(days: (4 - firstThursdayOfYear.weekday)),
  );

  int weekNumber =
      ((thursdayOfCurrentWeek.difference(firstWeekThursday).inDays) ~/ 7) + 1;
  return weekNumber;
}

/// Returns the first day of the week for the given [context].
///
/// The returned value is converted to a format compatible with [DateTime.weekday].
/// That is, the returned value is in the range 1 to 7, inclusive, where
/// 1 represents Monday and 7 represents Sunday.
int firstDayOfWeekFor(Locale locale) {
  if (locale.languageCode == AppLocale.en.languageCode) {
    return DateTime.sunday;
  } else {
    return DateTime.monday;
  }
}
