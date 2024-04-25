import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

Set<_ExerciseHistoryChartType> _calculateTypes(
    List<_ExerciseHistoryChartChild> children) {
  final types = <_ExerciseHistoryChartType>{};
  final values = <_ExerciseHistoryChartType, List<double>>{
    _ExerciseHistoryChartType.volume: [],
    _ExerciseHistoryChartType.reps: [],
    _ExerciseHistoryChartType.time: [],
    _ExerciseHistoryChartType.distance: [],
  };

  for (final (wo, ex) in children) {
    if (ex.liftedWeight != null) {
      values[_ExerciseHistoryChartType.volume]!.add(Weights.convert(
        value: ex.liftedWeight!,
        from: wo.weightUnit,
        to: settingsController.weightUnit.value,
      ));
    }
    if (ex.reps != null) {
      values[_ExerciseHistoryChartType.reps]!.add(ex.reps!.toDouble());
    }
    if (ex.time != null) {
      values[_ExerciseHistoryChartType.time]!
          .add(ex.time!.inSeconds.toDouble());
    }
    if (ex.distanceRun != null) {
      values[_ExerciseHistoryChartType.distance]!.add(Distance.convert(
        value: ex.distanceRun!,
        from: wo.distanceUnit,
        to: settingsController.distanceUnit.value,
      ));
    }
  }

  for (final type in _ExerciseHistoryChartType.values) {
    if (values[type]!.isEmpty) continue;
    types.add(type);
  }

  return types;
}

typedef _ExerciseHistoryChartChild = (Workout, Exercise);

class ExerciseHistoryChart extends StatefulWidget {
  const ExerciseHistoryChart({
    required this.children,
    super.key,
  });

  // ignore: library_private_types_in_public_api
  final List<_ExerciseHistoryChartChild> children;

  @override
  State<ExerciseHistoryChart> createState() => _ExerciseHistoryChartState();

  // ignore: library_private_types_in_public_api
  static shouldShow(List<_ExerciseHistoryChartChild> exercises) {
    return exercises.length >= 2 && _calculateTypes(exercises).isNotEmpty;
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
  List<_ExerciseHistoryChartChild> get children => widget.children;

  late int selectedIndex = children.length - 1;

  late final dateRecognizer = TapGestureRecognizer()
    ..onTap = () {
      Go.to(
        () => ExercisesView(
            workout: Get.find<HistoryController>()
                .getByID(children[selectedIndex].$1.id)!),
      );
    };

  late _ExerciseHistoryChartType type = availableTypes.first;
  late final Set<_ExerciseHistoryChartType> availableTypes =
      _calculateTypes(children);

  @override
  void dispose() {
    dateRecognizer.dispose();
    super.dispose();
  }

  IconData buildType(_ExerciseHistoryChartType type) {
    switch (type) {
      case _ExerciseHistoryChartType.volume:
        return Icons.line_weight_rounded;
      case _ExerciseHistoryChartType.reps:
        return Icons.numbers_rounded;
      case _ExerciseHistoryChartType.time:
        return Icons.timer_rounded;
      case _ExerciseHistoryChartType.distance:
        return Icons.run_circle_outlined;
    }
  }

  double _getY(_ExerciseHistoryChartChild tuple) {
    final wo = tuple.$1;
    final ex = tuple.$2;
    switch (type) {
      case _ExerciseHistoryChartType.volume:
        return Weights.convert(
          value: ex.liftedWeight!,
          from: wo.weightUnit,
          to: settingsController.weightUnit.value,
        );
      case _ExerciseHistoryChartType.reps:
        return ex.reps!.toDouble();
      case _ExerciseHistoryChartType.time:
        return ex.time!.inSeconds.toDouble();
      case _ExerciseHistoryChartType.distance:
        return Distance.convert(
          value: ex.distanceRun!,
          from: wo.distanceUnit,
          to: settingsController.distanceUnit.value,
        );
    }
  }

  Widget buildSpan(
    double value,
    TextStyle style, {
    bool showDate = true,
    TextAlign? textAlign,
    required Weights weightUnit,
    required Distance distanceUnit,
  }) {
    return TimerView.buildTimeString(
      context,
      Duration(seconds: value.toInt()),
      builder: (time) {
        TextSpan buildType() {
          switch (type) {
            case _ExerciseHistoryChartType.volume:
              return TextSpan(
                  text: Weights.convert(
                          value: value,
                          from: weightUnit,
                          to: settingsController.weightUnit.value)
                      .userFacingWeight);
            case _ExerciseHistoryChartType.reps:
              return TextSpan(
                  text: "exerciseList.fields.reps".plural(value.toInt()));
            case _ExerciseHistoryChartType.time:
              return time;
            case _ExerciseHistoryChartType.distance:
              return TextSpan(
                  text: Distance.convert(
                          value: value,
                          from: settingsController.distanceUnit.value,
                          to: distanceUnit)
                      .userFacingDistance);
          }
        }

        return Text.rich(
          TextSpan(children: [
            TextSpan(
              children: [buildType()],
              style: style,
            ),
            if (showDate) ...[
              const TextSpan(text: " "),
              TextSpan(
                text: DateFormat.yMd(context.locale.languageCode)
                    .format(children[selectedIndex].$1.startingDate!),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: dateRecognizer,
              ),
            ],
          ]),
          textAlign: textAlign,
        );
      },
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSpan(
          _getY(children[selectedIndex]),
          Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
          // The value was converted by _getY already
          weightUnit: settingsController.weightUnit.value,
          distanceUnit: settingsController.distanceUnit.value,
        ),
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
                  drawVerticalLine: false,
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
                      reservedSize: 70,
                      // interval: 1,
                      getTitlesWidget: leftTitleWidgets(context),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
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
                    tooltipBgColor: Colors.transparent,
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
                    if (index != selectedIndex && index != null) {
                      setState(() => selectedIndex = index);
                    }
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    dotData: const FlDotData(show: false),
                    spots: [
                      for (int i = 0; i < children.length; i++)
                        FlSpot(
                          i.toDouble(),
                          _getY(children[i]),
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
                for (final type in availableTypes)
                  ChoiceChip(
                    label: Text("exercise.chart.views.${type.name}".t),
                    avatar: CircleAvatar(
                      child: this.type == type
                          ? const SizedBox.shrink()
                          : Icon(buildType(type), size: 16),
                    ),
                    selected: this.type == type,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() => this.type = type);
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
      DateTime? cur = children[value.toInt()].$1.startingDate;
      String text = DateFormat.Md(context.locale.languageCode)
          .format(cur ?? DateTime.now());

      if (value > 0) {
        DateTime? prev = children[value.toInt() - 1].$1.startingDate;
        if (_getDayMonth(prev) == _getDayMonth(cur)) {
          text = "";
        } else if (_getMonth(prev) == _getMonth(cur)) {
          text = DateFormat.d(context.locale.languageCode)
              .format(cur ?? DateTime.now());
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
          child: buildSpan(
            value,
            Theme.of(context).textTheme.labelSmall!,
            showDate: false,
            textAlign: TextAlign.end,
            // The value was already converted by the _getY call
            weightUnit: settingsController.weightUnit.value,
            distanceUnit: settingsController.distanceUnit.value,
          ),
        );
  }
}
