import 'package:flutter/material.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/workout.dart';

class SupersetEditor extends StatefulWidget {
  final Superset superset;
  final int index;
  final bool isCreating;
  final VoidCallback onSupersetRemove;
  final VoidCallback onSupersetReorder;
  final VoidCallback onSupersetReplace;
  final ValueChanged<Duration> onSupersetChangeRestTime;
  final VoidCallback onExerciseAdd;
  final void Function(int index) onExerciseRemove;
  final void Function(int index) onExerciseReorder;
  final void Function(int oldIndex, int newIndex) onExerciseReorderIndexed;
  final void Function(int index) onExerciseReplace;
  final void Function(int index, Duration time) onExerciseChangeRestTime;
  final void Function(int index) onExerciseSetCreate;
  final void Function(int exIndex, int setIndex) onExerciseSetRemove;
  final void Function(int exIndex, ExSet set, SetKind kind)
      onExerciseSetSelectKind;
  final void Function(Exercise exercise, ExSet set, bool isDone)
      onExerciseSetSetDone;
  final VoidCallback onExerciseSetValueChange;
  final void Function(Superset superset, String notes) onNotesChange;
  final void Function(Exercise exercise, String notes) onExerciseNotesChange;

  const SupersetEditor({
    required super.key,
    required this.superset,
    required this.index,
    required this.isCreating,
    required this.onSupersetRemove,
    required this.onSupersetReorder,
    required this.onSupersetReplace,
    required this.onSupersetChangeRestTime,
    required this.onExerciseAdd,
    required this.onExerciseRemove,
    required this.onExerciseReorder,
    required this.onExerciseReorderIndexed,
    required this.onExerciseReplace,
    required this.onExerciseChangeRestTime,
    required this.onExerciseSetCreate,
    required this.onExerciseSetRemove,
    required this.onExerciseSetSelectKind,
    required this.onExerciseSetSetDone,
    required this.onExerciseSetValueChange,
    required this.onNotesChange,
    required this.onExerciseNotesChange,
  });

  @override
  State<SupersetEditor> createState() => _SupersetEditorState();
}

class _SupersetEditorState extends State<SupersetEditor> {
  late final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(widget.superset.restTime),
  );
  late final notesController =
      TextEditingController(text: widget.superset.notes);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text("routines.editor.superset.title".t),
            subtitle: Text("routines.editor.superset.subtitle"
                .plural(widget.superset.exercises.length)),
            leading: widget.isCreating
                ? DragHandle(
                    index: widget.index,
                  )
                : ExerciseIcon(exercise: widget.superset),
            trailing: PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                if (!widget.isCreating) ...[
                  PopupMenuItem(
                    onTap: widget.onSupersetReorder,
                    child: ListTile(
                      leading: const Icon(Icons.compare_arrows),
                      title: Text('ongoingWorkout.exercises.reorder'.t),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: widget.onSupersetReplace,
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title:
                          Text('ongoingWorkout.superset.replaceWithExercise'.t),
                    ),
                  ),
                  const PopupMenuDivider(),
                ],
                PopupMenuItem(
                  onTap: () async {
                    final delete = await Go.confirm(
                      "routines.editor.superset.remove.title",
                      "routines.editor.superset.remove.body",
                    );
                    if (delete) widget.onSupersetRemove();
                  },
                  child: ListTile(
                    textColor: Theme.of(context).colorScheme.error,
                    iconColor: Theme.of(context).colorScheme.error,
                    leading: const Icon(Icons.delete),
                    title: Text('ongoingWorkout.superset.remove'.t),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(
              widget.superset.notes.isEmpty
                  ? "exercise.editor.fields.notes.label".t
                  : widget.superset.notes,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontStyle: widget.superset.notes.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: widget.superset.notes.isEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: widget.superset.notes.isEmpty ? 15 : null,
                  ),
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(24),
                    title: Text('exercise.editor.fields.notes.label'.t),
                    content: TextField(
                      controller: notesController,
                      autofocus: true,
                      minLines: 4,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "exercise.editor.fields.notes.label".t,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(MaterialLocalizations.of(context)
                            .cancelButtonLabel),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onNotesChange(
                              widget.superset, notesController.text.trim());
                          Navigator.pop(context);
                        },
                        child: Text(
                            MaterialLocalizations.of(context).okButtonLabel),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TimeInputField(
              controller: timeController,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                labelText: "exercise.fields.restTime".t,
              ),
              // onChangedTime: (value) =>
              //     widget.onChangeRestTime(value ?? Duration.zero),
              onChangedTime: (value) {
                widget.onSupersetChangeRestTime(value ?? Duration.zero);
              },
            ),
          ),
          const Divider(),
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              // _reorder(widget.superset.exercises, oldIndex, newIndex);
              // controller.exercises.refresh();
              widget.onExerciseReorderIndexed(oldIndex, newIndex);
            },
            children: [
              for (int j = 0; j < widget.superset.exercises.length; j++) ...[
                WorkoutExerciseEditor(
                  key: ValueKey(
                      "superset-${widget.superset.exercises[j].name}${widget.superset.id}"),
                  exercise: widget.superset.exercises[j],
                  index: j,
                  createDivider: true,
                  isCreating: widget.isCreating,
                  isInSuperset: true,
                  onReorder: () {
                    widget.onExerciseReorder(j);
                  },
                  onReplace: () {
                    widget.onExerciseReplace(j);
                  },
                  onRemove: () {
                    widget.onExerciseRemove(j);
                  },
                  onChangeRestTime: (value) {
                    // widget.superset.restTime = value;
                    // controller.exercises.refresh();
                    widget.onExerciseChangeRestTime(j, value);
                  },
                  onSetCreate: () {
                    // final ex = widget.superset.exercises[j];
                    // widget.superset.exercises[j].sets.add(
                    //   ExSet.empty(
                    //     kind: SetKind.normal,
                    //     parameters: ex.parameters,
                    //   ),
                    // );
                    // controller.exercises.refresh();
                    widget.onExerciseSetCreate(j);
                  },
                  onSetRemove: (int index) {
                    // setState(() {
                    //   // widget.superset.exercises[j].sets.removeAt(index);
                    //   // controller.exercises.refresh();
                    // });
                    widget.onExerciseSetRemove(j, index);
                  },
                  onSetSelectKind: (set, kind) {
                    // set.kind = kind;
                    // controller.exercises.refresh();
                    widget.onExerciseSetSelectKind(j, set, kind);
                  },
                  onSetSetDone: (ex, set, done) {
                    widget.onExerciseSetSetDone(ex, set, done);
                  },
                  onSetValueChange: () {
                    widget.onExerciseSetValueChange();
                  },
                  onNotesChange: (ex, notes) {
                    // ex.notes = notes;
                    // controller.exercises.refresh();
                    widget.onExerciseNotesChange(ex, notes);
                  },
                ),
              ],
            ],
          ),
          ListTile(
            title: Text("routines.editor.superset.addExercise".t),
            leading: const Icon(Icons.add),
            onTap: () {
              widget.onExerciseAdd();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
