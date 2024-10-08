import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/charts/base_types.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:intl/intl.dart';

export 'package:gymtracker/view/charts/base_types.dart';

class LineChartWithCategories<T> extends StatefulWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Map<T, List<LineChartPoint>> predictedData;
  final Widget Function(T, int, LineChartPoint, bool) currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;

  LineChartWithCategories({
    super.key,
    required this.categories,
    required this.data,
    this.predictedData = const {},
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
  })  : assert(categories.isNotEmpty),
        assert(categories.length == data.length),
        assert(categories.keys.every((key) => data.keys.contains(key)));

  @override
  State<LineChartWithCategories<T>> createState() =>
      _LineChartWithCategoriesState<T>();
}

class _LineChartWithCategoriesState<T>
    extends State<LineChartWithCategories<T>> {
  late T selectedCategory = widget.categories.keys.first;
  late int hoveredIndex = widget.data[selectedCategory]!.length - 1;

  List<LineChartPoint> get children => widget.data[selectedCategory]!;

  late final double leftReservedSize = () {
    final sizes = widget.data.entries.map((e) {
      final categorySizes = e.value.map((point) {
        return widget
            .leftTitleBuilder(e.key, point.value)
            .computeSize(
              style: context.textTheme.labelSmall!,
            )
            .width;
      }).toList();
      return categorySizes.max;
    }).toList();
    return sizes.max;
  }();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.currentValueBuilder(
            selectedCategory,
            hoveredIndex,
            hoveredIndex >= children.length
                ? widget.predictedData[selectedCategory]!
                    .elementAt(hoveredIndex - children.length)
                : children[hoveredIndex],
            hoveredIndex >= children.length),
        ConstrainedBox(
          constraints: BoxConstraints.loose(const Size.fromHeight(300)),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              right: 16,
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: 1,
                  checkToShowVerticalLine: (value) {
                    if (value % 1 != 0) return false;
                    DateTime? prev = children.getAt(value.toInt() - 1)?.date;
                    if (prev == null) return true;
                    DateTime? cur = children[value.toInt()].date;
                    return _getMonth(prev) != _getMonth(cur);
                  },
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize:
                          [context.width / 5, leftReservedSize].min + 8,
                      getTitlesWidget: leftTitleWidgets(context),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: bottomTitleWidgets(context),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  border: Border.all(color: colorScheme.outline),
                ),
                showingTooltipIndicators: [],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    getTooltipItems: (items) => <LineTooltipItem?>[
                      ...items.map((_) => const LineTooltipItem(
                            "hhh",
                            TextStyle(color: Colors.transparent),
                          ))
                    ],
                  ),
                  touchSpotThreshold: 10000,
                  enabled: true,
                  touchCallback: (event, response) {
                    final touchLineBarSpot = response?.lineBarSpots?.first;
                    final index = touchLineBarSpot?.x.toInt();
                    if (index != hoveredIndex && index != null) {
                      setState(() => hoveredIndex = index);
                    }
                  },
                ),
                lineBarsData: [
                  if (widget.predictedData[selectedCategory]?.isNotEmpty ==
                      true)
                    LineChartBarData(
                      dotData: const FlDotData(show: false),
                      spots: [
                        FlSpot(
                          (children.length - 1).toDouble(),
                          children.last.value,
                        ),
                        for (int i = 0;
                            i < widget.predictedData[selectedCategory]!.length;
                            i++)
                          FlSpot(
                            (children.length + i).toDouble(),
                            widget.predictedData[selectedCategory]![i].value,
                          ),
                      ],
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: colorScheme.quaternary,
                      dashArray: [5, 10],
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.quaternary.withOpacity(0.3),
                      ),
                    ),
                  LineChartBarData(
                    dotData: const FlDotData(show: false),
                    spots: [
                      for (int i = 0; i < children.length; i++)
                        FlSpot(
                          i.toDouble(),
                          children[i].value,
                        ),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.linearToEaseOut,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in widget.categories.entries)
                  ChoiceChip(
                    label: Text(entry.value.title),
                    avatar: CircleAvatar(
                      child: this.selectedCategory == entry.key
                          ? const SizedBox.shrink()
                          : entry.value.icon,
                    ),
                    selected: this.selectedCategory == entry.key,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() => this.selectedCategory = entry.key);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDayMonth(DateTime? dateTime) {
    if (dateTime == null) return "";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _getMonth(DateTime? dateTime) {
    if (dateTime == null) return "";
    return "${dateTime.month}/${dateTime.year}";
  }

  Widget Function(double, TitleMeta) bottomTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      if (value % 1 != 0) return const SizedBox.shrink();

      DateTime? cur =
          value >= children.length ? null : children[value.toInt()].date;
      if (cur == null) return const SizedBox.shrink();

      String text = DateFormat.Md(context.locale.languageCode).format(cur);

      if (value > 0) {
        DateTime? prev = children.getAt(value.toInt() - 1)?.date;
        if (_getDayMonth(prev) == _getDayMonth(cur)) {
          text = "";
        }
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
    };
  }

  Widget Function(double, TitleMeta) leftTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: widget.leftTitleBuilder(
                  selectedCategory,
                  value,
                ),
                style: context.textTheme.labelSmall!,
              ),
            ]),
            textAlign: TextAlign.end,
          ),
        );
  }
}

