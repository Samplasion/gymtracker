import 'package:gymtracker/provider/trainer.dart';
import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_menus.dart';
import 'package:intl/intl.dart';

WorkoutController? _workoutController(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  return container.read(workoutControllerProvider) == null
      ? null
      : container.read(workoutControllerProvider.notifier);
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
  Widget build(BuildContext context) {
    final countdownController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(countdownControllerProvider.notifier);
    final stopwatchController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(stopwatchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        title: Consumer(
          builder: (context, ref, _) {
            ref.watch(workoutControllerProvider);
            ref.watch(countdownControllerProvider);
            ref.watch(stopwatchControllerProvider);
            if (!stopwatchController.globalStopwatch.isStopped ||
                stopwatchController.globalStopwatch.currentDuration.inSeconds >
                    0) {
              return TimerView(
                builder: (ctx, _) {
                  return Text.rich(
                    TimerView.buildTimeString(
                      context,
                      stopwatchController.globalStopwatch.currentDuration,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      builder: (time) => TextSpan(
                        children: [
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  GTIcons.stopwatch,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
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
            return Text(context.t.ongoingWorkout.title);
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) =>
                buildToolboxMenuEntries(context, _workoutController(context)),
            tooltip: context.t.ongoingWorkout.toolbox.title,
            icon: const Icon(GTIcons.tools),
          ),
          PopupMenuButton(
            key: const Key("main-menu"),
            itemBuilder: (context) {
              final controller = _workoutController(context);
              if (controller == null) return <PopupMenuEntry<dynamic>>[];
              return buildWorkoutControlMenuEntries(context, controller);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
            10,
            (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight),
          ),
          child: const WorkoutInfoBar(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          ref.watch(workoutControllerProvider);
          ref.watch(countdownControllerProvider);
          ref.watch(stopwatchControllerProvider);
          return Crossfade(
            firstChild: const SizedBox.shrink(),
            secondChild: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [WorkoutTimerView()],
            ),
            showSecond: countdownController.isActive,
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(workoutControllerProvider);
            ref.watch(countdownControllerProvider);
            ref.watch(stopwatchControllerProvider);
            if (_workoutController(context) != null &&
                Workout.shouldShowAsInfobox(
                  _workoutController(context)!.infobox,
                )) {
              return _buildListView();
            }
            return CustomMaterialIndicator(
              onRefresh: () async {
                _workoutController(context)?.showEditNotesDialog();
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

  Widget _buildListView() {
    return WorkoutListView(
      children: [
        if (_workoutController(context) != null &&
            Workout.shouldShowAsInfobox(
              ProviderScope.containerOf(
                context,
                listen: false,
              ).read(workoutControllerProvider.notifier).infobox,
            )) ...[
          Infobox(
            text: _workoutController(context)!.infobox!,
            onLongPress: () {
              _workoutController(context)!.showEditNotesDialog();
            },
          ),
        ],

        // Avoid calling [get controller] in order to avoid
        // recreating it, thus starting a new workout.
        if (_workoutController(context) != null)
          for (
            int i = 0;
            i < _workoutController(context)!.exercises.length;
            i++
          )
            if (_workoutController(context)!.exercises[i] is Exercise)
              WorkoutExerciseEditor(
                key: ValueKey(
                  (_workoutController(context)!.exercises[i] as Exercise).id,
                ),
                exercise: _workoutController(context)!.exercises[i] as Exercise,
                index: (exerciseIndex: i, supersetIndex: null),
                isCreating: false,
                weightUnit: _workoutController(context)!.weightUnit,
                distanceUnit: _workoutController(context)!.distanceUnit,
                callbacks: _workoutController(context)!.callbacks,
              )
            else
              SupersetEditor(
                superset: _workoutController(context)!.exercises[i] as Superset,
                index: i,
                isCreating: false,
                key: ValueKey(
                  (_workoutController(context)!.exercises[i] as Superset).id,
                ),
                weightUnit: _workoutController(context)!.weightUnit,
                distanceUnit: _workoutController(context)!.distanceUnit,
                callbacks: _workoutController(context)!.callbacks,
              ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SplitButton(
            segments: [
              SplitButtonSegment(
                title: context.t.ongoingWorkout.exercises.add,
                type: SplitButtonSegmentType.filled,
                onTap: () async {
                  _workoutController(context)?.pickExercises();
                },
              ),
              SplitButtonSegment(
                title: context.t.ongoingWorkout.exercises.addSuperset,
                onTap: () {
                  _workoutController(context)?.addSuperset();
                  _workoutController(context)?.publishExercises();
                },
              ),
            ],
          ),
        ),
        if (_workoutController(context)?.exercises.isEmpty ?? false)
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
                  _workoutController(context)?.generateWorkout();
                },
                label: Text(context.t.ongoingWorkout.exercises.generate),
                icon: const Icon(GTIcons.generate),
              ),
            ),
          ),
      ],
    );
  }
}

/// Keeps keyboard metrics out of the workout and exercise build contexts.
class WorkoutListView extends StatelessWidget {
  const WorkoutListView({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.symmetric(vertical: 8) +
          EdgeInsets.only(
            bottom:
                MediaQuery.viewInsetsOf(context).bottom +
                MediaQuery.paddingOf(context).bottom,
          ),
      children: children,
    );
  }
}

class WorkoutInfoBar extends ConsumerWidget {
  const WorkoutInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 16),
          child: Builder(
            builder: (context) {
              final activeEnergy = ref.watch(healthEnergyProvider).value;
              return Builder(
                builder: (context) {
                  final heartRate = ref.watch(healthHeartRateProvider).value;
                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Consumer(
                          builder: (context, ref, _) {
                            ref.watch(workoutControllerProvider);
                            ref.watch(countdownControllerProvider);
                            ref.watch(stopwatchControllerProvider);
                            if (_workoutController(context) == null) {
                              return const SizedBox.shrink();
                            }
                            return TimerView(
                              startingTime:
                                  _workoutController(context)?.time ??
                                  DateTime.now(),
                              builder: (context, text) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.t.ongoingWorkout.info.time,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Hero(tag: "Ongoing", child: text),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t.ongoingWorkout.info.reps,
                              style: Theme.of(context).textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                ref.watch(workoutControllerProvider);
                                ref.watch(countdownControllerProvider);
                                ref.watch(stopwatchControllerProvider);
                                return TweenAnimationBuilder(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end:
                                        _workoutController(
                                          context,
                                        )?.reps.toDouble() ??
                                        0,
                                  ),
                                  curve: Curves.decelerate,
                                  duration: const Duration(milliseconds: 400),
                                  builder: (context, value, _) {
                                    return Text("${value.round()}");
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t.ongoingWorkout.info.volume,
                              style: Theme.of(context).textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                ref.watch(workoutControllerProvider);
                                ref.watch(countdownControllerProvider);
                                ref.watch(stopwatchControllerProvider);
                                return TweenAnimationBuilder(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end:
                                        _workoutController(
                                          context,
                                        )?.liftedWeight ??
                                        0,
                                  ),
                                  curve: Curves.decelerate,
                                  duration: const Duration(milliseconds: 400),
                                  builder: (context, value, _) {
                                    if (doubleIsActuallyInt(
                                      _workoutController(
                                            context,
                                          )?.liftedWeight ??
                                          0,
                                    )) {
                                      return Text("${value.round()}");
                                    }
                                    return Text(stringifyDouble(value));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (heartRate != null) ...[
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t.ongoingWorkout.info.heartRate,
                                style: Theme.of(context).textTheme.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: heartRate),
                                curve: Curves.decelerate,
                                duration: const Duration(milliseconds: 400),
                                builder: (context, value, _) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        const WidgetSpan(
                                          child: Icon(
                                            GTIcons.heart_rate,
                                            size: 14,
                                          ),
                                          alignment:
                                              PlaceholderAlignment.middle,
                                        ),
                                        const TextSpan(text: " "),
                                        TextSpan(text: "${value.round()}"),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (activeEnergy != null) ...[
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t.ongoingWorkout.info.activeEnergy,
                                style: Theme.of(context).textTheme.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: activeEnergy,
                                ),
                                curve: Curves.decelerate,
                                duration: const Duration(milliseconds: 400),
                                builder: (context, value, _) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        const WidgetSpan(
                                          child: Icon(
                                            GTIcons.active_energy,
                                            size: 14,
                                          ),
                                          alignment:
                                              PlaceholderAlignment.middle,
                                        ),
                                        const TextSpan(text: " "),
                                        TextSpan(
                                          text:
                                              NumberFormat.decimalPatternDigits(
                                                locale:
                                                    context.locale.languageCode,
                                                decimalDigits: 1,
                                              ).format(value),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ].toList(),
                  );
                },
              );
            },
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            ref.watch(workoutControllerProvider);
            ref.watch(countdownControllerProvider);
            ref.watch(stopwatchControllerProvider);
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut,
              tween: Tween<double>(
                begin: 0,
                end: _workoutController(context)?.progress ?? 0,
              ),
              builder: (context, value, _) =>
                  LinearProgressIndicator(value: value),
            );
          },
        ),
      ],
    );
  }
}

class WorkoutTimerView extends StatelessWidget {
  const WorkoutTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    final countdownController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(countdownControllerProvider.notifier);
    final isPhone =
        MediaQuery.sizeOf(context).width < Breakpoints.xs.screenWidth;

    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
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
                  return _workoutController(context)!.time;
                } catch (e, s) {
                  logger.e(
                    "Error getting workout time",
                    error: e,
                    stackTrace: s,
                  );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            ref.watch(workoutControllerProvider);
                            ref.watch(countdownControllerProvider);
                            ref.watch(stopwatchControllerProvider);
                            return TimerView(
                              startingTime: () {
                                try {
                                  return _workoutController(context)!.time;
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
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Text(
                          context.t.timer.subtract15s,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: () =>
                            countdownController.subtract15Seconds(),
                      ),
                      IconButton(
                        icon: Text(
                          context.t.timer.add15s,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        onPressed: () => countdownController.add15Seconds(),
                      ),
                      Crossfade(
                        firstChild: TextButton.icon(
                          onPressed: () => skipCountdown(context),
                          icon: const Icon(GTIcons.skip),
                          clipBehavior: Clip.hardEdge,
                          label: Text(
                            context.t.timer.skip,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        ),
                        secondChild: IconButton(
                          onPressed: () => skipCountdown(context),
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

  void skipCountdown(BuildContext context) {
    final countdownController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(countdownControllerProvider.notifier);
    countdownController.removeCountdown();
  }
}

class WorkoutFinishPage extends ConsumerStatefulWidget {
  const WorkoutFinishPage({super.key});

  @override
  ConsumerState<WorkoutFinishPage> createState() => _WorkoutFinishPageState();
}

class _WorkoutFinishPageState extends ConsumerState<WorkoutFinishPage> {
  bool _submitting = false;
  Future<bool>? _closeRequest;
  final formKey = GlobalKey<FormState>();
  late final WorkoutController _session;
  late final int _generation;
  late final String _initialName;
  late final String _initialDuration;
  late final DateTime _initialDate;
  late final String? _initialParentID;
  late final String _initialNotes;
  late DateTime _date;
  String? _parentID;
  late final TextEditingController titleController;
  late final TextEditingController timeController;
  late final QuillController infoboxController;

  String get _notes =>
      jsonEncode(infoboxController.document.toDelta().toJson());

  @override
  void initState() {
    super.initState();
    _session = ref.read(workoutControllerProvider.notifier);
    final activeSession = _workoutController(context);
    _generation = _session.sessionGeneration;
    _initialName = activeSession?.name ?? '';
    _initialDate = _date = activeSession?.time ?? DateTime.now();
    _initialParentID = _parentID = activeSession?.parentID;
    _initialDuration = TimeInputField.encodeDuration(
      DateTime.now().difference(_initialDate),
    );
    titleController = TextEditingController(text: _initialName);
    timeController = TextEditingController(text: _initialDuration);
    infoboxController = QuillController(
      document: (activeSession?.infobox ?? '').asQuillDocument(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _initialNotes = _notes;
  }

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    infoboxController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      titleController.text != _initialName ||
      timeController.text != _initialDuration ||
      _date != _initialDate ||
      _parentID != _initialParentID ||
      _notes != _initialNotes;

  Future<bool> _canClose() async {
    if (_submitting || _session.isSubmitting) return false;
    if (!_hasChanges) return true;
    if (_closeRequest != null) return _closeRequest!;
    final text = context.t.ongoingWorkout.finish.discard;
    final request = showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.title),
        content: Text(text.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.keep),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(text.confirm),
          ),
        ],
      ),
    ).then((discard) => discard ?? false);
    _closeRequest = request;
    try {
      return await request;
    } finally {
      _closeRequest = null;
    }
  }

  Future<void> _close() async {
    if (await _canClose() && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting =
        ref.watch(workoutControllerProvider)?.isSubmitting ?? false;
    if (_workoutController(context) == null) {
      return const Dialog.fullscreen(child: SizedBox.shrink());
    }

    final controller = _workoutController(context)!;

    final padding = MediaQuery.of(context).viewPadding;
    final toolbarHeight =
        kToolbarHeight * MediaQuery.textScalerOf(context).scale(1);
    // The Cupertino modal route uses scoped will-pop callbacks for drag dismissal.
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _canClose,
      child: Dialog.fullscreen(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(0, toolbarHeight + 1),
            child: AppBar(
              toolbarHeight: toolbarHeight,
              title: Text(context.t.ongoingWorkout.finish.title, maxLines: 2),
              leading: CloseButton(onPressed: _close),
              bottom: const PreferredSize(
                preferredSize: Size(0, 1),
                child: Divider(height: 1),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _submitting || submitting ? null : _submit,
              child: _submitting || submitting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(context.t.ongoingWorkout.finish.saving),
                      ],
                    )
                  : Text(context.t.ongoingWorkout.finish.save),
            ),
          ),
          body: AbsorbPointer(
            absorbing: _submitting || submitting,
            child: Form(
              key: formKey,
              child: Consumer(
                builder: (context, ref, _) {
                  ref.watch(workoutControllerProvider);
                  ref.watch(countdownControllerProvider);
                  ref.watch(stopwatchControllerProvider);
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(padding: EdgeInsets.zero),
                    child: ListView(
                      padding: padding,
                      children:
                          [
                                const SizedBox(height: 8),
                                if (!controller.isContinuation)
                                  TextFormField(
                                    controller: titleController,
                                    decoration: _decoration(
                                      context
                                          .t
                                          .ongoingWorkout
                                          .finish
                                          .fields
                                          .name
                                          .label,
                                    ),
                                    validator: (string) {
                                      if (string == null || string.isEmpty) {
                                        return context
                                            .t
                                            .ongoingWorkout
                                            .finish
                                            .fields
                                            .name
                                            .errors
                                            .empty;
                                      }
                                      return null;
                                    },
                                  ),
                                if (!trainerControls(ref, _initialParentID))
                                  DateField(
                                    decoration: _decoration(
                                      context
                                          .t
                                          .ongoingWorkout
                                          .finish
                                          .fields
                                          .startingTime
                                          .label,
                                    ),
                                    date: _date,
                                    onSelect: (date) =>
                                        setState(() => _date = date),
                                    firstDate:
                                        DateTime.fromMillisecondsSinceEpoch(0),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 7),
                                    ),
                                  ),
                                if (!controller.isContinuation &&
                                    !trainerControls(ref, _initialParentID))
                                  RoutineFormPicker(
                                    key: ValueKey(_parentID),
                                    decoration:
                                        _decoration(
                                          context
                                              .t
                                              .ongoingWorkout
                                              .finish
                                              .fields
                                              .parent
                                              .label,
                                        ).copyWith(
                                          helper: Text(
                                            context
                                                .t
                                                .ongoingWorkout
                                                .finish
                                                .fields
                                                .parent
                                                .help,
                                          ),
                                        ),
                                    onChanged: (routine) {
                                      setState(() {
                                        _parentID = routine?.id;
                                      });
                                    },
                                    routine:
                                        ProviderScope.containerOf(
                                              context,
                                              listen: false,
                                            )
                                            .read(routinesControllerProvider)
                                            .workouts
                                            .firstWhereOrNull(
                                              (element) =>
                                                  element.id == _parentID,
                                            ),
                                  ),
                                TimeInputField(
                                  controller: timeController,
                                  decoration: _decoration(
                                    context
                                        .t
                                        .ongoingWorkout
                                        .finish
                                        .fields
                                        .duration
                                        .label,
                                  ),
                                  validator: (duration) {
                                    if (duration == null ||
                                        duration.inSeconds == 0) {
                                      return context
                                          .t
                                          .ongoingWorkout
                                          .finish
                                          .fields
                                          .duration
                                          .errors
                                          .empty;
                                    }
                                    return null;
                                  },
                                ),
                                GTRichTextEditor(
                                  controller: infoboxController,
                                  decoration: GymTrackerInputDecoration(
                                    labelText: context
                                        .t
                                        .ongoingWorkout
                                        .finish
                                        .fields
                                        .infobox
                                        .label,
                                    alignLabelWithHint: true,
                                  ),
                                ),
                              ]
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ).copyWith(top: 0),
                                  child: c,
                                ),
                              )
                              .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return GymTrackerInputDecoration(labelText: label);
  }

  Future<void> _submit() async {
    final controller = _workoutController(context);
    if (_submitting ||
        controller == null ||
        controller.isSubmitting ||
        !identical(controller, _session) ||
        !_session.isSessionActive(_generation)) {
      return;
    }
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitting = true);
    final generation = controller.sessionGeneration;
    try {
      await controller.submitWithPresentation(
        titleController.text,
        TimeInputField.parseDuration(timeController.text),
        ref: ref,
        details: WorkoutFinishDetails(
          startingTime: _date,
          parentID: _parentID,
          infobox: _notes,
        ),
      );
    } catch (error, stack) {
      logger.e('Error submitting workout', error: error, stackTrace: stack);
      if (mounted && controller.isSessionActive(generation)) {
        setState(() => _submitting = false);
        Go.snack(context.t.ongoingWorkout.finish.saveError);
      }
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
            title: Text(context.t.ongoingWorkout.exercises.reorder),
            leading: const CloseButton(),
            bottom: const PreferredSize(
              preferredSize: Size(0, 1),
              child: Divider(height: 1),
            ),
            actions: [
              IconButton(icon: const Icon(GTIcons.done), onPressed: _submit),
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
    Go.back(result: indices);
  }
}
