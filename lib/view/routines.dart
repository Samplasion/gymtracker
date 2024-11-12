import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/animated_selectable.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RoutinesView extends StatefulWidget {
  final bool _skeleton;

  const RoutinesView({super.key}) : _skeleton = false;

  const RoutinesView.skeleton({super.key}) : _skeleton = true;

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

const _kFakeRoutineSeed = 2001;

class _RoutinesViewState extends State<RoutinesView> with _RoutineList {
  RoutinesController get controller => Get.find<RoutinesController>();
  int selectedIndex = 0;

  List<({int occurrences, Workout routine})> get fakeSuggested => List.generate(
      2,
      (i) => (occurrences: 1, routine: skeletonWorkout(_kFakeRoutineSeed + i)));
  List<Workout> get fakeRoutines =>
      List.generate(3, (i) => skeletonWorkout(_kFakeRoutineSeed + i));
  Map<GTRoutineFolder, List<Workout>> get fakeFolders => {
        for (int i = 0; i < 3; i++)
          skeletonFolder(_kFakeRoutineSeed + i):
              List.generate(2, (j) => skeletonWorkout(_kFakeRoutineSeed + j))
      };

  @override
  void initState() {
    super.initState();
    controller.onServiceChange();
  }

  @override
  void onTapWorkout(Workout workout) {
    Go.to(() => ExercisesView(workout: workout));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget._skeleton;
    final showSuggestedRoutines =
        Get.find<SettingsController>().showSuggestedRoutines.value;
    return IgnorePointer(
      ignoring: isLoading,
      child: Scaffold(
        body: Obx(() {
          final suggested = isLoading
              ? fakeSuggested
              : showSuggestedRoutines
                  ? controller.suggestions
                  : <RoutineSuggestion>[];
          return CustomScrollView(
            slivers: [
              // Hardcode the title while loading to avoid flickering
              SliverAppBar.large(
                title: Text(isLoading ? "Routines" : "routines.title".t),
                leading: SkeletonDrawerButton(),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text("routines.quickWorkout.title".t),
                  subtitle: Text("routines.quickWorkout.subtitle".t),
                  leading: Skeleton.leaf(
                    child: CircleAvatar(
                      foregroundColor:
                          context.colorScheme.onQuaternaryContainer,
                      backgroundColor: context.colorScheme.quaternaryContainer,
                      child: const Icon(GTIcons.empty_workout),
                    ),
                  ),
                  onTap: () {
                    controller.startRoutine(context);
                  },
                ),
              ),
              if (showSuggestedRoutines && suggested.isNotEmpty) ...[
                const SliverToBoxAdapter(child: Divider()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final (routine: workout, occurrences: frequency) =
                          suggested[index];
                      return Material(
                        type: MaterialType.transparency,
                        key: ValueKey(workout.id),
                        child: ListTile(
                          leading: WorkoutIcon(workout: workout),
                          title: Text.rich(TextSpan(
                            children: [
                              TextSpan(
                                text: workout.name,
                              ),
                              const TextSpan(text: " "),
                              WidgetSpan(
                                child: Skeleton.ignore(
                                  child: GTBadge(content: frequency.toString()),
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                            ],
                          )),
                          subtitle: Text("general.exercises"
                              .plural(workout.displayExerciseCount)),
                          onTap: () {
                            onTapWorkout(workout);
                          },
                        ),
                      );
                    },
                    childCount: suggested.length,
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
              ],
              ...routineList(
                isLoading ? fakeFolders.obs : controller.folders,
                isLoading ? fakeRoutines.obs : controller.rootRoutines,
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text("routines.newRoutine".t),
                  leading: const Skeleton.leaf(
                    child: CircleAvatar(
                      child: Icon(GTIcons.create_routine),
                    ),
                  ),
                  onTap: () {
                    Go.to(() => const RoutineCreator());
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text("routines.newFolder".t),
                  leading: const Skeleton.leaf(
                    child: CircleAvatar(
                      child: Icon(GTIcons.create_folder),
                    ),
                  ),
                  onTap: () {
                    controller.createFolder();
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverBottomSafeArea(),
            ],
          );
        }),
      ),
    );
  }
}

class _DraggingListItem extends StatelessWidget {
  const _DraggingListItem({
    required this.dragKey,
    required this.workout,
  });

  final GlobalKey dragKey;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: ClipRRect(
        key: dragKey,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          width: 150,
          child: Opacity(
            opacity: 0.85,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WorkoutIcon(workout: workout),
                    Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      "general.exercises".plural(workout.displayExerciseCount),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditFolderModal extends StatefulWidget {
  final GTRoutineFolder folder;

  const EditFolderModal({super.key, required this.folder});

  @override
  State<EditFolderModal> createState() => _EditFolderModalState();
}

class _EditFolderModalState
    extends ControlledState<EditFolderModal, RoutinesController> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _controller =
      TextEditingController(text: widget.folder.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("routines.editFolder".t), actions: [
        IconButton(
          icon: const Icon(GTIcons.delete),
          tooltip: "actions.remove".t,
          onPressed: () {
            controller.deleteFolder(widget.folder);
          },
        ),
        IconButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Get.back(
                result: widget.folder.copyWith(
              name: _controller.text,
            ));
          },
          tooltip: "actions.save".t,
          icon: const Icon(GTIcons.done),
        ),
      ]),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: GymTrackerInputDecoration(
                  labelText: "routines.folderName".t,
                ),
                controller: _controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "routines.folderNameEmpty".t;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

mixin _RoutineList<T extends StatefulWidget> on State<T> {
  final GlobalKey _draggableKey = GlobalKey();

  final Map<String, bool> _folderExpansion = {};

  bool isDraggingOverRoot = false;
  bool isDraggingRootMovingCandidate = false;

  List<Widget> routineList(
      Map<GTRoutineFolder, List<Workout>> folders, List<Workout> rootRoutines) {
    final controller = Get.find<RoutinesController>();
    final folderList = folders.keys.toList()
      ..sort((a, b) {
        return a.name.compareTo(b.name);
      });
    return [
      SliverList.builder(
        itemBuilder: (context, index) {
          final folder = folderList[index];
          final workouts = folders[folder]!;
          return DragTarget<Workout>(
            builder: (context, candidateItems, rejectedItems) {
              final isExpanded = _folderExpansion[folder.id] ?? false;

              final shouldHighlight = candidateItems.isNotEmpty;
              var backgroundColor = Theme.of(context).colorScheme.secondary;
              var foregroundColor = Theme.of(context).colorScheme.onSecondary;
              var icon = GTIcons.folder_closed;

              if (shouldHighlight || isExpanded) {
                icon = GTIcons.folder_open;
              }

              final elevation = shouldHighlight || isExpanded ? 4.0 : 0.0;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: isExpanded ? 8 : 0,
                ),
                child: Material(
                  elevation: elevation,
                  color: ElevationOverlay.applySurfaceTint(
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceTint,
                    elevation,
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      controller.editFolderScreen(folder);
                    },
                    child: ExpansionTile(
                      expansionAnimationStyle: AnimationStyle(
                        curve: Curves.easeInOutCubic,
                        duration: const Duration(milliseconds: 350),
                      ),
                      initiallyExpanded: isExpanded,
                      shape: const RoundedRectangleBorder(),
                      collapsedShape: const RoundedRectangleBorder(),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _folderExpansion[folder.id] = expanded;
                        });
                      },
                      leading: Skeleton.leaf(
                        child: CircleAvatar(
                          backgroundColor: backgroundColor,
                          foregroundColor: foregroundColor,
                          child: Icon(icon),
                        ),
                      ),
                      title: Text(folder.name),
                      subtitle:
                          Text("general.routines".plural(workouts.length)),
                      trailing: SelectableAnimatedBuilder(
                        isSelected: isExpanded,
                        builder: (context, anim) {
                          return RotationTransition(
                            turns: anim.drive(
                              Animatable.fromCallback((value) =>
                                  mapRange(value, 0.0, 1.0, 0.25, 0.75)),
                            ),
                            child: const Icon(GTIcons.lt_chevron),
                          );
                        },
                      ),
                      children: [
                        ReorderableList(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: workouts.length,
                          itemBuilder: (context, index) => _buildWorkout(
                            context,
                            index,
                            workouts[index],
                          ),
                          onReorder: (oldIndex, newIndex) {
                            controller.reorderFolder(
                                folder, oldIndex, newIndex);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            onAcceptWithDetails: (details) {
              controller.moveToFolder(details.data, folder);
            },
          );
        },
        itemCount: folders.length,
      ),
      SliverReorderableList(
        itemBuilder: (context, index) => DragTarget<Workout>(
          key: ValueKey(rootRoutines[index].id),
          onWillAcceptWithDetails: (data) {
            if (data.data.folder == null) {
              return false;
            }
            setState(() {
              isDraggingOverRoot = true;
            });
            return true;
          },
          onLeave: (data) {
            setState(() {
              isDraggingOverRoot = false;
            });
          },
          onAcceptWithDetails: (details) {
            controller.moveToRoot(details.data);
            setState(() {
              isDraggingOverRoot = false;
            });
          },
          builder: (context, candidateItems, rejectedItems) {
            final shouldHighlight =
                candidateItems.isNotEmpty || isDraggingOverRoot;
            final elevation = shouldHighlight ? 4.0 : 0.0;

            return Material(
              elevation: elevation,
              color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceTint,
                elevation,
              ),
              child: _buildWorkout(
                context,
                index,
                rootRoutines[index],
              ),
            );
          },
        ),
        itemCount: rootRoutines.length,
        onReorder: (oldIndex, newIndex) {
          controller.reorderRoot(oldIndex, newIndex);
        },
      ),
      SliverToBoxAdapter(
        child: DragTarget<Workout>(
          onWillAcceptWithDetails: (data) {
            if (data.data.folder == null) {
              return false;
            }
            return true;
          },
          onAcceptWithDetails: (details) {
            controller.moveToRoot(details.data);
          },
          builder: (context, candidateItems, rejectedItems) {
            final shouldHighlight = candidateItems.isNotEmpty;
            return Crossfade(
              showSecond: shouldHighlight || isDraggingRootMovingCandidate,
              firstChild: const Divider(),
              secondChild: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  elevation: shouldHighlight ? 4.0 : 0.0,
                  color: ElevationOverlay.applySurfaceTint(
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceTint,
                    shouldHighlight ? 4.0 : 0.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ListTile(
                      title: Text("routines.dropHere".t),
                      subtitle: Text("routines.moveToRoot".t),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        child: const Icon(GTIcons.folder_open),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildWorkout(BuildContext context, int index, Workout workout) {
    return LongPressDraggable<Workout>(
      data: workout,
      key: ValueKey(workout.id),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DraggingListItem(
        dragKey: _draggableKey,
        workout: workout,
      ),
      onDragStarted: () {
        setState(() {
          if (workout.folder != null) isDraggingRootMovingCandidate = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          if (workout.folder != null) isDraggingRootMovingCandidate = false;
        });
      },
      child: Material(
        type: MaterialType.transparency,
        child: RoutineListTile(
          routine: workout,trailing: DragHandle(index: index),
onTap: () {
        onTapWorkout(workout);
      },
        ),
      ),
    );
  }

  void onTapWorkout(Workout workout);
}

class RoutinePicker extends StatefulWidget {
  final ValueChanged<Workout?> onPick;
  final bool allowNone;

  const RoutinePicker({
    super.key,
    required this.onPick,
    required this.allowNone,
  });

  @override
  State<RoutinePicker> createState() => _RoutinePickerState();
}

class _RoutinePickerState
    extends ControlledState<RoutinePicker, RoutinesController>
    with _RoutineList {
  @override
  void onTapWorkout(Workout workout) {
    logger.i("Picked workout: ${workout.name}");
    widget.onPick(workout);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("routines.pick".t),
            ),
            if (widget.allowNone) ...[
              SliverToBoxAdapter(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.tertiaryContainer,
                    foregroundColor: context.colorScheme.onTertiaryContainer,
                    child: const Icon(GTIcons.no_routine),
                  ),
                  title: Text("routines.none".t),
                  onTap: () {
                    widget.onPick(null);
                    Get.back();
                  },
                ),
              ),
              const SliverToBoxAdapter(child: Divider()),
            ],
            ...routineList(controller.folders, controller.rootRoutines),
            // Make space for the expandable divider when dragging
            const SliverToBoxAdapter(child: SizedBox(height: 128)),
          ],
        ),
      ),
    );
  }
}

class TerseRoutineListTile extends StatelessWidget {
  final Workout? routine;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool showIcon;

  const TerseRoutineListTile({
    super.key,
    required this.routine,
    this.onTap,
    this.contentPadding = EdgeInsets.zero,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    Icon icon;
    String text;

    if (routine!.folder != null) {
      icon = const Icon(GTIcons.folder_closed, size: 20);
      text = routine!.folder!.name;
    } else {
      icon = const Icon(GTIcons.folder_root, size: 20);
      text = "routineFormPicker.fields.routine.options.root".t;
    }

    return ListTile(
      leading: showIcon
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(routine!.name.characters.first.toUpperCase()),
            )
          : null,
      title: Text(
        routine!.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text.rich(
        TextSpan(children: [
          WidgetSpan(child: icon, alignment: PlaceholderAlignment.middle),
          const TextSpan(text: " "),
          TextSpan(text: text),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(GTIcons.lt_chevron),
      onTap: onTap,
      contentPadding: contentPadding,
      visualDensity: VisualDensity.standard,
      mouseCursor: MouseCursor.defer,
    );
  }
}