class RoutineHistoryChart extends StatefulWidget {
  const RoutineHistoryChart({
    required this.routine,
    super.key,
  });

  final Workout routine;

  @override
  State<RoutineHistoryChart> createState() => _RoutineHistoryChartState();

  static shouldShow(Workout workout) {
    final controller = Get.find<RoutinesController>();
    final ongoingWorkout = Get.isRegistered<WorkoutController>()
        ? Get.find<WorkoutController>().synthesizeTemporaryWorkout()
        : null;
    final added =
        ongoingWorkout != null && ongoingWorkout.isChildOf(workout) ? 1 : 0;
    return !workout.isConcrete &&
        controller
                    .getChildren(
                      workout,
                      allowSynthesized: true,
                    )
                    .where((wo) => wo.doneSets.isNotEmpty)
                    .length +
                added >=
            2;
  }
}

enum _RoutineHistoryChartType {
  volume,
  reps,
  duration,
}

class _RoutineHistoryChartState
    extends ControlledState<RoutineHistoryChart, RoutinesController> {
  Workout? get _currentSynthOngoing {
    if (!Get.isRegistered<WorkoutController>()) return null;
    final wo = Get.find<WorkoutController>().synthesizeTemporaryWorkout();
    return wo.isChildOf(widget.routine) ? wo : null;
  }

  LineChartPoint? _getSynthesizedPointFor(_RoutineHistoryChartType type) {
    if (_currentSynthOngoing == null) return null;
    final wo = _currentSynthOngoing!;
    switch (type) {
      case _RoutineHistoryChartType.volume:
        return LineChartPoint(
          value: Weights.convert(
            value: wo.liftedWeight,
            from: wo.weightUnit,
            to: settingsController.weightUnit.value,
          ),
          date: wo.startingDate!,
        );
      case _RoutineHistoryChartType.reps:
        return LineChartPoint(
          value: wo.reps.toDouble(),
          date: wo.startingDate!,
        );
      case _RoutineHistoryChartType.duration:
        return LineChartPoint(
          value: wo.duration!.inSeconds.toDouble(),
          date: wo.startingDate!,
        );
    }
  }

  List<Workout> get children => controller
      .getChildren(
        widget.routine,
        allowSynthesized: true,
      )
      .where((wo) => wo.doneSets.isNotEmpty)
      .toList();

  late final dateRecognizer = TapGestureRecognizer();

  late final Map<_RoutineHistoryChartType, List<LineChartPoint>> values = () {
    final values = <_RoutineHistoryChartType, List<LineChartPoint>>{
      _RoutineHistoryChartType.volume: [],
      _RoutineHistoryChartType.reps: [],
      _RoutineHistoryChartType.duration: [],
    };

    for (final wo in children) {
      values[_RoutineHistoryChartType.volume]!.add(LineChartPoint(
        value: Weights.convert(
          value: wo.liftedWeight,
          from: wo.weightUnit,
          to: settingsController.weightUnit.value,
        ),
        date: wo.startingDate!,
      ));
      values[_RoutineHistoryChartType.reps]!.add(LineChartPoint(
        value: wo.reps.toDouble(),
        date: wo.startingDate!,
      ));
      values[_RoutineHistoryChartType.duration]!.add(LineChartPoint(
        value: wo.duration!.inSeconds.toDouble(),
        date: wo.startingDate!,
      ));
    }

    return values;
  }();
  late final Set<_RoutineHistoryChartType> availableTypes = () {
    final types = <_RoutineHistoryChartType>{};

    if (values[_RoutineHistoryChartType.volume]!.any((v) => v.value != 0)) {
      types.add(_RoutineHistoryChartType.volume);
    }
    if (values[_RoutineHistoryChartType.reps]!.any((v) => v.value != 0)) {
      types.add(_RoutineHistoryChartType.reps);
    }

    types.add(_RoutineHistoryChartType.duration);

    return types;
  }();

  @override
  void dispose() {
    dateRecognizer.dispose();
    super.dispose();
  }

  String buildType(_RoutineHistoryChartType type, TextSpan time, double y) {
    switch (type) {
      case _RoutineHistoryChartType.volume:
        return y.userFacingWeight;
      case _RoutineHistoryChartType.reps:
        return "exerciseList.fields.reps".plural(y.toInt());
      case _RoutineHistoryChartType.duration:
        return time.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChartWithCategories(
      categories: {
        _RoutineHistoryChartType.volume: LineChartCategory(
          title: "exercise.chart.views.volume".t,
          icon: const Icon(GTIcons.volume, size: 16),
        ),
        _RoutineHistoryChartType.reps: LineChartCategory(
          title: "exercise.chart.views.reps".t,
          icon: const Icon(GTIcons.reps, size: 16),
        ),
        _RoutineHistoryChartType.duration: LineChartCategory(
          title: "exercise.chart.views.duration".t,
          icon: const Icon(GTIcons.duration, size: 16),
        ),
      }
          .entries
          .where((element) => availableTypes.contains(element.key))
          .toMap(),
      data: {
        for (final entry in values.entries)
          if (availableTypes.contains(entry.key)) entry.key: entry.value
      },
      predictedData: {
        for (final type in availableTypes)
          if (_currentSynthOngoing != null)
            type: [_getSynthesizedPointFor(type)!]
      },
      currentValueBuilder: (type, index, point, isPredicted) {
        final hoveredPoint =
            index >= children.length ? _currentSynthOngoing! : children[index];

        final style = Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isPredicted ? Theme.of(context).colorScheme.quaternary : null,
            );
        return TimerView.buildTimeString(
          context,
          Duration(seconds: point.value.toInt()),
          builder: (time) {
            return Text.rich(
              TextSpan(children: [
                TextSpan(
                  children: [
                    TextSpan(text: buildType(type, time, point.value))
                  ],
                  style: style,
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text: DateFormat.yMd(context.locale.languageCode)
                      .format(hoveredPoint.startingDate!),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: dateRecognizer
                    ..onTap = () {
                      if (index >= children.length) {
                        Go.toNamed(WorkoutView.routeName);
                      } else {
                        Go.to(
                          () => ExercisesView(
                              workout: Get.find<HistoryController>()
                                  .getByID(children[index].id)!),
                        );
                      }
                    },
                ),
              ]),
            );
          },
          style: style,
        );
      },
      leftTitleBuilder: (type, point) {
        return TimerView.buildTimeString(
          context,
          Duration(seconds: point.toInt()),
          builder: (time) {
            return buildType(type, time, point);
          },
        );
      },
    );
  }
}

