import 'package:gymtracker/view/utils/drag_handle.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';

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
  final bool isInSuperset;
  final bool createDivider;

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
    this.isInSuperset = false,
    this.createDivider = false,
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
    return Scrollable(
      viewportBuilder: (BuildContext context, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (widget.isCreating) ...[
                    DragHandle(index: widget.index),
                  ] else
                    ExerciseIcon(exercise: widget.exercise),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: widget.exercise.displayName),
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
                            title: Text('ongoingWorkout.exercises.reorder'.t),
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        onTap: widget.onReplace,
                        child: ListTile(
                          leading: const Icon(Icons.refresh),
                          title: Text('ongoingWorkout.exercises.replace'.t),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        onTap: widget.onRemove,
                        child: ListTile(
                          textColor: Theme.of(context).colorScheme.error,
                          iconColor: Theme.of(context).colorScheme.error,
                          leading: const Icon(Icons.delete),
                          title: Text('ongoingWorkout.exercises.remove'.t),
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
                    ? "exercise.editor.fields.notes.label".t
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
                      title: Text('exercise.editor.fields.notes.label'.t),
                      content: TextField(
                        controller: notesController,
                        autofocus: true,
                        minLines: 4,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "exercise.editor.fields.notes.label".t,
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
            if (!widget.isInSuperset)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TimeInputField(
                  controller: timeController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    labelText: "exercise.fields.restTime".t,
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
              child: Text('exercise.actions.addSet'.t),
            ),
            if (widget.createDivider) ...[
              const SizedBox(height: 8),
              const Divider(),
            ],
          ],
        ),
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
          labelText: "exercise.fields.weight".t,
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
          labelText: "exercise.fields.time".t,
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
          labelText: "exercise.fields.reps".t,
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
          labelText: "exercise.fields.distance".t,
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
        ? scheme.background.withOpacity(0)
        : ElevationOverlay.applySurfaceTint(
            scheme.surface,
            scheme.surfaceTint,
            0.7,
          );
    return Slidable(
      key: ValueKey("${widget.exercise.id}${widget.set.id}"),
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
            label: 'actions.remove'.t,
          ),
        ],
      ),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
        tween: ColorTween(
          begin: defaultColor,
          end: widget.set.done && !widget.isCreating
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
                  tooltip: "set.kind".t,
                  itemBuilder: (context) => <PopupMenuEntry<SetKind>>[
                    for (final kind in SetKind.values)
                      PopupMenuItem(
                        value: kind,
                        onTap: () => widget.onSetSelectKind(kind),
                        child: ListTile(
                          leading: buildSetType(
                            context,
                            kind,
                            set: widget.set,
                            allSets: widget.exercise.sets,
                          ),
                          title: Text('set.kindLong.${kind.name}'.t),
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('set.kinds.help.title'.t),
                              scrollable: true,
                              content: Column(
                                children: [
                                  for (final kind in SetKind.values)
                                    ListTile(
                                      leading: buildSetType(
                                        context,
                                        kind,
                                        set: widget.set,
                                        allSets: widget.exercise.sets,
                                        fontSize: 16,
                                      ),
                                      title:
                                          Text('set.kindLong.${kind.name}'.t),
                                      subtitle:
                                          Text('set.kinds.help.${kind.name}'.t),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(MaterialLocalizations.of(context)
                                      .okButtonLabel),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ListTile(
                        leading: Text(
                          "?",
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text('set.kinds.help.title'.t),
                      ),
                    ),
                  ],
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
