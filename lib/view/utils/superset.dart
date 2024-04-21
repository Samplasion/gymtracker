import 'package:flutter/material.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/workout.dart';

class SupersetEditor extends StatefulWidget {
  final Superset superset;
  final int index;
  final bool isCreating;
  final EditorCallbacks callbacks;
  final Weights weightUnit;
  final Distance distanceUnit;

  const SupersetEditor({
    required super.key,
    required this.superset,
    required this.index,
    required this.isCreating,
    required this.callbacks,
    required this.weightUnit,
    required this.distanceUnit,
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
    final topLevelEntryIndex =
        (exerciseIndex: widget.index, supersetIndex: null);
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
                    onTap: () =>
                        widget.callbacks.onExerciseReorder(widget.index),
                    child: ListTile(
                      leading: const Icon(Icons.compare_arrows),
                      title: Text('ongoingWorkout.exercises.reorder'.t),
                    ),
                  ),
                ],
                PopupMenuItem(
                  // We're considering this superset as a top-level exercise entry
                  onTap: () =>
                      widget.callbacks.onExerciseReplace(topLevelEntryIndex),
                  child: ListTile(
                    leading: const Icon(Icons.refresh),
                    title:
                        Text('ongoingWorkout.superset.replaceWithExercise'.t),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () async {
                    final delete = await Go.confirm(
                      "routines.editor.superset.remove.title",
                      "routines.editor.superset.remove.body",
                    );
                    if (delete) {
                      // We're considering this superset as a top-level exercise entry
                      widget.callbacks.onExerciseRemove(topLevelEntryIndex);
                    }
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
                          widget.callbacks.onExerciseNotesChange(
                              topLevelEntryIndex, notesController.text.trim());
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
              onChangedTime: (value) {
                widget.callbacks.onExerciseChangeRestTime(
                    topLevelEntryIndex, value ?? Duration.zero);
              },
            ),
          ),
          const Divider(),
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              widget.callbacks.onSupersetExercisesReorderPair(
                  widget.index, oldIndex, newIndex);
            },
            children: [
              for (int j = 0; j < widget.superset.exercises.length; j++) ...[
                WorkoutExerciseEditor(
                  key: ValueKey(
                      "superset-${widget.superset.exercises[j].name}${widget.superset.id}"),
                  exercise: widget.superset.exercises[j],
                  index: (
                    exerciseIndex: j,
                    supersetIndex: widget.index,
                  ),
                  createDivider: true,
                  isCreating: widget.isCreating,
                  isInSuperset: true,
                  weightUnit: widget.weightUnit,
                  distanceUnit: widget.distanceUnit,
                  callbacks: widget.callbacks,
                ),
              ],
            ],
          ),
          ListTile(
            title: Text("routines.editor.superset.addExercise".t),
            leading: const Icon(Icons.add),
            onTap: () {
              widget.callbacks.onSupersetAddExercise(widget.index);
            },
          ),
          SizedBox(height: widget.superset.exercises.isEmpty ? 8 : 16),
        ],
      ),
    );
  }
}
