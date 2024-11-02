import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/workout.dart';

class _DateWrapped<T> {
  T data;
  final DateTime date;

  _DateWrapped(this.data) : date = DateTime.now();
}

extension _Wrap<T> on List<T> {
  List<_DateWrapped<T>> wrap() => [for (final data in this) _DateWrapped(data)];
}

extension _Unwrap<T> on RxList<_DateWrapped<T>> {
  List<T> unwrap() => [for (final box in this) box.data];
}

// ignore: library_private_types_in_public_api
_RoutineCreatorController get _controller =>
    Get.put(_RoutineCreatorController());

class RoutineCreator extends StatefulWidget {
  final Workout? base;

  const RoutineCreator({this.base, super.key});

  @override
  State<RoutineCreator> createState() => _RoutineCreatorState();
}

class _RoutineCreatorState extends State<RoutineCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);
  late final infoboxController = QuillController(
    document: (widget.base?.infobox ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  RoutinesController get workoutsController => Get.find<RoutinesController>();

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      _controller.exercises(
          widget.base!.exercises.map((e) => e.clone()).toList().wrap());
    }
  }

  @override
  void dispose() {
    Get.delete<_RoutineCreatorController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(() {
          if (widget.base == null) {
            return "routines.actions.create".t;
          } else {
            return "routines.actions.edit".t;
          }
        }()),
        actions: [
          IconButton(
            icon: const Icon(GTIcons.done),
            onPressed: _submit,
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: GymTrackerInputDecoration(
                  labelText: "routines.editor.fields.name.label".t,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "routines.editor.fields.name.errors.empty".t;
                  }
                  return null;
                },
              ),
              GTRichTextEditor(
                infoboxController: infoboxController,
                decoration: GymTrackerInputDecoration(
                  labelText: "routines.editor.fields.infobox.label".t,
                  alignLabelWithHint: true,
                ),
                onTapOutside: () {},
              ),
              Text("routines.editor.exercises.title".t,
                  style: Theme.of(context).textTheme.titleMedium),
            ].map((c) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ).copyWith(top: 0),
                  child: c,
                )),
            ListTile(
              title: Text("routines.editor.exercises.add".t),
              leading: const CircleAvatar(child: Icon(GTIcons.add_exercise)),
              onTap: () {
                Go.to<List<Exercise>>(() => const ExercisePicker(
                      singlePick: false,
                    )).then((result) {
                  result ??= [];
                  setState(() {
                    _controller.exercises.addAll(result!
                        .map((ex) {
                          return ex.makeChild().copyWith.sets([
                            if (!ex.parameters.isSetless)
                              GTSet.empty(
                                kind: GTSetKind.normal,
                                parameters: ex.parameters,
                              ),
                          ]);
                        })
                        .toList()
                        .wrap());
                  });
                });
              },
            ),
            ListTile(
              title: Text("routines.editor.superset.add".t),
              leading: const CircleAvatar(child: Icon(GTIcons.add_superset)),
              onTap: () {
                Go.to<List<Exercise>>(() => const ExercisePicker(
                      singlePick: false,
                    )).then((result) {
                  result ??= [];
                  setState(() {
                    // controller.exercises.addAll(result!.wrap());
                    _controller.exercises.add(_DateWrapped(
                      Superset(
                        restTime: Duration.zero,
                        exercises: [for (final ex in result!) ex.makeChild()],
                        workoutID: widget.base?.id,
                      ),
                    ));
                  });
                });
              },
            ),
            Obx(
              () => ReorderableListView(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < _controller.exercises.length; i++) ...[
                    exerciseEntry(i),
                  ],
                ],
                onReorder: (oldIndex, newIndex) {
                  reorder(_controller.exercises, oldIndex, newIndex);
                  _controller.exercises.refresh();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exerciseEntry(int i) =>
      _controller.exercises[i].data.map(exercise: (ex) {
        return WorkoutExerciseEditor(
          key: ValueKey("${ex.name}${_controller.exercises[i].date}"),
          exercise: ex,
          index: (exerciseIndex: i, supersetIndex: null),
          isCreating: true,
          weightUnit: Get.find<SettingsController>().weightUnit.value,
          distanceUnit: Get.find<SettingsController>().distanceUnit.value,
          callbacks: _controller.callbacks,
        );
      }, superset: (ss) {
        return SupersetEditor(
          key: ValueKey("superset-${ss.id}${_controller.exercises[i].date}"),
          superset: ss,
          index: i,
          isCreating: true,
          weightUnit: Get.find<SettingsController>().weightUnit.value,
          distanceUnit: Get.find<SettingsController>().distanceUnit.value,
          callbacks: _controller.callbacks,
        );
      });

  void _submit() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      if (widget.base == null) {
        workoutsController.submitRoutine(
          name: titleController.text,
          exercises: _controller.exercises.unwrap(),
          infobox: infoboxController.document.toPlainText().trim().isEmpty
              ? null
              : infoboxController.toEncoded(),
        );
      } else {
        Get.back(
          result: workoutsController.generate(
            name: titleController.text,
            exercises: _controller.exercises.unwrap(),
            id: widget.base!.id,
            infobox: infoboxController.document.toPlainText().trim().isEmpty
                ? null
                : infoboxController.toEncoded(),
            folder: widget.base!.folder,
          ),
        );
      }
    }
  }
}

class _RoutineCreatorController extends GetxController {
  final exercises = <_DateWrapped<WorkoutExercisable>>[].obs;

