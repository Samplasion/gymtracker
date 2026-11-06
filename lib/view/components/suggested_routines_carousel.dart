import 'package:flutter/material.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';

/// Feed recommendations retain their ranking; the first card gets emphasis.
class SuggestedRoutinesCarousel extends StatelessWidget {
  const SuggestedRoutinesCarousel({
    super.key,
    required this.routines,
    required this.onStart,
    required this.onOpen,
    this.trainer = TrainerState.empty,
  });

  final List<Workout> routines;
  final TrainerState trainer;
  final ValueChanged<Workout> onStart;
  final ValueChanged<Workout> onOpen;

  @override
  Widget build(BuildContext context) {
    if (routines.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text(
              context.t.feed.suggestedRoutines,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * .6).clamp(224.0, 320.0);
              return SingleChildScrollView(
                key: const PageStorageKey('suggested-routines-carousel'),
                primary: false,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < routines.length; index++) ...[
                        if (index > 0) const SizedBox(width: 12),
                        SizedBox(
                          width: cardWidth,
                          child: _SuggestedRoutineCard(
                            key: ValueKey(
                              'suggested-routine-${routines[index].id}',
                            ),
                            routine: routines[index],
                            subtitle: _subtitle(context, routines[index]),
                            highlighted: index == 0,
                            onStart: () => onStart(routines[index]),
                            onOpen: () => onOpen(routines[index]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _subtitle(BuildContext context, Workout routine) {
    if (trainer.controls.contains(routine.id)) {
      final name = (trainer.link?['trainer_name'] as String?)?.trim();
      return name == null || name.isEmpty
          ? context.t.feed.suggestions.assignedByTrainer
          : context.t.feed.suggestions.assignedBy(name: name);
    }
    final folderName = routine.folder?.name.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return folderName == null || folderName.isEmpty
        ? context.t.routines.rootFolder
        : folderName;
  }
}

class _SuggestedRoutineCard extends StatelessWidget {
  const _SuggestedRoutineCard({
    super.key,
    required this.routine,
    required this.subtitle,
    required this.highlighted,
    required this.onStart,
    required this.onOpen,
  });

  final Workout routine;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onStart, onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = highlighted ? scheme.onPrimary : scheme.onSurface;
    final title = routine.name.trim().isEmpty
        ? context.t.general.unnamed
        : routine.name;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: Material(
        color: highlighted ? scheme.primary : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: highlighted
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: highlighted
                        ? foreground.withValues(alpha: .85)
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Spacer(),
                Semantics(
                  label: title,
                  child: FilledButton(
                    key: ValueKey('start-suggested-routine-${routine.id}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: highlighted
                          ? scheme.onPrimary
                          : scheme.secondaryContainer,
                      foregroundColor: highlighted
                          ? scheme.primary
                          : scheme.onSecondaryContainer,
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onStart,
                    child: Text(context.t.feed.suggestions.start),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
