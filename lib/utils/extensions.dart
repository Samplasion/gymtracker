import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:intl/intl.dart' hide TextDirection;

extension StringUtils on String {
  double parseDouble() {
    return double.parse(replaceAll(",", "."));
  }

  double? tryParseDouble() {
    return double.tryParse(replaceAll(",", "."));
  }

  Size computeSize({
    TextStyle? style,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: this, style: style ?? Get.context!.theme.textTheme.bodyMedium),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    return textPainter.size;
  }

  dynamic tryParseJson() {
    try {
      return jsonDecode(this);
    } catch (e) {
      return null;
    }
  }

  Document asQuillDocument() {
    final json = tryParseJson();
    if (json != null) {
      logger.t(
          "[String#asQuillDocument] not a null json; interpreting it as a delta");
      try {
        return Document.fromJson(json);
      } catch (_) {
        logger.t(
            "[String#asQuillDocument] not a valid delta; falling back to plaintext string");
      }
    } else {
      logger.t("[String#asQuillDocument] not a json; creating delta");
    }
    return Document.fromDelta(Delta()..insert("${trim()}\n"));
  }

  String richCombine(String other) {
    final Delta self = asQuillDocument().toDelta();
    final Delta otherDelta = other.trim().asQuillDocument().toDelta();
    return Document.fromDelta(self.compose(otherDelta)).toEncoded();
  }
}

extension DateUtils on DateTime {
  int get minutesSinceEpoch => millisecondsSinceEpoch ~/ 60000;

