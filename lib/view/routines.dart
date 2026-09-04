import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/repository/routines.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/boutique.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/components/subscription_nag.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/library.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/animated_selectable.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class RoutinesView extends ConsumerStatefulWidget {
  final bool _skeleton;

  const RoutinesView({super.key}) : _skeleton = false;

  const RoutinesView.skeleton({super.key}) : _skeleton = true;

  @override
  ConsumerState<RoutinesView> createState() => _RoutinesViewState();
}

const _kFakeRoutineSeed = 2001;

class _NonJumpableScrollController extends ScrollController {
  @override
  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) {
    // no-op
    return Future.value(null);
  }

  @override
  void jumpTo(double value) {
    // no-op
  }
}

class _RoutinesViewState extends ConsumerState<RoutinesView> with _RoutineList {
  RoutinesController get controller => Get.find<RoutinesController>();
  int selectedIndex = 0;
  final ScrollController _scrollController = _NonJumpableScrollController();

  List<({int occurrences, Workout routine})> get fakeSuggested => List.generate(
    2,
    (i) => (occurrences: 1, routine: skeletonWorkout(_kFakeRoutineSeed + i)),
  );
  List<Workout> get fakeRoutines =>
      List.generate(30, (i) => skeletonWorkout(_kFakeRoutineSeed + i));
  Map<GTRoutineFolder, List<Workout>> get fakeFolders => {
    for (int i = 0; i < 3; i++)
      skeletonFolder(_kFakeRoutineSeed + i): List.generate(
        2,
        (j) => skeletonWorkout(_kFakeRoutineSeed + j),
      ),
  };

