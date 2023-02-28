import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:get/get.dart';

import 'animated_selectable.dart';

class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final String? Function(Duration?)? validator;
  final void Function(Duration?)? onChangedTime;
  final bool timerInteractive;

  const TimeInputField({
    required this.controller,
    this.decoration,
    this.onChanged,
    this.onChangedTime,
    this.validator,
    this.timerInteractive = false,
    super.key,
  });

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

class _TimeInputFieldState extends State<TimeInputField> {
  late String numericalValue = _toTimeString(widget.controller.text);
  final node = FocusNode();

  Timer? timer;

  void _onTimerTick(Timer timer) {
    final parsed = TimeInputField.parseDuration(widget.controller.text);
    final encoded = TimeInputField.encodeDuration(Duration(
      seconds: 1,
      microseconds: parsed.inMicroseconds,
    ));
    widget.onChanged?.call(encoded);
    setState(() => widget.controller.text = encoded);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.text =
        _normalize(widget.controller.text.replaceAll(":", ""));
  }

  _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  _endTimer() {
    timer?.cancel();
  }

  _toggleTimer() {
    if (timer?.isActive ?? false) {
      _endTimer();
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _endTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: node,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        suffixIcon: () {
          if (widget.timerInteractive) {
            var isActive = timer?.isActive ?? false;
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
          }
        }(),
      ),
      inputFormatters: <TextInputFormatter>[TimeTextInputFormatter()],
      onChanged: (value) {
        value = value.replaceAll(":", "");
        setState(() => numericalValue = int.parse(value).toString());
        widget.onChanged?.call(value);
        widget.onChangedTime
            ?.call(TimeInputField.parseDuration(widget.controller.text));
      },
      onEditingComplete: () => normalizeField(),
      onTapOutside: (_) {
        normalizeField();
        node.unfocus();
      },
      style: TextStyle(
        color: () {
          if (timer?.isActive ?? false) {
            return Theme.of(context).colorScheme.primary;
          }
        }(),
      ),
      readOnly: timer?.isActive ?? false,
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
