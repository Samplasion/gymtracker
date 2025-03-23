import 'package:flutter/material.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';

class ExerciseSetView extends StatelessWidget {
  final GTSet set;
  final Exercise exercise;
  final bool isConcrete;
  final bool alt;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool draggable;
  final int? index;

  const ExerciseSetView({
    required this.set,
    required this.exercise,
    required this.isConcrete,
    required this.alt,
    required this.weightUnit,
    required this.distanceUnit,
    this.draggable = false,
    this.index,
    super.key,
  }) : assert(draggable ? index != null : true,
            "index must be provided when draggable is true");

  List<Widget> get fields => [
        if ([GTSetParameters.repsWeight, GTSetParameters.timeWeight]
            .contains(set.parameters))
          Text(Weights.convert(
            value: set.weight!,
            from: weightUnit,
            to: settingsController.weightUnit.value,
          ).userFacingWeight),
        if ([
          GTSetParameters.timeWeight,
          GTSetParameters.time,
        ].contains(set.parameters))
          Text("exerciseList.fields.time".tParams({
            "time":
                "${(set.time!.inSeconds ~/ 60).toString().padLeft(2, "0")}:${(set.time!.inSeconds % 60).toString().padLeft(2, "0")}",
          })),
        if ([GTSetParameters.repsWeight, GTSetParameters.freeBodyReps]
            .contains(set.parameters))
          Text("exerciseList.fields.reps".plural(set.reps ?? 0)),
        if ([GTSetParameters.distance].contains(set.parameters))
          Text(Distance.convert(
            value: set.distance!,
            from: distanceUnit,
            to: settingsController.distanceUnit.value,
          ).userFacingDistance),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colorScheme = Theme.of(context).colorScheme;
    final container = Container(
      color: alt
          ? scheme.surface.withAlpha((0 * 255).round())
          : ElevationOverlay.applySurfaceTint(
              scheme.surface,
              scheme.surfaceTint,
              0.7,
            ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: buildSetType(
              context,
              set.kind,
              set: set,
              allSets: exercise.sets,
            ),
            onPressed: null,
          ),
          const SizedBox(width: 8),
          for (int i = 0; i < fields.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            Expanded(child: fields[i])
          ],
          const SizedBox(width: 8),
          if (isConcrete) ...[
            if (set.done)
              Icon(GTIcons.checkbox_on, color: colorScheme.tertiary)
            else
              Icon(GTIcons.checkbox_off, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          if (draggable) DragHandle(index: index!),
        ],
      ),
    );

    if (draggable) return DraggableChild(index: index!, child: container);

    return container;
  }
}