  EditorCallbacks get callbacks => EditorCallbacks.creation(
        onExerciseReplace: (index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            final newExercise = ex.first.makeChild().copyWith.sets([
              GTSet.empty(
                kind: GTSetKind.normal,
                parameters: ex.first.parameters,
              ),
            ]);
            if (supersetIndex == null) {
              exercises[i].data = newExercise;
            } else {
              exercises[supersetIndex].data =
                  (exercises[supersetIndex].data as Superset)
                      .copyWith(exercises: [
                for (int j = 0;
                    j < (exercises[supersetIndex] as Superset).exercises.length;
                    j++)
                  if (j == i)
                    newExercise
                  else
                    (exercises[supersetIndex] as Superset).exercises[j]
              ]);
            }
            _controller.exercises.refresh();
          });
        },
        onExerciseRemove: (index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            exercises.removeAt(i);
          } else {
            exercises[supersetIndex].data =
                (exercises[supersetIndex].data as Superset)
                    .copyWith(exercises: [
              for (int j = 0;
                  j < (exercises[supersetIndex] as Superset).exercises.length;
                  j++)
                if (j != i) (exercises[supersetIndex] as Superset).exercises[j]
            ]);
          }
          _controller.exercises.refresh();
        },
        onExerciseChangeRestTime: (index, value) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            final ex = exercises[i].data;
            // Type safety
            exercises[i].data = ex is Exercise
                ? ex.copyWith(
                    restTime: value,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        restTime: value,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            // We don't support rest time for individual exercises in a superset
            throw UnimplementedError();
          }
          _controller.exercises.refresh();
        },
        onExerciseSetReorder: (index, newIndices) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            final ex = exercises[i].data as Exercise;
            final newSets = [
              for (final newIndex in newIndices) ex.sets[newIndex]
            ];
            exercises[i].data = ex.copyWith(sets: newSets);
          } else {
            final superset = exercises[supersetIndex].data as Superset;
            exercises[supersetIndex].data = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (final newIndex in newIndices)
                        superset.exercises[j].sets[newIndex]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }
          _controller.exercises.refresh();
        },
        onSetCreate: (index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            final ex = exercises[i].data as Exercise;
            ex.sets.add(
              GTSet.empty(
                kind: GTSetKind.normal,
                parameters: ex.parameters,
              ),
            );
          } else {
            final ex = (exercises[supersetIndex].data as Superset).exercises[i];
            ex.sets.add(
              GTSet.empty(
                kind: GTSetKind.normal,
                parameters: ex.parameters,
              ),
            );
          }
          _controller.exercises.refresh();
        },
        onSetRemove: (exerciseIndex, index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) =
              exerciseIndex;
          if (supersetIndex == null) {
            final ex = exercises[i].data as Exercise;
            exercises[i].data = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j != index) ex.sets[j]
              ],
            );
          } else {
            final ex = (exercises[supersetIndex].data as Superset).exercises[i];
            (exercises[supersetIndex].data as Superset).exercises[i] =
                ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j != index) ex.sets[j]
              ],
            );
          }

          _controller.exercises.refresh();
        },
        onSetSelectKind: (index, setIndex, kind) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            final ex = exercises[i].data as Exercise;
            exercises[i].data = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex)
                    ex.sets[j].copyWith(kind: kind)
                  else
                    ex.sets[j]
              ],
            );
          } else {
            final ex = (exercises[supersetIndex].data as Superset).exercises[i];
            (exercises[supersetIndex].data as Superset).exercises[i] =
                ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex)
                    ex.sets[j].copyWith(kind: kind)
                  else
                    ex.sets[j]
              ],
            );
          }
          _controller.exercises.refresh();
        },
        onSetValueChange: (index, setIndex, newSet) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          if (supersetIndex == null) {
            final ex = exercises[i].data as Exercise;
            exercises[i].data = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          } else {
            final ex = (exercises[supersetIndex].data as Superset).exercises[i];
            (exercises[supersetIndex].data as Superset).exercises[i] =
                ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          }
          _controller.exercises.refresh();
        },
        onExerciseNotesChange: (index, notes) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex].data;
            // Type safety
            exercises[exerciseIndex].data = ex is Exercise
                ? ex.copyWith(
                    notes: notes,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        notes: notes,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex].data as Superset;
            exercises[supersetIndex].data = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    notes: notes,
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
        },
        onSupersetAddExercise: (supersetIndex) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            final newExercise = ex.first.makeChild().copyWith.sets([
              if (!ex.first.parameters.isSetless)
                GTSet.empty(
                  kind: GTSetKind.normal,
                  parameters: ex.first.parameters,
                ),
            ]);
            exercises[supersetIndex].data =
                (exercises[supersetIndex].data as Superset)
                    .copyWith(exercises: [
              ...((exercises[supersetIndex].data as Superset).exercises),
              newExercise,
            ]);
            _controller.exercises.refresh();
          });
        },
        onSupersetExercisesReorderPair:
            (supersetIndex, oldExIndex, newExIndex) {
          final superset = exercises[supersetIndex].data as Superset;
          final supersetExercises = superset.exercises.toList();
          reorder(supersetExercises, oldExIndex, newExIndex);
          _controller.exercises[supersetIndex].data = superset.copyWith(
            exercises: supersetExercises,
          );
          _controller.exercises.refresh();
        },
      );
}
