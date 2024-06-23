import 'package:flutter/material.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class RoutineFormPicker extends StatefulWidget {
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
  State<RoutineFormPicker> createState() => _RoutineFormPickerState();
}

class _RoutineFormPickerState
    extends ControlledState<RoutineFormPicker, RoutinesController> {
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
    controller.pickRoutine(
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
        title: Text(
          "routineFormPicker.fields.routine.options.none".t,
        ),
        trailing: const Icon(GymTrackerIcons.lt_chevron),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        mouseCursor: MouseCursor.defer,
      );
    }

    return TerseRoutineListTile(routine: widget.routine);
  }
}
