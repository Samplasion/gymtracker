import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/view/actions/routines.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class RoutineFormPicker extends ConsumerStatefulWidget {
  final Workout? routine;
  final ValueChanged<Workout?> onChanged;
  final InputDecoration decoration;
  final double borderRadius;

  const RoutineFormPicker({
    super.key,
    required this.routine,
    required this.onChanged,
    required this.decoration,
    this.borderRadius = kGymTrackerInputBorderRadius,
  });

  @override
  ConsumerState<RoutineFormPicker> createState() => _RoutineFormPickerState();
}

class _RoutineFormPickerState extends ConsumerState<RoutineFormPicker> {
  final _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_focusHandler);
  }

  @override
  dispose() {
    _node.removeListener(_focusHandler);
    _node.dispose();
    super.dispose();
  }

  _focusHandler() {
    logger.d("Focus changed to ${_node.hasFocus}");
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      onTap: _callback,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InputDecorator(
        isFocused: _node.hasFocus,
        decoration: widget.decoration.copyWith(
          contentPadding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
        ),
        child: _buildBody(),
      ),
    );
  }

  _callback() {
    ref
        .read(routinesControllerProvider)
        .pickRoutine(
          onPick: (routine) {
            widget.onChanged(routine);
          },
          allowNone: true,
        );
  }

  Widget _buildBody() {
    if (widget.routine == null) {
      return ListTile(
        focusNode: _node,
        title: Text(context.t.routineFormPicker.fields.routine.options.none),
        trailing: const Icon(GTIcons.lt_chevron),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        mouseCursor: MouseCursor.defer,
      );
    }

    return TerseRoutineListTile(routine: widget.routine);
  }
}
