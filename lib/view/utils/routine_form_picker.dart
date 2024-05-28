import 'package:flutter/material.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/routines.dart';

class RoutineFormPicker extends ControlledWidget<RoutinesController> {
  final Workout? routine;
  final ValueChanged<Workout?> onChanged;
  final InputDecoration decoration;

  const RoutineFormPicker({
    super.key,
    required this.routine,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      onTap: _callback,
      child: InputDecorator(
        decoration: decoration.copyWith(
          contentPadding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
        ),
        child: _buildBody(),
      ),
    );
  }

  _callback() {
    controller.pickRoutine(
      onPick: (routine) {
        onChanged(routine);
      },
      allowNone: true,
    );
  }

  Widget _buildBody() {
    if (routine == null) {
      return ListTile(
        title: Text(
          "routineFormPicker.fields.routine.options.none".t,
        ),
        trailing: const Icon(GymTrackerIcons.lt_chevron),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        mouseCursor: MouseCursor.defer,
      );
    }

    return TerseRoutineListTile(routine: routine);
  }
}
