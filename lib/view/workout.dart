import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/utils/superset.dart';

import '../controller/countdown_controller.dart';
import '../controller/workout_controller.dart';
import '../controller/workouts_controller.dart';
import '../model/exercise.dart';
import '../model/set.dart';
import '../utils/constants.dart';
import '../utils/go.dart';
import '../utils/utils.dart';
import '../view/exercise_picker.dart';
import '../view/utils/workout.dart';
import 'utils/crossfade.dart';
import 'utils/date_field.dart';
import 'utils/exercise.dart';
import 'utils/time.dart';
import 'utils/timer.dart';
import 'utils/weight_calculator.dart';

WorkoutController get controller =>
    Get.put(WorkoutController("Untitled workout", null, null));

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
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

  @override
  Widget build(BuildContext context) {
    final countdownController = Get.find<CountdownController>();

    return Scaffold(
      appBar: AppBar(
        title: Text("ongoingWorkout.title".t),
        actions: [
          IconButton(
            tooltip: "ongoingWorkout.weightCalculator".t,
            icon: const Icon(Icons.calculate),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const WeightCalculator(),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.finish".t,
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    controller.finishWorkoutWithDialog(context);
                  });
                },
              ),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.cancel".t,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    controller.cancelWorkoutWithDialog(context, onCanceled: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Get.back(closeOverlays: true);
                        Get.delete<WorkoutController>();
                      });
                    });
                  });
                },
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
              10, (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight)),
          child: const WorkoutInfoBar(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Obx(() {
        return SafeArea(
          child: Crossfade(
            firstChild: const SizedBox.shrink(),
            secondChild: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [WorkoutTimerView()],
            ),
            showSecond: countdownController.isActive,
          ),
        );
      }),
      body: Obx(
        () => ListView(
          children: [
            if (Get.isRegistered<WorkoutController>() &&
                Get.find<WorkoutController>().infobox() != null)
              Infobox(text: controller.infobox()!),

            // Avoid calling [get controller] in order to avoid
            // recreating it, thus starting a new workout.
            if (Get.find<WorkoutsController>().hasOngoingWorkout())
              for (int i = 0; i < controller.exercises.length; i++)
                if (controller.exercises[i] is Exercise)
                  WorkoutExerciseEditor(
                    key: ValueKey((controller.exercises[i] as Exercise).id),
                    exercise: controller.exercises[i] as Exercise,
                    index: i,
                    isCreating: false,
                    onReorder: () async {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        // TODO: While we're at it, fix the timers messing up when reordering exercises.
                        final newIndices = await showDialog<List<int>>(
                          builder: (context) => WorkoutExerciseReorderDialog(
                            exercises: controller.exercises,
                          ),
                          context: context,
                        );
                        if (newIndices == null ||
                            newIndices.length != controller.exercises.length) {
                          return;
                        }
                        controller.exercises([
                          for (int i = 0; i < newIndices.length; i++)
                            controller.exercises[newIndices[i]]
                        ]);
                      });
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onReplace: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final old = controller.exercises[i] as Exercise;
                        final ex = await Go.to<List<Exercise>>(
                            () => const ExercisePicker(singlePick: true));
                        if (ex == null || ex.isEmpty) return;
                        controller.exercises[i] = ex.first.copyWith(
                          sets: ([
                            for (final set in old.sets)
                              ExSet.empty(
                                kind: set.kind,
                                parameters: ex.first.parameters,
                              ),
                          ]),
                          restTime: old.restTime,
                        );
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onRemove: () {
                      controller.exercises.removeAt(i);
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onChangeRestTime: (value) {
                      (controller.exercises[i] as Exercise).restTime = value;
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onSetCreate: () {
                      controller.exercises[i].sets.add(ExSet.empty(
                        kind: SetKind.normal,
                        parameters:
                            (controller.exercises[i] as Exercise).parameters,
                      ));
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onSetRemove: (index) {
                      setState(() {
                        controller.exercises[i].sets.removeAt(index);
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onSetSelectKind: (set, kind) {
                      set.kind = kind;
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onSetSetDone: (exercise, set, done) {
                      set.done = done;
                      if (done) {
                        if (exercise.restTime.inSeconds > 0) {
                          countdownController.setCountdown(exercise.restTime);
                        }
                      }
                      controller.save();
                      controller.exercises.refresh();
                    },
                    onSetValueChange: () {
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onNotesChange: (exercise, notes) {
                      exercise.notes = notes;
                      controller.exercises.refresh();
                      controller.save();
                    },
                  )
                else
                  SupersetEditor(
                    superset: controller.exercises[i] as Superset,
                    index: i,
                    isCreating: false,
                    key: ValueKey((controller.exercises[i] as Superset).id),
                    onSupersetRemove: () {
                      controller.exercises.removeAt(i);
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onSupersetReorder: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final newIndices = await showDialog<List<int>>(
                          builder: (context) => WorkoutExerciseReorderDialog(
                            exercises: controller.exercises,
                          ),
                          context: context,
                        );
                        if (newIndices == null ||
                            newIndices.length != controller.exercises.length) {
                          return;
                        }
                        controller.exercises([
                          for (int i = 0; i < newIndices.length; i++)
                            controller.exercises[newIndices[i]]
                        ]);
                      });
                    },
                    onSupersetReplace: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final ex = await Go.to<List<Exercise>>(
                            () => const ExercisePicker(singlePick: true));
                        if (ex == null || ex.isEmpty) return;
                        controller.exercises[i] = ex.first.copyWith.sets([
                          ExSet.empty(
                            kind: SetKind.normal,
                            parameters: ex.first.parameters,
                          ),
                        ]);
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onSupersetChangeRestTime: (time) {
                      (controller.exercises[i] as Superset).restTime = time;
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onNotesChange: (_, notes) {
                      (controller.exercises[i] as Superset).notes = notes;
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onExerciseAdd: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final exs = await Go.to<List<Exercise>>(
                            () => const ExercisePicker(singlePick: false));
                        if (exs == null || exs.isEmpty) return;
                        (controller.exercises[i] as Superset).exercises.addAll(
                              exs.map((ex) => ex.copyWith.sets([
                                    ExSet.empty(
                                      kind: SetKind.normal,
                                      parameters: ex.parameters,
                                    ),
                                  ])),
                            );
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onExerciseRemove: (index) {
                      setState(() {
                        (controller.exercises[i] as Superset)
                            .exercises
                            .removeAt(index);
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onExerciseReorder: (_) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final exercises = (controller.exercises[i] as Superset)
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
                        controller.exercises[i] =
                            (controller.exercises[i] as Superset)
                                .copyWith
                                .exercises([
                          for (int j = 0; j < newIndices.length; j++)
                            (controller.exercises[i] as Superset)
                                .exercises[newIndices[j]]
                        ]);
                      });
                      controller.save();
                      controller.exercises.refresh();
                    },
                    onExerciseReorderIndexed: (_, __) {},
                    onExerciseReplace: (index) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        final old = (controller.exercises[i] as Superset)
                            .exercises[index];
                        final ex = await Go.to<List<Exercise>>(
                            () => const ExercisePicker(singlePick: true));
                        if (ex == null || ex.isEmpty) return;
                        (controller.exercises[i] as Superset).exercises[index] =
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
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onExerciseSetCreate: (index) {
                      (controller.exercises[i] as Superset)
                          .exercises[index]
                          .sets
                          .add(ExSet.empty(
                            kind: SetKind.normal,
                            parameters: (controller.exercises[i] as Superset)
                                .exercises[index]
                                .parameters,
                          ));
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onExerciseSetRemove: (index, setIndex) {
                      setState(() {
                        (controller.exercises[i] as Superset)
                            .exercises[index]
                            .sets
                            .removeAt(setIndex);
                        controller.exercises.refresh();
                        controller.save();
                      });
                    },
                    onExerciseSetSelectKind: (index, set, kind) {
                      set.kind = kind;
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onExerciseSetSetDone: (exercise, set, done) {
                      final superset = controller.exercises[i] as Superset;
                      set.done = done;
                      if (done) {
                        final index =
                            superset.exercises.findExerciseIndex(exercise);
                        if (index == superset.exercises.length - 1 &&
                            superset.restTime.inSeconds > 0) {
                          countdownController.setCountdown(superset.restTime);
                        }
                      }
                      controller.save();
                      controller.exercises.refresh();
                    },
                    onExerciseSetValueChange: () {
                      controller.exercises.refresh();
                      controller.save();
                    },
                    onExerciseChangeRestTime: (index, time) {
                      // Currently unsupported
                    },
                    onExerciseNotesChange: (exercise, notes) {
                      exercise.notes = notes;
                      controller.exercises.refresh();
                      controller.save();
                    },
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SplitButton(segments: [
                SplitButtonSegment(
                  title: 'ongoingWorkout.exercises.add'.t,
                  type: SplitButtonSegmentType.filled,
                  onTap: () async {
                    final exs = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: false));
                    if (exs == null || exs.isEmpty) return;
                    controller.exercises.addAll(
                      exs.map((ex) => ex.copyWith.sets([
                            ExSet.empty(
                              kind: SetKind.normal,
                              parameters: ex.parameters,
                            ),
                          ])),
                    );
                    controller.exercises.refresh();
                  },
                ),
                SplitButtonSegment(
                  title: "ongoingWorkout.exercises.addSuperset".t,
                  onTap: () {
                    controller.exercises.add(Superset.empty());
                    controller.exercises.refresh();
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutInfoBar extends StatelessWidget {
  const WorkoutInfoBar({
    super.key,
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
              Obx(
                () => TimerView(
                  startingTime: controller.time.value,
                  builder: (context, text) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ongoingWorkout.info.time".t,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Hero(
                          tag: "Ongoing",
                          child: text,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ongoingWorkout.info.reps".t,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: controller.reps.toDouble(),
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        return Text("${value.round()}");
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ongoingWorkout.info.volume".t,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: controller.liftedWeight,
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        if (doubleIsActuallyInt(controller.liftedWeight)) {
                          return Text("${value.round()}");
                        }
                        return Text(stringifyDouble(value));
                      },
                    ),
                  ),
                ],
              ),
            ].map((w) => Expanded(child: w)).toList(),
          ),
        ),
        Obx(
          () => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
            tween: Tween<double>(
              begin: 0,
              end: controller.progress,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
            ),
          ),
        ),
      ],
    );
  }
}

class WorkoutTimerView extends StatelessWidget {
  const WorkoutTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    final countdownController = Get.find<CountdownController>();
    final isPhone = context.width < Breakpoints.xs;

    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(13),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          TimerView(
            startingTime: Get.find<WorkoutController>().time.value,
            builder: (_, time) {
              return TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 1,
                  end: countdownController.progress,
                ),
                duration: const Duration(milliseconds: 220),
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value);
                },
              );
            },
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Obx(
                      () => TimerView(
                        startingTime: Get.find<WorkoutController>().time.value,
                        builder: (_, time) => TimerView.buildTimeString(
                          context,
                          countdownController.remaining,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Text(
                      "timer.subtract15s".t,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onPressed: () => countdownController.subtract15Seconds(),
                  ),
                  IconButton(
                    icon: Text(
                      "timer.add15s".t,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    onPressed: () => countdownController.add15Seconds(),
                  ),
                  Crossfade(
                    firstChild: TextButton.icon(
                      onPressed: skipCountdown,
                      icon: const Icon(Icons.skip_next_rounded),
                      clipBehavior: Clip.hardEdge,
                      label: Text(
                        "timer.skip".t,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                    secondChild: IconButton(
                      onPressed: skipCountdown,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    showSecond: isPhone,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void skipCountdown() {
    final countdownController = Get.find<CountdownController>();
    countdownController.removeCountdown();
  }
}

class WorkoutFinishPage extends StatefulWidget {
  const WorkoutFinishPage({super.key});

  @override
  State<WorkoutFinishPage> createState() => _WorkoutFinishPageState();
}

class _WorkoutFinishPageState extends State<WorkoutFinishPage> {
  late Duration workoutDuration;
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController(text: controller.name.value);
  final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(
        DateTime.now().difference(controller.time.value)),
  );
  final dateController = TextEditingController();
  final infoboxController =
      TextEditingController(text: controller.infobox.value);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("ongoingWorkout.finish.title".t),
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
                    _decoration("ongoingWorkout.finish.fields.name.label".t),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "ongoingWorkout.finish.fields.name.errors.empty".t;
                  }
                  return null;
                },
              ),
              DateField(
                decoration: _decoration(
                    "ongoingWorkout.finish.fields.startingTime.label".t),
                date: controller.time.value,
                onSelect: (date) => setState(() => controller.time(date)),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now().add(const Duration(days: 7)),
              ),
              DropdownButtonFormField<String?>(
                decoration:
                    _decoration("ongoingWorkout.finish.fields.parent.label".t),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                        "ongoingWorkout.finish.fields.parent.options.none".t),
                  ),
                  for (final routine in Get.find<WorkoutsController>().workouts)
                    DropdownMenuItem(
                      value: routine.id,
                      child: Text(routine.name),
                    ),
                ],
                onChanged: (v) => setState(() => controller.parentID.value = v),
                value: controller.parentID.value,
              ),
              TimeInputField(
                controller: timeController,
                decoration: _decoration(
                    "ongoingWorkout.finish.fields.duration.label".t),
                validator: (duration) {
                  if (duration == null || duration.inSeconds == 0) {
                    return "ongoingWorkout.finish.fields.duration.errors.empty"
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
                  labelText: "ongoingWorkout.finish.fields.infobox.label".t,
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
      controller.sumbit(
        titleController.text,
        TimeInputField.parseDuration(timeController.text),
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
            title: Text("ongoingWorkout.exercises.reorder".t),
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
