import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/utils/animated_selectable.dart';

class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final String? Function(Duration?)? validator;
  final void Function(Duration?)? onChangedTime;
  final bool timerInteractive;
  final String? setID;

  const TimeInputField({
    required this.controller,
    this.decoration,
    this.onChanged,
    this.onChangedTime,
    this.validator,
    this.timerInteractive = false,
    this.setID,
    super.key,
  }) : assert(timerInteractive ? (setID != null) : true,
            "If timerInteractive is true, setID must be provided");

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();

  static Duration parseDuration(String value) {
    final parts = _toTimeString(value).split(":");
    final minutes = int.parse(parts.first);
    final seconds = int.parse(parts.last);
    return Duration(minutes: minutes, seconds: seconds);
  }

  static String encodeDuration(Duration duration) {
    final minutes = (duration.inMinutes).toString().padLeft(2, "0");
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }
}

class _TimeInputFieldState
    extends ControlledState<TimeInputField, StopwatchController> {
  late String numericalValue = _toTimeString(widget.controller.text);
  final node = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.text =
        _normalize(widget.controller.text.replaceAll(":", ""));
    if (widget.timerInteractive && controller.isRunning(widget.setID!)) {
      controller.updateBinding(widget.setID!, _onTick);
    }
  }

  _startTimer() {
    controller.addStopwatch(TimeFieldStopwatch(
      onTick: _onTick,
      getCurrentTime: () => widget.controller.text,
      setID: widget.setID!,
    ));
  }

  void _onTick(timer, duration, encoded) {
    widget.onChanged?.call(encoded);
    if (mounted) setState(() => widget.controller.text = encoded);
  }

  _endTimer() {
    controller.removeStopwatch(widget.setID!);
  }

  bool get _isActive =>
      widget.timerInteractive && controller.isRunning(widget.setID!);

  _toggleTimer() {
    if (_isActive) {
      _endTimer();
    } else {
      _startTimer();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didUpdateWidget(TimeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.timerInteractive && !widget.timerInteractive) {
      if (controller.isRunning(widget.setID!)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _endTimer();
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextSelection? _oldSelection;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: node,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            )
          : const TextInputType.numberWithOptions(decimal: false),
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        suffixIcon: () {
          if (!widget.timerInteractive) return null;
          var isActive = _isActive;
          return SelectableAnimatedBuilder(
            isSelected: isActive,
            builder: (context, animation) => IconButton(
              icon: AnimatedIcon(
                progress: animation,
                icon: AnimatedIcons.play_pause,
              ),
              onPressed: () {
                setState(() {
                  _toggleTimer();
                });
              },
            ),
          );
        }(),
      ),
      inputFormatters: <TextInputFormatter>[TimeTextInputFormatter()],
      onChanged: (value) {
        if (_oldSelection != null) {
          if (_oldSelection?.baseOffset == value.length) {
            widget.controller.selection = _oldSelection!;
          }
        }
        value = value.replaceAll(":", "");
        setState(() => numericalValue = int.parse(value).toString());
        widget.onChanged?.call(value);
        widget.onChangedTime
            ?.call(TimeInputField.parseDuration(widget.controller.text));
        setState(() {
          _oldSelection = widget.controller.selection;
        });
      },
      onEditingComplete: () {
        normalizeField();
        node.unfocus();
      },
      onTapOutside: (_) {
        normalizeField();
        node.unfocus();
      },
      style: TextStyle(
        color: () {
          if (_isActive) {
            return Theme.of(context).colorScheme.primary;
          }
        }(),
      ),
      readOnly: _isActive,
      validator: widget.validator == null
          ? null
          : (string) {
              if (string != null) {
                return widget.validator!(TimeInputField.parseDuration(string));
              }
              return widget.validator!(null);
            },
    );
  }

  void normalizeField() {
    widget.controller.text = _normalize(widget.controller.text);
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  final RegExp _exp = RegExp(r'^[0-9:]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      TextSelection newSelection = newValue.selection;

      String value =
          int.parse(newValue.text.replaceAll(":", "").padLeft(1, "0"))
              .toString();
      final colonPosition = max(2, oldValue.text.length - 2);
      final colonOffset = newSelection.baseOffset >= colonPosition ? 1 : 0;
      if (oldValue.text.length < newValue.text.length) {
        // When typing
        newSelection = newSelection.copyWith(
          baseOffset: min(max(4, value.length),
                      newSelection.baseOffset + max(0, 4 - value.length))
                  .toInt() +
              colonOffset,
          extentOffset: min(max(4, value.length),
                      newSelection.extentOffset + max(0, 4 - value.length))
                  .toInt() +
              colonOffset,
        );
      } else if (value.length < 5) {
        // When erasing
        newSelection = oldValue.selection.copyWith(
          baseOffset: min(oldValue.selection.baseOffset, 5),
          extentOffset: min(oldValue.selection.baseOffset, 5),
        );
      }
      value = _toTimeString(value);

      return newValue.copyWith(
        text: value,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return oldValue;
  }
}

String _toTimeString(String value) {
  value = value.padLeft(4, "0");
  value =
      "${value.substring(0, value.length - 2)}:${value.substring(value.length - 2)}";
  return value;
}

String _normalize(String value) {
  final parts = _toTimeString(value).split(":");
  final minutes = int.parse(parts.first);
  final seconds = int.parse(parts.last);
  final duration = Duration(minutes: minutes, seconds: seconds);
  final raw =
      "${duration.inMinutes.toString().padLeft(2, "0")}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
  return raw.padLeft(5, "0");
}
