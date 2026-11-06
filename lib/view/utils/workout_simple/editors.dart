part of '../workout_simple.dart';

class _SimpleSetEditDialog extends StatefulWidget {
  final _CurrentSetData data;

  const _SimpleSetEditDialog({required this.data});

  @override
  State<_SimpleSetEditDialog> createState() => _SimpleSetEditDialogState();
}

class _SimpleSetEditDialogState extends State<_SimpleSetEditDialog> {
  late GTSet _set = widget.data.set.copyWith();

  @override
  Widget build(BuildContext context) {
    final controller = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(workoutControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.ongoingWorkout.simple.editSet)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            _SimpleSetFields(
              data: widget.data,
              set: _set,
              onDelete: () {
                controller.callbacks.onSetRemove(
                  widget.data.index,
                  widget.data.cursor.setIndex,
                );
                Navigator.of(context).pop();
              },
              onChanged: (set) {
                setState(() => _set = set);
                controller.callbacks.onSetValueChange(
                  widget.data.index,
                  widget.data.cursor.setIndex,
                  set,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showRestTimeEditor(
  BuildContext context,
  _CurrentSetData data,
) async {
  final controller = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(workoutControllerProvider.notifier);
  final generation = controller.sessionGeneration;
  final textController = TextEditingController(
    text: TimeInputField.encodeDuration(data.restTime),
  );
  final focusNode = FocusNode();
  Duration restTime = data.restTime;

  SchedulerBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.t.exercise.fields.restTime),
      content: TimeInputField(
        controller: textController,
        focusNode: focusNode,
        decoration: GymTrackerInputDecoration(
          labelText: context.t.exercise.fields.restTime,
        ),
        onChangedTime: (value) {
          restTime = value ?? Duration.zero;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            final index = data.cursor.supersetIndex == null
                ? data.index
                : (
                    exerciseIndex: data.cursor.supersetIndex!,
                    supersetIndex: null,
                  );
            if (controller.isSessionActive(generation)) {
              controller.onExerciseChangeRestTime(index, restTime);
            }
            Navigator.of(ctx).pop();
          },
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );

  textController.dispose();
  focusNode.dispose();
}

Future<void> _showNotesEditor(
  BuildContext context, {
  required String initialText,
  required ValueChanged<String> onSave,
}) async {
  final controller = quillControllerFromText(initialText);
  await showDialog<void>(
    context: context,
    builder: (context) => GTRichTextEditDialog(
      controller: controller,
      onNotesChange: (text) {
        onSave(text);
        Navigator.of(context).pop();
      },
    ),
  );
}

/// Shared fields preserve the existing duration timers and parameter validation.
class _SimpleSetFields extends StatelessWidget {
  const _SimpleSetFields({
    super.key,
    required this.data,
    required this.set,
    required this.onChanged,
    required this.onDelete,
  });
  final _CurrentSetData data;
  final GTSet set;
  final ValueChanged<GTSet> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final controller = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(workoutControllerProvider.notifier);
    return WorkoutExerciseSetEditor(
      exercise: data.exercise,
      set: set,
      index: data.index,
      setIndex: data.cursor.setIndex,
      alt: true,
      isCreating: false,
      showDoneCheckbox: false,
      onDelete: onDelete,
      onSetSelectKind: (kind) => controller.callbacks.onSetSelectKind(
        data.index,
        data.cursor.setIndex,
        kind,
      ),
      onSetSetDone: (done) => controller.callbacks.onSetSetDone(
        data.index,
        data.cursor.setIndex,
        done,
      ),
      onSetChangeRPE: (rpe) => controller.callbacks.onSetChangeRPE(
        data.index,
        data.cursor.setIndex,
        rpe,
      ),
      onSetValueChange: onChanged,
      weightUnit: controller.weightUnit,
      distanceUnit: controller.distanceUnit,
    );
  }
}
