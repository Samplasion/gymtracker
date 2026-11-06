import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/exercises_to_superset.dart';
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

extension _Unwrap<T> on List<_DateWrapped<T>> {
  List<T> unwrap() => [for (final box in this) box.data];
}

class RoutineCreator extends ConsumerStatefulWidget {
  final Workout? base;

  const RoutineCreator({this.base, super.key});

  @override
  ConsumerState<RoutineCreator> createState() => _RoutineCreatorState();
}

class _RoutineCreatorState extends ConsumerState<RoutineCreator> {
  late final _RoutineCreatorController _controller = _RoutineCreatorController(
    () {
      if (!mounted) return;
      if (!_titleIsTouched && widget.base == null) {
        titleController.text = generateWorkoutTitle(
          context.t,
          _controller.exercises
              .expand(
                (e) => e.data.map(
                  exercise: (ex) => [ex.primaryMuscleGroup.category],
                  superset: (ss) =>
                      ss.exercises.map((ex) => ex.primaryMuscleGroup.category),
                ),
              )
              .whereType<GTMuscleCategory>()
              .toSet(),
        );
      }
      setState(() {});
    },
  );
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);
  late final infoboxController = QuillController(
    document: (widget.base?.infobox ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  bool _titleIsTouched = false;

  RoutinesController get workoutsController =>
      ref.read(routinesControllerProvider);

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      _titleIsTouched = true;
      _controller.exercises = widget.base!.exercises
          .map((e) => e.clone())
          .toList()
          .wrap();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        titleController.text = generateWorkoutTitle(context.t, {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appPreferencesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(() {
          if (widget.base == null) {
            return context.t.routines.actions.create;
          } else {
            return context.t.routines.actions.edit;
          }
        }()),
        actions: [
          IconButton(icon: const Icon(GTIcons.done), onPressed: _submit),
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
                  labelText: context.t.routines.editor.fields.name.label,
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return context.t.routines.editor.fields.name.errors.empty;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (!_titleIsTouched) {
                    setState(() {
                      _titleIsTouched = true;
                    });
                  }
                },
              ),
              GTRichTextEditor(
                controller: infoboxController,
                decoration: GymTrackerInputDecoration(
                  labelText: context.t.routines.editor.fields.infobox.label,
                  alignLabelWithHint: true,
                ),
                onTapOutside: () {},
              ),
              Text(
                context.t.routines.editor.exercises.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ].map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ).copyWith(top: 0),
                child: c,
              ),
            ),
            ListTile(
              title: Text(context.t.routines.editor.exercises.add),
              leading: const CircleAvatar(child: Icon(GTIcons.add_exercise)),
              onTap: () {
                Go.to<List<Exercise>>(
                  () => const ExercisePicker(singlePick: false),
                ).then((result) {
                  result ??= [];
                  setState(() {
                    _controller.exercises.addAll(
                      result!
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
                          .wrap(),
                    );
                  });
                });
              },
            ),
            ListTile(
              title: Text(context.t.routines.editor.superset.add),
              leading: const CircleAvatar(child: Icon(GTIcons.add_superset)),
              onTap: () {
                Go.to<List<Exercise>>(
                  () => const ExercisePicker(singlePick: false),
                ).then((result) {
                  result ??= [];
                  setState(() {
                    // controller.exercises.addAll(result!.wrap());
                    _controller.exercises.add(
                      _DateWrapped(
                        Superset(
                          restTime: Duration.zero,
                          exercises: [for (final ex in result!) ex.makeChild()],
                          workoutID: widget.base?.id,
                        ),
                      ),
                    );
                  });
                });
              },
            ),
            Builder(
              builder: (context) => ReorderableListView(
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
                  _controller.changed();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exerciseEntry(int i) => _controller.exercises[i].data.map(
    exercise: (ex) {
      return WorkoutExerciseEditor(
        key: ValueKey("${ex.name}${_controller.exercises[i].date}"),
        exercise: ex,
        index: (exerciseIndex: i, supersetIndex: null),
        isCreating: true,
        weightUnit: ref.read(settingsControllerInstanceProvider).weightUnit,
        distanceUnit: ref.read(settingsControllerInstanceProvider).distanceUnit,
        callbacks: _controller.callbacks,
      );
    },
    superset: (ss) {
      return SupersetEditor(
        key: ValueKey("superset-${ss.id}${_controller.exercises[i].date}"),
        superset: ss,
        index: i,
        isCreating: true,
        weightUnit: ref.read(settingsControllerInstanceProvider).weightUnit,
        distanceUnit: ref.read(settingsControllerInstanceProvider).distanceUnit,
        callbacks: _controller.callbacks,
      );
    },
  );

  void _submit() {
    if (!_titleIsTouched) {
      titleController.text = generateWorkoutTitle(
        context.t,
        _controller.exercises
            .unwrap()
            .expand((e) {
              if (e is Exercise) {
                return {e.primaryMuscleGroup.category};
              } else if (e is Superset) {
                return e.exercises.expand(
                  (ex) => {ex.primaryMuscleGroup.category},
                );
              }
              return <GTMuscleCategory>{};
            })
            .whereType<GTMuscleCategory>()
            .toSet(),
      );
    }
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
        Go.back();
      } else {
        Go.back(
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

class _RoutineCreatorController {
  _RoutineCreatorController(this.changed);
  final VoidCallback changed;
  List<_DateWrapped<WorkoutExercisable>> exercises = [];

  Exercise _withRoutineSets(Exercise exercise, List<GTSet> sets) =>
      exercise.copyWith(
        sets: sets,
        progression: exercise.progression?.forRoutineSets(exercise.sets, sets),
      );

  EditorCallbacks get callbacks => EditorCallbacks.creation(
    onExerciseProgressionChange: (index, progression) {
      if (index.supersetIndex == null) {
        final ex = exercises[index.exerciseIndex].data as Exercise;
        exercises[index.exerciseIndex].data = ex.copyWith(
          progression: progression,
        );
      } else {
        final wrapper = exercises[index.supersetIndex!];
        final superset = wrapper.data as Superset;
        wrapper.data = superset.copyWith(
          exercises: [
            for (var i = 0; i < superset.exercises.length; i++)
              i == index.exerciseIndex
                  ? superset.exercises[i].copyWith(progression: progression)
                  : superset.exercises[i],
          ],
        );
      }
      changed();
    },
    onExerciseReplace: (index) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        final ex = await Go.to<List<Exercise>>(
          () => const ExercisePicker(singlePick: true),
        );
        if (ex == null || ex.isEmpty) return;
        final newExercise = ex.first.makeChild().copyWith.sets([
          if (!ex.first.parameters.isSetless)
            GTSet.empty(
              kind: GTSetKind.normal,
              parameters: ex.first.parameters,
            ),
        ]);
        if (supersetIndex == null) {
          exercises[i].data = newExercise;
        } else {
          exercises[supersetIndex].data =
              (exercises[supersetIndex].data as Superset).copyWith(
                exercises: [
                  for (
                    int j = 0;
                    j < (exercises[supersetIndex] as Superset).exercises.length;
                    j++
                  )
                    if (j == i)
                      newExercise
                    else
                      (exercises[supersetIndex] as Superset).exercises[j],
                ],
              );
        }
        changed();
      });
    },
    onExerciseRemove: (index) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        exercises.removeAt(i);
      } else {
        exercises[supersetIndex]
            .data = (exercises[supersetIndex].data as Superset).copyWith(
          exercises: [
            for (
              int j = 0;
              j < (exercises[supersetIndex] as Superset).exercises.length;
              j++
            )
              if (j != i) (exercises[supersetIndex] as Superset).exercises[j],
          ],
        );
      }
      changed();
    },
    onExerciseChangeRestTime: (index, value) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        final ex = exercises[i].data;
        // Type safety
        exercises[i].data = ex is Exercise
            ? ex.copyWith(restTime: value)
            : ex is Superset
            ? ex.copyWith(restTime: value)
            : throw AssertionError("Unreachable yet");
      } else {
        // A child uses the shared recovery interval of its superset.
        final superset = exercises[supersetIndex].data as Superset;
        exercises[supersetIndex].data = superset.copyWith(restTime: value);
      }
      changed();
    },
    onExerciseSetReorder: (index, newIndices) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        final newSets = [for (final newIndex in newIndices) ex.sets[newIndex]];
        exercises[i].data = _withRoutineSets(ex, newSets);
      } else {
        final superset = exercises[supersetIndex].data as Superset;
        exercises[supersetIndex].data = superset.copyWith(
          exercises: [
            for (int j = 0; j < superset.exercises.length; j++)
              if (j == i)
                _withRoutineSets(superset.exercises[j], [
                  for (final newIndex in newIndices)
                    superset.exercises[j].sets[newIndex],
                ])
              else
                superset.exercises[j],
          ],
        );
      }
      changed();
    },
    onSetCreate: (index) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        exercises[i].data = _withRoutineSets(ex, [
          ...ex.sets,
          GTSet.empty(kind: GTSetKind.normal, parameters: ex.parameters),
        ]);
      } else {
        final ex = (exercises[supersetIndex].data as Superset).exercises[i];
        (exercises[supersetIndex].data as Superset).exercises[i] =
            _withRoutineSets(ex, [
              ...ex.sets,
              GTSet.empty(kind: GTSetKind.normal, parameters: ex.parameters),
            ]);
      }
      changed();
    },
    onSetRemove: (exerciseIndex, index) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = exerciseIndex;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        exercises[i].data = _withRoutineSets(ex, [
          for (int j = 0; j < ex.sets.length; j++)
            if (j != index) ex.sets[j],
        ]);
      } else {
        final ex = (exercises[supersetIndex].data as Superset).exercises[i];
        (exercises[supersetIndex].data as Superset).exercises[i] =
            _withRoutineSets(ex, [
              for (int j = 0; j < ex.sets.length; j++)
                if (j != index) ex.sets[j],
            ]);
      }

      changed();
    },
    onSetSelectKind: (index, setIndex, kind) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        exercises[i].data = _withRoutineSets(ex, [
          for (int j = 0; j < ex.sets.length; j++)
            if (j == setIndex) ex.sets[j].copyWith(kind: kind) else ex.sets[j],
        ]);
      } else {
        final ex = (exercises[supersetIndex].data as Superset).exercises[i];
        (exercises[supersetIndex].data as Superset)
            .exercises[i] = _withRoutineSets(ex, [
          for (int j = 0; j < ex.sets.length; j++)
            if (j == setIndex) ex.sets[j].copyWith(kind: kind) else ex.sets[j],
        ]);
      }
      changed();
    },
    onSetChangeRPE: (exerciseIndex, setIndex, newRPE) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = exerciseIndex;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        exercises[i].data = ex.copyWith(
          sets: [
            for (int j = 0; j < ex.sets.length; j++)
              if (j == setIndex)
                ex.sets[j].copyWith(rpe: newRPE)
              else
                ex.sets[j],
          ],
        );
      } else {
        final ex = (exercises[supersetIndex].data as Superset).exercises[i];
        (exercises[supersetIndex].data as Superset).exercises[i] = ex.copyWith(
          sets: [
            for (int j = 0; j < ex.sets.length; j++)
              if (j == setIndex)
                ex.sets[j].copyWith(rpe: newRPE)
              else
                ex.sets[j],
          ],
        );
      }
      changed();
    },
    onSetValueChange: (index, setIndex, newSet) {
      final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
      if (supersetIndex == null) {
        final ex = exercises[i].data as Exercise;
        exercises[i].data = ex.copyWith(
          sets: [
            for (int j = 0; j < ex.sets.length; j++)
              if (j == setIndex) newSet else ex.sets[j],
          ],
        );
      } else {
        final ex = (exercises[supersetIndex].data as Superset).exercises[i];
        (exercises[supersetIndex].data as Superset).exercises[i] = ex.copyWith(
          sets: [
            for (int j = 0; j < ex.sets.length; j++)
              if (j == setIndex) newSet else ex.sets[j],
          ],
        );
      }
      changed();
    },
    onExerciseNotesChange: (index, notes) {
      final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) =
          index;

      if (supersetIndex == null) {
        final ex = exercises[exerciseIndex].data;
        // Type safety
        exercises[exerciseIndex].data = ex is Exercise
            ? ex.copyWith(notes: notes)
            : ex is Superset
            ? ex.copyWith(notes: notes)
            : throw AssertionError("Unreachable yet");
      } else {
        final superset = exercises[supersetIndex].data as Superset;
        exercises[supersetIndex].data = superset.copyWith(
          exercises: [
            for (int j = 0; j < superset.exercises.length; j++)
              if (j == exerciseIndex)
                superset.exercises[j].copyWith(notes: notes)
              else
                superset.exercises[j],
          ],
        );
      }

      changed();
    },
    onSupersetAddExercise: (supersetIndex) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        final ex = await Go.to<List<Exercise>>(
          () => const ExercisePicker(singlePick: true),
        );
        if (ex == null || ex.isEmpty) return;
        final newExercise = ex.first.makeChild().copyWith.sets([
          if (!ex.first.parameters.isSetless)
            GTSet.empty(
              kind: GTSetKind.normal,
              parameters: ex.first.parameters,
            ),
        ]);
        exercises[supersetIndex].data =
            (exercises[supersetIndex].data as Superset).copyWith(
              exercises: [
                ...((exercises[supersetIndex].data as Superset).exercises),
                newExercise,
              ],
            );
        changed();
      });
    },
    onSupersetExercisesReorderPair: (supersetIndex, oldExIndex, newExIndex) {
      final superset = exercises[supersetIndex].data as Superset;
      final supersetExercises = superset.exercises.toList();
      reorder(supersetExercises, oldExIndex, newExIndex);
      exercises[supersetIndex].data = superset.copyWith(
        exercises: supersetExercises,
      );
      changed();
    },
    onGroupExercisesIntoSuperset: (startingIndex) async {
      final indices = await Go.toDialog(
        () => ExercisesToSupersetDialog(
          exercises: [for (final ex in exercises) ex.data],
          startingIndex: startingIndex,
        ),
      );

      if (indices == null || indices.length < 2) return;

      final newSuperset = Superset(
        restTime: Duration.zero,
        workoutID: null,
        exercises: [
          for (final index in indices) exercises[index].data as Exercise,
        ],
      );

      final newExercises = [
        for (int i = 0; i < indices.first; i++) exercises[i],
        _DateWrapped(newSuperset),
        for (int i = indices.last + 1; i < exercises.length; i++) exercises[i],
      ];

      exercises = newExercises;
      changed();
    },
  );
}
