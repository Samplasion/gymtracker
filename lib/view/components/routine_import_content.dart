import 'package:flutter/material.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/section_card.dart';

/// Read-only import layout: one scroll surface, no nested navigation or toolbars.
class RoutineImportContent extends StatelessWidget {
  const RoutineImportContent({
    super.key,
    required this.routines,
    this.notes = '',
    this.selectedDay = 0,
    this.onDayChanged,
  });
  final List<Workout> routines;
  final String notes;
  final int selectedDay;
  final ValueChanged<int>? onDayChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.t.routineImport;
    final routine = routines[selectedDay];
    final exerciseCount = routines.fold(
      0,
      (n, r) => n + r.displayExerciseCount,
    );
    final setCount = routines.fold(0, (n, r) => n + r.allSets.length);
    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GTSectionCard(
                  icon: Icons.download_rounded,
                  title: s.summary,
                  subtitle: s.summaryDescription,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CountChip(s.days(n: routines.length)),
                      _CountChip(s.exercises(n: exerciseCount)),
                      _CountChip(s.sets(n: setCount)),
                    ],
                  ),
                ),
                if (_hasNotes(notes)) ...[
                  const SizedBox(height: 16),
                  _ImportNotes(title: s.programNotes, notes: notes),
                ],
                if (routines.length > 1) ...[
                  const SizedBox(height: 16),
                  GTSectionCard(
                    icon: Icons.view_day_outlined,
                    title: s.preview,
                    subtitle: s.dayDescription,
                    child: DropdownButtonFormField<int>(
                      key: ValueKey(selectedDay),
                      initialValue: selectedDay,
                      isExpanded: true,
                      isDense: false,
                      itemHeight: null,
                      decoration: InputDecoration(
                        labelText: s.day,
                        isDense: false,
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      items: [
                        for (var i = 0; i < routines.length; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(routines[i].name),
                            ),
                          ),
                      ],
                      onChanged: onDayChanged == null
                          ? null
                          : (value) {
                              if (value != null) onDayChanged!(value);
                            },
                    ),
                  ),
                ],
                if (routine.shouldShowInfobox) ...[
                  const SizedBox(height: 16),
                  _ImportNotes(title: s.workoutNotes, notes: routine.infobox!),
                ],
                const SizedBox(height: 16),
                GTSectionCard(
                  icon: Icons.fitness_center_rounded,
                  title: s.exerciseList,
                  subtitle: context.t.general.exercises(
                    n: routine.displayExerciseCount,
                  ),
                  child: routine.exercises.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.emptyTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.emptyDescription,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (
                              var i = 0;
                              i < routine.exercises.length;
                              i++
                            ) ...[
                              if (i > 0)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(height: 1),
                                ),
                              _ImportExercise(
                                entry: routine.exercises[i],
                                routine: routine,
                                number: i + 1,
                              ),
                            ],
                          ],
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

bool _hasNotes(String text) =>
    text.trim().isNotEmpty && !text.asQuillDocument().isEmpty();

class _ImportNotes extends StatelessWidget {
  const _ImportNotes({required this.title, required this.notes});
  final String title;
  final String notes;
  @override
  Widget build(BuildContext context) => GTSectionCard(
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 12),
      shape: const Border(),
      collapsedShape: const Border(),
      leading: const GTSectionIcon(Icons.notes_rounded),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [MaybeRichText(text: notes)],
    ),
  );
}

class _CountChip extends StatelessWidget {
  const _CountChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  );
}

class _ImportExercise extends StatelessWidget {
  const _ImportExercise({
    required this.entry,
    required this.routine,
    required this.number,
  });
  final WorkoutExercisable entry;
  final Workout routine;
  final int number;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.t.routineImport;
    if (entry is Superset) {
      final group = entry as Superset;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.layers_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.t.superset(n: group.exercises.length),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.rest(
              duration: s.seconds(
                count: group.restTime.inSeconds.localizedWith(context.t),
              ),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (_hasNotes(group.notes)) ...[
            const SizedBox(height: 12),
            MaybeRichText(text: group.notes),
          ],
          for (var i = 0; i < group.exercises.length; i++) ...[
            const SizedBox(height: 16),
            _ImportExercise(
              entry: group.exercises[i],
              routine: routine,
              number: i + 1,
            ),
          ],
        ],
      );
    }
    final exercise = entry as Exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$number',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.getDisplayName(context.t),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (exercise.isCustom) s.custom,
                      s.rest(
                        duration: s.seconds(
                          count: exercise.restTime.inSeconds.localizedWith(
                            context.t,
                          ),
                        ),
                      ),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_hasNotes(exercise.notes)) ...[
          const SizedBox(height: 12),
          MaybeRichText(text: exercise.notes),
        ],
        if (exercise.sets.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < exercise.sets.length; i++)
            _ImportSet(set: exercise.sets[i], routine: routine, number: i + 1),
        ] else if (!exercise.parameters.isSetless) ...[
          const SizedBox(height: 12),
          Text(
            s.noSets,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ImportSet extends StatelessWidget {
  const _ImportSet({
    required this.set,
    required this.routine,
    required this.number,
  });
  final GTSet set;
  final Workout routine;
  final int number;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).colorScheme;
    final values = <String>[
      if (set.parameters.hasReps) t.exerciseList.fields.reps(n: set.reps ?? 0),
      if (set.parameters.hasWeight)
        '${set.parameters == GTSetParameters.repsNegWeight ? '${t.routineImport.assistance} ' : ''}${routine.weightUnit.format(t, set.parameters == GTSetParameters.repsNegWeight ? (set.weight ?? 0).abs() : set.weight ?? 0)}',
      if (set.parameters.hasTime)
        t.routineImport.seconds(
          count: ((set.time?.inMilliseconds ?? 0) / 1000).localizedWith(t),
        ),
      if (set.parameters.hasDistance)
        routine.distanceUnit.format(t, set.distance ?? 0),
    ];
    final details = <String>[
      if (set.kind != GTSetKind.normal) t.set.kindLong[set.kind.name] ?? '',
      if (set.rpe != null)
        t.exerciseList.fields.rpe(rpe: set.rpe!.localizedWith(t)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$number',
              textAlign: TextAlign.center,
              semanticsLabel: t.routineImport.setNumber(number: number),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  values.join(' × '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (details.isNotEmpty)
                  Text(
                    details.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineImportActionBar extends StatelessWidget {
  const RoutineImportActionBar({
    super.key,
    required this.isPro,
    required this.onPressed,
    this.busy = false,
    this.error,
  });
  final bool isPro;
  final VoidCallback onPressed;
  final bool busy;
  final String? error;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed: busy ? null : onPressed,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text.rich(
                      TextSpan(
                        text: busy
                            ? context.t.routineImport.importing
                            : context.t.importRoutine.import.label,
                        children: [
                          if (!isPro) ...[
                            const TextSpan(text: ' '),
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: ProBadge(),
                            ),
                          ],
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
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
