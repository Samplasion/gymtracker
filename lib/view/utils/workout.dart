import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../model/exercise.dart';
import '../../model/set.dart';
import '../../utils/extensions.dart';
import '../../utils/sets.dart';
import '../../utils/utils.dart';
import 'exercise.dart';
import 'time.dart';

class WorkoutExerciseEditor extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final bool isCreating;
  final VoidCallback onReorder;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final void Function(Duration time) onChangeRestTime;
  final VoidCallback onSetCreate;
  final void Function(int index) onSetRemove;
  final void Function(ExSet set, SetKind kind) onSetSelectKind;
  final void Function(Exercise exercise, ExSet set, bool isDone) onSetSetDone;
  final VoidCallback onSetValueChange;
  final void Function(Exercise exercise, String notes) onNotesChange;

  const WorkoutExerciseEditor({
    required this.exercise,
    required this.index,
    required this.isCreating,
    required this.onReorder,
    required this.onReplace,
    required this.onRemove,
    required this.onChangeRestTime,
    required this.onSetCreate,
    required this.onSetRemove,
    required this.onSetSelectKind,
    required this.onSetSetDone,
    required this.onSetValueChange,
    required this.onNotesChange,
    super.key,
  });

  @override
  State<WorkoutExerciseEditor> createState() => _WorkoutExerciseEditorState();
}

class _WorkoutExerciseEditorState extends State<WorkoutExerciseEditor> {
  late final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(widget.exercise.restTime),
  );
  late final notesController =
      TextEditingController(text: widget.exercise.notes);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (widget.isCreating) ...[
                  if (Platform.isAndroid || Platform.isIOS)
                    ReorderableDelayedDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_handle),
                    )
                  else
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_handle),
                    ),
                ] else
                  ExerciseIcon(exercise: widget.exercise),
                const SizedBox(width: 16),
                Expanded(
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: widget.exercise.name),
                        if (widget.exercise.isCustom) ...[
                          const TextSpan(text: " "),
                          const WidgetSpan(
                            baseline: TextBaseline.ideographic,
                            alignment: PlaceholderAlignment.middle,
                            child: CustomExerciseBadge(),
                          ),
                        ],
                      ]),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                    if (!widget.isCreating) ...[
                      PopupMenuItem(
                        onTap: widget.onReorder,
                        child: ListTile(
                          leading: const Icon(Icons.compare_arrows),
                          title: Text('ongoingWorkout.exercises.reorder'.tr),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: widget.onReplace,
                        child: ListTile(
                          leading: const Icon(Icons.refresh),
                          title: Text('ongoingWorkout.exercises.replace'.tr),
                        ),
                      ),
                      const PopupMenuDivider(),
                    ],
                    PopupMenuItem(
                      onTap: widget.onRemove,
                      child: ListTile(
                        textColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                        leading: const Icon(Icons.delete),
                        title: Text('ongoingWorkout.exercises.remove'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(
              widget.exercise.notes.isEmpty
                  ? "exercise.editor.fields.notes.label".tr
                  : widget.exercise.notes,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontStyle: widget.exercise.notes.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: widget.exercise.notes.isEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: widget.exercise.notes.isEmpty ? 15 : null,
                  ),
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(24),
                    title: Text('exercise.editor.fields.notes.label'.tr),
                    content: TextField(
                      controller: notesController,
                      autofocus: true,
                      minLines: 4,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "exercise.editor.fields.notes.label".tr,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(MaterialLocalizations.of(context)
                            .cancelButtonLabel),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onNotesChange(
                              widget.exercise, notesController.text.trim());
                          Navigator.pop(context);
                        },
                        child: Text(
                            MaterialLocalizations.of(context).okButtonLabel),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TimeInputField(
              controller: timeController,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                labelText: "exercise.fields.restTime".tr,
              ),
              onChangedTime: (value) =>
                  widget.onChangeRestTime(value ?? Duration.zero),
            ),
          ),
          for (int i = 0; i < widget.exercise.sets.length; i++)
            WorkoutExerciseSetEditor(
              key: ValueKey(widget.exercise.sets[i].id),
              set: widget.exercise.sets[i],
              exercise: widget.exercise,
              onDelete: () => widget.onSetRemove(i),
              alt: i % 2 == 0,
              isCreating: widget.isCreating,
              onSetSelectKind: (val) =>
                  widget.onSetSelectKind(widget.exercise.sets[i], val),
              onSetSetDone: (val) => widget.onSetSetDone(
                widget.exercise,
                widget.exercise.sets[i],
                val,
              ),
              onSetValueChange: widget.onSetValueChange,
            ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: widget.onSetCreate,
            child: Text('exercise.actions.addSet'.tr),
          ),
        ],
      ),
    );
  }
}

class WorkoutExerciseSetEditor extends StatefulWidget {
  final Exercise exercise;
  final ExSet set;
  final bool alt;
  final bool isCreating;
  final VoidCallback onDelete;
  final void Function(SetKind) onSetSelectKind;
  final void Function(bool) onSetSetDone;
  final VoidCallback onSetValueChange;

  const WorkoutExerciseSetEditor({
    required this.exercise,
    required this.set,
    required this.alt,
    required this.isCreating,
    required this.onSetSelectKind,
    required this.onSetSetDone,
    required this.onDelete,
    required this.onSetValueChange,
    super.key,
  });

