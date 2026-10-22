import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/exercise_progression.dart';
import 'package:gymtracker/view/components/exercise_set_view.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/parent_viewer.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/utils/cardio_timer.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:intl/intl.dart';

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
    var notesTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: widget.exercise.notes.isEmpty ? 15 : null,
      color: widget.exercise.notes.isEmpty
          ? Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.75 * 255).round())
          : null,
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
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.exercise.getDisplayName(context.t),
                        ),
                        if (widget.exercise.isCustom) ...[
                          const TextSpan(text: " "),
                          const WidgetSpan(
                            baseline: TextBaseline.ideographic,
                            alignment: PlaceholderAlignment.middle,
                            child: CustomExerciseBadge(),
                          ),
                        ],
                      ],
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                          leading: const Icon(GTIcons.reorder),
                          title: Text(
                            context.t.ongoingWorkout.exercises.reorder,
                          ),
                        ),
                      ),
                    ],
                    PopupMenuItem(
                      onTap: () {
                        widget.callbacks.onExerciseReplace(widget.index);
                      },
                      child: ListTile(
                        leading: const Icon(GTIcons.replace),
                        title: Text(context.t.ongoingWorkout.exercises.replace),
                      ),
                    ),
                    if (widget.index.supersetIndex == null)
                      PopupMenuItem(
                        onTap: () {
                          widget.callbacks.onGroupExercisesIntoSuperset(
                            widget.index.exerciseIndex,
                          );
                        },
                        child: ListTile(
                          leading: const Icon(GTIcons.add_to_superset),
                          title: Text(
                            context.t.ongoingWorkout.exercises.addToSuperset,
                          ),
                        ),
                      ),
                    if (!widget.exercise.parameters.isSetless ||
                        !widget.isCreating)
                      const PopupMenuDivider(),
                    if (!widget.exercise.parameters.isSetless)
                      PopupMenuItem(
                        enabled: widget.exercise.sets.isNotEmpty,
                        onTap: widget.exercise.sets.isEmpty
                            ? null
                            : () async {
                                final newIndices = await Go.toDialog<List<int>>(
                                  () => _WorkoutReorderSetsDialog(
                                    exercise: widget.exercise,
                                    sets: widget.exercise.sets,
                                    weightUnit: widget.weightUnit,
                                    distanceUnit: widget.distanceUnit,
                                    isConcrete: !widget.isCreating,
                                  ),
                                );
                                if (newIndices != null) {
                                  widget.callbacks.onExerciseSetReorder(
                                    widget.index,
                                    newIndices,
                                  );
                                }
                              },
                        child: ListTile(
                          leading: const Icon(GTIcons.reorder),
                          title: Text(
                            context.t.ongoingWorkout.exercises.reorderSets,
                          ),
                          enabled: widget.exercise.sets.isNotEmpty,
                        ),
                      ),
                    if (!widget.isCreating) ...[
                      if (CardioTimerScreen.supportsTimer(widget.exercise)) ...[
                        PopupMenuItem(
                          onTap: () {
                            Go.to(
                              () => CardioTimerScreen.fromExercise(
                                widget.exercise,
                              ),
                            );
                          },
                          child: ListTile(
                            leading: const Icon(GTIcons.cardio_timer),
                            title: Text(
                              context
                                  .t
                                  .ongoingWorkout
                                  .exercises
                                  .startCardioTimer,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      onTap: () {
                        widget.callbacks.onExerciseRemove(widget.index);
                      },
                      child: ListTile(
                        textColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                        leading: const Icon(GTIcons.delete),
                        title: Text(context.t.ongoingWorkout.exercises.remove),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (ExerciseBadgeRow.shouldShow(widget.exercise)) ...[
            const SizedBox(height: 8),
            ExerciseBadgeRow(exercise: widget.exercise),
          ],
          const SizedBox(height: 8),
          ListTile(
            titleAlignment: ListTileTitleAlignment.titleHeight,
            leading: const Icon(GTIcons.notes),
            title: widget.exercise.notes.asQuillDocument().isEmpty()
                ? Text(
                    context.t.exercise.editor.fields.notes.tapToEdit,
                    style: notesTextStyle,
                  )
                : MaybeRichText(
                    text: widget.exercise.notes,
                    style: notesTextStyle,
                  ),
            trailing: const Icon(GTIcons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return GTRichTextEditDialog(
                    controller: notesController,
                    onNotesChange: (text) {
                      widget.callbacks.onExerciseNotesChange(
                        widget.index,
                        text,
                      );
                      Go.back();
                    },
                  );
                },
              );
            },
          ),
          if (!widget.exercise.parameters.isSetless)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: ExerciseProgressionPanel(
                exercise: widget.exercise,
                weightUnit: widget.weightUnit,
                distanceUnit: widget.distanceUnit,
                index: widget.index,
                callbacks: widget.callbacks,
                isCreating: widget.isCreating,
              ),
            ),
          if (!widget.isInSuperset)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TimeInputField(
                      controller: timeController,
                      decoration: GymTrackerInputDecoration(
                        labelText: context.t.exercise.fields.restTime,
                      ),
                      onChangedTime: (value) =>
                          widget.callbacks.onExerciseChangeRestTime(
                            widget.index,
                            value ?? Duration.zero,
                          ),
                    ),
                  ),
                  if (widget.exercise.parameters.isSetless &&
                      !widget.isCreating) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          widget.callbacks.onSetSetDone(widget.index, -1, true),
                      icon: const Icon(GTIcons.time),
                      tooltip: context.t.exercise.fields.restTime,
                    ),
                  ],
                ],
              ),
            ),
          if (!widget.exercise.parameters.isSetless) ...[
            for (int i = 0; i < widget.exercise.sets.length; i++)
              WorkoutExerciseSetEditor(
                key: ValueKey((widget.index, i)),
                set: widget.exercise.sets[i],
                index: widget.index,
                setIndex: i,
                exercise: widget.exercise,
                onDelete: () => widget.callbacks.onSetRemove(widget.index, i),
                alt: i % 2 == 0,
                isCreating: widget.isCreating,
                onSetSelectKind: (val) =>
                    widget.callbacks.onSetSelectKind(widget.index, i, val),
                onSetSetDone: (val) =>
                    widget.callbacks.onSetSetDone(widget.index, i, val),
                onSetChangeRPE: (val) =>
                    widget.callbacks.onSetChangeRPE(widget.index, i, val),
                onSetValueChange: (set) =>
                    widget.callbacks.onSetValueChange(widget.index, i, set),
                weightUnit: widget.weightUnit,
                distanceUnit: widget.distanceUnit,
              ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => widget.callbacks.onSetCreate(widget.index),
              child: Text(context.t.exercise.actions.addSet),
            ),
          ],
          // if (kDebugMode) ...[
          //   Text(
          //     "id: ${widget.exercise.id}",
          //     textAlign: TextAlign.center,
          //   ),
          //   Text(
          //     "parent: ${widget.exercise.parentID}",
          //     textAlign: TextAlign.center,
          //   ),
          //   Text(
          //     "supersede: ${widget.exercise.supersedesID}",
          //     textAlign: TextAlign.center,
          //   ),
          // ],
          if (widget.createDivider) ...[
            const SizedBox(height: 8),
            const Divider(),
          ],
        ],
      ),
    );
  }
}

