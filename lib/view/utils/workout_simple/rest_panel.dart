part of '../workout_simple.dart';

class _RestPanel extends ConsumerWidget {
  const _RestPanel({required this.accentColor});
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(countdownControllerProvider);
    final countdown = ref.read(countdownControllerProvider.notifier);
    final active = countdown.isActive;
    final duration = _workoutMotionDuration(context);
    final body = active
        ? _WorkoutChangeTransition(
            identity: countdown.startingTime!,
            axis: Axis.vertical,
            animateOnMount: true,
            child: Material(
              type: MaterialType.transparency,
              child: _ContentInset(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RestControls(countdown: countdown),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TimerView(
                          startingTime: countdown.startingTime!,
                          builder: (context, _) => _AnimatedWorkoutProgress(
                            value: countdown.progress.clamp(0.0, 1.0),
                            minHeight: 4,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
    return AnimatedContainer(
      key: const ValueKey('simple-rest-panel'),
      duration: duration,
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      color: active
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        // Keep the bottom safe inset reserved throughout the transition.
        child: duration == Duration.zero
            ? body
            : AnimatedSize(
                key: const ValueKey('simple-rest-size'),
                duration: duration,
                reverseDuration: duration,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: body,
              ),
      ),
    );
  }
}

class _RestControls extends StatelessWidget {
  const _RestControls({required this.countdown});
  final CountdownController countdown;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final actionsWidth = (208 * scale).clamp(0.0, constraints.maxWidth);
      final timer = _RestTime(countdown: countdown);
      final actions = SizedBox(
        key: const ValueKey('simple-rest-actions'),
        width: actionsWidth,
        child: _RestActions(countdown: countdown),
      );
      // Reserve space for controls independently of the current timer string.
      // On narrow screens or with enlarged text, put the controls on their own row.
      if (constraints.maxWidth < actionsWidth + 8 + 96 * scale) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            timer,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        );
      }
      return Row(
        children: [
          SizedBox(
            width: constraints.maxWidth - actionsWidth - 8,
            child: timer,
          ),
          const Spacer(),
          actions,
        ],
      );
    },
  );
}

class _RestTime extends StatelessWidget {
  const _RestTime({required this.countdown});
  final CountdownController countdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.exercise.fields.restTime,
          style: theme.textTheme.labelMedium,
        ),
        SizedBox(
          height:
              MediaQuery.textScalerOf(context).scale(style.fontSize!) *
              style.height!,
          width: double.infinity,
          child: TimerView(
            startingTime: countdown.startingTime!,
            builder: (context, _) {
              final remaining = countdown.remaining.isNegative
                  ? Duration.zero
                  : countdown.remaining;
              final minutes = (remaining.inMinutes % 60).toString().padLeft(
                2,
                '0',
              );
              final seconds = (remaining.inSeconds % 60).toString().padLeft(
                2,
                '0',
              );
              final value = remaining.inHours > 0
                  ? '${remaining.inHours}:$minutes:$seconds'
                  : '$minutes:$seconds';
              return FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  key: const ValueKey('simple-rest-time'),
                  style: style,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RestActions extends StatelessWidget {
  const _RestActions({required this.countdown});
  final CountdownController countdown;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            key: const ValueKey('simple-rest-subtract'),
            style: style,
            onPressed: countdown.subtract15Seconds,
            child: Text(
              context.t.timer.subtract15s,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            key: const ValueKey('simple-rest-add'),
            style: style,
            onPressed: countdown.add15Seconds,
            child: Text(context.t.timer.add15s, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            key: const ValueKey('simple-rest-skip'),
            style: style,
            onPressed: countdown.removeCountdown,
            child: Text(context.t.timer.skip, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
