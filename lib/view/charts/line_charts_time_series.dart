import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/charts/base_types.dart';
import 'package:intl/intl.dart';

export 'package:gymtracker/view/charts/base_types.dart';

class LineChartTimeSeries<T> extends StatefulWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Widget Function(T, int, LineChartPoint) currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;

  LineChartTimeSeries({
    super.key,
    required this.categories,
    required this.data,
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
  })  : assert(categories.isNotEmpty),
        assert(data.isNotEmpty),
        assert(categories.length == data.length),
        assert(categories.keys.every((key) => data.keys.contains(key)));

  @override
  State<LineChartTimeSeries<T>> createState() => _LineChartTimeSeriesState<T>();
}

enum _LineChartTimeSeriesType {
  threeMonths(Duration(days: 90)),
  sixMonths(Duration(days: 180)),
  oneYear(Duration(days: 365));

  const _LineChartTimeSeriesType(this.duration);

  final Duration duration;
}

class _LineChartTimeSeriesState<T> extends State<LineChartTimeSeries<T>> {
  late T selectedCategory = widget.categories.keys.first;
  late int hoveredIndex =
      widget.data[selectedCategory]!.last.date.minutesSinceEpoch;
  var type = _LineChartTimeSeriesType.threeMonths;

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

  late final Map<T, Map<int, LineChartPoint>> dataIndices = widget.data.map(
    (key, value) => MapEntry(
      key,
      Map.fromEntries(
          value.map((point) => MapEntry(point.date.minutesSinceEpoch, point))),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startingDate = DateTime.now().startOfDay.subtract(type.duration);
    final filteredChildren = children.where((point) {
      return point.date.isAfter(startingDate);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: widget.currentValueBuilder(selectedCategory, hoveredIndex,
                  dataIndices[selectedCategory]![hoveredIndex]!),
            ),
            TextButton(
              onPressed: () {
                Go.showRadioModal(
                  selectedValue: type,
                  values: {
                    for (final type in _LineChartTimeSeriesType.values)
                      type: "timeSeriesChart.interval.${type.name}".t
                  },
                  title: Text("timeSeriesChart.selectInterval".t),
                  onChange: (value) {
                    setState(() => type = value as _LineChartTimeSeriesType);
                  },
                );
              },
              child: Text("timeSeriesChart.interval.${type.name}".t),
            ),
          ],
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
                  // verticalInterval: 1,
                  verticalInterval:
                      const Duration(days: 1).inMinutes.toDouble(),
                  checkToShowVerticalLine: (value) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt() * 60000);
                    return date.day == 1;
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
                    final availableIndices = {
                      ...dataIndices[selectedCategory]!.keys
                    };
                    if (index != hoveredIndex &&
                        index != null &&
                        availableIndices.contains(index)) {
                      setState(() => hoveredIndex = index);
                    }
                  },
                ),
                minX: startingDate.minutesSinceEpoch.toDouble(),
                maxX: (filteredChildren.isEmpty
                        ? DateTime.now()
                        : filteredChildren.last.date)
                    .minutesSinceEpoch
                    .toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    dotData: const FlDotData(),
                    spots: [
                      for (int i = 0; i < filteredChildren.length; i++)
                        FlSpot(
                          filteredChildren[i].date.minutesSinceEpoch.toDouble(),
                          filteredChildren[i].value,
                        ),
                    ],
                    isCurved: type == _LineChartTimeSeriesType.threeMonths,
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

  Widget Function(double, TitleMeta) bottomTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      DateTime? cur =
          DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);
      String text = DateFormat.Md(context.locale.languageCode).format(cur);

      return SideTitleWidget(
        axisSide: meta.axisSide,
        angle: -pi / 4,
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
