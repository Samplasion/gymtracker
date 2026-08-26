import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart' show doubleEquality;
import 'package:gymtracker/utils/utils.dart' as utils show maxDate;
import 'package:gymtracker/view/charts/base_types.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:intl/intl.dart';

export 'package:gymtracker/view/charts/base_types.dart';

enum _LineChartTimeSeriesType {
  threeMonths(Duration(days: 90), isPro: false),
  sixMonths(Duration(days: 180), dragOffset: 2),
  oneYear(Duration(days: 365), dragOffset: 4);

  const _LineChartTimeSeriesType(
    this.duration, {
    this.dragOffset = 1,
    this.isPro = true,
  });

  final Duration duration;
  final double dragOffset;
  final bool isPro;
}

class LineChartTimeSeries<T> extends StatelessWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Map<T, List<LineChartPoint>>? predictions;
  final Widget Function(
    T selectedCategory,
    int hoveredIndex,
    LineChartPoint point,
    bool isPredicted,
  )
  currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;
  final double? minY;
  final double? maxY;
  final ValueChanged<T>? onCategoryChanged;
  final Widget Function(T) nullCurrentValueBuilder;
  final List<Color> Function(BuildContext) categoryColors;
  final String Function(DateTime)? bottomTitleBuilder;

  /// Whether to allow multiple categories to be selected at the same time. If
  /// true, the chart will display all categories at once, and the user will not
  /// be able to select a single category.
  ///
  /// Generally, with the Y axis shared among all categories, it is advisable
  /// that the categories have similar meaning of the Y axis values (eg.
  /// comparing time and weight makes no sense) or that showing multiple
  /// categories at once is not confusing to the user.
  final bool concurrent;

  static Widget defaultNullCurrentValueBuilder(dynamic category) {
    return Text("---");
  }

  static List<Color> defaultCategoryColors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.quaternary,
    ];
  }

  LineChartTimeSeries({
    super.key,
    required this.categories,
    required this.data,
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
    this.predictions,
    this.minY,
    this.maxY,
    this.onCategoryChanged,
    this.concurrent = false,
    this.nullCurrentValueBuilder = defaultNullCurrentValueBuilder,
    this.categoryColors = defaultCategoryColors,
    this.bottomTitleBuilder,
  }) : assert(categories.isNotEmpty),
       assert(data.isNotEmpty),
       assert(categories.length == data.length),
       assert(categories.keys.every((key) => data.keys.contains(key)));

  @override
  Widget build(BuildContext context) {
    if (concurrent) {
      return _LineChartTimeSeriesConcurrent<T>(
        categories: categories,
        data: data,
        predictions: predictions,
        currentValueBuilder: currentValueBuilder,
        leftTitleBuilder: leftTitleBuilder,
        minY: minY,
        maxY: maxY,
        onCategoryChanged: onCategoryChanged,
        nullCurrentValueBuilder: nullCurrentValueBuilder,
        categoryColors: categoryColors,
        bottomTitleBuilder: bottomTitleBuilder,
      );
    } else {
      return _LineChartTimeSeriesSingle<T>(
        categories: categories,
        data: data,
        predictions: predictions,
        currentValueBuilder: currentValueBuilder,
        leftTitleBuilder: leftTitleBuilder,
        minY: minY,
        maxY: maxY,
        onCategoryChanged: onCategoryChanged,
        nullCurrentValueBuilder: nullCurrentValueBuilder,
        categoryColors: categoryColors,
        bottomTitleBuilder: bottomTitleBuilder,
      );
    }
  }
}

