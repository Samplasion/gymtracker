import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:universal_platform/universal_platform.dart';

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
    controller.onServiceChange();
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestedRoutines =
        Get.find<SettingsController>().showSuggestedRoutines.value;
    return Scaffold(
      body: Obx(() {
        final suggested = showSuggestedRoutines
            ? controller.suggestions
            : <RoutineSuggestion>[];
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("routines.title".t),
            ),
            SliverToBoxAdapter(
              child: ListTile(
                title: Text("routines.quickWorkout.title".t),
                subtitle: Text("routines.quickWorkout.subtitle".t),
                leading: CircleAvatar(
                  foregroundColor: context.colorScheme.onQuaternaryContainer,
                  backgroundColor: context.colorScheme.quaternaryContainer,
                  child: const Icon(GymTrackerIcons.empty_workout),
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
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          child:
                              Text(workout.name.characters.first.toUpperCase()),
                        ),
                        title: Text.rich(TextSpan(
                          children: [
                            TextSpan(
                              text: workout.name,
                            ),
                            const TextSpan(text: " "),
                            WidgetSpan(
                              child: GTBadge(content: frequency.toString()),
                              alignment: PlaceholderAlignment.middle,
                            ),
                          ],
                        )),
                        subtitle: Text("general.exercises"
                            .plural(workout.displayExerciseCount)),
                        onTap: () {
                          Go.to(() => ExercisesView(workout: workout));
                        },
                      ),
                    );
                  },
                  childCount: suggested.length,
                ),
              ),
              const SliverToBoxAdapter(child: Divider()),
            ],
            SliverReorderableList(
              itemBuilder: (context, index) {
                final workout = controller.workouts[index];
                return Material(
                  type: MaterialType.transparency,
                  key: ValueKey(workout.id),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      child: Text(workout.name.characters.first.toUpperCase()),
                    ),
                    trailing: () {
                      if (UniversalPlatform.isAndroid ||
                          UniversalPlatform.isIOS) {
                        return ReorderableDelayedDragStartListener(
                          index: index,
                          child: const Icon(GymTrackerIcons.drag_handle),
                        );
                      } else {
                        return ReorderableDragStartListener(
                          index: index,
                          child: const Icon(GymTrackerIcons.drag_handle),
                        );
                      }
                    }(),
                    title: Text(workout.name),
                    subtitle: Text("general.exercises"
                        .plural(workout.displayExerciseCount)),
                    onTap: () {
                      Go.to(() => ExercisesView(workout: workout));
                    },
                  ),
                );
              },
              itemCount: controller.workouts.length,
              onReorder: (oldIndex, newIndex) {
                controller.reorder(oldIndex, newIndex);
              },
            ),
            const SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: ListTile(
                title: Text("routines.newRoutine".t),
                leading: const CircleAvatar(
                    child: Icon(GymTrackerIcons.create_routine)),
                onTap: () {
                  Go.to(() => const RoutineCreator());
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        );
      }),
    );
  }
}
