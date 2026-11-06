part of '../workout_simple.dart';

class _EmptyCurrentSetView extends StatelessWidget {
  const _EmptyCurrentSetView({
    required this.isWorkoutComplete,
    required this.onFinishWorkout,
    required this.onAddExercise,
  });
  final bool isWorkoutComplete;
  final VoidCallback onFinishWorkout, onAddExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t.ongoingWorkout;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            isWorkoutComplete ? Icons.task_alt : GTIcons.workout,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            isWorkoutComplete ? t.simple.completedTitle : t.simple.emptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWorkoutComplete
                ? t.simple.completedDescription
                : t.simple.emptyDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (isWorkoutComplete)
            FilledButton.icon(
              onPressed: onFinishWorkout,
              icon: const Icon(GTIcons.done),
              label: Text(t.actions.finish),
            ),
          TextButton(onPressed: onAddExercise, child: Text(t.exercises.add)),
        ],
      ),
    );
  }
}
