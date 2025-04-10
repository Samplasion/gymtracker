import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/utils/cardio_timer.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';

WorkoutController? get _controller {
  if (Get.isRegistered<WorkoutController>()) {
    return Get.find<WorkoutController>();
  }
}

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  static const routeName = "/workout";

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
    final stopwatchController = Get.find<StopwatchController>();

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Obx(() {
          if (stopwatchController.globalStopwatch.isStopped.isFalse ||
              stopwatchController.globalStopwatch.currentDuration.inSeconds >
                  0) {
            return TimerView(
              builder: (ctx, _) {
                return Text.rich(
                  TimerView.buildTimeString(
                    context,
                    stopwatchController.globalStopwatch.currentDuration,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    builder: (time) => TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                GTIcons.stopwatch,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            const TextSpan(text: " "),
                            time,
                          ],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              startingTime: DateTime.now(),
            );
          }
          return Text("ongoingWorkout.title".t);
        }),
        actions: [
          IconButton(
            tooltip: "ongoingWorkout.stopwatch.label".t,
            icon: const Icon(GTIcons.stopwatch),
            onPressed: () {
              GlobalStopwatch getStopwatch() =>
                  stopwatchController.globalStopwatch;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("ongoingWorkout.stopwatch.label".t),
                  content: TimerView(
                    startingTime: DateTime.now(),
                    builder: (context, _) {
                      return Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TimerView.buildTimeString(
                              context,
                              getStopwatch().currentDuration,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            OverflowBar(
                              alignment: MainAxisAlignment.end,
                              overflowAlignment: OverflowBarAlignment.end,
                              children: [
                                if (getStopwatch().isStopped())
                                  TextButton.icon(
                                    key: const Key("start"),
                                    icon: const Icon(GTIcons.resume),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.start".t),
                                    onPressed: () {
                                      getStopwatch().start();
                                    },
                                  )
                                else
                                  TextButton.icon(
                                    key: const Key("pause"),
                                    icon: const Icon(GTIcons.pause),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.pause".t),
                                    onPressed: () {
                                      getStopwatch().pause();
                                    },
                                  ),
                                if (getStopwatch().isStopped() &&
                                    getStopwatch().currentDuration.inSeconds >
                                        0)
                                  TextButton.icon(
                                    key: const Key("reset"),
                                    icon: const Icon(GTIcons.reset),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.reset".t),
                                    onPressed: () {
                                      getStopwatch().reset();
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "ongoingWorkout.weightCalculator".t,
            icon: const Icon(GTIcons.weight_calculator),
            onPressed: () {
              final weightUnit = _controller == null
                  ? settingsController.weightUnit.value
                  : _controller!.weightUnit.value;
              showDialog(
                context: context,
                builder: (context) => WeightCalculator(
                  weightUnit: weightUnit,
                ),
              );
            },
          ),
          IconButton(
            tooltip: "cardioTimer.name".t,
            icon: const Icon(GTIcons.cardio_timer),
            onPressed: () {
              Go.to(() => const CardioTimerSetupScreen());
            },
          ),
          PopupMenuButton(
            key: const Key("main-menu"),
            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.changeWeightUnit".t,
                ),
                onTap: () {
                  _controller?.changeWeightUnitDialog();
                },
              ),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.changeDistanceUnit".t,
                ),
                onTap: () {
                  _controller?.changeDistanceUnitDialog();
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.finish".t,
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    _controller?.finishWorkoutWithDialog(context);
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
                    _controller?.cancelWorkoutWithDialog(context,
                        onCanceled: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Get.back(closeOverlays: true);
                        Get.delete<WorkoutController>();
                      });
                    });
                  });
                },
              ),
              if (kDebugMode) ...[
                PopupMenuItem(
                  child: const Text("Show Good Job dialog"),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Go.showBottomModalScreen((context, controller) =>
                          WorkoutDoneSheet(
                            workout: _controller!.synthesizeTemporaryWorkout(),
                            controller: controller,
                          ));
                    });
                  },
                ),
              ],
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
              10, (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight)),
          child: const WorkoutInfoBar(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Obx(() {
        return Crossfade(
          firstChild: const SizedBox.shrink(),
          secondChild: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [WorkoutTimerView()],
          ),
          showSecond: countdownController.isActive,
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Obx(
          () {
            if (_controller != null &&
                Workout.shouldShowAsInfobox(_controller!.infobox())) {
              return _buildListView();
            }
            return CustomMaterialIndicator(
              onRefresh: () async {
                _controller?.showEditNotesDialog();
              },
              indicatorBuilder: (context, controller) {
                final cardTheme = ContextThemingUtils(context).theme.cardTheme;
                return Container(
                  decoration: BoxDecoration(
                    color: ElevationOverlay.applySurfaceTint(
                      cardTheme.color ??
                          ContextThemingUtils(context).theme.cardColor,
                      cardTheme.surfaceTintColor,
                      cardTheme.elevation ?? 4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    GTIcons.notes_add,
                    color: context.colorScheme.primary,
                  ),
                );
              },
              child: _buildListView(),
            );
          },
        ),
      ),
    );
  }

  ListView _buildListView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8) +
          EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
      children: [
        if (_controller != null &&
            Workout.shouldShowAsInfobox(
                Get.find<WorkoutController>().infobox())) ...[
          Infobox(
            text: _controller!.infobox()!,
            onLongPress: () {
              _controller!.showEditNotesDialog();
            },
          ),
        ],

        // Avoid calling [get controller] in order to avoid
        // recreating it, thus starting a new workout.
        if (_controller != null)
          for (int i = 0; i < _controller!.exercises.length; i++)
            if (_controller!.exercises[i] is Exercise)
              WorkoutExerciseEditor(
                key: ValueKey((_controller!.exercises[i] as Exercise).id),
                exercise: _controller!.exercises[i] as Exercise,
                index: (exerciseIndex: i, supersetIndex: null),
                isCreating: false,
                weightUnit: _controller!.weightUnit.value,
                distanceUnit: _controller!.distanceUnit.value,
                callbacks: _controller!.callbacks,
              )
            else
              SupersetEditor(
                superset: _controller!.exercises[i] as Superset,
                index: i,
                isCreating: false,
                key: ValueKey((_controller!.exercises[i] as Superset).id),
                weightUnit: _controller!.weightUnit.value,
                distanceUnit: _controller!.distanceUnit.value,
                callbacks: _controller!.callbacks,
              ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SplitButton(segments: [
            SplitButtonSegment(
              title: 'ongoingWorkout.exercises.add'.t,
              type: SplitButtonSegmentType.filled,
              onTap: () async {
                _controller?.pickExercises();
              },
            ),
            SplitButtonSegment(
              title: "ongoingWorkout.exercises.addSuperset".t,
              onTap: () {
                _controller?.addSuperset();
                _controller?.exercises.refresh();
              },
            ),
          ]),
        ),
        if (_controller?.exercises.isEmpty ?? false)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    getOnThemedColor(context, GTColors.ai),
                  ),
                  iconColor: WidgetStateProperty.all(
                    getOnThemedColor(context, GTColors.ai),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    getThemedColor(context, GTColors.ai),
                  ),
                ),
                onPressed: () {
                  _controller?.generateWorkout();
                },
                label: Text("ongoingWorkout.exercises.generate".t),
                icon: const Icon(GTIcons.generate),
              ),
            ),
          ),
      ],
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
                () {
                  if (_controller == null) return const SizedBox.shrink();
                  return TimerView(
                    startingTime: _controller?.time.value ?? DateTime.now(),
                    builder: (context, text) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ongoingWorkout.info.time".t,
                            style: Theme.of(context).textTheme.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Hero(
                            tag: "Ongoing",
                            child: text,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ongoingWorkout.info.reps".t,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: _controller?.reps.toDouble() ?? 0,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: _controller?.liftedWeight ?? 0,
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        if (doubleIsActuallyInt(
                            _controller?.liftedWeight ?? 0)) {
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
              end: _controller?.progress ?? 0,
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
    final isPhone = context.width < Breakpoints.xs.screenWidth;

    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(13),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            TimerView(
              startingTime: () {
                try {
                  return _controller!.time.value;
                } catch (e, s) {
                  logger.e("Error getting workout time",
                      error: e, stackTrace: s);
                  return DateTime.now();
                }
              }(),
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
            SafeArea(
              top: false,
              bottom: false,
              child: Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(
                          () => TimerView(
                            startingTime: () {
                              try {
                                return _controller!.time.value;
                              } catch (e, s) {
                                logger.e(
                                  "Error getting workout time",
                                  error: e,
                                  stackTrace: s,
                                );
                                return DateTime.now();
                              }
                            }(),
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
                        onPressed: () =>
                            countdownController.subtract15Seconds(),
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
                          icon: const Icon(GTIcons.skip),
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
                            GTIcons.skip,
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
            ),
          ],
        ),
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

  final titleController =
      TextEditingController(text: _controller?.name.value ?? "");
  final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(_controller == null
        ? Duration.zero
        : DateTime.now().difference(_controller!.time.value)),
  );
  final dateController = TextEditingController();
  final infoboxController = QuillController(
    document: (_controller?.infobox.value ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  late String? pwInitialItem = () {
    // Parent workout data
    String? pwInitialItem = _controller?.parentID.value;
    if (Get.find<RoutinesController>()
        .workouts
        .every((element) => element.id != pwInitialItem)) {
      pwInitialItem = null;
    }

    return pwInitialItem;
  }();

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Dialog.fullscreen(
        child: SizedBox.shrink(),
      );
    }

    final controller = _controller!;

    final padding = MediaQuery.of(context).viewPadding;
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
                icon: const Icon(GTIcons.done),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: Form(
          key: formKey,
          child: Obx(
            () => MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
              child: ListView(
                padding: padding,
                children: [
                  const SizedBox(height: 8),
                  if (!controller.isContinuation.value)
                    TextFormField(
                      controller: titleController,
                      decoration: _decoration(
                          "ongoingWorkout.finish.fields.name.label".t),
                      validator: (string) {
                        if (string == null || string.isEmpty) {
                          return "ongoingWorkout.finish.fields.name.errors.empty"
                              .t;
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
                  if (!controller.isContinuation.value)
                    RoutineFormPicker(
                      key: ValueKey(controller.parentID.value),
                      decoration: _decoration(
                          "ongoingWorkout.finish.fields.parent.label".t),
                      onChanged: (routine) {
                        setState(() {
                          controller.parentID.value = routine?.id;
                        });
                      },
                      routine: Get.find<RoutinesController>()
                          .workouts
                          .firstWhereOrNull((element) =>
                              element.id == controller.parentID.value),
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
                  GTRichTextEditor(
                    infoboxController: infoboxController,
                    decoration: GymTrackerInputDecoration(
                      labelText: "ongoingWorkout.finish.fields.infobox.label".t,
                      alignLabelWithHint: true,
                    ),
                    onTapOutside: () {
                      logger.d("Quill Editor onTapOutside");
                      controller.infobox(jsonEncode(
                          infoboxController.document.toDelta().toJson()));
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

    if (isValid && _controller != null) {
      _controller!.submit(
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
