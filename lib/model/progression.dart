import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

enum ProgressionMode { doubleProgression, cyclicLinear }

/// Stored on a routine exercise and copied to its workout instance.
class ExerciseProgression {
  final ProgressionMode mode;
  final int minReps;
  final int maxReps;
  final int repsPerStep;
  final int setCount;
  final double startingWeight;
  final double weightPerStep;
  final double weightPerCycle;
  final int cycle;
  final int step;
  final List<int> targetReps;

  const ExerciseProgression({
    required this.mode,
    required this.minReps,
    required this.maxReps,
    required this.repsPerStep,
    required this.setCount,
    required this.startingWeight,
    required this.weightPerStep,
    required this.weightPerCycle,
    this.cycle = 0,
    this.step = 0,
    this.targetReps = const [],
  });

  int get stepsPerCycle => (maxReps - minReps) ~/ repsPerStep + 1;

  double get targetWeight => mode == ProgressionMode.doubleProgression
      ? startingWeight + cycle * weightPerStep
      : startingWeight + cycle * weightPerCycle + step * weightPerStep;

  int get targetRepetitions => maxReps - step * repsPerStep;

  bool sameAs(ExerciseProgression other) =>
      mode == other.mode &&
      minReps == other.minReps &&
      maxReps == other.maxReps &&
      repsPerStep == other.repsPerStep &&
      setCount == other.setCount &&
      startingWeight == other.startingWeight &&
      weightPerStep == other.weightPerStep &&
      weightPerCycle == other.weightPerCycle &&
      cycle == other.cycle &&
      step == other.step &&
      targetReps.length == other.targetReps.length &&
      [
        for (var i = 0; i < targetReps.length; i++)
          targetReps[i] == other.targetReps[i],
      ].every((same) => same);

  List<int> repsFor(int count) => mode == ProgressionMode.cyclicLinear
      ? List.filled(count, targetRepetitions)
      : targetReps.length == count
      ? targetReps
      : List.filled(count, minReps);

  bool get isValid =>
      minReps > 0 &&
      setCount > 0 &&
      maxReps >= minReps &&
      repsPerStep > 0 &&
      (mode != ProgressionMode.cyclicLinear ||
          (maxReps - minReps) % repsPerStep == 0) &&
      startingWeight >= 0 &&
      weightPerStep > 0 &&
      weightPerCycle >= 0 &&
      cycle >= 0 &&
      step >= 0 &&
      step < stepsPerCycle;

  /// Only the planned working sets count. Extra sets do not change the goal.
  bool reached(Exercise exercise) {
    final working = exercise.sets
        .where((set) => set.kind == GTSetKind.normal)
        .toList();
    final targets = repsFor(setCount);
    if (working.length < setCount) return false;
    for (var i = 0; i < setCount; i++) {
      final set = working[i];
      if (!set.done || (set.reps ?? 0) < targets[i]) {
        return false;
      }
      if (exercise.parameters.hasWeight &&
          (set.weight ?? 0) + 0.00001 < targetWeight) {
        return false;
      }
    }
    return true;
  }

  ExerciseProgression advance(int setCount, {bool hasWeight = true}) {
    if (mode == ProgressionMode.cyclicLinear) {
      final nextStep = step + 1;
      return copyWith(
        step: nextStep == stepsPerCycle ? 0 : nextStep,
        cycle: nextStep == stepsPerCycle ? cycle + 1 : cycle,
      );
    }
    final reps = repsFor(setCount).toList();
    if (reps.every((value) => value >= maxReps)) {
      if (!hasWeight) return this;
      return copyWith(
        cycle: cycle + 1,
        targetReps: List.filled(setCount, minReps),
      );
    }
    final lowest = reps.reduce((a, b) => a < b ? a : b);
    reps[reps.indexOf(lowest)]++;
    return copyWith(targetReps: reps);
  }

  ExerciseProgression copyWith({
    int? cycle,
    int? step,
    List<int>? targetReps,
  }) => ExerciseProgression(
    mode: mode,
    minReps: minReps,
    maxReps: maxReps,
    repsPerStep: repsPerStep,
    setCount: setCount,
    startingWeight: startingWeight,
    weightPerStep: weightPerStep,
    weightPerCycle: weightPerCycle,
    cycle: cycle ?? this.cycle,
    step: step ?? this.step,
    targetReps: targetReps ?? this.targetReps,
  );

  ExerciseProgression changeUnits(
    Weights from,
    Weights to,
  ) => ExerciseProgression(
    mode: mode,
    minReps: minReps,
    maxReps: maxReps,
    repsPerStep: repsPerStep,
    setCount: setCount,
    startingWeight: Weights.convert(value: startingWeight, from: from, to: to),
    weightPerStep: Weights.convert(value: weightPerStep, from: from, to: to),
    weightPerCycle: Weights.convert(value: weightPerCycle, from: from, to: to),
    cycle: cycle,
    step: step,
    targetReps: targetReps,
  );

  factory ExerciseProgression.fromJson(Map<String, dynamic> json) =>
      ExerciseProgression(
        mode: ProgressionMode.values.byName(json['mode'] as String),
        minReps: json['minReps'] as int,
        maxReps: json['maxReps'] as int,
        repsPerStep: json['repsPerStep'] as int,
        setCount: json['setCount'] as int,
        startingWeight: (json['startingWeight'] as num).toDouble(),
        weightPerStep: (json['weightPerStep'] as num).toDouble(),
        weightPerCycle: (json['weightPerCycle'] as num).toDouble(),
        cycle: json['cycle'] as int? ?? 0,
        step: json['step'] as int? ?? 0,
        targetReps: (json['targetReps'] as List<dynamic>? ?? []).cast<int>(),
      );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'minReps': minReps,
    'maxReps': maxReps,
    'repsPerStep': repsPerStep,
    'setCount': setCount,
    'startingWeight': startingWeight,
    'weightPerStep': weightPerStep,
    'weightPerCycle': weightPerCycle,
    'cycle': cycle,
    'step': step,
    'targetReps': targetReps,
  };
}
