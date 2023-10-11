import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

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

WorkoutController get controller =>
    Get.put(WorkoutController("Untitled workout", null));

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
        title: Text("ongoingWorkout.title".tr),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.finish".tr,
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    controller.finishWorkoutWithDialog(context);
                  });
                },
              ),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.cancel".tr,
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
        return Crossfade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [WorkoutTimerView()],
          ),
          showSecond: countdownController.isActive,
        );
      }),
      body: Obx(
        () => ListView(
          children: [
            // Avoid calling [get controller] in order to avoid
            // recreating it, thus starting a new workout.
            if (Get.find<WorkoutsController>().hasOngoingWorkout())
              for (int i = 0; i < controller.exercises.length; i++)
                WorkoutExerciseEditor(
                  exercise: controller.exercises[i],
                  index: i,
                  isCreating: false,
                  onReorder: () async {
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
                    controller.save();
                  },
                  onReplace: () {
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
                  onRemove: () {
                    controller.exercises.removeAt(i);
                    controller.exercises.refresh();
                    controller.save();
                  },
                  onChangeRestTime: (value) {
                    controller.exercises[i].restTime = value;
                    controller.exercises.refresh();
                    controller.save();
                  },
                  onSetCreate: () {
                    controller.exercises[i].sets.add(ExSet.empty(
                      kind: SetKind.normal,
                      parameters: controller.exercises[i].parameters,
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
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () async {
                  final ex = await Go.to<List<Exercise>>(
                      () => const ExercisePicker(singlePick: true));
                  if (ex == null || ex.isEmpty) return;
                  controller.exercises.add(
                    ex.first.copyWith.sets([
                      ExSet.empty(
                        kind: SetKind.normal,
                        parameters: ex.first.parameters,
                      ),
                    ]),
                  );
                  controller.exercises.refresh();
                },
                child: Text('ongoingWorkout.exercises.add'.tr),
              ),
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
                          "ongoingWorkout.info.time".tr,
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
                    "ongoingWorkout.info.reps".tr,
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
                    "ongoingWorkout.info.volume".tr,
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Text(
                      "timer.subtract15s".tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onPressed: () => countdownController.subtract15Seconds(),
                  ),
                  IconButton(
                    icon: Text(
                      "timer.add15s".tr,
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
                        "timer.skip".tr,
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

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("ongoingWorkout.finish.title".tr),
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
                    _decoration("ongoingWorkout.finish.fields.name.label".tr),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "ongoingWorkout.finish.fields.name.errors.empty".tr;
                  }
                  return null;
                },
              ),
              DateField(
                decoration: _decoration(
                    "ongoingWorkout.finish.fields.startingTime.label".tr),
                date: controller.time.value,
                onSelect: (date) => setState(() => controller.time(date)),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now().add(const Duration(days: 7)),
              ),
              DropdownButtonFormField<String?>(
                decoration:
                    _decoration("ongoingWorkout.finish.fields.parent.label".tr),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                        "ongoingWorkout.finish.fields.parent.options.none".tr),
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
                    "ongoingWorkout.finish.fields.duration.label".tr),
                validator: (duration) {
                  if (duration == null || duration.inSeconds == 0) {
                    return "ongoingWorkout.finish.fields.duration.errors.empty"
                        .tr;
                  }
                  return null;
                },
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
  final List<Exercise> exercises;

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
            title: Text("ongoingWorkout.exercises.reorder".tr),
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