  @override
  State<WorkoutExerciseSetEditor> createState() =>
      _WorkoutExerciseSetEditorState();
}

class _WorkoutExerciseSetEditorState extends State<WorkoutExerciseSetEditor> {
  late var weightController =
      TextEditingController(text: stringifyDouble(widget.set.weight ?? 0));
  late var timeController = TextEditingController(
      text: widget.set.time == null
          ? "0"
          : TimeInputField.encodeDuration(widget.set.time!));
  late var repsController =
      TextEditingController(text: widget.set.reps.toString());
  late var distanceController =
      TextEditingController(text: stringifyDouble(widget.set.distance ?? 0));

  TextField get weightField => TextField(
        controller: weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
        ],
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: "exercise.fields.weight".tr,
        ),
        onChanged: (value) {
          widget.onSetValueChange();
          if (value.isEmpty) {
            widget.set.weight = null;
          } else {
            widget.set.weight = value.tryParseDouble();
          }
        },
      );
  Widget get timeField => TimeInputField(
        timerInteractive: !widget.isCreating,
        controller: timeController,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: "exercise.fields.time".tr,
        ),
        onChanged: (value) {
          widget.onSetValueChange();
          if (value.isEmpty) {
            widget.set.time = null;
          } else {
            widget.set.time = TimeInputField.parseDuration(value);
          }
        },
      );
  TextField get repsField => TextField(
        controller: repsController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: "exercise.fields.reps".tr,
        ),
        onChanged: (value) {
          widget.onSetValueChange();
          if (value.isEmpty) {
            widget.set.reps = null;
          } else {
            widget.set.reps = int.tryParse(value);
          }
        },
      );
  TextField get distanceField => TextField(
        controller: weightController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
        ],
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: "exercise.fields.distance".tr,
        ),
        onChanged: (value) {
          widget.onSetValueChange();
          if (value.isEmpty) {
            widget.set.distance = null;
          } else {
            widget.set.distance = double.tryParse(value);
          }
        },
      );

  List<Widget> get fields => [
        if ([SetParameters.repsWeight, SetParameters.timeWeight]
            .contains(widget.set.parameters))
          weightField,
        if ([
          SetParameters.timeWeight,
          SetParameters.time,
        ].contains(widget.set.parameters))
          timeField,
        if ([SetParameters.repsWeight, SetParameters.freeBodyReps]
            .contains(widget.set.parameters))
          repsField,
        if ([SetParameters.distance].contains(widget.set.parameters))
          distanceField,
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final defaultColor = widget.alt
        ? scheme.background
        : ElevationOverlay.applySurfaceTint(
            scheme.surface,
            scheme.surfaceTint,
            0.7,
          );
    return Slidable(
      key: ValueKey(widget.set.id),
      endActionPane: ActionPane(
        extentRatio: 1 / 3,
        dragDismissible: false,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            icon: Icons.delete_forever_rounded,
            label: 'actions.remove'.tr,
          ),
        ],
      ),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
        tween: ColorTween(
          begin: defaultColor,
          end: widget.set.done
              ? scheme.tertiaryContainer.withOpacity(0.5)
              : defaultColor,
        ),
        builder: (context, value, _) {
          return Container(
            color: value,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                PopupMenuButton(
                  icon: buildSetType(
                    context,
                    widget.set.kind,
                    set: widget.set,
                    allSets: widget.exercise.sets,
                  ),
                  tooltip: "set.kind".tr,
                  itemBuilder: (context) => <PopupMenuEntry<SetKind>>[
                    PopupMenuItem(
                      value: SetKind.normal,
                      child: ListTile(
                        leading: buildSetType(
                          context,
                          SetKind.normal,
                          set: widget.set,
                          allSets: widget.exercise.sets,
                        ),
                        title: Text('set.kindLong.normal'.tr),
                      ),
                    ),
                    PopupMenuItem(
                      value: SetKind.warmUp,
                      child: ListTile(
                        leading: buildSetType(
                          context,
                          SetKind.warmUp,
                          set: widget.set,
                          allSets: widget.exercise.sets,
                        ),
                        title: Text('set.kindLong.warmUp'.tr),
                      ),
                    ),
                    PopupMenuItem(
                      value: SetKind.drop,
                      child: ListTile(
                        leading: buildSetType(
                          context,
                          SetKind.drop,
                          set: widget.set,
                          allSets: widget.exercise.sets,
                        ),
                        title: Text('set.kindLong.drop'.tr),
                      ),
                    ),
                  ],
                  onSelected: widget.onSetSelectKind,
                ),
                const SizedBox(width: 8),
                for (int i = 0; i < fields.length; i++) ...[
                  if (i != 0) const SizedBox(width: 8),
                  Flexible(child: fields[i])
                ],
                const SizedBox(width: 8),
                if (!widget.isCreating) ...[
                  ValueBuilder<bool?>(
                    builder: (_, update) => Checkbox(
                      value: widget.set.done,
                      onChanged: update,
                      activeColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    onUpdate: (isDone) {
                      widget.onSetSetDone(isDone ?? widget.set.done);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
