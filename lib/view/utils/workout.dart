import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/parent_viewer.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/utils/cardio_timer.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';

class WorkoutExerciseEditor extends StatefulWidget {
  final Exercise exercise;
  final ExerciseIndex index;
  final bool isCreating;
  final EditorCallbacks callbacks;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool isInSuperset;
  final bool createDivider;

  const WorkoutExerciseEditor({
    required this.exercise,
    required this.index,
    required this.isCreating,
    required this.callbacks,
    required this.weightUnit,
    required this.distanceUnit,
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
  late final notesController = quillControllerFromText(widget.exercise.notes);

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      viewportBuilder: (BuildContext context, _) {
        var notesTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontStyle: widget.exercise.notes.isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
              fontWeight: widget.exercise.notes.isEmpty
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: widget.exercise.notes.isEmpty ? 15 : null,
            );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (widget.isCreating) ...[
                      DragHandle(index: widget.index.exerciseIndex),
                    ] else
                      ExerciseParentViewGesture(
                        exercise: widget.exercise,
                        child: ExerciseIcon(exercise: widget.exercise),
                      ),
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
                            onTap: () {
                              widget.callbacks.onExerciseReorder(
                                widget.index.supersetIndex,
                              );
                            },
                            child: ListTile(
                              leading: const Icon(GymTrackerIcons.reorder),
                              title: Text('ongoingWorkout.exercises.reorder'.t),
                            ),
                          ),
                        ],
                        PopupMenuItem(
                          onTap: () {
                            widget.callbacks.onExerciseReplace(widget.index);
                          },
                          child: ListTile(
                            leading: const Icon(GymTrackerIcons.replace),
                            title: Text('ongoingWorkout.exercises.replace'.t),
                          ),
                        ),
                        if (widget.index.supersetIndex == null)
                          PopupMenuItem(
                            onTap: () {
                              widget.callbacks.onGroupExercisesIntoSuperset(
                                  widget.index.exerciseIndex);
                            },
                            child: ListTile(
                              leading:
                                  const Icon(GymTrackerIcons.add_to_superset),
                              title: Text(
                                  'ongoingWorkout.exercises.addToSuperset'.t),
                            ),
                          ),
                        if (!widget.isCreating &&
                            CardioTimerScreen.supportsTimer(
                                widget.exercise)) ...[
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            onTap: () {
                              Go.to(() => CardioTimerScreen.fromExercise(
                                  widget.exercise));
                            },
                            child: ListTile(
                              leading: const Icon(GymTrackerIcons.cardio_timer),
                              title: Text(
                                  'ongoingWorkout.exercises.startCardioTimer'
                                      .t),
                            ),
                          ),
                        ],
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          onTap: () {
                            widget.callbacks.onExerciseRemove(widget.index);
                          },
                          child: ListTile(
                            textColor: Theme.of(context).colorScheme.error,
                            iconColor: Theme.of(context).colorScheme.error,
                            leading: const Icon(GymTrackerIcons.delete),
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
                leading: const Icon(GymTrackerIcons.notes),
                title: widget.exercise.notes.asQuillDocument().isEmpty()
                    ? Text(
                        "exercise.editor.fields.notes.label".t,
                        style: notesTextStyle,
                      )
                    : MaybeRichText(
                        text: widget.exercise.notes,
                        style: notesTextStyle,
                      ),
                trailing: const Icon(GymTrackerIcons.edit),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return GTRichTextEditDialog(
                        controller: notesController,
                        onNotesChange: (text) {
                          widget.callbacks
                              .onExerciseNotesChange(widget.index, text);
                          Get.back();
                        },
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
                    decoration: GymTrackerInputDecoration(
                      labelText: "exercise.fields.restTime".t,
                    ),
                    onChangedTime: (value) => widget.callbacks
                        .onExerciseChangeRestTime(
                            widget.index, value ?? Duration.zero),
                  ),
                ),
              for (int i = 0; i < widget.exercise.sets.length; i++)
                WorkoutExerciseSetEditor(
                  key: ValueKey(widget.exercise.sets[i].id),
                  set: widget.exercise.sets[i],
                  exercise: widget.exercise,
                  onDelete: () => widget.callbacks.onSetRemove(widget.index, i),
                  alt: i % 2 == 0,
                  isCreating: widget.isCreating,
                  onSetSelectKind: (val) =>
                      widget.callbacks.onSetSelectKind(widget.index, i, val),
                  onSetSetDone: (val) => widget.callbacks.onSetSetDone(
                    widget.index,
                    i,
                    val,
                  ),
                  onSetValueChange: (set) => widget.callbacks.onSetValueChange(
                    widget.index,
                    i,
                    set,
                  ),
                  weightUnit: widget.weightUnit,
                  distanceUnit: widget.distanceUnit,
                ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => widget.callbacks.onSetCreate(widget.index),
                child: Text('exercise.actions.addSet'.t),
              ),
              if (kDebugMode) ...[
                Text(
                  "id: ${widget.exercise.id}",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "parent: ${widget.exercise.parentID}",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "supersede: ${widget.exercise.supersedesID}",
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.createDivider) ...[
                const SizedBox(height: 8),
                const Divider(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class WorkoutExerciseSetEditor extends StatefulWidget {
  final Exercise exercise;
  final GTSet set;
  final bool alt;
  final bool isCreating;
  final VoidCallback onDelete;
  final void Function(GTSetKind) onSetSelectKind;
  final void Function(bool) onSetSetDone;
  final void Function(GTSet) onSetValueChange;
  final Weights weightUnit;
  final Distance distanceUnit;

  const WorkoutExerciseSetEditor({
    required this.exercise,
    required this.set,
    required this.alt,
    required this.isCreating,
    required this.onSetSelectKind,
    required this.onSetSetDone,
    required this.onDelete,
    required this.onSetValueChange,
    required this.weightUnit,
    required this.distanceUnit,
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
      TextEditingController(text: (widget.set.reps ?? 0).toString());
  late var distanceController =
      TextEditingController(text: stringifyDouble(widget.set.distance ?? 0));

  final _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _weightFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _weightFocusNode.dispose();
    super.dispose();
  }

  TextField get weightField => TextField(
        focusNode: _weightFocusNode,
        controller: weightController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
        ],
        decoration: GymTrackerInputDecoration(
          labelText: "exercise.fields.weight".t,
          suffix: Text("units.${widget.weightUnit.name}".t),
          suffixIcon: _weightFocusNode.hasFocus
              ? IconButton(
                  icon: const Icon(GymTrackerIcons.weight_calculator),
                  onPressed: () {
                    Go.toDialog(
                      () => WeightCalculator(
                        startingWeight: weightController.text.tryParseDouble(),
                        weightUnit: widget.weightUnit,
                      ),
                    );
                  },
                )
              : null,
        ),
        onChanged: (value) {
          final newSet = widget.set.copyWith(
            weight: value.isEmpty ? null : value.tryParseDouble(),
          );
          widget.onSetValueChange(newSet);
        },
      );
  Widget get timeField => TimeInputField(
        timerInteractive: () {
          if (widget.isCreating) return false;
          return !widget.set.done;
        }(),
        setID: widget.set.id,
        controller: timeController,
        decoration: GymTrackerInputDecoration(
          labelText: "exercise.fields.time".t,
        ),
        onChanged: (value) {
          final newSet = widget.set.copyWith(
            time: value.isEmpty ? null : TimeInputField.parseDuration(value),
          );
          widget.onSetValueChange(newSet);
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
        decoration: GymTrackerInputDecoration(
          labelText: "exercise.fields.reps".t,
        ),
        onChanged: (value) {
          final newSet = widget.set.copyWith(
            reps: value.isEmpty ? null : int.tryParse(value),
          );
          widget.onSetValueChange(newSet);
        },
      );
  TextField get distanceField => TextField(
        controller: distanceController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
        ],
        decoration: GymTrackerInputDecoration(
          labelText: "exercise.fields.distance".t,
          suffix: Text("units.${widget.distanceUnit.name}".t),
        ),
        onChanged: (value) {
          final newSet = widget.set.copyWith(
            distance: value.isEmpty ? null : value.tryParseDouble(),
          );
          widget.onSetValueChange(newSet);
        },
      );

  List<Widget> get fields => [
        if ([GTSetParameters.repsWeight, GTSetParameters.timeWeight]
            .contains(widget.set.parameters))
          weightField,
        if ([
          GTSetParameters.timeWeight,
          GTSetParameters.time,
        ].contains(widget.set.parameters))
          timeField,
        if ([GTSetParameters.repsWeight, GTSetParameters.freeBodyReps]
            .contains(widget.set.parameters))
          repsField,
        if ([GTSetParameters.distance].contains(widget.set.parameters))
          distanceField,
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final defaultColor = widget.alt
        ? scheme.surface.withOpacity(0)
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
            icon: GymTrackerIcons.delete_forever,
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
                  itemBuilder: (context) => <PopupMenuEntry<GTSetKind>>[
                    for (final kind in GTSetKind.values)
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
                                  for (final kind in GTSetKind.values)
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
