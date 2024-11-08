import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart' show doubleEquality;
import 'package:gymtracker/view/charts/base_types.dart';
import 'package:intl/intl.dart';

export 'package:gymtracker/view/charts/base_types.dart';

class LineChartTimeSeries<T> extends StatefulWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Map<T, List<LineChartPoint>>? predictions;
  final Widget Function(T selectedCategory, int hoveredIndex,
      LineChartPoint point, bool isPredicted) currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;
  final double? minY;
  final double? maxY;

  LineChartTimeSeries({
    super.key,
    required this.categories,
    required this.data,
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
    this.predictions,
    this.minY,
    this.maxY,
  })  : assert(categories.isNotEmpty),
        assert(data.isNotEmpty),
        assert(categories.length == data.length),
        assert(categories.keys.every((key) => data.keys.contains(key)));

  @override
  State<LineChartTimeSeries<T>> createState() => _LineChartTimeSeriesState<T>();
}

enum _LineChartTimeSeriesType {
  threeMonths(Duration(days: 90)),
  sixMonths(Duration(days: 180), dragOffset: 2),
  oneYear(Duration(days: 365), dragOffset: 4);

  const _LineChartTimeSeriesType(
    this.duration, {
    this.dragOffset = 1,
  });

  final Duration duration;
  final double dragOffset;
}

class _LineChartTimeSeriesState<T> extends State<LineChartTimeSeries<T>> {
  late T selectedCategory = widget.categories.keys.first;
  late int hoveredIndex =
      widget.data[selectedCategory]!.last.date.minutesSinceEpoch;
  var type = _LineChartTimeSeriesType.threeMonths;

  var _offset = Duration.zero;
  Duration get offset => _offset;
  set offset(Duration value) {
    if (value.inHours >= 0) {
      _offset = Duration.zero;
      return;
    }

    _offset = value;
  }

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

  late final Map<T, Map<int, LineChartPoint>> dataIndices = widget.data
      .combinedWith(
        widget.predictions ?? {},
      )
      .map(
        (key, value) => MapEntry(
          key,
          Map.fromEntries(value
              .map((point) => MapEntry(point.date.minutesSinceEpoch, point))),
        ),
      );

  DateTime get startingDate =>
      children.last.date.startOfDay.subtract(type.duration);
  List<LineChartPoint> get filteredChildren => children.where((point) {
        return point.date.isAfter(startingDate);
      }).toList();

  DateTime get absoluteMinimum => children.first.date.startOfDay;
  DateTime get absoluteMaximum {
    var maxDate = (filteredChildren.isEmpty
        ? DateTime.now()
        : filteredChildren.last.date);

    if (widget.predictions?[selectedCategory] != null) {
      final predictionDates = widget.predictions![selectedCategory]!
          .map((point) => point.date)
          .toList();
      if (predictionDates.length > 1 && predictionDates.last.isAfter(maxDate)) {
        maxDate = predictionDates.last;
      }
    }

    // Pad the max date by 2 days to make the last day visible
    maxDate = maxDate.add(const Duration(days: 2));

    return maxDate;
  }

  _onDrag(DragUpdateDetails details) {
    final days = -details.delta.dx / 2 * type.dragOffset;
    var newOffset = Duration(hours: (days * 24).toInt());

    if (newOffset.isNegative &&
        currentMinDate.add(newOffset).isBefore(absoluteMinimum)) {
      newOffset = absoluteMinimum.difference(currentMinDate);
    }

    if (!newOffset.isNegative &&
        currentMaxDate.add(newOffset).isAfter(absoluteMaximum)) {
      newOffset = absoluteMaximum.difference(currentMaxDate);
    }

    setState(() => offset = offset + newOffset);
  }

  DateTime get currentMinDate {
    return startingDate.add(offset);
  }

  DateTime get currentMaxDate {
    return absoluteMaximum.add(offset);
  }

  double? minY, maxY;

  @override
  void initState() {
    super.initState();
    _recalculateMinMax();
  }

