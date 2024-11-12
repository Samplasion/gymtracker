import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/gradient_bottom_bar.dart';
import 'package:gymtracker/view/components/routines.dart';

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
            return RoutinePreview(routine: workout);
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