class _LineChartTimeSeriesSingle<T> extends StatefulWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Map<T, List<LineChartPoint>>? predictions;
  final Widget Function(
    T selectedCategory,
    int hoveredIndex,
    LineChartPoint point,
    bool isPredicted,
  )
  currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;
  final double? minY;
  final double? maxY;
  final ValueChanged<T>? onCategoryChanged;
  final Widget Function(T) nullCurrentValueBuilder;
  final List<Color> Function(BuildContext) categoryColors;
  final String Function(DateTime)? bottomTitleBuilder;

  const _LineChartTimeSeriesSingle({
    super.key,
    required this.categories,
    required this.data,
    required this.predictions,
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
    required this.minY,
    required this.maxY,
    required this.onCategoryChanged,
    required this.nullCurrentValueBuilder,
    required this.categoryColors,
    required this.bottomTitleBuilder,
  });

  @override
  State<_LineChartTimeSeriesSingle<T>> createState() =>
      __LineChartTimeSeriesSingleState<T>();
}

class __LineChartTimeSeriesSingleState<T>
    extends State<_LineChartTimeSeriesSingle<T>> {
  late T selectedCategory;
  late int hoveredIndex;
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

  bool _isDragging = false;
  double? _leftReservedSize;

  late Map<T, Map<int, LineChartPoint>> dataIndices;
  late Map<T, Set<int>> dataTimestampSets;
  late Map<T, List<FlSpot>> dataSpots;
  late Map<T, List<FlSpot>> predictionSpots;
  late Map<T, int?> lastDataTimestamps;
  late Map<T, int?> lastPredictionTimestamps;

  late DateTime absoluteMinimum;
  late Map<T, DateTime> absoluteMaximumByCategory;
  late Map<T, double?> minYByCategory;
  late Map<T, double?> maxYByCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.keys.first;
    hoveredIndex =
        widget.data[selectedCategory]?.lastOrNull?.date.minutesSinceEpoch ?? 0;
    _initPrecomputedData();
  }

  @override
  void didUpdateWidget(covariant _LineChartTimeSeriesSingle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.categories != oldWidget.categories ||
        widget.predictions != oldWidget.predictions ||
        widget.minY != oldWidget.minY ||
        widget.maxY != oldWidget.maxY) {
      if (!widget.categories.containsKey(selectedCategory)) {
        selectedCategory = widget.categories.keys.first;
      }
      hoveredIndex =
          widget.data[selectedCategory]?.lastOrNull?.date.minutesSinceEpoch ??
          0;
      _initPrecomputedData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculateLeftReservedSize();
  }

  void _initPrecomputedData() {
    dataIndices = {};
    dataTimestampSets = {};
    dataSpots = {};
    predictionSpots = {};
    lastDataTimestamps = {};
    lastPredictionTimestamps = {};
    absoluteMaximumByCategory = {};
    minYByCategory = {};
    maxYByCategory = {};

    DateTime? globalMinDate;

    for (final entry in widget.data.entries) {
      final key = entry.key;
      final points = entry.value;
      final predictions = widget.predictions?[key] ?? [];

      final indexMap = <int, LineChartPoint>{};
      final timestampSet = <int>{};
      final spots = <FlSpot>[];

      for (final p in points) {
        final ts = p.date.minutesSinceEpoch;
        indexMap[ts] = p;
        timestampSet.add(ts);
        spots.add(FlSpot(ts.toDouble(), p.value));
        if (globalMinDate == null || p.date.isBefore(globalMinDate)) {
          globalMinDate = p.date;
        }
      }

      dataIndices[key] = indexMap;
      dataTimestampSets[key] = timestampSet;
      dataSpots[key] = spots;
      lastDataTimestamps[key] = points.lastOrNull?.date.minutesSinceEpoch;

      final pSpots = <FlSpot>[];
      for (final p in predictions) {
        final ts = p.date.minutesSinceEpoch;
        indexMap[ts] = p;
        pSpots.add(FlSpot(ts.toDouble(), p.value));
        if (globalMinDate == null || p.date.isBefore(globalMinDate)) {
          globalMinDate = p.date;
        }
      }
      predictionSpots[key] = pSpots;
      lastPredictionTimestamps[key] =
          predictions.lastOrNull?.date.minutesSinceEpoch;

      final concreteLastDate = points.lastOrNull?.date ?? DateTime.now();
      var maxDate = utils.maxDate(
        concreteLastDate,
        predictions.lastOrNull?.date ?? concreteLastDate,
      );
      maxDate = maxDate.add(const Duration(days: 2));
      absoluteMaximumByCategory[key] = maxDate;

      final allValues = [
        ...points.map((p) => p.value),
        ...predictions.map((p) => p.value),
      ];

      if (allValues.isEmpty) {
        minYByCategory[key] = widget.minY;
        maxYByCategory[key] = widget.maxY;
      } else {
        final rawMin = allValues.min;
        final rawMax = allValues.max;

        double? calcMin =
            max(widget.minY ?? double.negativeInfinity, rawMin) - 2;
        double? calcMax = min(widget.maxY ?? double.infinity, rawMax) + 2;

        final delta = calcMax - calcMin;
        if (calcMax.isFinite && calcMin.isFinite && delta < 5) {
          calcMin = calcMin - 2;
          calcMax = calcMax + 2;
        }

        final paddedDelta = calcMax - calcMin;
        calcMin = calcMin - 0.1 * paddedDelta;
        calcMax = calcMax + 0.1 * paddedDelta;

        if (calcMin.isInfinite) calcMin = widget.minY;
        if (calcMax.isInfinite) calcMax = widget.maxY;

        minYByCategory[key] = calcMin;
        maxYByCategory[key] = calcMax;
      }
    }

    absoluteMinimum = globalMinDate?.startOfDay ?? DateTime.now().startOfDay;
  }

  void _recalculateLeftReservedSize() {
    final style = context.textTheme.labelSmall!;
    final sizes = widget.data.entries.map((e) {
      final categorySizes =
          e.value.map((point) {
            return widget
                .leftTitleBuilder(e.key, point.value)
                .replaceAll(RegExp(r"[0-9]"), "m")
                .computeSize(style: style)
                .width;
          }).toList() +
          [0.0];
      return categorySizes.max;
    }).toList();
    _leftReservedSize = sizes.max;
  }

  DateTime get startingDate {
    final lastData = widget.data[selectedCategory]?.lastOrNull?.date;
    final lastPred = widget.predictions?[selectedCategory]?.lastOrNull?.date;
    DateTime lastDate;
    if (lastData == null && lastPred == null) {
      lastDate = DateTime.now();
    } else if (lastData == null) {
      lastDate = lastPred!;
    } else if (lastPred == null) {
      lastDate = lastData;
    } else {
      lastDate = utils.maxDate(lastData, lastPred);
    }
    return utils.maxDate(
      absoluteMinimum,
      lastDate.startOfDay.subtract(type.duration),
    );
  }

  DateTime get currentMinDate => startingDate.add(offset);
  DateTime get currentMaxDate =>
      (absoluteMaximumByCategory[selectedCategory] ?? DateTime.now()).add(
        offset,
      );

  void _onDrag(DragUpdateDetails details) {
    final days = -details.delta.dx / 2 * type.dragOffset;
    var newOffset = Duration(hours: (days * 24).toInt());

    final absMin = absoluteMinimum;
    final absMax =
        absoluteMaximumByCategory[selectedCategory] ?? DateTime.now();

    if (newOffset.isNegative &&
        currentMinDate.add(newOffset).isBefore(absMin)) {
      newOffset = absMin.difference(currentMinDate);
    }

    if (!newOffset.isNegative &&
        currentMaxDate.add(newOffset).isAfter(absMax)) {
      newOffset = absMax.difference(currentMaxDate);
    }

    setState(() => offset = offset + newOffset);
  }

  Widget Function(double, TitleMeta) topTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      DateTime cur = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);

      var isStarting = doubleEquality(value, meta.min, epsilon: 0.001);
      if (cur.day != 1 && !isStarting) {
        return const SizedBox.shrink();
      }

      String text;
      if (cur.month != DateTime.january && !isStarting) {
        text = DateFormat.MMM(
          context.locale.languageCode,
        ).format(cur).characters.first.toUpperCase();
      } else {
        final m = DateFormat.MMM(
          context.locale.languageCode,
        ).format(cur).characters.first.toUpperCase();
        final y = DateFormat("yy", context.locale.languageCode).format(cur);
        text = "$m '$y";
      }

      return SideTitleWidget(
        meta: meta,
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
      DateTime cur = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);
      String text =
          widget.bottomTitleBuilder?.call(cur) ??
          DateFormat.Md(context.locale.languageCode).format(cur);

      return SideTitleWidget(
        meta: meta,
        angle: -pi / 4,
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      );
    };
  }

  Widget Function(double, TitleMeta) leftTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) => SideTitleWidget(
      meta: meta,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: widget.leftTitleBuilder(selectedCategory, value),
              style: context.textTheme.labelSmall!,
            ),
          ],
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final predictionColor = colorScheme.quaternary;
    final currentPoint = dataIndices[selectedCategory]?[hoveredIndex];
    final categoryDataTimestampSet =
        dataTimestampSets[selectedCategory] ?? const {};

    final currentMinY = minYByCategory[selectedCategory];
    final currentMaxY = maxYByCategory[selectedCategory];
    final currentDataSpots = dataSpots[selectedCategory] ?? const [];
    final currentPredictionSpots =
        predictionSpots[selectedCategory] ?? const [];
    final lastDataTs = lastDataTimestamps[selectedCategory];
    final lastPredTs = lastPredictionTimestamps[selectedCategory];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentPoint != null)
              Expanded(
                child: widget.currentValueBuilder(
                  selectedCategory,
                  hoveredIndex,
                  currentPoint,
                  !categoryDataTimestampSet.contains(hoveredIndex),
                ),
              )
            else
              const Spacer(),
            ProBuilder(
              builder: (context, subState) {
                final shouldBlock = subState?.hasProFeatures != true;
                return TextButton(
                  onPressed: () {
                    Go.showRadioModalNew(
                      selectedValue: type,
                      values: {
                        for (final type in _LineChartTimeSeriesType.values)
                          type: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "timeSeriesChart.interval.${type.name}".t,
                                ),
                                if (type.isPro && shouldBlock) ...[
                                  const TextSpan(text: " "),
                                  WidgetSpan(
                                    child: ProBadge(),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                ],
                              ],
                            ),
                          ),
                      },
                      title: Text("timeSeriesChart.selectInterval".t),
                      onChange: (value) {
                        if (value == null) return;
                        if (shouldBlock && value.isPro) {
                          Navigator.of(context).pop();
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Get.find<PurchasesController>().presentPaywall();
                          });
                          return;
                        }
                        setState(() => type = value);
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
                );
              },
            ),
          ],
        ),
        ProBuilder(
          builder: (context, subStats) {
            final shouldBlock = subStats?.hasProFeatures != true;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                if (shouldBlock) return;
                setState(() => _isDragging = true);
              },
              onHorizontalDragUpdate: shouldBlock ? null : _onDrag,
              onHorizontalDragEnd: (details) {
                if (shouldBlock) return;
                setState(() => _isDragging = false);
              },
              onHorizontalDragCancel: () {
                if (shouldBlock) return;
                setState(() => _isDragging = false);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size.fromHeight(300)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: LineChart(
                    LineChartData(
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        verticalInterval: const Duration(
                          days: 1,
                        ).inMinutes.toDouble(),
                        checkToShowVerticalLine: (value) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt() * 60000,
                          );
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
                            interval: const Duration(
                              days: 1,
                            ).inMinutes.toDouble(),
                            showTitles: true,
                            getTitlesWidget: topTitleWidgets(context),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize:
                                [
                                  context.width / 5,
                                  _leftReservedSize ?? 0,
                                ].min +
                                8,
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
                            ...items.map(
                              (_) => const LineTooltipItem(
                                "hhh",
                                TextStyle(color: Colors.transparent),
                              ),
                            ),
                          ],
                        ),
                        touchSpotThreshold: 10000,
                        enabled: true,
                        touchCallback: (event, response) {
                          final allLines = response?.lineBarSpots ?? [];
                          if (allLines.isEmpty) return;
                          allLines.sort(
                            (a, b) => a.distance.compareTo(b.distance),
                          );

                          final touchLineBarSpot = allLines.first;
                          final index = touchLineBarSpot.x.toInt();

                          if (dataIndices[selectedCategory]?.containsKey(
                                index,
                              ) ==
                              true) {
                            if (hoveredIndex != index) {
                              setState(() {
                                hoveredIndex = index;
                              });
                            }
                          }
                        },
                      ),
                      minX: currentMinDate.minutesSinceEpoch.toDouble(),
                      maxX: currentMaxDate.minutesSinceEpoch.toDouble(),
                      minY: currentMinY,
                      maxY: currentMaxY,
                      lineBarsData: [
                        if (widget.predictions?[selectedCategory] != null)
                          LineChartBarData(
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                return !categoryDataTimestampSet.contains(
                                  spot.x.toInt(),
                                );
                              },
                            ),
                            spots: currentPredictionSpots,
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
                                    spot.x == lastPredTs,
                                flLineStyle: FlLine(
                                  color: predictionColor,
                                  dashArray: [5],
                                ),
                              ),
                              color: predictionColor.withAlpha(
                                (0.3 * 255).round(),
                              ),
                            ),
                          ),
                        LineChartBarData(
                          dotData: const FlDotData(),
                          spots: currentDataSpots,
                          isCurved:
                              type == _LineChartTimeSeriesType.threeMonths,
                          preventCurveOverShooting: true,
                          color: colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            spotsLine: BarAreaSpotsLine(
                              show: true,
                              checkToShowSpotLine: (spot) =>
                                  spot.x == (lastDataTs ?? 0),
                              flLineStyle: FlLine(color: colorScheme.primary),
                            ),
                            color: colorScheme.primary.withAlpha(
                              (0.3 * 255).round(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: Duration(milliseconds: _isDragging ? 0 : 350),
                    curve: Curves.linearToEaseOut,
                  ),
                ),
              ),
            );
          },
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
                      tooltip: entry.value.info,
                      label: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: entry.value.title),
                            if (entry.value.info != null) ...[
                              const TextSpan(text: "   "),
                              WidgetSpan(
                                child: Icon(
                                  GTIcons.info,
                                  size: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      avatar: CircleAvatar(
                        child: selectedCategory == entry.key
                            ? const SizedBox.shrink()
                            : entry.value.icon,
                      ),
                      selected: selectedCategory == entry.key,
                      onSelected: widget.data[entry.key]?.isEmpty != false
                          ? null
                          : (sel) {
                              if (sel) {
                                setState(() {
                                  selectedCategory = entry.key;
                                  hoveredIndex =
                                      widget
                                          .data[entry.key]
                                          ?.lastOrNull
                                          ?.date
                                          .minutesSinceEpoch ??
                                      0;
                                });
                                widget.onCategoryChanged?.call(entry.key);
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
}

class _LineChartTimeSeriesConcurrent<T> extends StatefulWidget {
  final Map<T, LineChartCategory> categories;
  final Map<T, List<LineChartPoint>> data;
  final Map<T, List<LineChartPoint>>? predictions;
  final Widget Function(
    T selectedCategory,
    int hoveredIndex,
    LineChartPoint point,
    bool isPredicted,
  )
  currentValueBuilder;
  final String Function(T, double) leftTitleBuilder;
  final double? minY;
  final double? maxY;
  final ValueChanged<T>? onCategoryChanged;
  final Widget Function(T) nullCurrentValueBuilder;
  final List<Color> Function(BuildContext) categoryColors;
  final String Function(DateTime)? bottomTitleBuilder;

  const _LineChartTimeSeriesConcurrent({
    super.key,
    required this.categories,
    required this.data,
    required this.predictions,
    required this.currentValueBuilder,
    required this.leftTitleBuilder,
    required this.minY,
    required this.maxY,
    required this.onCategoryChanged,
    required this.nullCurrentValueBuilder,
    required this.categoryColors,
    required this.bottomTitleBuilder,
  });

  @override
  State<_LineChartTimeSeriesConcurrent<T>> createState() =>
      __LineChartTimeSeriesConcurrentState<T>();
}

class __LineChartTimeSeriesConcurrentState<T>
    extends State<_LineChartTimeSeriesConcurrent<T>> {
  late Map<T, int> hoveredIndex;
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

  bool _isDragging = false;
  double? _leftReservedSize;

  late Map<T, Map<int, LineChartPoint>> dataIndices;
  late Map<T, Set<int>> dataTimestampSets;
  late Map<T, List<FlSpot>> dataSpots;

  late DateTime absoluteMinimum;
  late DateTime absoluteMaximum;
  late double? minY;
  late double? maxY;

  @override
  void initState() {
    super.initState();
    hoveredIndex = {
      for (final category in widget.categories.keys)
        category:
            widget.data[category]?.lastOrNull?.date.minutesSinceEpoch ?? 0,
    };
    _initPrecomputedData();
  }

  @override
  void didUpdateWidget(covariant _LineChartTimeSeriesConcurrent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.categories != oldWidget.categories ||
        widget.predictions != oldWidget.predictions ||
        widget.minY != oldWidget.minY ||
        widget.maxY != oldWidget.maxY) {
      hoveredIndex = {
        for (final category in widget.categories.keys)
          category:
              widget.data[category]?.lastOrNull?.date.minutesSinceEpoch ?? 0,
      };
      _initPrecomputedData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculateLeftReservedSize();
  }

  void _initPrecomputedData() {
    dataIndices = {};
    dataTimestampSets = {};
    dataSpots = {};

    DateTime? globalMinDate;
    DateTime? globalMaxDate;
    final allValues = <double>[];

    for (final entry in widget.data.entries) {
      final key = entry.key;
      final points = entry.value;

      final indexMap = <int, LineChartPoint>{};
      final timestampSet = <int>{};
      final spots = <FlSpot>[];

      for (final p in points) {
        final ts = p.date.minutesSinceEpoch;
        indexMap[ts] = p;
        timestampSet.add(ts);
        spots.add(FlSpot(ts.toDouble(), p.value));
        allValues.add(p.value);

        if (globalMinDate == null || p.date.isBefore(globalMinDate)) {
          globalMinDate = p.date;
        }
        if (globalMaxDate == null || p.date.isAfter(globalMaxDate)) {
          globalMaxDate = p.date;
        }
      }

      dataIndices[key] = indexMap;
      dataTimestampSets[key] = timestampSet;
      dataSpots[key] = spots;

      if (widget.predictions?[key] != null) {
        for (final p in widget.predictions![key]!) {
          final ts = p.date.minutesSinceEpoch;
          indexMap[ts] = p;
          allValues.add(p.value);
          if (globalMinDate == null || p.date.isBefore(globalMinDate)) {
            globalMinDate = p.date;
          }
          if (globalMaxDate == null || p.date.isAfter(globalMaxDate)) {
            globalMaxDate = p.date;
          }
        }
      }
    }

    absoluteMinimum = globalMinDate?.startOfDay ?? DateTime.now().startOfDay;
    absoluteMaximum = (globalMaxDate ?? DateTime.now()).add(
      const Duration(days: 2),
    );

    if (allValues.isEmpty) {
      minY = widget.minY;
      maxY = widget.maxY;
    } else {
      final rawMin = allValues.min;
      final rawMax = allValues.max;

      double? calcMin = max(widget.minY ?? double.negativeInfinity, rawMin) - 2;
      double? calcMax = min(widget.maxY ?? double.infinity, rawMax) + 2;

      final delta = calcMax - calcMin;
      if (calcMax.isFinite && calcMin.isFinite && delta < 5) {
        calcMin = calcMin - 2;
        calcMax = calcMax + 2;
      }

      final paddedDelta = calcMax - calcMin;
      calcMin = calcMin - 0.1 * paddedDelta;
      calcMax = calcMax + 0.1 * paddedDelta;

      if (calcMin.isInfinite) calcMin = widget.minY;
      if (calcMax.isInfinite) calcMax = widget.maxY;

      minY = calcMin;
      maxY = calcMax;
    }
  }

  void _recalculateLeftReservedSize() {
    final style = context.textTheme.labelSmall!;
    final sizes = widget.data.entries.map((e) {
      final categorySizes =
          e.value.map((point) {
            return widget
                .leftTitleBuilder(e.key, point.value)
                .replaceAll(RegExp(r"[0-9]"), "m")
                .computeSize(style: style)
                .width;
          }).toList() +
          [0.0];
      return categorySizes.max;
    }).toList();
    _leftReservedSize = sizes.max;
  }

  DateTime get startingDate {
    final earliestLastDate = widget.categories.keys
        .map((c) {
          final lastData = widget.data[c]?.lastOrNull?.date;
          final lastPred = widget.predictions?[c]?.lastOrNull?.date;
          if (lastData == null && lastPred == null) return DateTime.now();
          if (lastData == null) return lastPred!;
          if (lastPred == null) return lastData;
          return utils.maxDate(lastData, lastPred);
        })
        .fold(DateTime.now(), (a, b) => a.isBefore(b) ? a : b);

    return utils.maxDate(
      absoluteMinimum,
      earliestLastDate.startOfDay.subtract(type.duration),
    );
  }

  DateTime get currentMinDate => startingDate.add(offset);
  DateTime get currentMaxDate => absoluteMaximum.add(offset);

  void _onDrag(DragUpdateDetails details) {
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

  Color _categoryColor(T category) {
    final list = widget.categoryColors(context);
    final index = widget.categories.keys.toList().indexOf(category);
    return context.harmonizeColor(list[index % list.length]);
  }

  Widget Function(double, TitleMeta) topTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      DateTime cur = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);

      var isStarting = doubleEquality(value, meta.min, epsilon: 0.001);
      if (cur.day != 1 && !isStarting) {
        return const SizedBox.shrink();
      }

      String text;
      if (cur.month != DateTime.january && !isStarting) {
        text = DateFormat.MMM(
          context.locale.languageCode,
        ).format(cur).characters.first.toUpperCase();
      } else {
        final m = DateFormat.MMM(
          context.locale.languageCode,
        ).format(cur).characters.first.toUpperCase();
        final y = DateFormat("yy", context.locale.languageCode).format(cur);
        text = "$m '$y";
      }

      return SideTitleWidget(
        meta: meta,
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
      DateTime cur = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 60000);
      String text =
          widget.bottomTitleBuilder?.call(cur) ??
          DateFormat.Md(context.locale.languageCode).format(cur);

      return SideTitleWidget(
        meta: meta,
        angle: -pi / 4,
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      );
    };
  }

  Widget Function(double, TitleMeta) leftTitleWidgets(BuildContext context) {
    final firstCategory = widget.categories.keys.first;
    return (double value, TitleMeta meta) => SideTitleWidget(
      meta: meta,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: widget.leftTitleBuilder(firstCategory, value),
              style: context.textTheme.labelSmall!,
            ),
          ],
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final category in widget.categories.keys)
                    if (dataIndices[category]?[hoveredIndex[category]] != null)
                      widget.currentValueBuilder(
                        category,
                        hoveredIndex[category] ?? 0,
                        dataIndices[category]![hoveredIndex[category]]!,
                        !(dataTimestampSets[category]?.contains(
                              hoveredIndex[category],
                            ) ??
                            false),
                      )
                    else
                      widget.nullCurrentValueBuilder(category),
                ],
              ),
            ),
            ProBuilder(
              builder: (context, subState) {
                final shouldBlock = subState?.hasProFeatures != true;
                return TextButton(
                  onPressed: () {
                    Go.showRadioModalNew(
                      selectedValue: type,
                      values: {
                        for (final type in _LineChartTimeSeriesType.values)
                          type: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "timeSeriesChart.interval.${type.name}".t,
                                ),
                                if (type.isPro && shouldBlock) ...[
                                  const TextSpan(text: " "),
                                  WidgetSpan(
                                    child: ProBadge(),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                ],
                              ],
                            ),
                          ),
                      },
                      title: Text("timeSeriesChart.selectInterval".t),
                      onChange: (value) {
                        if (value == null) return;
                        if (shouldBlock && value.isPro) {
                          Navigator.of(context).pop();
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Get.find<PurchasesController>().presentPaywall();
                          });
                          return;
                        }
                        setState(() => type = value);
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
                );
              },
            ),
          ],
        ),
        ProBuilder(
          builder: (context, subStats) {
            final shouldBlock = subStats?.hasProFeatures != true;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                if (shouldBlock) return;
                setState(() => _isDragging = true);
              },
              onHorizontalDragUpdate: shouldBlock ? null : _onDrag,
              onHorizontalDragEnd: (details) {
                if (shouldBlock) return;
                setState(() => _isDragging = false);
              },
              onHorizontalDragCancel: () {
                if (shouldBlock) return;
                setState(() => _isDragging = false);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size.fromHeight(300)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: LineChart(
                    LineChartData(
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        verticalInterval: const Duration(
                          days: 1,
                        ).inMinutes.toDouble(),
                        checkToShowVerticalLine: (value) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt() * 60000,
                          );
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
                            interval: const Duration(
                              days: 1,
                            ).inMinutes.toDouble(),
                            showTitles: true,
                            getTitlesWidget: topTitleWidgets(context),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize:
                                [
                                  context.width / 5,
                                  _leftReservedSize ?? 0,
                                ].min +
                                8,
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
                            ...items.map(
                              (_) => const LineTooltipItem(
                                "hhh",
                                TextStyle(color: Colors.transparent),
                              ),
                            ),
                          ],
                        ),
                        touchSpotThreshold: 10000,
                        enabled: true,
                        touchCallback: (event, response) {
                          final allLines = response?.lineBarSpots ?? [];
                          if (allLines.isEmpty) return;
                          allLines.sort(
                            (a, b) => a.distance.compareTo(b.distance),
                          );

                          final touchLineBarSpot = allLines.first;
                          final index = touchLineBarSpot.x.toInt();

                          setState(() {
                            for (final category in widget.categories.keys) {
                              if (dataIndices[category]?.containsKey(index) ==
                                  true) {
                                hoveredIndex[category] = index;
                              }
                            }
                          });
                        },
                      ),
                      minX: currentMinDate.minutesSinceEpoch.toDouble(),
                      maxX: currentMaxDate.minutesSinceEpoch.toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        for (final category in widget.categories.keys)
                          LineChartBarData(
                            dotData: const FlDotData(),
                            spots: dataSpots[category] ?? const [],
                            isCurved: false,
                            preventCurveOverShooting: true,
                            color: _categoryColor(category),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              spotsLine: BarAreaSpotsLine(
                                show: false,
                                flLineStyle: FlLine(
                                  color: _categoryColor(category),
                                  strokeWidth: 1,
                                ),
                              ),
                              color: Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                    duration: Duration(milliseconds: _isDragging ? 0 : 350),
                    curve: Curves.linearToEaseOut,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.categories.length > 1) ...[
          const SizedBox(height: 16),
          for (final entry in widget.categories.entries)
            Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.circle,
                      size: 16,
                      color: _categoryColor(entry.key),
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const TextSpan(text: " "),
                  TextSpan(text: entry.value.title),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