({
  Set<_ExerciseHistoryChartType> types,
  Map<_ExerciseHistoryChartType, List<LineChartPoint>> values,
}) _calculateTypes(List<ExerciseHistoryChartChild> children) {
  final types = <_ExerciseHistoryChartType>{};
  final values = <_ExerciseHistoryChartType, List<LineChartPoint>>{
    _ExerciseHistoryChartType.volume: [],
    _ExerciseHistoryChartType.reps: [],
    _ExerciseHistoryChartType.time: [],
    _ExerciseHistoryChartType.distance: [],
  };

  for (final (wo, ex) in children) {
    if (ex.doneSets.isEmpty) continue;

    if (ex.liftedWeight != null) {
      values[_ExerciseHistoryChartType.volume]!.add(LineChartPoint(
        value: Weights.convert(
          value: ex.liftedWeight!,
          from: wo.weightUnit,
          to: settingsController.weightUnit.value,
        ),
        date: wo.startingDate!,
      ));
    }
    if (ex.reps != null) {
      values[_ExerciseHistoryChartType.reps]!.add(LineChartPoint(
        value: ex.reps!.toDouble(),
        date: wo.startingDate!,
      ));
    }
    if (ex.time != null) {
      values[_ExerciseHistoryChartType.time]!.add(LineChartPoint(
        value: ex.time!.inSeconds.toDouble(),
        date: wo.startingDate!,
      ));
    }
    if (ex.distanceRun != null) {
      values[_ExerciseHistoryChartType.distance]!.add(LineChartPoint(
        value: Distance.convert(
          value: ex.distanceRun!,
          from: wo.distanceUnit,
          to: settingsController.distanceUnit.value,
        ),
        date: wo.startingDate!,
      ));
    }
  }

  for (final type in _ExerciseHistoryChartType.values) {
    if (values[type]!.isEmpty) continue;
    types.add(type);
  }

  return (
    types: types,
    values: {
      for (final entry in values.entries)
        if (types.contains(entry.key)) entry.key: entry.value
    }
  );
}

typedef ExerciseHistoryChartChild = (Workout, Exercise);

