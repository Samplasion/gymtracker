import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/exercises.dart';

class ImportRoutineModal extends StatefulWidget {
  final Workout workout;

  const ImportRoutineModal({required this.workout, super.key});

  @override
  State<ImportRoutineModal> createState() => _ImportRoutineModalState();
}

class _ImportRoutineModalState extends State<ImportRoutineModal>
    with SingleTickerProviderStateMixin {
  late AnimationController controller =
      BottomSheet.createAnimationController(this);
  Workout get workout => widget.workout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = ElevationOverlay.applySurfaceTint(
      colorScheme.surface,
      colorScheme.surfaceTint,
      4,
    );
    return BottomSheet(
      animationController: controller,
      onClosing: () {},
      clipBehavior: Clip.hardEdge,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: Text(workout.name),
                automaticallyImplyLeading: false,
                shadowColor: Colors.transparent,
              ),
              if (workout.shouldShowInfobox)
                SliverToBoxAdapter(
                  child: Infobox(
                    text: workout.infobox!,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16)
                    .copyWith(bottom: kBottomNavigationBarHeight + 20),
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
                          final exercise = workout.exercises[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ExerciseDataView(
                              exercise: exercise,
                              workout: workout,
                              index: index,
                              isInSuperset: false,
                              weightUnit: workout.weightUnit,
                            ),
                          );
                        },
                        childCount: workout.exercises.length,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: Container(
            alignment: Alignment.center,
            height: kBottomNavigationBarHeight + 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColor.withAlpha(0),
                  gradientColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0,
                  16 / (16 + kBottomNavigationBarHeight),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 16,
                children: [
                  FilledButton.tonal(
                    onPressed: () => Get.back(),
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                  FilledButton(
                    onPressed: () {
                      Get.back();
                      Get.find<RoutinesController>().importWorkout(workout);
                      Go.snack("importRoutine.import.done".t);
                    },
                    child: Text('importRoutine.import.label'.t),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