  @override
  void initState() {
    super.initState();
    controller.onServiceChange();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    final rootRoutines = ref.watch(routinesStreamProvider);
    final routinesByFolder = ref.watch(routinesByFolderProvider);
    final folders = ref.watch(foldersStreamProvider);

    final loadingView = SliverSkeletonizer(
      enabled: true,
      child: MultiSliver(
        children: routineList(
          fakeFolders,
          fakeRoutines,
          foldersInNewPage: true,
        ),
      ),
    );

    final suggested = isLoading
        ? fakeSuggested
        : showSuggestedRoutines
        ? controller.suggestions
        : <RoutineSuggestion>[];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hardcode the title while loading to avoid flickering
          SliverAppBar.large(
            title: Text(isLoading ? "Routines" : "routines.title".t),
            leading: const SkeletonDrawerButton(),
            actions: [
              IconButton(
                onPressed: () {
                  Go.to(() => const BoutiqueView());
                },
                icon: const Icon(GTIcons.boutique),
                tooltip: "boutique.title".t,
              ),
              IconButton(
                onPressed: () {
                  Go.to(() => const LibraryView());
                },
                icon: const Icon(GTIcons.library),
                tooltip: "library.title".t,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SubscriptionNag(
              stringKey: "routines",
              shouldHide: (subscriptionInfo) {
                return subscriptionInfo.hasProFeatures ||
                    controller.workouts.length <
                        Configuration.trialRoutineAlertLimit;
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ProBuilder(
              builder: (context, subscriptionInfo) {
                final historyController = Get.find<HistoryController>();
                final shouldDisable =
                    (subscriptionInfo == null ||
                        !subscriptionInfo.hasProFeatures) &&
                    historyController.history.length >=
                        Configuration.trialWorkoutLimit;
                return ListTile(
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
                    if (shouldDisable) {
                      Get.find<PurchasesController>().presentPaywall();
                      return;
                    }
                    controller.startRoutine(context);
                  },
                );
              },
            ),
          ),

          ...folders.maybeMap(
            data: (folders) {
              return routinesByFolder.maybeMap(
                data: (folderMappings) {
                  return rootRoutines.maybeMap(
                    data: (routines) {
                      return routineList(
                        {
                          for (final MapEntry(key: folderID, value: routine)
                              in folderMappings.value.entries)
                            if (folders.value.any(
                              (folder) => folder.id == folderID,
                            ))
                              folders.value.firstWhere(
                                (folder) => folder.id == folderID,
                              ): routine,
                        },
                        routines.value
                            .where((element) => element.folder == null)
                            .toList(),
                        foldersInNewPage: true,
                      );
                    },
                    orElse: () => [loadingView],
                  );
                },
                orElse: () => [loadingView],
              );
            },
            orElse: () => [loadingView],
          ),

          SliverToBoxAdapter(
            child: ProBuilder(
              builder: (context, subscriptionInfo) {
                final shouldDisable =
                    (subscriptionInfo == null ||
                        !subscriptionInfo.hasProFeatures) &&
                    controller.workouts.length >=
                        Configuration.trialRoutineLimit;
                return ListTile(
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "routines.newRoutine".t),
                        if (shouldDisable) ...[
                          const TextSpan(text: " "),
                          WidgetSpan(
                            child: Skeleton.ignore(child: ProBadge()),
                            alignment: PlaceholderAlignment.middle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  leading: Skeleton.leaf(
                    child: CircleAvatar(child: Icon(GTIcons.create_routine)),
                  ),
                  onTap: shouldDisable
                      ? () {
                          Get.find<PurchasesController>().presentPaywall();
                        }
                      : () {
                          Go.to(() => const RoutineCreator());
                        },
                );
              },
            ),
          ),
          if (controller.workouts.isNotEmpty)
            SliverToBoxAdapter(
              child: ProBuilder(
                builder: (context, subscriptionInfo) {
                  final shouldDisable =
                      (subscriptionInfo == null ||
                      !subscriptionInfo.hasProFeatures);

                  return ListTile(
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "routines.newFolder".t),
                          if (shouldDisable) ...[
                            const TextSpan(text: " "),
                            WidgetSpan(
                              child: Skeleton.ignore(child: ProBadge()),
                              alignment: PlaceholderAlignment.middle,
                            ),
                          ],
                        ],
                      ),
                    ),
                    leading: const Skeleton.leaf(
                      child: CircleAvatar(child: Icon(GTIcons.create_folder)),
                    ),
                    onTap: () {
                      if (shouldDisable) {
                        Get.find<PurchasesController>().presentPaywall();
                        return;
                      }
                      controller.createFolder();
                    },
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

class _DraggingListItem extends StatelessWidget {
  const _DraggingListItem({required this.dragKey, required this.workout});

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
  late final TextEditingController _controller = TextEditingController(
    text: widget.folder.name,
  );
  late final QuillController _notesController = quillControllerFromText(
    widget.folder.notes,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("routines.editFolder".t),
        actions: [
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

              Navigator.of(context).pop<GTRoutineFolder>(
                widget.folder.copyWith(
                  name: _controller.text,
                  notes: jsonEncode(
                    _notesController.document.toDelta().toJson(),
                  ),
                ),
              );
            },
            tooltip: "actions.save".t,
            icon: const Icon(GTIcons.done),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
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
              GTRichTextEditor(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "routines.folderNotes".t,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

mixin _RoutineList<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final GlobalKey _draggableKey = GlobalKey();

  final Map<String, bool> _folderExpansion = {};

  bool isDraggingOverRoot = false;
  bool isDraggingRootMovingCandidate = false;

  List<Widget> routineList(
    Map<GTRoutineFolder, List<Workout>> folders,
    List<Workout> rootRoutines, {
    bool foldersInNewPage = false,
  }) {
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

              if (foldersInNewPage) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: backgroundColor,
                    foregroundColor: foregroundColor,
                    child: Icon(icon),
                  ),
                  title: Text(folder.name),
                  subtitle: Text("general.routines".plural(workouts.length)),
                  onTap: () {
                    Go.to(
                      () => _RoutinesFolderView(
                        folder: folder,
                        onTapWorkout: onTapWorkout,
                      ),
                    );
                  },
                );
              }

              return AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: isExpanded ? 8 : 0),
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
                      subtitle: Text(
                        "general.routines".plural(workouts.length),
                      ),
                      children: [
                        ReorderableList(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: workouts.length,
                          itemBuilder: (context, index) =>
                              _buildWorkout(context, index, workouts[index]),
                          onReorderItem: (oldIndex, newIndex) {
                            ref
                                .read(routinesRepositoryProvider)
                                .reorderFolder(folder, oldIndex, newIndex);
                          },
                        ),
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
              child: _buildWorkout(context, index, rootRoutines[index]),
            );
          },
        ),
        itemCount: rootRoutines.length,
        onReorderItem: (oldIndex, newIndex) {
          ref
              .read(routinesRepositoryProvider)
              .reorderFolder(null, oldIndex, newIndex);
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
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
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
      feedback: _DraggingListItem(dragKey: _draggableKey, workout: workout),
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
          routine: workout,
          trailing: DragHandle(index: index),
          onTap: () {
            onTapWorkout(workout);
          },
        ),
      ),
    );
  }

  void onTapWorkout(Workout workout);
}

class _RoutinesFolderView extends ConsumerStatefulWidget {
  final GTRoutineFolder folder;
  final void Function(Workout workout) onTapWorkout;

  const _RoutinesFolderView({required this.folder, required this.onTapWorkout});

  @override
  ConsumerState<_RoutinesFolderView> createState() =>
      _RoutinesFolderViewState();
}

