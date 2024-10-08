import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/exercises_to_superset.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:gymtracker/view/utils/workout.dart';

class WorkoutEditor extends StatefulWidget {
  final Workout baseWorkout;

  const WorkoutEditor({required this.baseWorkout, super.key});

  @override
  State<WorkoutEditor> createState() => _WorkoutEditorState();
}

class _WorkoutEditorState extends State<WorkoutEditor> {
  late Workout workout = widget.baseWorkout.clone();

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();

    try {
      Get.find<WorkoutController>().save();
    } catch (_) {}
  }

  late final historyController = Get.find<HistoryController>();

  bool shouldPop() {
    return Workout.deepEquality(workout, widget.baseWorkout);
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: <T>(didPop, result) async {
        if (didPop) return;
        if (shouldPop()) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            nav.pop(result);
          });
        } else {
          SchedulerBinding.instance.addPostFrameCallback((_) async {
            final confirm = await Go.confirm(
              "historyEditor.actions.discardChanges".t,
              "historyEditor.actions.discardChangesContent".t,
            );

            if (confirm) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                nav.pop(result);
              });
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Text("historyEditor.title".tParams({"name": workout.name})),
          actions: [
            IconButton(
              tooltip: "ongoingWorkout.weightCalculator".t,
              icon: const Icon(GTIcons.weight_calculator),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => WeightCalculator(
                    weightUnit: workout.weightUnit,
                  ),
                );
              },
            ),
            PopupMenuButton(
              key: const Key("main-menu"),
              itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                PopupMenuItem(
                  child: Text(
                    "historyEditor.actions.changeWeightUnit".t,
                  ),
                  onTap: () {
                    setState(() {
                      changeWeightUnitDialog();
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text(
                    "ongoingWorkout.actions.changeDistanceUnit".t,
                  ),
                  onTap: () {
                    setState(() {
                      changeDistanceUnitDialog();
                    });
                  },
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  child: Text(
                    "historyEditor.actions.finish".t,
                  ),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      historyController.finishEditingWorkoutWithDialog(
                        context,
                        workout,
                      );
                    });
                  },
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(
                10, (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight)),
            child: WorkoutInfoBar(
              reps: workout.reps,
              liftedWeight: workout.liftedWeight,
              progress: workout.progress,
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: ListView(
          children: [
            if (workout.shouldShowInfobox) Infobox(text: workout.infobox!),
            for (int i = 0; i < workout.exercises.length; i++)
              if (workout.exercises[i] is Exercise)
                WorkoutExerciseEditor(
                  key: ValueKey((workout.exercises[i] as Exercise).id),
                  exercise: workout.exercises[i] as Exercise,
                  index: (exerciseIndex: i, supersetIndex: null),
                  isCreating: false,
                  weightUnit: workout.weightUnit,
                  distanceUnit: workout.distanceUnit,
                  callbacks: callbacks,
                )
              else
                SupersetEditor(
                  superset: workout.exercises[i] as Superset,
                  index: i,
                  isCreating: false,
                  key: ValueKey((workout.exercises[i] as Superset).id),
                  weightUnit: workout.weightUnit,
                  distanceUnit: workout.distanceUnit,
                  callbacks: callbacks,
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SplitButton(segments: [
                SplitButtonSegment(
                  title: 'historyEditor.exercises.add'.t,
                  type: SplitButtonSegmentType.filled,
                  onTap: () async {
                    final exs = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: false));
                    if (exs == null || exs.isEmpty) return;
                    workout.exercises.addAll(
                      exs.map((ex) => ex.makeChild().copyWith.sets([
                            GTSet.empty(
                              kind: GTSetKind.normal,
                              parameters: ex.parameters,
                            ),
                          ])),
                    );
                    setState(() {});
                  },
                ),
                SplitButtonSegment(
                  title: "historyEditor.exercises.addSuperset".t,
                  onTap: () {
                    setState(() {
                      workout.exercises.add(Superset.empty());
                    });
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void changeWeightUnitDialog() {
    Go.showRadioModal(
      selectedValue: workout.weightUnit,
      title: Text("ongoingWorkout.actions.changeWeightUnit".t),
      values: {
        for (final val in Weights.values) val: "weightUnits.${val.name}".t,
      },
      onChange: (value) {
        logger.w("Changing weight unit to $value");
        if (value != null) workout = workout.copyWith.weightUnit(value);
        setState(() {});
      },
    );
  }

  void changeDistanceUnitDialog() {
    Go.showRadioModal(
      selectedValue: workout.distanceUnit,
      title: Text("ongoingWorkout.actions.changeDistanceUnit".t),
      values: {
        for (final distance in Distance.values)
          distance: "distanceUnits.${distance.name}".t,
      },
      onChange: (value) {
        logger.i("Changing distance unit to $value");
        if (value != null) workout = workout.copyWith.distanceUnit(value);
        setState(() {});
      },
    );
  }

  void _setExercises(List<WorkoutExercisable> exercises) => setState(() {
        workout = workout.copyWith.exercises(exercises);
      });

  EditorCallbacks get callbacks => EditorCallbacks.editor(
        onExerciseReorder: (supersetIndex) async {
          final target = supersetIndex == null
              ? workout.exercises
              : (workout.exercises[supersetIndex] as Superset).exercises
                  as List<WorkoutExercisable>;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final newIndices = await showDialog<List<int>>(
              builder: (context) => WorkoutExerciseReorderDialog(
                exercises: target,
              ),
              context: Get.context!,
            );
            if (newIndices == null || newIndices.length != target.length) {
              return;
            }

            if (supersetIndex == null) {
              _setExercises([
                for (int i = 0; i < newIndices.length; i++)
                  target[newIndices[i]]
              ]);
            } else {
              final newExercises = workout.exercises.toList();
              newExercises[supersetIndex] =
                  (newExercises[supersetIndex] as Superset)
                      .copyWith(exercises: [
                for (int i = 0; i < newIndices.length; i++)
                  target[newIndices[i]] as Exercise,
              ]);
              _setExercises(newExercises);
            }
          });
          setState(() {});
        },
        onExerciseReplace: (ExerciseIndex index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final old = supersetIndex == null
                ? workout.exercises[i]
                : (workout.exercises[supersetIndex] as Superset).exercises[i];
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            final newExercise = old is Exercise
                ? Exercise.replaced(
                    from: old,
                    to: ex.first.makeChild(),
                  )
                : ex.first.makeChild().copyWith(sets: [
                    GTSet.empty(
                        kind: GTSetKind.normal,
                        parameters: ex.first.parameters),
                  ]);
            final newExercises = workout.exercises.toList();
            if (supersetIndex == null) {
              newExercises[i] = newExercise;
            } else {
              newExercises[supersetIndex] =
                  (newExercises[supersetIndex] as Superset)
                      .copyWith(exercises: [
                for (int j = 0;
                    j <
                        (newExercises[supersetIndex] as Superset)
                            .exercises
                            .length;
                    j++)
                  if (j == i)
                    newExercise
                  else
                    (newExercises[supersetIndex] as Superset).exercises[j]
              ]);
            }
            _setExercises(newExercises);
          });
        },
        onExerciseRemove: (index) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;
          final newExercises = workout.exercises.toList();
          if (supersetIndex == null) {
            newExercises.removeAt(exerciseIndex);
          } else {
            final superset = newExercises[supersetIndex] as Superset;
            newExercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j != exerciseIndex) superset.exercises[j]
            ]);
          }
          _setExercises(newExercises);
        },
        onExerciseChangeRestTime: (index, value) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    restTime: value,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        restTime: value,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            // We don't support changing rest time for individual exercises in a superset
            throw UnimplementedError();
          }

          _setExercises(exercises);
        },
        onExerciseChangeRPE: (index, rpe) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(rpe: rpe)
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (int j = 0; j < ex.exercises.length; j++)
                            if (j == exerciseIndex)
                              ex.exercises[j].copyWith(rpe: rpe)
                            else
                              ex.exercises[j]
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(rpe: rpe)
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onExerciseSetReorder: (index, newIndices) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    sets: [
                      for (int j = 0; j < ex.sets.length; j++)
                        ex.sets[newIndices[j]]
                    ],
                  )
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (int j = 0; j < ex.exercises.length; j++)
                            if (j == exerciseIndex)
                              ex.exercises[j].copyWith(
                                sets: [
                                  for (int k = 0;
                                      k < ex.exercises[j].sets.length;
                                      k++)
                                    ex.exercises[j].sets[newIndices[k]]
                                ],
                              )
                            else
                              ex.exercises[j]
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        superset.exercises[j].sets[newIndices[k]]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSetCreate: (index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercises = workout.exercises.toList();

          final set = GTSet.empty(
            kind: GTSetKind.normal,
            parameters: supersetIndex == null
                ? (exercises[i] as Exercise).parameters
                : (exercises[supersetIndex] as Superset)
                    .exercises[i]
                    .parameters,
          );

          if (supersetIndex == null) {
            exercises[i].sets.add(set);
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      ...superset.exercises[j].sets,
                      set,
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSetRemove: (index, setIndex) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            exercises[i].sets.removeAt(setIndex);
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k != setIndex) superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSetSelectKind: (index, setIndex, kind) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercises = workout.exercises.toList();

          final exercise = supersetIndex == null
              ? (exercises[i] as Exercise)
              : (exercises[supersetIndex] as Superset).exercises[i];
          final set = exercise.sets[setIndex];

          final newSet = set.copyWith(kind: kind);

          if (supersetIndex == null) {
            final ex = exercises[i] as Exercise;
            exercises[i] = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          newSet
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSetSetDone: (index, setIndex, done) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercises = workout.exercises.toList();

          final exercise = supersetIndex == null
              ? (exercises[i] as Exercise)
              : (exercises[supersetIndex] as Superset).exercises[i];
          final set = exercise.sets[setIndex];

          final newSet = set.copyWith(done: done);

          if (supersetIndex == null) {
            final ex = exercises[i] as Exercise;
            exercises[i] = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          newSet
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSetValueChange: (index, setIndex, set) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    sets: [
                      for (int j = 0; j < ex.sets.length; j++)
                        if (j == setIndex) set else ex.sets[j]
                    ],
                  )
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (int j = 0; j < ex.exercises.length; j++)
                            if (j == setIndex)
                              ex.exercises[j].copyWith(
                                sets: [
                                  for (int k = 0;
                                      k < ex.exercises[j].sets.length;
                                      k++)
                                    if (k == setIndex)
                                      set
                                    else
                                      ex.exercises[j].sets[k]
                                ],
                              )
                            else
                              ex.exercises[j]
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          set
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onExerciseNotesChange: (index, notes) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          final exercises = workout.exercises.toList();

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    notes: notes,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        notes: notes,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    notes: notes,
                  )
                else
                  superset.exercises[j]
            ]);
          }

          _setExercises(exercises);
        },
        onSupersetAddExercise: (supersetIndex) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final exs = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: false));
            if (exs == null || exs.isEmpty) return;
            final exercises = workout.exercises.toList();
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              ...superset.exercises,
              ...exs.map((ex) => ex.makeChild().copyWith.sets([
                    GTSet.empty(
                      kind: GTSetKind.normal,
                      parameters: ex.parameters,
                    ),
                  ])),
            ]);
            _setExercises(exercises);
          });
        },
        onGroupExercisesIntoSuperset: (startingIndex) async {
          final exercises = workout.exercises.toList();

          final indices = await Go.toDialog(() => ExercisesToSupersetDialog(
              exercises: exercises, startingIndex: startingIndex));

          if (indices == null || indices.length < 2) return;

          final newSuperset = Superset(
            restTime: Duration.zero,
            workoutID: null,
            exercises: [
              for (final index in indices) exercises[index] as Exercise,
            ],
          );

          final newExercises = [
            for (int i = 0; i < indices.first; i++) exercises[i],
            newSuperset,
            for (int i = indices.last + 1; i < exercises.length; i++)
              exercises[i],
          ];

          _setExercises(newExercises);
        },
      );
}

