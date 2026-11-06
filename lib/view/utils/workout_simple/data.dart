part of '../workout_simple.dart';

class _CurrentSetData {
  final WorkoutSetCursor cursor;
  final WorkoutExerciseIndex index;
  final Exercise exercise;
  final GTSet set;
  final Duration restTime;
  final String? supersetNotes;
  final bool isInSuperset;
  final int supersetExerciseCount;
  final Color exerciseColor;

  const _CurrentSetData({
    required this.cursor,
    required this.index,
    required this.exercise,
    required this.set,
    required this.restTime,
    required this.supersetNotes,
    required this.isInSuperset,
    required this.supersetExerciseCount,
    required this.exerciseColor,
  });
}

class _SetRef {
  final WorkoutSetCursor cursor;
  final Exercise exercise;
  final GTSet set;

  const _SetRef({
    required this.cursor,
    required this.exercise,
    required this.set,
  });
}

class _NextUpData {
  const _NextUpData({required this.exercise, required this.parametersLabel});
  final Exercise exercise;
  final String parametersLabel;
}

_CurrentSetData? _currentSetData(
  WorkoutController controller,
  BuildContext context,
) {
  final cursor = controller.currentSetCursor;
  if (cursor == null) return null;

  final exercise = _exerciseAtCursor(controller, cursor);
  if (exercise == null) return null;

  final set = exercise.sets[cursor.setIndex];
  final supersetNotes = cursor.supersetIndex == null
      ? null
      : (controller.exercises[cursor.supersetIndex!] as Superset).notes;
  final restTime = cursor.supersetIndex == null
      ? exercise.restTime
      : (controller.exercises[cursor.supersetIndex!] as Superset).restTime;
  final supersetExerciseCount = cursor.supersetIndex == null
      ? 1
      : ((controller.exercises[cursor.supersetIndex!] as Superset)
            .exercises
            .length);
  final fallbackColor = context.theme.colorScheme.primary;
  final exerciseColor = exercise.standard && exercise.category != null
      ? exerciseStandardLibrary[exercise.category]?.color ?? fallbackColor
      : fallbackColor;

  return _CurrentSetData(
    cursor: cursor,
    index: (
      exerciseIndex: cursor.exerciseIndex,
      supersetIndex: cursor.supersetIndex,
    ),
    exercise: exercise,
    set: set,
    restTime: restTime,
    supersetNotes: supersetNotes,
    isInSuperset: cursor.supersetIndex != null,
    supersetExerciseCount: supersetExerciseCount,
    exerciseColor: exerciseColor,
  );
}

Exercise? _exerciseAtCursor(
  WorkoutController controller,
  WorkoutSetCursor cursor,
) {
  if (cursor.supersetIndex == null) {
    final ex = controller.exercises[cursor.exerciseIndex];
    return ex is Exercise ? ex : null;
  }

  final superset = controller.exercises[cursor.supersetIndex!];
  if (superset is! Superset) return null;
  if (cursor.exerciseIndex < 0 ||
      cursor.exerciseIndex >= superset.exercises.length) {
    return null;
  }
  return superset.exercises[cursor.exerciseIndex];
}

List<_SetRef> _orderedSetRefs(List<WorkoutExercisable> exercises) {
  final refs = <_SetRef>[];

  for (int i = 0; i < exercises.length; i++) {
    final candidate = exercises[i];
    if (candidate is Exercise) {
      for (int setIndex = 0; setIndex < candidate.sets.length; setIndex++) {
        refs.add(
          _SetRef(
            cursor: (exerciseIndex: i, supersetIndex: null, setIndex: setIndex),
            exercise: candidate,
            set: candidate.sets[setIndex],
          ),
        );
      }
      continue;
    }

    if (candidate is! Superset) continue;

    final maxSets = candidate.exercises.fold<int>(
      0,
      (value, exercise) =>
          value > exercise.sets.length ? value : exercise.sets.length,
    );

    for (int setIndex = 0; setIndex < maxSets; setIndex++) {
      for (
        int exerciseIndex = 0;
        exerciseIndex < candidate.exercises.length;
        exerciseIndex++
      ) {
        final exercise = candidate.exercises[exerciseIndex];
        if (setIndex >= exercise.sets.length) continue;
        refs.add(
          _SetRef(
            cursor: (
              exerciseIndex: exerciseIndex,
              supersetIndex: i,
              setIndex: setIndex,
            ),
            exercise: exercise,
            set: exercise.sets[setIndex],
          ),
        );
      }
    }
  }

  return refs;
}

bool _sameCursor(WorkoutSetCursor a, WorkoutSetCursor b) {
  return a.exerciseIndex == b.exerciseIndex &&
      a.supersetIndex == b.supersetIndex &&
      a.setIndex == b.setIndex;
}

bool _hasPreviousSet(WorkoutController controller, WorkoutSetCursor? cursor) {
  if (cursor == null) return false;
  final ordered = _orderedSetRefs(controller.exercises);
  final current = ordered.indexWhere((ref) => _sameCursor(ref.cursor, cursor));
  if (current <= 0) return false;

  for (int i = current - 1; i >= 0; i--) {
    if (!ordered[i].set.done) return true;
  }

  return false;
}

