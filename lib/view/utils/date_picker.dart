import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

class DatePickerPlus extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool Function(DateTime) markDate;

  const DatePickerPlus({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.markDate,
    super.key,
  });

  @override
  State<DatePickerPlus> createState() => _DatePickerPlusState();
}

class _DatePickerPlusState extends State<DatePickerPlus> {
  late final calendarController = CleanCalendarController(
    initialDateSelected: widget.initialDate,
    initialFocusDate: widget.initialDate,
    minDate: widget.firstDate,
    maxDate: widget.lastDate,
    rangeMode: false,
    onDayTapped: (date) {
      Get.back(result: date);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MaterialLocalizations.of(context).datePickerHelpText),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ScrollableCleanCalendar(
          locale: Get.locale!.languageCode,
          calendarController: calendarController,
          layout: Layout.DEFAULT,
          padding: EdgeInsets.symmetric(
                horizontal:
                    max(0, (width - Breakpoints.xs.screenWidth.toDouble()) / 2),
              ) +
              const EdgeInsets.all(16) +
              MediaQuery.of(context).padding.copyWith(top: 0),
          dayBuilder: (context, values) {
            final date = values.day.startOfDay;

            return Badge(
              isLabelVisible: widget.markDate(date),
              offset: const Offset(2, 2),
              child: _pattern(context, values),
            );
          },
        );
      }),
    );
  }

  Widget _pattern(BuildContext context, DayValues values) {
    Color bgColor = Theme.of(context).colorScheme.surfaceContainerLow;
    TextStyle txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    if (values.day.startOfDay.isBefore(values.minDate.startOfDay) ||
        values.day.startOfDay.isAfter(values.maxDate.startOfDay)) {
      bgColor = Theme.of(context)
          .colorScheme
          .surfaceContainerLow
          .withAlpha((.4 * 255).round());
      txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withAlpha((.5 * 255).round()),
      );
    }

    if (values.isSelected) {
      bgColor = Theme.of(context).colorScheme.primary;
      txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        values.text,
        textAlign: TextAlign.center,
        style: txtStyle,
      ),
    );
  }
}