class WorkoutInfoBar extends StatelessWidget {
  final int reps;
  final double liftedWeight;
  final double progress;

  const WorkoutInfoBar({
    super.key,
    required this.reps,
    required this.liftedWeight,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "historyEditor.info.reps".t,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TweenAnimationBuilder(
                    tween: Tween<double>(
                      begin: 0,
                      end: reps.toDouble(),
                    ),
                    curve: Curves.decelerate,
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) {
                      return Text("${value.round()}");
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "historyEditor.info.volume".t,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TweenAnimationBuilder(
                    tween: Tween<double>(
                      begin: 0,
                      end: liftedWeight,
                    ),
                    curve: Curves.decelerate,
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) {
                      if (doubleIsActuallyInt(liftedWeight)) {
                        return Text("${value.round()}");
                      }
                      return Text(stringifyDouble(value));
                    },
                  ),
                ],
              ),
            ].map((w) => Expanded(child: w)).toList(),
          ),
        ),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linearToEaseOut,
          tween: Tween<double>(
            begin: 0,
            end: progress,
          ),
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
          ),
        ),
      ],
    );
  }
}

class WorkoutFinishEditingPage extends StatefulWidget {
  final Workout workout;

  const WorkoutFinishEditingPage({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutFinishEditingPage> createState() =>
      _WorkoutFinishEditingPageState();
}

class _WorkoutFinishEditingPageState extends State<WorkoutFinishEditingPage> {
  late Duration workoutDuration;
  final formKey = GlobalKey<FormState>();

  late final titleController = TextEditingController(text: widget.workout.name);
  late final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(
        widget.workout.duration ?? const Duration(seconds: 0)),
  );
  late final dateController = TextEditingController();
  late DateTime startingDate = widget.workout.startingDate ?? DateTime.now();
  late final infoboxController = QuillController(
    document: (widget.workout.infobox ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  late String? parentWorkoutID = () {
    // Parent workout data
    String? pwInitialItem = widget.workout.parentID;
    if (pwInitialItem == null ||
        !Get.find<RoutinesController>().hasRoutine(pwInitialItem)) {
      pwInitialItem = null;
    }

    return pwInitialItem;
  }();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewPadding;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("historyEditor.finish.title".t),
            leading: const CloseButton(),
            bottom: const PreferredSize(
              preferredSize: Size(0, 1),
              child: Divider(height: 1),
            ),
            actions: [
              IconButton(
                key: const Key("submit"),
                icon: const Icon(GTIcons.done),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: Form(
          key: formKey,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
            child: ListView(
              padding: padding,
              children: [
                const SizedBox(height: 8),
                if (!widget.workout.isContinuation)
                  TextFormField(
                    controller: titleController,
                    decoration:
                        _decoration("historyEditor.finish.fields.name.label".t),
                    validator: (string) {
                      if (string == null || string.isEmpty) {
                        return "historyEditor.finish.fields.name.errors.empty"
                            .t;
                      }
                      return null;
                    },
                  ),
                DateField(
                  decoration: _decoration(
                      "historyEditor.finish.fields.startingTime.label".t),
                  date: startingDate,
                  onSelect: (date) => setState(() => startingDate = date),
                  firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                ),
                if (!widget.workout.isContinuation)
                  RoutineFormPicker(
                    key: ValueKey(parentWorkoutID),
                    decoration: _decoration(
                        "historyEditor.finish.fields.parent.label".t),
                    onChanged: (routine) {
                      setState(() {
                        parentWorkoutID = routine?.id;
                      });
                    },
                    routine: Get.find<RoutinesController>()
                        .workouts
                        .firstWhereOrNull(
                            (element) => element.id == parentWorkoutID),
                  ),
                TimeInputField(
                  controller: timeController,
                  decoration: _decoration(
                      "historyEditor.finish.fields.duration.label".t),
                  validator: (duration) {
                    if (duration == null || duration.inSeconds == 0) {
                      return "historyEditor.finish.fields.duration.errors.empty"
                          .t;
                    }
                    return null;
                  },
                ),
                if (!widget.workout.isContinuation)
                  GTRichTextEditor(
                    infoboxController: infoboxController,
                    decoration: GymTrackerInputDecoration(
                      labelText: "historyEditor.finish.fields.infobox.label".t,
                      alignLabelWithHint: true,
                    ),
                    onTapOutside: () {},
                  ),
              ]
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ).copyWith(top: 0),
                        child: c,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return GymTrackerInputDecoration(
      labelText: label,
    );
  }

  void _submit() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      final controller = Get.find<HistoryController>();
      controller.submitEditedWorkout(
        widget.workout.copyWith(
          name: titleController.text,
          parentID: parentWorkoutID,
          startingDate: startingDate,
          duration: TimeInputField.parseDuration(timeController.text),
          infobox: infoboxController.toEncoded(),
        ),
      );
    }
  }
}

class WorkoutExerciseReorderDialog extends StatefulWidget {
  final List<WorkoutExercisable> exercises;

  const WorkoutExerciseReorderDialog({required this.exercises, super.key});

  @override
  State<WorkoutExerciseReorderDialog> createState() =>
      _WorkoutExerciseReorderDialogState();
}

class _WorkoutExerciseReorderDialogState
    extends State<WorkoutExerciseReorderDialog> {
  late List<int> indices = List.generate(widget.exercises.length, (i) => i);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("historyEditor.exercises.reorder".t),
            leading: const CloseButton(),
            bottom: const PreferredSize(
              preferredSize: Size(0, 1),
              child: Divider(height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(GTIcons.done),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: ReorderableListView.builder(
          itemCount: indices.length,
          itemBuilder: (context, i) {
            final index = indices[i];
            final exercise = widget.exercises[index];
            return ExerciseListTile(
              key: ValueKey(exercise.id),
              exercise: exercise,
              isConcrete: false,
              selected: false,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              reorder(indices, oldIndex, newIndex);
            });
          },
        ),
      ),
    );
  }

  void _submit() {
    Get.back(result: indices);
  }
}
