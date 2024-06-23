// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
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
  final _node = FocusNode();
  final _noTabNode = FocusNode(skipTraversal: true);
  final WidgetStatesController _widgetStatesController =
      WidgetStatesController();

  bool get _isFocused =>
      _widgetStatesController.value.contains(WidgetState.focused);
  set _isFocused(bool value) {
    setState(() {
      if (_isFocused && !value) return;
      _widgetStatesController
        ..update(WidgetState.focused, value)
        ..logger.d("Setting focus to $value (from $_isFocused)");
    });
  }

  @override
  void initState() {
    super.initState();
    _widgetStatesController.addListener(() {
      if (_isFocused &&
          !_widgetStatesController.value.contains(WidgetState.focused)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _widgetStatesController
            ..update(WidgetState.focused, true)
            ..logger.d("Forcibly setting focus to true");
        });
      }
    });
    _node.addListener(() {
      if (_node.hasPrimaryFocus) {
        _isFocused = true;
      } else {
        _isFocused = false;
      }
    });
  }

  @override
  void dispose() {
    _node.dispose();
    _noTabNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var decoration = (widget.decoration ?? const GymTrackerInputDecoration());
    return FocusableActionDetector(
      focusNode: _node,
      onShowFocusHighlight: (value) {
        _isFocused = value;
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(onInvoke: (intent) {
          _openDialog();
          return null;
        }),
        NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: (intent) {
          logger.d("Next focus");
          FocusManager.instance.primaryFocus?.nextFocus();
        }),
        PreviousFocusIntent:
            CallbackAction<PreviousFocusIntent>(onInvoke: (intent) {
          logger.d("Previous focus");
          FocusManager.instance.primaryFocus?.previousFocus();
        }),
      },
      child: TextFormField(
        focusNode: _noTabNode,
        statesController: _widgetStatesController,
        decoration: decoration,
        controller: TextEditingController(
          text: DateFormat.yMEd(context.locale.languageCode)
              .add_jm()
              .format(widget.date),
        ),
        readOnly: true,
        canRequestFocus: false,
        onTap: _openDialog,
        validator: widget.validator != null ? _validator : null,
      ),
    );
  }

  _openDialog() async {
    logger.d("Opening Date picker");
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 1),
    );
    if (date != null) {
      logger.d("Opening Time picker");
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