  _recalculateMinMax() {
    final shownValues = children
        .where((element) =>
            element.date.isAfterOrAtSameMomentAs(currentMinDate) &&
            element.date.isBeforeOrAtSameMomentAs(currentMaxDate))
        .map((e) => e.value)
        .toList();
    final shownPredictions = widget.predictions?[selectedCategory]
            ?.where((element) =>
                element.date.isAfterOrAtSameMomentAs(currentMinDate) &&
                element.date.isBeforeOrAtSameMomentAs(currentMaxDate))
            .map((e) => e.value)
            .toList() ??
        [];
    final shownPoints = [...shownValues, ...shownPredictions];

    minY = max(widget.minY ?? double.negativeInfinity,
            [double.infinity, ...shownPoints].min) -
        2;
    maxY = min(widget.maxY ?? double.infinity,
            [double.negativeInfinity, ...shownPoints].max) +
        2;

    if (maxY!.isFinite && minY!.isFinite && maxY! - minY! < 5) {
      minY = minY! - 2;
      maxY = maxY! + 2;
    }

    // Add some padding
    final delta = maxY! - minY!;
    minY = minY! - 0.05 * delta;
    maxY = maxY! + 0.05 * delta;

    if (minY!.isInfinite) minY = widget.minY;
    if (maxY!.isInfinite) maxY = widget.maxY;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final predictionColor = colorScheme.quaternary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: widget.currentValueBuilder(
                selectedCategory,
                hoveredIndex,
                dataIndices[selectedCategory]![hoveredIndex]!,
                // Whether this point is predicted
                !children.any((element) =>
                    element.date.minutesSinceEpoch == hoveredIndex),
              ),
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
                    _recalculateMinMax();
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("timeSeriesChart.interval.${type.name}".t),
                  const SizedBox(width: 4),
                  const Icon(GTIcons.dropdown),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDrag,
          onHorizontalDragEnd: (details) {
            _recalculateMinMax();
          },
          onHorizontalDragCancel: () {
            _recalculateMinMax();
          },
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromHeight(300)),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                right: 16,
              ),
              child: LineChart(
                LineChartData(
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
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
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        interval: const Duration(days: 1).inMinutes.toDouble(),
                        showTitles: true,
                        getTitlesWidget: topTitleWidgets(context),
                      ),
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
                      final allLines = response?.lineBarSpots ?? [];
                      if (allLines.isEmpty) {
                        return;
                      }
                      allLines.sort((a, b) => a.distance.compareTo(b.distance));

                      final touchLineBarSpot = allLines.first;

                      final index = touchLineBarSpot.x.toInt();
                      final availableIndices = {
                        ...dataIndices[selectedCategory]!.keys
                      };

                      if (index != hoveredIndex &&
                          availableIndices.contains(index)) {
                        setState(() => hoveredIndex = index);
                      }
                    },
                  ),
                  minX: currentMinDate.minutesSinceEpoch.toDouble(),
                  maxX: currentMaxDate.minutesSinceEpoch.toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    if (widget.predictions?[selectedCategory] != null)
                      LineChartBarData(
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) {
                            return !filteredChildren.any((element) =>
                                element.date.minutesSinceEpoch ==
                                spot.x.toInt());
                          },
                        ),
                        spots: [
                          for (final point
                              in widget.predictions![selectedCategory]!)
                            FlSpot(
                              point.date.minutesSinceEpoch.toDouble(),
                              point.value,
                            ),
                        ],
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: predictionColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dashArray: [5, 10],
                        belowBarData: BarAreaData(
                          show: true,
                          spotsLine: BarAreaSpotsLine(
                            show: true,
                            checkToShowSpotLine: (spot) =>
                                spot.x ==
                                widget.predictions![selectedCategory]?.last.date
                                    .minutesSinceEpoch,
                            flLineStyle:
                                FlLine(color: predictionColor, dashArray: [5]),
                          ),
                          color: predictionColor.withOpacity(0.3),
                        ),
                      ),
                    LineChartBarData(
                      dotData: const FlDotData(),
                      spots: [
                        for (int i = 0; i < children.length; i++)
                          FlSpot(
                            children[i].date.minutesSinceEpoch.toDouble(),
                            children[i].value,
                          ),
                      ],
                      isCurved: type == _LineChartTimeSeriesType.threeMonths,
                      preventCurveOverShooting: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        spotsLine: BarAreaSpotsLine(
                          show: true,
                          checkToShowSpotLine: (spot) =>
                              spot.x ==
                              filteredChildren.last.date.minutesSinceEpoch,
                          flLineStyle: FlLine(color: colorScheme.primary),
                        ),
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
        ),
        if (widget.categories.length > 1)
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
                          _recalculateMinMax();
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

  Widget Function(double, TitleMeta) topTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      DateTime? cur =
          DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);

      var isStarting = doubleEquality(value, meta.min, epsilon: 0.001);
      if (cur.day != 1 && !isStarting) {
        return const SizedBox.shrink();
      }

      String text;
      if (cur.month != DateTime.january && !isStarting) {
        text = DateFormat.MMM(context.locale.languageCode)
            .format(cur)
            .characters
            .first
            .toUpperCase();
      } else {
        final m = DateFormat.MMM(context.locale.languageCode)
            .format(cur)
            .characters
            .first
            .toUpperCase();
        final y = DateFormat("yy", context.locale.languageCode).format(cur);
        text = "$m '$y";
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: ColoredBox(
          color: Theme.of(context).cardColor,
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: isStarting ? TextAlign.center : TextAlign.end,
          ),
        ),
      );
    };
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