class WorkoutExerciseSetEditor extends ConsumerStatefulWidget {
  final Exercise exercise;
  final GTSet set;
  final WorkoutExerciseIndex index;
  final int setIndex;
  final bool alt;
  final bool isCreating;
  final bool showDoneCheckbox;
  final VoidCallback onDelete;
  final void Function(GTSetKind) onSetSelectKind;
  final void Function(bool) onSetSetDone;
  final void Function(double?) onSetChangeRPE;
  final void Function(GTSet) onSetValueChange;
  final Weights weightUnit;
  final Distance distanceUnit;

  const WorkoutExerciseSetEditor({
    required this.exercise,
    required this.set,
    required this.index,
    required this.setIndex,
    required this.alt,
    required this.isCreating,
    this.showDoneCheckbox = true,
    required this.onSetSelectKind,
    required this.onSetChangeRPE,
    required this.onSetSetDone,
    required this.onDelete,
    required this.onSetValueChange,
    required this.weightUnit,
    required this.distanceUnit,
    super.key,
  });

  @override
  ConsumerState<WorkoutExerciseSetEditor> createState() =>
      _WorkoutExerciseSetEditorState();
}

class _WorkoutExerciseSetEditorState
    extends ConsumerState<WorkoutExerciseSetEditor> {
  late var weightController = TextEditingController(
    text: stringifyDouble(widget.set.weight ?? 0),
  );
  late var timeController = TextEditingController(
    text: widget.set.time == null
        ? "0"
        : TimeInputField.encodeDuration(widget.set.time!),
  );
  late var repsController = TextEditingController(
    text: (widget.set.reps ?? 0).toString(),
  );
  late var distanceController = TextEditingController(
    text: stringifyDouble(widget.set.distance ?? 0),
  );

  final _weightFocusNode = FocusNode();
  final _timeFocusNode = FocusNode();
  final _repsFocusNode = FocusNode();
  final _distanceFocusNode = FocusNode();

  ProviderSubscription<WorkoutState?>? subscription;
  late GTSet _lastSyncedSet = widget.set;

  @override
  void initState() {
    super.initState();
    _weightFocusNode.addListener(() {
      setState(() {});
    });
    // Update data if a different actor edits it (such as a paired Apple Watch)
    subscription = ref.listenManual(workoutControllerProvider, (
      previous,
      next,
    ) {
      if (next == null) return;
      final exs = next.workout.exercises;
      final newExercise = exs.exerciseAt(widget.index);
      if (newExercise == null) return;
      if (newExercise.sets.length <= widget.setIndex) return;
      final newSet = newExercise.sets[widget.setIndex];
      if (!mounted || identical(newSet, _lastSyncedSet)) return;
      _syncControllers(newSet);
    });
  }

  @override
  void dispose() {
    subscription?.close();
    weightController.dispose();
    timeController.dispose();
    repsController.dispose();
    distanceController.dispose();
    _weightFocusNode.dispose();
    _timeFocusNode.dispose();
    _repsFocusNode.dispose();
    _distanceFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WorkoutExerciseSetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(_lastSyncedSet, widget.set)) {
      _syncControllers(widget.set);
    }
  }

  void _syncControllers(GTSet set) {
    _lastSyncedSet = set;
    void update(
      TextEditingController controller,
      FocusNode focus,
      String text,
    ) {
      if (!focus.hasFocus && controller.text != text) {
        controller.text = text;
      }
    }

    if (set.weight != null) {
      update(weightController, _weightFocusNode, stringifyDouble(set.weight!));
    }
    if (set.time != null) {
      update(
        timeController,
        _timeFocusNode,
        TimeInputField.encodeDuration(set.time!),
      );
    }
    if (set.reps != null) {
      update(repsController, _repsFocusNode, set.reps.toString());
    }
    if (set.distance != null) {
      update(
        distanceController,
        _distanceFocusNode,
        stringifyDouble(set.distance!),
      );
    }
  }

  Widget get weightField => TextField(
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
      labelText: context.t.exercise.fields.weight,
      suffix: Text(context.t.units[widget.weightUnit.name] ?? "UNKNOWN"),
      suffixIconConstraints: const BoxConstraints(minHeight: 24),
      suffixIcon: _weightFocusNode.hasFocus
          ? IconButton(
              padding: const EdgeInsets.all(8),
              style: IconButton.styleFrom(minimumSize: const Size(0, 0)),
              icon: const Icon(GTIcons.weight_calculator),
              onPressed: () {
                Go.toDialog(
                  () => WeightCalculator(
                    startingWeight: weightController.text.tryParseDouble(),
                    weightUnit: widget.weightUnit,
                    showInsertButton: true,
                    onPressInsert: (weight) {
                      weightController.text = stringifyDouble(weight);
                      _updateSetWeight(weight);
                    },
                  ),
                );
              },
            )
          : null,
    ),
    onChanged: (value) {
      _updateSetWeight(value.isEmpty ? null : value.tryParseDouble());
    },
  );
  Widget get timeField => TimeInputField(
    focusNode: _timeFocusNode,
    timerInteractive: () {
      if (widget.isCreating) return false;
      return !widget.set.done;
    }(),
    setID: widget.set.id,
    controller: timeController,
    decoration: GymTrackerInputDecoration(
      labelText: context.t.exercise.fields.time,
    ),
    onChanged: (value) {
      final newSet = widget.set.copyWith(
        time: value.isEmpty ? null : TimeInputField.parseDuration(value),
      );
      widget.onSetValueChange(newSet);
    },
  );
  TextField get repsField => TextField(
    focusNode: _repsFocusNode,
    controller: repsController,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: GymTrackerInputDecoration(
      labelText: context.t.exercise.fields.reps,
    ),
    onChanged: (value) {
      final newSet = widget.set.copyWith(
        reps: value.isEmpty ? null : int.tryParse(value),
      );
      widget.onSetValueChange(newSet);
    },
  );
  TextField get distanceField => TextField(
    focusNode: _distanceFocusNode,
    controller: distanceController,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
    ],
    decoration: GymTrackerInputDecoration(
      labelText: context.t.exercise.fields.distance,
      suffix: Text(context.t.units[widget.distanceUnit.name] ?? "UNKNOWN"),
    ),
    onChanged: (value) {
      final newSet = widget.set.copyWith(
        distance: value.isEmpty ? null : value.tryParseDouble(),
      );
      widget.onSetValueChange(newSet);
    },
  );

  List<Widget> get fields => [
    if ([
      GTSetParameters.repsWeight,
      GTSetParameters.timeWeight,
    ].contains(widget.set.parameters))
      weightField,
    if ([
      GTSetParameters.timeWeight,
      GTSetParameters.time,
    ].contains(widget.set.parameters))
      timeField,
    if ([
      GTSetParameters.repsWeight,
      GTSetParameters.freeBodyReps,
    ].contains(widget.set.parameters))
      repsField,
    if ([GTSetParameters.distance].contains(widget.set.parameters))
      distanceField,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final defaultColor = widget.alt
        ? scheme.surface.withAlpha((0 * 255).round())
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
            icon: GTIcons.delete_forever,
            label: context.t.actions.remove,
          ),
        ],
      ),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
        tween: ColorTween(
          begin: defaultColor,
          end: widget.set.done && !widget.isCreating
              ? scheme.tertiaryContainer.withAlpha((0.5 * 255).round())
              : defaultColor,
        ),
        builder: (context, value, _) {
          return Container(
            color: value,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              spacing: 8,
              children: [
                PopupMenuButton(
                  icon: buildSetType(
                    context,
                    widget.set.kind,
                    set: widget.set,
                    allSets: widget.exercise.sets,
                  ),
                  tooltip: context.t.set.kind,
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
                          title: Text(
                            context.t.set.kindLong[kind.name] ?? "UNKNOWN",
                          ),
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(context.t.set.kinds.help['title']!),
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
                                      title: Text(
                                        context.t.set.kindLong[kind.name] ??
                                            "UNKNOWN",
                                      ),
                                      subtitle: Text(
                                        context.t.set.kinds.help[kind.name] ??
                                            "UNKNOWN",
                                      ),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    MaterialLocalizations.of(
                                      context,
                                    ).okButtonLabel,
                                  ),
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
                        title: Text(context.t.set.kinds.help['title']!),
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < fields.length; i++) ...[
                  Flexible(child: fields[i]),
                ],
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                    tapTargetSize: .shrinkWrap,
                  ),
                  onPressed: () {
                    showDialog<Optional<double?>>(
                      context: context,
                      builder: (context) {
                        return WorkoutSetRPEDialog(currentRPE: widget.set.rpe);
                      },
                    ).then((value) {
                      if (value != null) {
                        widget.onSetChangeRPE(value.safeUnwrap());
                      }
                    });
                  },
                  child: RPECompactColumn(rpe: widget.set.rpe),
                ),
                if (!widget.isCreating && widget.showDoneCheckbox) ...[
                  Checkbox(
                    value: widget.set.done,
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    onChanged: (isDone) {
                      widget.onSetSetDone(isDone ?? widget.set.done);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateSetWeight(double? value) {
    final newSet = widget.set.copyWith(weight: value);
    widget.onSetValueChange(newSet);
  }
}

class RPECompactColumn extends StatelessWidget {
  const RPECompactColumn({super.key, required this.rpe});

  final double? rpe;

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: .ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Assuming 9.9 is our maximal "em-size"
    final width =
        _textSize(
          NumberFormat.compact(locale: context.locale.languageCode).format(9.9),
          TextStyle(fontSize: 12),
        ).width.ceilToDouble() +
        4; // Add some padding
    return SizedBox(
      width: width,
      child: Center(
        child: Column(
          children: [
            Text(
              "RPE",
              style: TextStyle(
                fontSize: 8,
                color: rpe == null
                    ? scheme.onSurface.withAlpha((0.5 * 255).round())
                    : rpeColor(context, rpe!),
              ),
            ),
            Text(
              rpe == null
                  ? "-"
                  : NumberFormat.compact(
                      locale: context.locale.languageCode,
                    ).format(rpe),
              style: TextStyle(
                fontSize: 12,
                color: rpe == null
                    ? scheme.onSurface.withAlpha((0.5 * 255).round())
                    : rpeColor(context, rpe!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutSetRPEDialog extends StatefulWidget {
  final double? currentRPE;

  const WorkoutSetRPEDialog({this.currentRPE});

  @override
  State<WorkoutSetRPEDialog> createState() => _WorkoutSetRPEDialogState();
}

class _WorkoutSetRPEDialogState extends State<WorkoutSetRPEDialog> {
  // Average
  late double currentRPE = widget.currentRPE ?? 5.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.exercise.editor.fields.rpe.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(GTIcons.help),
                    subtitle: Text(
                      context.t.exercise.editor.fields.rpe.description.text,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(GTIcons.rpe),
                    title: Text(
                      'exercise.editor.fields.rpe.level${currentRPE.toInt()}.title',
                    ),
                    subtitle: Text(
                      'exercise.editor.fields.rpe.level${currentRPE.toInt()}.text',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            year2023: false,
            value: currentRPE.toDouble(),
            secondaryTrackValue: widget.currentRPE?.toDouble(),
            onChanged: (value) {
              setState(() {
                currentRPE = value;
              });
            },
            min: 1,
            max: 10,
            divisions: 18,
            label: NumberFormat.compact(
              locale: context.locale.languageCode,
            ).format(currentRPE),
            activeColor: rpeColor(context, currentRPE),
            secondaryActiveColor: rpeColor(
              context,
              widget.currentRPE ?? 5,
            ).withAlpha((0.54 * 255).round()),
            inactiveColor: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.12 * 255).round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<Optional<double?>>(context, const None());
          },
          child: Text(context.t.exercise.editor.fields.rpe.removeRPE),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<Optional<double?>>(context, Some(currentRPE));
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

class _WorkoutReorderSetsDialog extends StatefulWidget {
  const _WorkoutReorderSetsDialog({
    required this.exercise,
    required this.sets,
    required this.weightUnit,
    required this.distanceUnit,
    required this.isConcrete,
  });

  final Exercise exercise;
  final List<GTSet> sets;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool isConcrete;

  @override
  State<_WorkoutReorderSetsDialog> createState() =>
      __WorkoutReorderSetsDialogState();
}

class __WorkoutReorderSetsDialogState extends State<_WorkoutReorderSetsDialog> {
  late var indices = List.generate(widget.sets.length, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.exercise.editor.fields.reorderSets.title),
          leading: IconButton(
            icon: const Icon(GTIcons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(GTIcons.save),
              onPressed: () {
                Navigator.pop(context, indices);
              },
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AlertBanner(
                  title: context.t.exercise.editor.fields.reorderSets.title,
                  text: Text(context.t.exercise.editor.fields.reorderSets.text),
                  color: AlertColor.secondary(context),
                ),
              ),
            ),
            SliverReorderableList(
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  indices.insert(newIndex, indices.removeAt(oldIndex));
                });
              },
              itemBuilder: (context, j) {
                final index = indices[j];
                return ExerciseSetView(
                  key: ValueKey(widget.sets[index]),
                  set: widget.sets[index],
                  exercise: widget.exercise,
                  isConcrete: widget.isConcrete,
                  alt: j % 2 == 0,
                  weightUnit: widget.weightUnit,
                  distanceUnit: widget.distanceUnit,
                  draggable: true,
                  index: j,
                );
              },
              itemCount: widget.sets.length,
            ),
          ],
        ),
      ),
    );
  }
}