  DateTime get startOfDay {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  bool isAfterOrAtSameMomentAs(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool isBeforeOrAtSameMomentAs(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }
}

extension ColorUtils on Color {
  Brightness estimateForegroundBrightness() {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Brightness.dark : Brightness.light;
  }

  List<Color> get triadicColors {
    final List<Color> result = [this];
    final HSLColor hsl = HSLColor.fromColor(this);
    for (int i = 1; i <= 2; i++) {
      result.add(hsl.withHue((hsl.hue + 120 * i) % 360).toColor());
    }

    return result;
  }

  List<Color> get tetradicColors {
    final List<Color> result = [this];
    final HSLColor hsl = HSLColor.fromColor(this);
    for (int i = 1; i <= 3; i++) {
      result.add(hsl.withHue((hsl.hue + 90 * i) % 360).toColor());
    }

    return result;
  }

  List<Color> get pentadicColors {
    final List<Color> result = [this];
    final HSLColor hsl = HSLColor.fromColor(this);
    for (int i = 1; i <= 4; i++) {
      result.add(hsl.withHue((hsl.hue + 72 * i) % 360).toColor());
    }

    return result;
  }

  List<Color> get splitComplementaryColors {
    final List<Color> result = [this];
    final HSLColor hsl = HSLColor.fromColor(this);

    result.add(hsl.withHue((hsl.hue + 150) % 360).toColor());
    result.add(hsl.withHue((hsl.hue + 210) % 360).toColor());

    return result;
  }

  List<Color> get analogousColors {
    final List<Color> result = [this];
    final HSLColor hsl = HSLColor.fromColor(this);

    result.add(hsl.withHue((hsl.hue - 30) % 360).toColor());
    result.add(hsl.withHue((hsl.hue + 30) % 360).toColor());

    return result;
  }
}

extension ListUtils<T> on List<T> {
  T? getAt(int index) {
    if (index < 0) index += length;
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

extension IterableUtils<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  ({List<T> matching, List<T> rest}) partition(bool Function(T) predicate) {
    final List<T> matching = [];
    final List<T> rest = [];
    for (final element in this) {
      if (predicate(element)) {
        matching.add(element);
      } else {
        rest.add(element);
      }
    }
    return (matching: matching, rest: rest);
  }
}

extension NumIterableUtils<T extends num> on Iterable<T> {
  T get min {
    T min = first;
    for (final element in this) {
      if (element < min) {
        min = element;
      }
    }
    return min;
  }

  T get max {
    T max = first;
    for (final element in this) {
      if (element > max) {
        max = element;
      }
    }
    return max;
  }

  T? get safeMin {
    if (isEmpty) return null;
    return min;
  }

  T? get safeMax {
    if (isEmpty) return null;
    T max = first;
    for (final element in this) {
      if (element > max) {
        max = element;
      }
    }
    return max;
  }

  T get _zero => switch (T) {
        double => 0.0,
        num => 0,
        int => 0,
        _ => 0 as dynamic,
      };

  T get sum {
    T sum = _zero;
    for (final element in this) {
      sum = (sum + element as T);
    }
    return sum;
  }
}

extension BuildContextUtils on BuildContext {
  Color harmonizeColor(Color color) {
    return color.harmonizeWith(Theme.of(this).colorScheme.primary);
  }
}

extension NumGenericUtils<T extends num> on T {
  String get localized => NumberFormat(
        "###,###.##",
        Get.locale!.languageCode,
      ).format(this);
}

extension NumUtils on num {
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

final stringCompressor = utf8.fuse(gzip.fuse(base64));

extension StringCompression on String {
  String get compressed => stringCompressor.encode(this);
  String get uncompressed => stringCompressor.decode(this);
}

extension WorkoutIterableUtils on Iterable<Workout> {
  /// Returns all the workouts performed in the given time [period].
  ///
  /// Assumes [this] is sorted such that the most recent workout is last.
  List<Workout> inTimePeriod(Duration period) {
    List<Workout> result = [];
    List<Workout> self = toList();
    final today = DateTime.now().startOfDay;
    final timeStart = today.subtract(period);
    for (final workout in self.reversed) {
      if (workout.startingDate != null &&
          workout.startingDate!.isAfter(timeStart)) {
        result.add(workout);
      }
    }
    return result;
  }

  /// Returns all the workouts performed in the time [period] immediately
  /// preceding the current period.
  ///
  /// Assumes [this] is sorted such that the most recent workout is last.
  List<Workout> inPrecedingTimePeriod(Duration period) {
    List<Workout> result = [];
    List<Workout> self = toList();
    final today = DateTime.now().startOfDay.subtract(period);
    final timeStart = today;
    for (final workout in self.reversed) {
      if (workout.startingDate != null &&
          workout.startingDate!.isAfter(timeStart) &&
          workout.startingDate!.isBefore(today)) {
        result.add(workout);
      }
    }
    return result;
  }

  /// Returns a flattened view of the exercises in this list of workouts.
  ///
  /// {@template flattenedExercises}
  /// For example, if you have this list of workouts:
  ///
  /// ```dart
  /// final workouts = [
  ///   Workout(
  ///     exercises: [
  ///       Exercise(name: "A"),
  ///       Exercise(name: "B"),
  ///       Superset(
  ///         exercises: [
  ///           Exercise(name: "C"),
  ///           Exercise(name: "D"),
  ///         ],
  ///       ),
  ///     ],
  ///   ),
  ///   Workout(
  ///     exercises: [
  ///       Exercise(name: "E"),
  ///     ],
  ///   ),
  /// ];
  /// ```
  ///
  /// Then this getter will return:
  ///
  /// ```dart
  /// [
  ///    Exercise(name: "A"),
  ///    Exercise(name: "B"),
  ///    Superset(),
  ///    Exercise(name: "C"),
  ///    Exercise(name: "D"),
  ///    Exercise(name: "E"),
  /// ]
  /// ```
  ///
  /// (This is a simplified example; the actual output will be more complex.)
  ///
  /// The order of the exercises is preserved.
  /// {@endtemplate}
  List<WorkoutExercisable> get flattenedExercises {
    List<WorkoutExercisable> result = [];
    for (final workout in this) {
      result.addAll(workout.exercises.expand((element) => element.map(
            exercise: (ex) => [ex],
            superset: (ss) => [ss, ...ss.exercises],
          )));
    }
    return result;
  }
}

extension WorkoutUtils on Workout {
  /// Returns a flattened view of the exercises in this workout.
  ///
  /// {@macro flattenedExercises}
  List<WorkoutExercisable> get flattenedExercises {
    return exercises
        .expand((element) => element.map(
              exercise: (ex) => [ex],
              superset: (ss) => [ss, ...ss.exercises],
            ))
        .toList();
  }
}

extension ValueUtils on double {
  String get userFacingWeight {
    return "exerciseList.fields.weight".tParams({
      "weight": localized,
      "unit": "units.${settingsController.weightUnit.value.name}".t,
    });
  }

  String get userFacingDistance {
    return "exerciseList.fields.distance".tParams({
      "distance": localized,
      "unit": "units.${settingsController.distanceUnit.value.name}".t,
    });
  }
}

extension ContextThemingUtils on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  Color cardColor({double elevation = 1}) {
    return ElevationOverlay.applySurfaceTint(
      theme.cardTheme.color ?? colorScheme.surface,
      theme.cardTheme.surfaceTintColor ?? colorScheme.surfaceTint,
      elevation,
    );
  }
}

Widget separatorBuilder(int index) => const Divider();

extension SeparatedWidgetList on Iterable<Widget> {
  List<Widget> separated({
    Widget Function(int index) separatorBuilder = separatorBuilder,
  }) {
    final self = toList();
    final List<Widget> widgets = [];

    for (int i = 0; i < max(0, self.length * 2 - 1); i++) {
      final int itemIndex = i ~/ 2;
      if (i.isEven) {
        widgets.add(self[itemIndex]);
      } else {
        widgets.add(separatorBuilder(itemIndex));
      }
    }

    return widgets;
  }
}

extension StringifyQuill on Document {
  String toEncoded() {
    return jsonEncode(toDelta().toJson());
  }
}

extension StringifyQuillController on QuillController {
  String toEncoded() {
    return document.toEncoded();
  }
}

extension EmptyDocument on Document {
  bool get isEmpty {
    return toPlainText().trim().isEmpty;
  }
}

extension HarmonizedMaterialColor on MaterialColor {
  MaterialColor harmonizeWith(Color color) {
    return MaterialColor(
      color.harmonizeWith(this).value,
      {
        50: this[50]!.harmonizeWith(color),
        100: this[100]!.harmonizeWith(color),
        200: this[200]!.harmonizeWith(color),
        300: this[300]!.harmonizeWith(color),
        400: this[400]!.harmonizeWith(color),
        500: this[500]!.harmonizeWith(color),
        600: this[600]!.harmonizeWith(color),
        700: this[700]!.harmonizeWith(color),
        800: this[800]!.harmonizeWith(color),
        900: this[900]!.harmonizeWith(color),
      },
    );
  }
}

String _toPrettyString(x, String indent) =>
    JsonEncoder.withIndent(indent).convert(x);

extension PrettyJsonExtensionMap on Map<String, dynamic> {
  String toPrettyString([String indent = '  ']) {
    return _toPrettyString(this, indent);
  }
}

extension PrettyJsonExtensionList on List<Map<String, dynamic>> {
  String toPrettyString([String indent = '  ']) {
    return _toPrettyString(this, indent);
  }
}

extension ToMap<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() {
    return Map.fromEntries(this);
  }
}

extension MapOfListUtils<K, V> on Map<K, List<V>> {
  Map<K, List<V>> combinedWith(Map<K, List<V>> other) {
    final res = Map<K, List<V>>.from(this);
    for (final entry in other.entries) {
      res[entry.key] = [...(res[entry.key] ?? []), ...entry.value];
    }
    return res;
  }
}

// https://stackoverflow.com/a/72219124
extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

extension PaddingUtils on EdgeInsets {
  EdgeInsets get onlyHorizontal {
    return EdgeInsets.only(left: left, right: right);
  }

  EdgeInsets get onlyVertical {
    return EdgeInsets.only(top: top, bottom: bottom);
  }
}

extension IntUtils on int {
  String toRomanNumeral() {
    if (this < 1 || this > 3999) {
      throw ArgumentError(
          "Roman numerals can only represent numbers between 1 and 3999");
    }

    const letters = {
      1000: "M",
      900: "CM",
      500: "D",
      400: "CD",
      100: "C",
      90: "XC",
      50: "L",
      40: "XL",
      10: "X",
      9: "IX",
      5: "V",
      4: "IV",
      1: "I",
    };

    StringBuffer result = StringBuffer();

    for (int i = this; i > 0;) {
      final entry = letters.entries.firstWhere((entry) => entry.key <= i);
      result.write(entry.value);
      i -= entry.key;
    }

    return result.toString();
  }
}