class ExerciseHistoryChart extends StatefulWidget {
  const ExerciseHistoryChart({
    required this.children,
    required this.ongoing,
    super.key,
  });

  final List<ExerciseHistoryChartChild> children;

  final ExerciseHistoryChartChild? ongoing;

  @override
  State<ExerciseHistoryChart> createState() => _ExerciseHistoryChartState();

  // ignore: library_private_types_in_public_api
  static shouldShow(List<ExerciseHistoryChartChild> exercises, bool ongoing) {
    return exercises.where((e) => e.$2.doneSets.isNotEmpty).length >=
            (ongoing ? 1 : 2) &&
        _calculateTypes(exercises).types.isNotEmpty;
  }
}

enum _ExerciseHistoryChartType {
  volume,
  reps,
  time,
  distance,
}

class _ExerciseHistoryChartState
    extends ControlledState<ExerciseHistoryChart, RoutinesController> {
  late final dateRecognizer = TapGestureRecognizer();

  late _ExerciseHistoryChartType type = availableTypes.first;
  late final Map<_ExerciseHistoryChartType, List<LineChartPoint>> values;
  late final Set<_ExerciseHistoryChartType> availableTypes;
  late final List<ExerciseHistoryChartChild> children = widget.children
      .where(
        (e) => e.$2.doneSets.isNotEmpty,
      )
      .toList();

  @override
  void initState() {
    super.initState();

    widget.ongoing?.$2.logger.i("");

    final (types: availableTypes, values: values) = _calculateTypes(
        [...children, if (widget.ongoing != null) widget.ongoing!]);
    this.values = values;
    this.availableTypes = availableTypes;
  }

  @override
  void dispose() {
    dateRecognizer.dispose();
    super.dispose();
  }

  String buildType(_ExerciseHistoryChartType type, TextSpan time, double y) =>
      switch (type) {
        _ExerciseHistoryChartType.volume => y.userFacingWeight,
        _ExerciseHistoryChartType.reps =>
          "exerciseList.fields.reps".plural(y.toInt()),
        _ExerciseHistoryChartType.time => time.text!,
        _ExerciseHistoryChartType.distance => y.userFacingDistance,
      };

  @override
  Widget build(BuildContext context) {
    final partition = children.length;

    return LineChartWithCategories(
      categories: {
        _ExerciseHistoryChartType.volume: LineChartCategory(
          title: "exercise.chart.views.volume".t,
          icon: const Icon(GTIcons.volume, size: 16),
        ),
        _ExerciseHistoryChartType.reps: LineChartCategory(
          title: "exercise.chart.views.reps".t,
          icon: const Icon(GTIcons.reps, size: 16),
        ),
        _ExerciseHistoryChartType.time: LineChartCategory(
          title: "exercise.chart.views.time".t,
          icon: const Icon(GTIcons.time, size: 16),
        ),
        _ExerciseHistoryChartType.distance: LineChartCategory(
          title: "exercise.chart.views.distance".t,
          icon: const Icon(GTIcons.distance, size: 16),
        ),
      }
          .entries
          .where((element) => availableTypes.contains(element.key))
          .toMap(),
      data: {
        for (final entry in values.entries)
          entry.key: entry.value.take(partition).toList(),
      },
      predictedData: {
        for (final entry in values.entries)
          entry.key: entry.value.skip(partition).toList(),
      },
      currentValueBuilder: (type, index, point, isPredicted) {
        final style = Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isPredicted ? Theme.of(context).colorScheme.quaternary : null,
            );
        final date = isPredicted
            ? widget.ongoing!.$1.startingDate!
            : children[index].$1.startingDate!;
        return TimerView.buildTimeString(
          context,
          Duration(seconds: point.value.toInt()),
          builder: (time) {
            return Text.rich(
              TextSpan(children: [
                TextSpan(
                  children: [
                    TextSpan(
                      text: buildType(type, time, point.value),
                    )
                  ],
                  style: style,
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text:
                      DateFormat.yMd(context.locale.languageCode).format(date),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: dateRecognizer
                    ..onTap = () {
                      if (isPredicted) {
                        Go.toNamed(WorkoutView.routeName);
                      } else {
                        Go.to(
                          () => ExercisesView(
                              workout: Get.find<HistoryController>()
                                  .getByID(children[index].$1.id)!),
                        );
                      }
                    },
                ),
              ]),
            );
          },
          style: style,
        );
      },
      leftTitleBuilder: (type, point) {
        final style = context.textTheme.labelSmall!;

        return TimerView.buildTimeString(
          context,
          Duration(seconds: point.toInt()),
          builder: (time) {
            return buildType(type, time, point);
          },
          style: style,
        );
      },
    );
  }
}