bool _hasNextSet(WorkoutController controller, WorkoutSetCursor? cursor) {
  if (cursor == null) return false;
  final ordered = _orderedSetRefs(controller.exercises);
  final current = ordered.indexWhere((ref) => _sameCursor(ref.cursor, cursor));
  if (current < 0 || current >= ordered.length - 1) return false;

  for (int i = current + 1; i < ordered.length; i++) {
    if (!ordered[i].set.done) return true;
  }

  return false;
}

_NextUpData? _nextUpData(
  BuildContext context,
  WorkoutController controller,
  _CurrentSetData current,
) {
  final ordered = _orderedSetRefs(controller.exercises);
  final currentIndex = ordered.indexWhere(
    (ref) => _sameCursor(ref.cursor, current.cursor),
  );
  if (currentIndex == -1) return null;

  for (int i = currentIndex + 1; i < ordered.length; i++) {
    if (!ordered[i].set.done) {
      final next = ordered[i];
      return _NextUpData(
        exercise: next.exercise,
        parametersLabel: next.set.getHumanReadableDescription(
          t: context.t,
          weightUnit: controller.weightUnit,
          distanceUnit: controller.distanceUnit,
          targetWeightUnit: controller.weightUnit,
          targetDistanceUnit: controller.distanceUnit,
          context: context,
        ),
      );
    }
  }

  return null;
}

String _nextUpSetShortLabel(
  Exercise exercise,
  GTSet set, {
  required BuildContext context,
}) {
  switch (set.kind) {
    case GTSetKind.warmUp:
      return context.t.set.kindShort.warmUp;
    case GTSetKind.normal:
      final normalSets = exercise.sets
          .where((element) => element.kind == GTSetKind.normal)
          .toList();
      final setIndex = normalSets.indexWhere((element) => element.id == set.id);
      final index = setIndex < 0 ? 1 : setIndex + 1;
      return index.toString();
    case GTSetKind.drop:
      return context.t.set.kindShort.drop;
    case GTSetKind.failure:
      return context.t.set.kindShort.failure;
    case GTSetKind.failureStripping:
      return context.t.set.kindShort.failureStripping;
  }
}

bool _canTriggerRestTimer(_CurrentSetData? current) =>
    current != null && current.restTime > Duration.zero;

bool _isWorkoutComplete(WorkoutController controller) {
  final ordered = _orderedSetRefs(controller.exercises);
  if (ordered.isEmpty) return false;
  return ordered.every((entry) => entry.set.done);
}

bool _isLastSetInWorkout(
  WorkoutController controller,
  WorkoutSetCursor cursor,
) {
  final ordered = _orderedSetRefs(controller.exercises);
  final currentIndex = ordered.indexWhere(
    (entry) => _sameCursor(entry.cursor, cursor),
  );
  return currentIndex == ordered.length - 1;
}

bool _isLastSetInExercise(WorkoutSetCursor cursor, Exercise exercise) {
  return exercise.sets.isNotEmpty &&
      cursor.setIndex == exercise.sets.length - 1;
}

void _insertSetAfterCurrent(
  WorkoutController controller,
  _CurrentSetData current,
  GTSetKind kind,
) {
  final cursor = current.cursor;
  final insertionIndex = cursor.setIndex + 1;
  final newSet = GTSet.empty(
    kind: kind,
    parameters: current.exercise.parameters,
  );

  if (cursor.supersetIndex == null) {
    final exercise = controller.exercises[cursor.exerciseIndex] as Exercise;
    controller.exercises[cursor.exerciseIndex] = exercise.copyWith(
      sets: [
        ...exercise.sets.take(insertionIndex),
        newSet,
        ...exercise.sets.skip(insertionIndex),
      ],
    );
  } else {
    final superset = controller.exercises[cursor.supersetIndex!] as Superset;
    controller.exercises[cursor.supersetIndex!] = superset.copyWith(
      exercises: [
        for (int i = 0; i < superset.exercises.length; i++)
          if (i == cursor.exerciseIndex)
            superset.exercises[i].copyWith(
              sets: [
                ...superset.exercises[i].sets.take(insertionIndex),
                newSet,
                ...superset.exercises[i].sets.skip(insertionIndex),
              ],
            )
          else
            superset.exercises[i],
      ],
    );
  }

  controller.publishExercises();
  controller.save();
  controller.selectSetCursorByIndex(current.index, insertionIndex);
}

Future<void> _addExerciseAndAdvanceCursor(
  WorkoutController controller,
  _CurrentSetData? current,
) async {
  final generation = controller.sessionGeneration;
  final previousLength = controller.exercises.length;
  await controller.pickExercises();
  if (!controller.isSessionActive(generation)) return;

  if (controller.exercises.length <= previousLength) {
    return;
  }

  final firstNewExerciseIndex = previousLength;
  final firstNewExercise = controller.exercises[firstNewExerciseIndex];
  if (firstNewExercise is Exercise && firstNewExercise.sets.isNotEmpty) {
    controller.selectSetCursorByIndex((
      exerciseIndex: firstNewExerciseIndex,
      supersetIndex: null,
    ), 0);
    return;
  }

  if (current != null) {
    controller.selectSetCursorByIndex(current.index, current.cursor.setIndex);
  }
}
