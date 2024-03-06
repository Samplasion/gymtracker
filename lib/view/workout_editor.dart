import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/exercise.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("historyEditor.title".tParams({"name": workout.name})),
        actions: [
          IconButton(
            tooltip: "ongoingWorkout.weightCalculator".t,
            icon: const Icon(Icons.calculate),
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
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Text(
                  "historyEditor.actions.changeWeightUnit".t,
                ),
                onTap: () {
                  setState(() {
                    workout.weightUnit = Weights.values[
                        (workout.weightUnit.index + 1) % Weights.values.length];
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

          // Avoid calling [get controller] in order to avoid
          // recreating it, thus starting a new workout.
          for (int i = 0; i < workout.exercises.length; i++)
            if (workout.exercises[i] is Exercise)
              WorkoutExerciseEditor(
                key: ValueKey((workout.exercises[i] as Exercise).id),
                exercise: workout.exercises[i] as Exercise,
                index: i,
                isCreating: false,
                weightUnit: workout.weightUnit,
                onReorder: () async {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: workout.exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != workout.exercises.length) {
                      return;
                    }
                    final newExercises = [
                      for (int i = 0; i < newIndices.length; i++)
                        workout.exercises[newIndices[i]]
                    ];
                    workout.exercises
                      ..clear()
                      ..addAll(newExercises);
                  });
                  setState(() {});
                },
                onReplace: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final old = workout.exercises[i] as Exercise;
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    workout.exercises[i] = ex.first.copyWith(
                      sets: ([
                        for (final set in old.sets)
                          ExSet.empty(
                            kind: set.kind,
                            parameters: ex.first.parameters,
                          ),
                      ]),
                      restTime: old.restTime,
                    );
                    setState(() {});
                  });
                },
                onRemove: () {
                  workout.exercises.removeAt(i);
                  setState(() {});
                },
                onChangeRestTime: (value) {
                  (workout.exercises[i] as Exercise).restTime = value;
                  setState(() {});
                },
                onSetCreate: () {
                  workout.exercises[i].sets.add(ExSet.empty(
                    kind: SetKind.normal,
                    parameters: (workout.exercises[i] as Exercise).parameters,
                  ));
                  setState(() {});
                },
                onSetRemove: (index) {
                  setState(() {
                    workout.exercises[i].sets.removeAt(index);
                    setState(() {});
                  });
                },
                onSetSelectKind: (set, kind) {
                  set.kind = kind;
                  setState(() {});
                },
                onSetSetDone: (exercise, set, done) {
                  set.done = done;
                  setState(() {});
                },
                onSetValueChange: () {
                  setState(() {});
                },
                onNotesChange: (exercise, notes) {
                  exercise.notes = notes;
                  setState(() {});
                },
              )
            else
              SupersetEditor(
                superset: workout.exercises[i] as Superset,
                index: i,
                isCreating: false,
                key: ValueKey((workout.exercises[i] as Superset).id),
                weightUnit: workout.weightUnit,
                onSupersetRemove: () {
                  workout.exercises.removeAt(i);
                  setState(() {});
                },
                onSupersetReorder: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: workout.exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != workout.exercises.length) {
                      return;
                    }
                    final newExercises = [
                      for (int i = 0; i < newIndices.length; i++)
                        workout.exercises[newIndices[i]]
                    ];
                    workout.exercises
                      ..clear()
                      ..addAll(newExercises);
                  });
                },
                onSupersetReplace: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    workout.exercises[i] = ex.first.copyWith.sets([
                      ExSet.empty(
                        kind: SetKind.normal,
                        parameters: ex.first.parameters,
                      ),
                    ]);
                    setState(() {});
                  });
                },
                onSupersetChangeRestTime: (time) {
                  (workout.exercises[i] as Superset).restTime = time;
                  setState(() {});
                },
                onNotesChange: (_, notes) {
                  (workout.exercises[i] as Superset).notes = notes;
                  setState(() {});
                },
                onExerciseAdd: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final exs = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: false));
                    if (exs == null || exs.isEmpty) return;
                    (workout.exercises[i] as Superset).exercises.addAll(
                          exs.map((ex) => ex.copyWith.sets([
                                ExSet.empty(
                                  kind: SetKind.normal,
                                  parameters: ex.parameters,
                                ),
                              ])),
                        );
                    setState(() {});
                  });
                },
                onExerciseRemove: (index) {
                  setState(() {
                    (workout.exercises[i] as Superset)
                        .exercises
                        .removeAt(index);
                  });
                },
                onExerciseReorder: (_) {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final exercises = (workout.exercises[i] as Superset)
                        .exercises
                        .cast<Exercise>();
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != exercises.length) {
                      return;
                    }
                    workout.exercises[i] =
                        (workout.exercises[i] as Superset).copyWith.exercises([
                      for (int j = 0; j < newIndices.length; j++)
                        (workout.exercises[i] as Superset)
                            .exercises[newIndices[j]]
                    ]);
                  });
                  setState(() {});
                },
                onExerciseReorderIndexed: (_, __) {},
                onExerciseReplace: (index) {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final old =
                        (workout.exercises[i] as Superset).exercises[index];
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    (workout.exercises[i] as Superset).exercises[index] =
                        ex.first.copyWith(
                      sets: ([
                        for (final set in old.sets)
                          ExSet.empty(
                            kind: set.kind,
                            parameters: ex.first.parameters,
                          ),
                      ]),
                      restTime: old.restTime,
                    );
                    setState(() {});
                  });
                },
                onExerciseSetCreate: (index) {
                  (workout.exercises[i] as Superset)
                      .exercises[index]
                      .sets
                      .add(ExSet.empty(
                        kind: SetKind.normal,
                        parameters: (workout.exercises[i] as Superset)
                            .exercises[index]
                            .parameters,
                      ));
                  setState(() {});
                },
                onExerciseSetRemove: (index, setIndex) {
                  setState(() {
                    (workout.exercises[i] as Superset)
                        .exercises[index]
                        .sets
                        .removeAt(setIndex);
                  });
                },
                onExerciseSetSelectKind: (index, set, kind) {
                  set.kind = kind;
                  setState(() {});
                },
                onExerciseSetSetDone: (exercise, set, done) {
                  set.done = done;
                  setState(() {});
                },
                onExerciseSetValueChange: () {
                  setState(() {});
                },
                onExerciseChangeRestTime: (index, time) {
                  // Currently unsupported
                },
                onExerciseNotesChange: (exercise, notes) {
                  exercise.notes = notes;
                  setState(() {});
                },
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
                    exs.map((ex) => ex.copyWith.sets([
                          ExSet.empty(
                            kind: SetKind.normal,
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
    );
  }
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
  late final infoboxController =
      TextEditingController(text: widget.workout.infobox);

  late String? pwInitialItem = () {
    // Parent workout data
    String? pwInitialItem = widget.workout.parentID;
    if (Get.find<RoutinesController>()
        .workouts
        .every((element) => element.id != pwInitialItem)) {
      pwInitialItem = null;
    }

    return pwInitialItem;
  }();

  @override
  Widget build(BuildContext context) {
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
                icon: const Icon(Icons.check),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration:
                    _decoration("historyEditor.finish.fields.name.label".t),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "historyEditor.finish.fields.name.errors.empty".t;
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
              DropdownButtonFormField<String?>(
                decoration:
                    _decoration("historyEditor.finish.fields.parent.label".t),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                        "historyEditor.finish.fields.parent.options.none".t),
                  ),
                  for (final routine in Get.find<RoutinesController>().workouts)
                    DropdownMenuItem(
                      value: routine.id,
                      child: Text(routine.name),
                    ),
                ],
                onChanged: (v) => setState(() => widget.workout.parentID = v),
                value: pwInitialItem,
              ),
              TimeInputField(
                controller: timeController,
                decoration:
                    _decoration("historyEditor.finish.fields.duration.label".t),
                validator: (duration) {
                  if (duration == null || duration.inSeconds == 0) {
                    return "historyEditor.finish.fields.duration.errors.empty"
                        .t;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: infoboxController,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "historyEditor.finish.fields.infobox.label".t,
                  alignLabelWithHint: true,
                ),
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
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
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
          startingDate: startingDate,
          duration: TimeInputField.parseDuration(timeController.text),
          infobox: infoboxController.text,
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
                icon: const Icon(Icons.check),
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
