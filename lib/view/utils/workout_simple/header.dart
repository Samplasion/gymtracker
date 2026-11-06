part of '../workout_simple.dart';

class _StopwatchTitle extends ConsumerWidget {
  const _StopwatchTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stopwatchControllerProvider);
    final stopwatch = ref
        .read(stopwatchControllerProvider.notifier)
        .globalStopwatch;
    if (stopwatch.isStopped && stopwatch.currentDuration == Duration.zero) {
      return Text(context.t.ongoingWorkout.title);
    }
    return TimerView(
      startingTime: DateTime.now(),
      builder: (context, _) => Text.rich(
        TextSpan(
          children: [
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(GTIcons.stopwatch, size: 20),
            ),
            const TextSpan(text: ' '),
            TimerView.buildTimeString(
              context,
              stopwatch.currentDuration,
              builder: (time) => time,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.controller, required this.current});
  final WorkoutController controller;
  final _CurrentSetData? current;

  @override
  Widget build(BuildContext context) {
    final exercises = [
      for (final item in controller.exercises)
        if (item is Exercise) item else if (item is Superset) ...item.exercises,
    ];
    final position = current == null
        ? -1
        : exercises.indexWhere((e) => e.id == current!.exercise.id);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WorkoutRecordingIndicator(workoutId: controller.nativeWorkoutId),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              controller.name.trim().isEmpty
                  ? context.t.ongoingWorkout.title
                  : controller.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) + 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (position >= 0)
              Text(
                context.t.ongoingWorkout.simple.exercisePosition(
                  current: position + 1,
                  total: exercises.length,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 16) / 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: width,
                  child: Consumer(
                    builder: (context, ref, _) => TimerView(
                      startingTime: controller.time,
                      builder: (context, _) => _MetricTile(
                        icon: GTIcons.time,
                        label: context.t.ongoingWorkout.info.time,
                        value: TimerView.buildTimeString(
                          context,
                          ref
                              .read(workoutClockProvider)
                              .now()
                              .difference(controller.time),
                          builder: (time) => time.text ?? '',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width, child: _HealthMetric(heartRate: true)),
                SizedBox(width: width, child: _HealthMetric(heartRate: false)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HealthMetric extends ConsumerWidget {
  const _HealthMetric({required this.heartRate});
  final bool heartRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = heartRate
        ? ref.watch(healthHeartRateProvider)
        : ref.watch(healthEnergyProvider);
    final value = result.hasError || result.isLoading ? null : result.value;
    return _MetricTile(
      icon: heartRate ? GTIcons.heart_rate : GTIcons.active_energy,
      label: heartRate
          ? context.t.ongoingWorkout.info.heartRate
          : context.t.ongoingWorkout.info.activeEnergy,
      value: value != null && value.isFinite
          ? NumberFormat.decimalPattern(
              context.locale.languageCode,
            ).format(value.round())
          : '—',
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseHeading extends StatelessWidget {
  const _ExerciseHeading({required this.data, required this.controller});
  final _CurrentSetData data;
  final WorkoutController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final t = context.t;
      final theme = Theme.of(context);
      final separateBadges =
          constraints.maxWidth < 340 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExerciseParentViewGesture(
                exercise: data.exercise,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ExerciseIcon(radius: 18, exercise: data.exercise),
                ),
              ),
              Expanded(
                child: Text(
                  data.exercise.getDisplayName(t),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) - 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!separateBadges && data.exercise.isCustom)
                const CustomExerciseBadge(),
              PopupMenuButton(
                itemBuilder: (context) => buildExerciseControlMenuEntries(
                  context: context,
                  index: data.index,
                  exercise: data.exercise,
                  isCreating: false,
                  callbacks: controller.callbacks,
                  weightUnit: controller.weightUnit,
                  distanceUnit: controller.distanceUnit,
                ),
              ),
            ],
          ),
          if ((separateBadges && data.exercise.isCustom) ||
              data.isInSuperset) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (separateBadges && data.exercise.isCustom)
                  const CustomExerciseBadge(),
                if (data.isInSuperset)
                  _LabelBadge(text: t.superset(n: data.supersetExerciseCount)),
              ],
            ),
          ],
        ],
      );
    },
  );
}
