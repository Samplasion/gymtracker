import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

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
    return !workout.isConcrete &&
        controller
                .getChildren(
                  workout,
                  allowSynthesized: true,
                )
                .length >=
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
  List<Workout> get children => controller.getChildren(
        widget.routine,
        allowSynthesized: true,
      );

  late int selectedIndex = children.length - 1;

  late final dateRecognizer = TapGestureRecognizer()
    ..onTap = () {
      Go.to(
        () => ExercisesView(
            workout: Get.find<HistoryController>()
                .getByID(children[selectedIndex].id)!),
      );
    };

  late _RoutineHistoryChartType type = availableTypes.first;
  late final Set<_RoutineHistoryChartType> availableTypes = () {
    final types = <_RoutineHistoryChartType>{};
    final values = <_RoutineHistoryChartType, List<double>>{
      _RoutineHistoryChartType.volume: [],
      _RoutineHistoryChartType.reps: [],
      _RoutineHistoryChartType.duration: [],
    };

    for (final wo in children) {
      values[_RoutineHistoryChartType.volume]!.add(Weights.convert(
        value: wo.liftedWeight,
        from: wo.weightUnit,
        to: settingsController.weightUnit.value,
      ));
      values[_RoutineHistoryChartType.reps]!.add(wo.reps.toDouble());
      values[_RoutineHistoryChartType.duration]!
          .add(wo.duration!.inSeconds.toDouble());
    }

    if (values[_RoutineHistoryChartType.volume]!.any((v) => v != 0)) {
      types.add(_RoutineHistoryChartType.volume);
    }
    if (values[_RoutineHistoryChartType.reps]!.any((v) => v != 0)) {
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

  IconData buildType(_RoutineHistoryChartType type) {
    switch (type) {
      case _RoutineHistoryChartType.volume:
        return Icons.line_weight_rounded;
      case _RoutineHistoryChartType.reps:
        return Icons.numbers_rounded;
      case _RoutineHistoryChartType.duration:
        return Icons.timer_rounded;
    }
  }

  double _getY(Workout wo) {
    switch (type) {
      case _RoutineHistoryChartType.volume:
        return Weights.convert(
          value: wo.liftedWeight,
          from: wo.weightUnit,
          to: settingsController.weightUnit.value,
        );
      case _RoutineHistoryChartType.reps:
        return wo.reps.toDouble();
      case _RoutineHistoryChartType.duration:
        return wo.duration!.inSeconds.toDouble();
    }
  }

  Widget buildSpan(
    double value,
    TextStyle style, {
    bool showDate = true,
    TextAlign? textAlign,
    required Weights weightUnit,
  }) {
    return TimerView.buildTimeString(
      context,
      Duration(seconds: value.toInt()),
      builder: (time) {
        TextSpan buildType() {
          switch (type) {
            case _RoutineHistoryChartType.volume:
              return TextSpan(
                  text: Weights.convert(
                          value: value,
                          from: weightUnit,
                          to: settingsController.weightUnit.value)
                      .userFacingWeight);
            case _RoutineHistoryChartType.reps:
              return TextSpan(
                  text: "exerciseList.fields.reps".plural(value.toInt()));
            case _RoutineHistoryChartType.duration:
              return time;
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
                    .format(children[selectedIndex].startingDate!),
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
                  drawVerticalLine: true,
                  verticalInterval: 1,
                  checkToShowVerticalLine: (value) {
                    if (value % 1 != 0) return false;
                    DateTime? prev =
                        children.getAt(value.toInt() - 1)?.startingDate;
                    if (prev == null) return true;
                    DateTime? cur = children[value.toInt()].startingDate;
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
                      reservedSize: 70,
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
      if (value % 1 != 0) return const SizedBox.shrink();

      DateTime? cur = children[value.toInt()].startingDate;
      String text = DateFormat.Md(context.locale.languageCode)
          .format(cur ?? DateTime.now());

      if (value > 0) {
        DateTime? prev = children.getAt(value.truncate() - 1)?.startingDate;
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
          child: buildSpan(
            value,
            Theme.of(context).textTheme.labelSmall!,
            showDate: false,
            textAlign: TextAlign.end,
            // The value was already converted by the _getY call
            weightUnit: settingsController.weightUnit.value,
          ),
        );
  }
}
