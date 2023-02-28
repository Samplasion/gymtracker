import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateField extends StatefulWidget {
  DateField({
    Key? key,
    this.decoration,
    required this.date,
    required this.onSelect,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  }) : super(key: key);

  final InputDecoration? decoration;
  final DateTime date;
  final void Function(DateTime) onSelect;
  final String? Function(DateTime)? validator;
  DateTime? firstDate;
  DateTime? lastDate;
  bool Function(DateTime)? selectableDayPredicate;

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: DateFormat.yMEd(/* context.currentLocale.languageCode */)
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
      // ignore: use_build_context_synchronously
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 0, minute: 0),
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
