import 'package:flutter/material.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutIcon extends StatelessWidget {
  const WorkoutIcon({super.key, 
    required this.workout,
  });

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        // Ensure that there is always a character to display
        child: Text("${workout.name}R".characters.first.toUpperCase()),
      ),
    );
  }
}

class RoutineListTile extends StatelessWidget {
  final Workout routine;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RoutineListTile({
    required this.routine,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: WorkoutIcon(workout: routine),
      trailing: trailing,
      title: Text(routine.name),
      subtitle:
          Text("general.exercises".plural(routine.displayExerciseCount)),
      onTap: onTap,
    );
  }
}

class RoutinePreview extends StatelessWidget {
  const RoutinePreview({
    super.key,
    required this.routine,
    this.automaticallyImplyLeading = false,
  });

  final Workout routine;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: ModalScrollController.of(context),
      slivers: [
        SliverAppBar.medium(
          title: SafeArea(child: Text(routine.name)),
          automaticallyImplyLeading: automaticallyImplyLeading,
          shadowColor: Colors.transparent,
        ),
        if (routine.shouldShowInfobox)
          SliverPadding(
          padding: 
              MediaQuery.of(context).padding.onlyHorizontal,
          sliver: SliverToBoxAdapter(
            child: Infobox(
              text: routine.infobox!,
            ),
          ),),
        SliverPadding(
          padding: const EdgeInsets.all(16) +
              MediaQuery.of(context).padding.copyWith(top: 0),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(1),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = routine.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ExerciseDataView(
                        exercise: exercise,
                        workout: routine,
                        index: index,
                        isInSuperset: false,
                        highlight: false,
                        weightUnit: routine.weightUnit,
                        distanceUnit: routine.distanceUnit,
                      ),
                    );
                  },
                  childCount: routine.exercises.length,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}