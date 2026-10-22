import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/workout.dart';

class ExerciseSetView extends ConsumerStatefulWidget {
  final GTSet set;
  final Exercise exercise;
  final bool isConcrete;
  final bool alt;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool draggable;
  final int? index;
  final bool showRPE;

  const ExerciseSetView({
    required this.set,
    required this.exercise,
    required this.isConcrete,
    required this.alt,
    required this.weightUnit,
    required this.distanceUnit,
    this.showRPE = false,
    this.draggable = false,
    this.index,
    super.key,
  }) : assert(
         draggable ? index != null : true,
         "index must be provided when draggable is true",
       );

  @override
  ConsumerState<ExerciseSetView> createState() => _ExerciseSetViewState();
}

class _ExerciseSetViewState extends ConsumerState<ExerciseSetView> {
  SettingsController get settingsController =>
      ref.watch(settingsControllerProvider);
  List<Widget> get fields => [
    if ([
      GTSetParameters.repsWeight,
      GTSetParameters.timeWeight,
    ].contains(widget.set.parameters))
      Expanded(
        child: Text(
          Weights.convert(
            value: widget.set.weight!,
            from: widget.weightUnit,
            to: settingsController.weightUnit,
          ).getUserFacingWeight(context.t, settingsController.weightUnit),
        ),
      ),
    if ([
      GTSetParameters.timeWeight,
      GTSetParameters.time,
    ].contains(widget.set.parameters))
      Expanded(
        child: Text(
          context.t.exerciseList.fields.time(
            time:
                "${(widget.set.time!.inSeconds ~/ 60).toString().padLeft(2, "0")}:${(widget.set.time!.inSeconds % 60).toString().padLeft(2, "0")}",
          ),
        ),
      ),
    if ([
      GTSetParameters.repsWeight,
      GTSetParameters.freeBodyReps,
    ].contains(widget.set.parameters))
      Expanded(
        child: Text(
          context.t.exerciseList.fields.reps(n: widget.set.reps ?? 0),
        ),
      ),
    if ([GTSetParameters.distance].contains(widget.set.parameters))
      Expanded(
        child: Text(
          Distance.convert(
            value: widget.set.distance!,
            from: widget.distanceUnit,
            to: settingsController.distanceUnit,
          ).getUserFacingDistance(context.t, settingsController.distanceUnit),
        ),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colorScheme = Theme.of(context).colorScheme;
    final container = Container(
      color: widget.alt
          ? scheme.surface.withAlpha((0 * 255).round())
          : ElevationOverlay.applySurfaceTint(
              scheme.surface,
              scheme.surfaceTint,
              0.7,
            ),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        spacing: 8,
        children: [
          IconButton(
            icon: buildSetType(
              context,
              widget.set.kind,
              set: widget.set,
              allSets: widget.exercise.sets,
            ),
            onPressed: null,
          ),
          for (int i = 0; i < fields.length; i++) ...[fields[i]],
          if (widget.showRPE) RPECompactColumn(rpe: widget.set.rpe),
          if (widget.isConcrete) ...[
            if (widget.set.done)
              Icon(GTIcons.checkbox_on, color: colorScheme.tertiary)
            else
              Icon(GTIcons.checkbox_off, color: colorScheme.onSurfaceVariant),
          ],
          if (widget.draggable) DragHandle(index: widget.index!),
        ],
      ),
    );

    if (widget.draggable)
      return DraggableChild(index: widget.index!, child: container);

    return container;
  }
}
