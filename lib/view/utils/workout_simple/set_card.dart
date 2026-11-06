part of '../workout_simple.dart';

class _CurrentSetView extends StatelessWidget {
  const _CurrentSetView({
    required this.data,
    required this.controller,
    required this.nextUp,
    required this.onEditSet,
  });
  final _CurrentSetData data;
  final WorkoutController controller;
  final _NextUpData? nextUp;
  final VoidCallback onEditSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContentInset(
          child: _ExerciseHeading(data: data, controller: controller),
        ),
        const SizedBox(height: 8),
        _SetSummary(data: data, controller: controller),
        const SizedBox(height: 8),
        _ContentInset(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .65),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.ongoingWorkout.simple.setPosition(
                              current: data.cursor.setIndex + 1,
                              total: data.exercise.sets.length,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _SetTypeBadge(
                          set: data.set,
                          exercise: data.exercise,
                          index: data.index,
                          setIndex: data.cursor.setIndex,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (data.set.parameters.hasWeight &&
                        !data.set.parameters.hasTime)
                      _ValueControl(
                        key: const ValueKey('simple-weight-value'),
                        label: t.exercise.fields.weight,
                        value: data.set.effectiveWeight.localizedWith(t),
                        unit: controller.weightUnit.name,
                        onEdit: onEditSet,
                        onSubtract: (data.set.weight ?? 0) > 0
                            ? () => _changeWeight(-1)
                            : null,
                        onAdd: () => _changeWeight(1),
                      ),
                    if (data.set.parameters.hasReps)
                      _ValueControl(
                        key: const ValueKey('simple-reps-value'),
                        label: t.exercise.fields.reps,
                        value: '${data.set.reps ?? 0}',
                        unit: t.ongoingWorkout.simple.repUnit,
                        onEdit: onEditSet,
                        onSubtract: (data.set.reps ?? 0) > 0
                            ? () => _changeReps(-1)
                            : null,
                        onAdd: () => _changeReps(1),
                      ),
                    if (data.set.parameters.hasTime ||
                        data.set.parameters.hasDistance)
                      _SimpleSetFields(
                        key: ValueKey(data.set.id),
                        data: data,
                        set: data.set,
                        onChanged: _updateSet,
                        onDelete: () => controller.callbacks.onSetRemove(
                          data.index,
                          data.cursor.setIndex,
                        ),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const ValueKey('complete-simple-set'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: controller.autoMarkNextSetDone,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          t.ongoingWorkout.simple.completeSet,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _SeriesActions(data: data, controller: controller),
              if (nextUp != null) ...[
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${t.ongoingWorkout.simple.nextUp} ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: nextUp!.exercise.getDisplayName(t),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' · ${nextUp!.parametersLabel}'),
                    ],
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              _ExerciseDetails(key: ValueKey(data.exercise.id), data: data),
              if (_isLastSetInWorkout(controller, data.cursor) ||
                  _isLastSetInExercise(data.cursor, data.exercise)) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_isLastSetInExercise(data.cursor, data.exercise))
                      TextButton.icon(
                        label: Text(t.exercise.actions.addSet),
                        onPressed: () {
                          controller.callbacks.onSetCreate(data.index);
                          controller.selectSetCursorByIndex(
                            data.index,
                            data.cursor.setIndex + 1,
                          );
                        },
                      ),
                    if (_isLastSetInWorkout(controller, data.cursor))
                      TextButton(
                        onPressed: () =>
                            _addExerciseAndAdvanceCursor(controller, data),
                        child: Text(t.ongoingWorkout.exercises.add),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _updateSet(GTSet set) => controller.callbacks.onSetValueChange(
    data.index,
    data.cursor.setIndex,
    set,
  );
  void _changeWeight(int direction) {
    final step = controller.weightUnit == Weights.kg ? 2.5 : 5.0;
    _updateSet(
      data.set.copyWith(
        weight: ((data.set.weight ?? 0) + direction * step).clamp(
          0.0,
          double.infinity,
        ),
      ),
    );
  }

  void _changeReps(int direction) => _updateSet(
    data.set.copyWith(
      reps: ((data.set.reps ?? 0) + direction).clamp(0, 2147483647),
    ),
  );
}
