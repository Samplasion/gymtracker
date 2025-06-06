import "dart:math" as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/extensions.dart' hide ContextThemingUtils;
import 'package:gymtracker/utils/utils.dart' hide max;
import 'package:intl/intl.dart';

class DensityCalendarChart extends StatelessWidget {
  final List<int> values;
  final String Function(DateTime start, int daysInThePast, int value)
      tooltipBuilder;

  DensityCalendarChart({
    super.key,
    required this.values,
    this.tooltipBuilder = _defaultTooltipBuilder,
  })  : assert(values.isNotEmpty),
        assert(values.every((value) => value >= 0));

  static String _defaultTooltipBuilder(
      DateTime start, int daysInThePast, int value) {
    return "${DateFormat.yMEd(Get.locale?.languageCode).format(start.subtract(Duration(days: daysInThePast)))}: $value";
  }

  final maxSquareSize = 24.0;
  final padding = 1.5;
  final minOpacity = 0.1;
  final maxOpacity = 1.0;
  late final start = DateTime.now();

  TextStyle _labelStyle(BuildContext context) =>
      context.theme.textTheme.labelSmall!;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final crossCount =
            (size.maxWidth / (maxSquareSize + 2 * padding)).floor() - 1;

        final squareCount = max(0, 7 * crossCount);
        final sublist = (values + List.generate(squareCount, (_) => 0))
            .take(squareCount)
            .toList();

        final runningMin = sublist.safeMin ?? 0;
        final runningMax = sublist.safeMax ?? 1;

        return Column(
          children: [
            ConstrainedBox(
              constraints: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    verticalDirection: VerticalDirection.up,
                    children: [
                      _textRaw(context, ""),
                      for (int j = 0; j < 7; j++) _day(context, j),
                    ],
                  ),
                  for (int i = crossCount - 1; i >= 0; i--)
                    Column(
                      verticalDirection: VerticalDirection.up,
                      children: [
                        if (i == crossCount - 1 ||
                            _getMonthNumberFor(index: 7 * i) !=
                                _getMonthNumberFor(index: 7 * (i + 1)))
                          _textRaw(context, _getMonthFor(index: 7 * i))
                        else
                          _textRaw(context, ""),
                        for (int j = 0; j < 7; j++)
                          _square(context, 7 * i + j, runningMax),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  runningMin.toString(),
                  style: _labelStyle(context),
                ),
                const SizedBox(width: 16),
                for (int i = 0;
                    i <
                        math.min((runningMax - runningMin + 1),
                            math.min(8, crossCount - 2));
                    i++)
                  _rawSquare(
                    context,
                    context.theme.colorScheme.tertiary.withAlpha((mapRange(
                              i.toDouble(),
                              0,
                              math.min((runningMax - runningMin + 1).toDouble(),
                                      math.min(8, crossCount - 2)) -
                                  1,
                              minOpacity,
                              maxOpacity,
                            ).clamp(0, 1) *
                            255)
                        .round()),
                  ),
                const SizedBox(width: 16),
                Text(
                  runningMax.toString(),
                  style: _labelStyle(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _square(BuildContext context, int index, int max) {
    final val = index >= values.length ? 0 : values[index];
    var opacity =
        mapRange(val.toDouble(), 0, max.toDouble(), minOpacity, maxOpacity)
            .clamp(0, 1)
            .toDouble();
    if (val == max && val == 0) opacity = minOpacity;
    return Tooltip(
      message: tooltipBuilder(start, index, val),
      child: _rawSquare(
        context,
        context.theme.colorScheme.tertiary.withAlpha((opacity * 255).round()),
      ),
    );
  }

  Widget _rawSquare(BuildContext context, Color color) {
    return Container(
      margin: EdgeInsets.all(padding),
      constraints: BoxConstraints(
        minWidth: maxSquareSize,
        maxWidth: maxSquareSize,
        minHeight: maxSquareSize,
        maxHeight: maxSquareSize,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.theme.dividerColor.withAlpha((0.35 * 255).round()),
          width: 0.8,
        ),
        color: color,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _day(BuildContext context, int index) {
    return _textRaw(
        context,
        DateFormat.E(Get.locale?.languageCode)
            .format(start.subtract(Duration(days: index)))
            .characters
            .first
            .toUpperCase());
  }

  Widget _textRaw(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.all(padding),
      constraints: BoxConstraints(
        minWidth: maxSquareSize,
        maxWidth: maxSquareSize,
        minHeight: maxSquareSize,
        maxHeight: maxSquareSize,
      ),
      child: Center(
        child: Text(
          text,
          style: _labelStyle(context),
        ),
      ),
    );
  }

  String _getMonthFor({required int index}) {
    return DateFormat.MMM(Get.locale?.languageCode)
        .format(start.subtract(Duration(days: index)))
        .characters
        .first
        .toUpperCase();
  }

  int _getMonthNumberFor({required int index}) {
    return start.subtract(Duration(days: index)).month;
  }
}
