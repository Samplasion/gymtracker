import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/gradient_bottom_bar.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
    final gradientColor = colorScheme.surfaceContainerHigh;
    return Scaffold(
      body: GradientBottomBar.wrap(
        context: context,
        child: Builder(
          builder: (context) {
            return CustomScrollView(
              controller: ModalScrollController.of(context),
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
                            final exercise = workout.exercises[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ExerciseDataView(
                                exercise: exercise,
                                workout: workout,
                                index: index,
                                isInSuperset: false,
                                highlight: false,
                                weightUnit: workout.weightUnit,
                                distanceUnit: workout.distanceUnit,
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
            );
          },
        ),
      ),
      extendBody: true,
      bottomNavigationBar: GradientBottomBar(
        color: gradientColor,
        center: true,
        buttons: [
          FilledButton.tonal(
            onPressed: () => Get.back(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
    );
  }
}
