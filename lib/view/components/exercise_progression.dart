import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:intl/intl.dart';

class ExerciseProgressionPanel extends StatelessWidget {
  const ExerciseProgressionPanel({
    required this.exercise,
    required this.weightUnit,
    required this.distanceUnit,
    required this.index,
    required this.callbacks,
    required this.isCreating,
    super.key,
  });

  final Exercise exercise;
  final Weights weightUnit;
  final Distance distanceUnit;
  final ExerciseIndex index;
  final EditorCallbacks callbacks;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
    if (exercise.parameters.isSetless ||
        (isCreating && !exercise.parameters.hasReps)) {
      return const SizedBox.shrink();
    }
    final progression = exercise.progression;
    final routineID = !isCreating && Get.isRegistered<WorkoutController>()
        ? Get.find<WorkoutController>().parentID.value
        : null;
    final canConfigure =
        callbacks.onExerciseProgressionChange != null &&
        (!Get.isRegistered<WorkoutController>() ||
            isCreating ||
            routineID != null);
    final history = Get.find<HistoryController>()
        .getHistoryOf(exercise.getParent() ?? exercise)
        .where((entry) => routineID == null || entry.$3.parentID == routineID)
        .toList();
    final previous = history
        .where(
          (entry) =>
              entry.$1.doneSets.any((set) => set.kind == GTSetKind.normal),
        )
        .firstOrNull;
    final t = context.t.progression;
    String setsText(Exercise ex, Weights unit, Distance distanceUnit) => ex.sets
        .where((set) => set.done && set.kind == GTSetKind.normal)
        .map(
          (set) => switch (ex.parameters) {
            GTSetParameters.repsWeight =>
              '${unit.stringify(set.weight ?? 0)} × ${set.reps}',
            GTSetParameters.freeBodyReps => '${set.reps}',
            GTSetParameters.timeWeight =>
              '${unit.stringify(set.weight ?? 0)} × ${set.time?.inSeconds ?? 0}s',
            GTSetParameters.time => '${set.time?.inSeconds ?? 0}s',
            GTSetParameters.distance =>
              '${set.distance ?? 0} ${distanceUnit.name}',
            GTSetParameters.setless => '',
          },
        )
        .join(' / ');
    final targets = progression?.repsFor(progression.setCount).join(' / ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCreating)
                Text(
                  previous == null
                      ? t.noHistory
                      : '${t.lastTime} · ${DateFormat.yMd().format(previous.$3.startingDate!)}: ${setsText(previous.$1, previous.$3.weightUnit, previous.$3.distanceUnit)}',
                ),
              if (progression != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${t.goal}: ${exercise.parameters.hasWeight ? '${weightUnit.stringify(progression.targetWeight)} × ' : ''}$targets',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (progression.mode == ProgressionMode.cyclicLinear)
                  Text(
                    t.step(
                      cycle: progression.cycle + 1,
                      step: progression.step + 1,
                    ),
                  ),
              ],
              if (exercise.parameters.hasReps && canConfigure)
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<ExerciseProgression>(
                          context: context,
                          builder: (_) => _ProgressionDialog(
                            exercise: exercise,
                            current: progression,
                            unit: weightUnit,
                          ),
                        );
                        if (result != null) {
                          callbacks.onExerciseProgressionChange!(index, result);
                        }
                      },
                      child: Text(t.configure),
                    ),
                    if (progression != null) ...[
                      if (!progression
                          .advance(
                            progression.setCount,
                            hasWeight: exercise.parameters.hasWeight,
                          )
                          .sameAs(progression))
                        TextButton(
                          onPressed: () =>
                              callbacks.onExerciseProgressionChange!(
                                index,
                                progression.advance(
                                  progression.setCount,
                                  hasWeight: exercise.parameters.hasWeight,
                                ),
                              ),
                          child: Text(t.advance),
                        ),
                      TextButton(
                        onPressed: () =>
                            callbacks.onExerciseProgressionChange!(index, null),
                        child: Text(t.remove),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressionDialog extends StatefulWidget {
  const _ProgressionDialog({
    required this.exercise,
    required this.current,
    required this.unit,
  });
  final Exercise exercise;
  final ExerciseProgression? current;
  final Weights unit;

  @override
  State<_ProgressionDialog> createState() => _ProgressionDialogState();
}

class _ProgressionDialogState extends State<_ProgressionDialog> {
  late ProgressionMode mode = widget.exercise.parameters.hasWeight
      ? widget.current?.mode ?? ProgressionMode.doubleProgression
      : ProgressionMode.doubleProgression;
  late final controllers = <String, TextEditingController>{
    'min': TextEditingController(text: '${widget.current?.minReps ?? 8}'),
    'max': TextEditingController(text: '${widget.current?.maxReps ?? 12}'),
    'repsStep': TextEditingController(
      text: '${widget.current?.repsPerStep ?? 2}',
    ),
    'start': TextEditingController(
      text: '${widget.current?.startingWeight ?? _initialWeight()}',
    ),
    'weightStep': TextEditingController(
      text:
          '${widget.current?.weightPerStep ?? (widget.unit == Weights.kg ? 2.5 : 5)}',
    ),
    'cycleStep': TextEditingController(
      text:
          '${widget.current?.weightPerCycle ?? (widget.unit == Weights.kg ? 2.5 : 5)}',
    ),
  };

  double _initialWeight() {
    final planned = widget.exercise.sets
        .where((set) => set.kind == GTSetKind.normal && (set.weight ?? 0) > 0)
        .firstOrNull
        ?.weight;
    if (planned != null) return planned;
    final previous = Get.find<HistoryController>()
        .getHistoryOf(widget.exercise.getParent() ?? widget.exercise)
        .where(
          (entry) => entry.$1.doneSets.any(
            (set) => set.kind == GTSetKind.normal && (set.weight ?? 0) > 0,
          ),
        )
        .firstOrNull;
    if (previous == null) return 0;
    final weight = previous.$1.doneSets
        .firstWhere(
          (set) => set.kind == GTSetKind.normal && (set.weight ?? 0) > 0,
        )
        .weight!;
    return Weights.convert(
      value: weight,
      from: previous.$3.weightUnit,
      to: widget.unit,
    );
  }

  int get setCount =>
      widget.exercise.sets.where((set) => set.kind == GTSetKind.normal).length;

  ExerciseProgression? get draft {
    final min = int.tryParse(controllers['min']!.text);
    final max = int.tryParse(controllers['max']!.text);
    final repsStep = int.tryParse(controllers['repsStep']!.text);
    final start = double.tryParse(
      controllers['start']!.text.replaceAll(',', '.'),
    );
    final weightStep = double.tryParse(
      controllers['weightStep']!.text.replaceAll(',', '.'),
    );
    final cycleStep = double.tryParse(
      controllers['cycleStep']!.text.replaceAll(',', '.'),
    );
    if (min == null ||
        max == null ||
        repsStep == null ||
        start == null ||
        weightStep == null ||
        cycleStep == null) {
      return null;
    }
    final value = ExerciseProgression(
      mode: mode,
      minReps: min,
      maxReps: max,
      repsPerStep: repsStep,
      setCount: setCount,
      startingWeight: start,
      weightPerStep: weightStep,
      weightPerCycle: cycleStep,
    );
    if (!value.isValid) return null;
    final old = widget.current;
    if (old != null &&
        old.mode == value.mode &&
        old.minReps == value.minReps &&
        old.maxReps == value.maxReps &&
        old.repsPerStep == value.repsPerStep &&
        old.setCount == value.setCount &&
        old.startingWeight == value.startingWeight &&
        old.weightPerStep == value.weightPerStep &&
        old.weightPerCycle == value.weightPerCycle) {
      return old;
    }
    return value;
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.progression;
    final current = draft;
    Widget field(String key, String label) => TextField(
      controller: controllers[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    );
    return AlertDialog(
      title: Text(t.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProgressionMode>(
                initialValue: mode,
                items: [
                  DropdownMenuItem(
                    value: ProgressionMode.doubleProgression,
                    child: Text(t.double),
                  ),
                  if (widget.exercise.parameters.hasWeight)
                    DropdownMenuItem(
                      value: ProgressionMode.cyclicLinear,
                      child: Text(t.cyclic),
                    ),
                ],
                onChanged: (value) => setState(() => mode = value!),
              ),
              field('min', t.minReps),
              field('max', t.maxReps),
              if (mode == ProgressionMode.cyclicLinear)
                field('repsStep', t.repsPerStep),
              if (widget.exercise.parameters.hasWeight) ...[
                field('start', '${t.startingWeight} (${widget.unit.name})'),
                field('weightStep', '${t.weightPerStep} (${widget.unit.name})'),
                if (mode == ProgressionMode.cyclicLinear)
                  field(
                    'cycleStep',
                    '${t.weightPerCycle} (${widget.unit.name})',
                  ),
              ],
              if (current == null) Text(t.invalid),
              if (current != null && mode == ProgressionMode.cyclicLinear) ...[
                const SizedBox(height: 12),
                Text(t.preview),
                for (var i = 0; i < current.stepsPerCycle; i++)
                  Text(
                    '${widget.unit.stringify(current.startingWeight + i * current.weightPerStep)} × ${current.maxReps - i * current.repsPerStep}',
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: current == null
              ? null
              : () => Navigator.pop(context, current),
          child: Text(t.save),
        ),
      ],
    );
  }
}
