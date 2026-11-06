part of '../workout_simple.dart';

class _SimpleProgressionCard extends StatelessWidget {
  const _SimpleProgressionCard({required this.data});

  final _CurrentSetData data;

  @override
  Widget build(BuildContext context) {
    final controller = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(workoutControllerProvider.notifier);
    return SizedBox(
      width: double.infinity,
      child: ExerciseProgressionPanel(
        exercise: data.exercise,
        weightUnit: controller.weightUnit,
        distanceUnit: controller.distanceUnit,
        index: data.index,
        callbacks: controller.callbacks,
        isCreating: false,
      ),
    );
  }
}

class _SetTypeBadge extends StatelessWidget {
  final GTSet set;
  final Exercise exercise;
  final WorkoutExerciseIndex index;
  final int setIndex;

  const _SetTypeBadge({
    required this.set,
    required this.exercise,
    required this.index,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: context.t.set.kind,
      icon: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.t.set.kindLong[set.kind.name]!,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => buildSetKindMenuEntries(
        context: context,
        exercise: exercise,
        set: set,
        onSetSelectKind: (kind) {
          ProviderScope.containerOf(context, listen: false)
              .read(workoutControllerProvider.notifier)
              .callbacks
              .onSetSelectKind(index, setIndex, kind);
        },
      ),
    );
  }
}

class _NotesContent extends StatelessWidget {
  const _NotesContent({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = text.asQuillDocument().isEmpty();
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: isEmpty ? theme.colorScheme.onSurfaceVariant : null,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: isEmpty
                ? Text(
                    context.t.exercise.editor.fields.notes.tapToEdit,
                    style: style,
                  )
                : MaybeRichText(text: text, style: style),
          ),
        ),
      ),
    );
  }
}

class _ExerciseDetails extends StatelessWidget {
  const _ExerciseDetails({super.key, required this.data});
  final _CurrentSetData data;

  @override
  Widget build(BuildContext context) {
    final controller = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(workoutControllerProvider.notifier);
    final exercise = data.exercise;
    final canShowProgression =
        exercise.parameters != GTSetParameters.repsNegWeight &&
        !exercise.parameters.isSetless;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canShowProgression)
          _DetailSection(
            title: context.t.ongoingWorkout.simple.historyAndProgression,
            subtitle:
                exercise.progression == null || controller.parentID == null
                ? context.t.ongoingWorkout.simple.historySummary
                : context.t.ongoingWorkout.simple.progressionSummary,
            icon: Icons.trending_up,
            child: _SimpleProgressionCard(data: data),
          ),
        _DetailSection(
          title: context.t.exercise.editor.fields.notes.label,
          subtitle: _notesPreview(exercise.notes, context),
          icon: GTIcons.notes,
          child: _NotesContent(
            text: exercise.notes,
            onTap: () => _showNotesEditor(
              context,
              initialText: exercise.notes,
              onSave: (text) =>
                  controller.callbacks.onExerciseNotesChange(data.index, text),
            ),
          ),
        ),
        if (data.supersetNotes != null)
          _DetailSection(
            title: context.t.ongoingWorkout.simple.supersetNotes,
            subtitle: _notesPreview(data.supersetNotes!, context),
            icon: GTIcons.superset,
            child: _NotesContent(
              text: data.supersetNotes!,
              onTap: () => _showNotesEditor(
                context,
                initialText: data.supersetNotes!,
                onSave: (text) => controller.callbacks.onExerciseNotesChange((
                  exerciseIndex: data.cursor.supersetIndex!,
                  supersetIndex: null,
                ), text),
              ),
            ),
          ),
      ],
    );
  }
}

String _notesPreview(String notes, BuildContext context) {
  final document = notes.asQuillDocument();
  return document.isEmpty()
      ? context.t.exercise.editor.fields.notes.tapToEdit
      : document.toPlainText().trim().replaceAll(RegExp(r'\s+'), ' ');
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });
  final String title, subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [child],
      ),
    ),
  );
}
