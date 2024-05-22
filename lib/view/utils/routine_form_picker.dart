import 'package:flutter/material.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/controlled.dart';

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

  ListTile _buildBody() {
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

    Icon icon;
    String text;

    if (routine!.folder != null) {
      icon = const Icon(GymTrackerIcons.folder_closed, size: 20);
      text = routine!.folder!.name;
    } else {
      icon = const Icon(GymTrackerIcons.folder_root, size: 20);
      text = "routineFormPicker.fields.routine.options.root".t;
    }

    return ListTile(
      title: Text(
        routine!.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text.rich(
        TextSpan(children: [
          WidgetSpan(child: icon, alignment: PlaceholderAlignment.middle),
          const TextSpan(text: " "),
          TextSpan(text: text),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(GymTrackerIcons.lt_chevron),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.standard,
      mouseCursor: MouseCursor.defer,
    );
  }
}
