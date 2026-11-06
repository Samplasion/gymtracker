part of '../workout_simple.dart';

class _LabelBadge extends StatelessWidget {
  const _LabelBadge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
  );
}

class _ValueControl extends StatelessWidget {
  const _ValueControl({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.onEdit,
    required this.onSubtract,
    required this.onAdd,
  });
  final String label, value, unit;
  final VoidCallback onEdit, onAdd;
  final VoidCallback? onSubtract;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: context.t.ongoingWorkout.simple.decreaseValue(
              field: label,
            ),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onSubtract,
            icon: const Icon(Icons.remove),
          ),
          Expanded(
            child: Semantics(
              label: label,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _WorkoutChangeTransition(
                          identity: '$value $unit',
                          axis: Axis.vertical,
                          duration: const Duration(milliseconds: 140),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: value,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontSize:
                                            (theme
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.fontSize ??
                                                24) +
                                            4,
                                        height: 1.05,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                TextSpan(
                                  text: ' $unit',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: context.t.ongoingWorkout.simple.increaseValue(
              field: label,
            ),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _SetSummary extends StatefulWidget {
  const _SetSummary({required this.data, required this.controller});
  final _CurrentSetData data;
  final WorkoutController controller;

  @override
  State<_SetSummary> createState() => _SetSummaryState();
}

class _SetSummaryState extends State<_SetSummary> {
  final _scrollController = ScrollController();
  final _selectedKey = GlobalKey();
  _CurrentSetData get data => widget.data;
  WorkoutController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _revealSelection();
  }

  @override
  void didUpdateWidget(_SetSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.set.id != data.set.id) _revealSelection(animate: true);
  }

  void _revealSelection({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _selectedKey.currentContext?.findRenderObject();
      if (target != null) {
        _scrollController.position.ensureVisible(
          target,
          alignment: .5,
          duration: animate
              ? _workoutMotionDuration(
                  context,
                  const Duration(milliseconds: 180),
                )
              : Duration.zero,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = Theme.of(context).textTheme.labelLarge!;
      final lineHeight =
          MediaQuery.textScalerOf(context).scale(style.fontSize!) *
          (style.height ?? 1.4);
      return SizedBox(
        height: (lineHeight + 16).clamp(48.0, double.infinity),
        child: CustomScrollView(
          key: const ValueKey('simple-set-strip'),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: _ContentInset.horizontal(constraints.maxWidth),
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    for (var i = 0; i < data.exercise.sets.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Builder(
                          builder: (context) {
                            final set = data.exercise.sets[i];
                            final selected = i == data.cursor.setIndex;
                            final scheme = Theme.of(context).colorScheme;
                            return Semantics(
                              key: selected ? _selectedKey : null,
                              selected: selected,
                              child: OutlinedButton(
                                key: ValueKey('simple-set-$i'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  backgroundColor: selected
                                      ? scheme.primaryContainer
                                      : set.done
                                      ? scheme.secondaryContainer
                                      : null,
                                  foregroundColor: selected
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurfaceVariant,
                                  disabledForegroundColor:
                                      scheme.onSecondaryContainer,
                                  side: BorderSide(
                                    color: selected
                                        ? scheme.primary
                                        : scheme.outlineVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: set.done
                                    ? null
                                    : () => controller.selectSetCursorByIndex(
                                        data.index,
                                        i,
                                      ),
                                child: Text(
                                  '${set.done ? '✓ ' : ''}${_nextUpSetShortLabel(data.exercise, set, context: context)} - ${set.getHumanReadableDescription(t: context.t, weightUnit: controller.weightUnit, distanceUnit: controller.distanceUnit, targetWeightUnit: controller.weightUnit, targetDistanceUnit: controller.distanceUnit, context: context)}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SeriesActions extends StatelessWidget {
  const _SeriesActions({required this.data, required this.controller});
  final _CurrentSetData data;
  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final rpeTint = data.set.rpe == null
        ? null
        : rpeColor(context, data.set.rpe!);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: rpeTint,
                iconColor: rpeTint,
              ),
              icon: const Icon(GTIcons.rpe, size: 18),
              label: Text(
                'RPE ${data.set.rpe == null ? '—' : NumberFormat.compact(locale: context.locale.languageCode).format(data.set.rpe)}',
              ),
              onPressed: () async {
                final generation = controller.sessionGeneration;
                final result = await showDialog<Optional<double?>>(
                  context: context,
                  builder: (_) => WorkoutSetRPEDialog(currentRPE: data.set.rpe),
                );
                if (result != null && controller.isSessionActive(generation)) {
                  controller.callbacks.onSetChangeRPE(
                    data.index,
                    data.cursor.setIndex,
                    result.safeUnwrap(),
                  );
                }
              },
            ),
            TextButton.icon(
              icon: const Icon(GTIcons.rest_timer, size: 18),
              label: Text(
                '${t.exercise.fields.restTime}: ${TimeInputField.encodeDuration(data.restTime)}',
              ),
              onPressed: () => _showRestTimeEditor(context, data),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavigationButton(
              icon: Icons.chevron_left,
              label: t.ongoingWorkout.simple.previousSet,
              onPressed: _hasPreviousSet(controller, data.cursor)
                  ? () {
                      controller.moveSetCursorToPrevious();
                    }
                  : null,
              onLongPress: _hasPreviousSet(controller, data.cursor)
                  ? () {
                      controller.moveSetCursorToFirstUndone();
                    }
                  : null,
            ),
            _NavigationButton(
              icon: Icons.chevron_right,
              label: t.ongoingWorkout.simple.nextSet,
              onPressed: _hasNextSet(controller, data.cursor)
                  ? () {
                      controller.moveSetCursorToNext();
                    }
                  : null,
              onLongPress: _hasNextSet(controller, data.cursor)
                  ? () {
                      controller.moveSetCursorToLastUndone();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.onLongPress,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed, onLongPress;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: SizedBox(
      width: 56,
      height: 48,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Icon(icon),
      ),
    ),
  );
}

/// Touch targets remain usable even under a compact application theme.
class _SimpleViewTheme extends StatelessWidget {
  const _SimpleViewTheme({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = WidgetStatePropertyAll(Size(48, 48));
    return Theme(
      data: theme.copyWith(
        textButtonTheme: TextButtonThemeData(
          style: (theme.textButtonTheme.style ?? const ButtonStyle()).copyWith(
            minimumSize: size,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: (theme.filledButtonTheme.style ?? const ButtonStyle())
              .copyWith(minimumSize: size),
        ),
      ),
      child: child,
    );
  }
}