class _RoutinesFolderViewState extends ConsumerState<_RoutinesFolderView>
    with _RoutineList<_RoutinesFolderView> {
  @override
  void onTapWorkout(Workout workout) {
    Navigator.of(context).pop();
    // Delaying by a frame because some uses of this push a new screen.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onTapWorkout(workout);
    });
  }

  @override
  Widget build(BuildContext context) {
    final folder = ref.watch(
      foldersStreamProvider.select(
        (folders) => folders.whenOrNull(
          data: (folders) =>
              folders.firstWhereOrNull((f) => f.id == widget.folder.id),
        ),
      ),
    );
    final workouts = ref
        .watch(routinesByFolderProvider)
        .whenData((map) => map[widget.folder.id] ?? []);

    final repo = ref.watch(routinesRepositoryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(folder?.name ?? "routines.folder".t),
            actions: [
              IconButton(
                icon: Icon(GTIcons.edit),
                onPressed: folder == null
                    ? null
                    : () async {
                        final newFolder = await Go.showBottomModalScreen(
                          (context, _) => EditFolderModal(folder: folder),
                        );
                        if (newFolder != null) {
                          repo.updateFolder(newFolder);
                        }
                      },
              ),
            ],
          ),

          if (folder == null)
            SliverFillRemaining(
              child: ContentUnavailableView(
                icon: Icon(GTIcons.folder_open),
                title: Text("routines.nullFolder".t),
                description: Text("routines.nullFolderSubtitle".t),
              ),
            )
          else
            ...workouts.when(
              error: (error, _) => [
                SliverFillRemaining(child: ErrorViewComponent(error: error)),
              ],
              data: (workouts) {
                if (workouts.isEmpty) {
                  return [
                    SliverFillRemaining(
                      child: ContentUnavailableView(
                        icon: Icon(GTIcons.folder_open),
                        title: Text("routines.emptyFolder".t),
                        description: Text("routines.emptyFolderSubtitle".t),
                      ),
                    ),
                  ];
                }

                return [
                  if (folder.notes.asQuillDocument().length > 1)
                    SliverToBoxAdapter(child: Infobox(text: folder.notes)),

                  SliverToBoxAdapter(
                    child: DragTarget<Workout>(
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
                        repo.moveRoutineToFolder(details.data, null);
                        setState(() {
                          isDraggingOverRoot = false;
                        });
                      },
                      builder: (context, candidateItems, rejectedItems) {
                        final shouldHighlight = candidateItems.isNotEmpty;
                        var backgroundColor = Theme.of(
                          context,
                        ).colorScheme.secondary;
                        var foregroundColor = Theme.of(
                          context,
                        ).colorScheme.onSecondary;
                        var icon = GTIcons.folder_closed;

                        if (shouldHighlight) {
                          icon = GTIcons.folder_open;
                        }

                        final elevation = shouldHighlight ? 4.0 : 0.0;

                        return Crossfade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: SafeArea(
                            top: false,
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                  color: ElevationOverlay.applySurfaceTint(
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context).colorScheme.surfaceTint,
                                    elevation,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  title: Text("routines.dropHere".t),
                                  subtitle: Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(GTIcons.home, size: 16),
                                          alignment:
                                              PlaceholderAlignment.middle,
                                        ),
                                        const TextSpan(text: " "),
                                        TextSpan(text: "routines.rootFolder".t),
                                      ],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: backgroundColor,
                                    foregroundColor: foregroundColor,
                                    child: Icon(icon),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          showSecond: isDraggingRootMovingCandidate,
                        );
                      },
                    ),
                  ),
                  SliverReorderableList(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) =>
                        _buildWorkout(context, index, workouts[index]),
                    onReorderItem: (oldIndex, newIndex) {
                      repo.reorderFolder(folder, oldIndex, newIndex);
                    },
                  ),
                ];
              },
              loading: () {
                return [
                  SliverFillRemaining(
                    child: Skeletonizer(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16) +
                            MediaQuery.of(context).padding.copyWith(top: 0),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final workout = skeletonWorkout(
                            _kFakeRoutineSeed + index,
                          );
                          return RoutineListTile(
                            routine: workout,
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
    );
  }
}

class RoutinePicker extends ConsumerStatefulWidget {
  final ValueChanged<Workout?> onPick;
  final bool allowNone;

  const RoutinePicker({
    super.key,
    required this.onPick,
    required this.allowNone,
  });

  @override
  ConsumerState<RoutinePicker> createState() => _RoutinePickerState();
}

class _RoutinePickerState extends ConsumerState<RoutinePicker>
    with _RoutineList {
  RoutinesController get controller => Get.find<RoutinesController>();

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
            SliverAppBar.large(title: Text("routines.pick".t)),
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
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(routine!.name.characters.first.toUpperCase()),
            )
          : null,
      title: Text(routine!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(child: icon, alignment: PlaceholderAlignment.middle),
            const TextSpan(text: " "),
            TextSpan(text: text),
          ],
        ),
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
