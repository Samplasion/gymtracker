import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/platform/app_bar.dart';
import 'package:gymtracker/view/platform/icons.dart';
import 'package:gymtracker/view/platform/list_tile.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';
import 'package:gymtracker/view/platform/scaffold.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/platform_padded.dart';

Workout get emptyWorkout => Workout(name: "", exercises: []);

class RoutinesView extends StatefulWidget {
  const RoutinesView({super.key});

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  RoutinesController get controller => Get.put(RoutinesController());
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // TODO: Figure out why this was needed and document it
    // controller.onServiceChange();
  }

  @override
  Widget build(BuildContext context) {
    final quickWorkoutButton = PlatformListTile(
      cupertinoIsNotched: true,
      title: Text("routines.quickWorkout.title".t),
      subtitle: Text("routines.quickWorkout.subtitle".t),
      leading: PlatformLeadingIcon(child: Icon(PlatformIcons.stopwatch)),
      onTap: () {
        controller.startRoutine(context, emptyWorkout, isEmpty: true);
      },
    );
    return PlatformScaffold(
      body: CustomScrollView(
        slivers: [
          PlatformSliverAppBar(
            title: Text("routines.title".t),
          ),
          PlatformBuilder(
            buildMaterial: (context, _) {
              return SliverToBoxAdapter(child: quickWorkoutButton);
            },
            buildCupertino: (context, _) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          PlatformBuilder(
            buildMaterial: (context, _) {
              return Obx(() {
                return SliverReorderableList(
                  itemBuilder: _buildRoutine,
                  itemCount: controller.workouts.length,
                  onReorder: (oldIndex, newIndex) {
                    controller.reorder(oldIndex, newIndex);
                  },
                );
              });
            },
            buildCupertino: (context, _) {
              return SliverToBoxAdapter(
                child: Obx(() {
                  return CupertinoListSection.insetGrouped(
                    children: [
                      quickWorkoutButton,
                      ReorderableList(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: _buildRoutine,
                        itemCount: controller.workouts.length,
                        onReorder: (oldIndex, newIndex) {
                          controller.reorder(oldIndex, newIndex);
                        },
                      ),
                    ],
                  );
                }),
              );
            },
          ),
          PlatformBuilder(
            buildMaterial: (context, _) {
              return const SliverToBoxAdapter(child: Divider());
            },
            buildCupertino: (context, _) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          PlatformPadded(
            sliver: SliverToBoxAdapter(
              child: PlatformBuilder(
                buildMaterial: (context, widget) => widget!,
                buildCupertino: (context, widget) =>
                    CupertinoListSection.insetGrouped(
                  children: [widget!],
                ),
                child: PlatformListTile(
                  title: Text("routines.newRoutine".t),
                  leading:
                      const PlatformLeadingIcon(child: Icon(Icons.add_rounded)),
                  onTap: () {
                    Go.to(() => const RoutineCreator());
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _buildRoutine(context, index) {
    final workout = controller.workouts[index];
    return Material(
      type: MaterialType.transparency,
      key: ValueKey(workout.id),
      child: PlatformListTile(
        cupertinoIsNotched: true,
        leading: PlatformLeadingIcon(
          materialBackgroundColor:
              Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          child: Text(workout.name.characters.first.toUpperCase()),
        ),
        trailing: DragHandle(index: index),
        title: Text(workout.name),
        subtitle:
            Text("general.exercises".plural(workout.displayExerciseCount)),
        onTap: () {
          Go.to(() => ExercisesView(workout: workout));
        },
      ),
    );
  }
}
