// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:intl/intl.dart';

class DateField extends StatefulWidget {
  DateField({
    super.key,
    this.decoration,
    required this.date,
    required this.onSelect,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  });

  final InputDecoration? decoration;
  final DateTime date;
  final void Function(DateTime) onSelect;
  final String? Function(DateTime)? validator;
  DateTime? firstDate;
  DateTime? lastDate;
  bool Function(DateTime)? selectableDayPredicate;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: (widget.decoration ?? const GymTrackerInputDecoration()),
      controller: TextEditingController(
        text: DateFormat.yMEd(context.locale.languageCode)
            .add_jm()
            .format(widget.date),
      ),
      onTap: _openDialog,
      validator: widget.validator != null ? _validator : null,
    );
  }

  _openDialog() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 1),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime:
            TimeOfDay(hour: widget.date.hour, minute: widget.date.minute),
      );

      if (time != null) {
        date = date.copyWith(
          hour: time.hour,
          minute: time.minute,
        );
        widget.onSelect(date);
      }
    }
  }

  String? _validator(_) {
    return widget.validator!(widget.date);
  }
}
