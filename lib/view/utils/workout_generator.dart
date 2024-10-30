import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/equipment_icon.dart';
import 'package:gymtracker/view/components/themed_subtree.dart';

class WorkoutGeneratorSetupScreen extends StatefulWidget {
  const WorkoutGeneratorSetupScreen({super.key});

  @override
  State<WorkoutGeneratorSetupScreen> createState() =>
      _WorkoutGeneratorSetupScreenState();
}

class _WorkoutGeneratorSetupScreenState
    extends State<WorkoutGeneratorSetupScreen> {
  final muscleGroups = <GTMuscleCategory>{};
  final equipment = GTGymEquipment.values.toSet();

  @override
  Widget build(BuildContext context) {
    return ThemedSubtree(
      color: getThemedColor(context, GTColors.ai),
      child: AlertDialog(
        title: Text("workoutGenerator.title".t),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("workoutGenerator.muscleGroups".t),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in GTMuscleCategory.values)
                    ChoiceChip.elevated(
                      label: Text(group.localizedName),
                      selected: muscleGroups.contains(group),
                      onSelected: (_) {
                        setState(() {
                          if (muscleGroups.contains(group)) {
                            muscleGroups.remove(group);
                          } else {
                            muscleGroups.add(group);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text("workoutGenerator.equipment".t),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final eq in GTGymEquipment.values)
                    ChoiceChip.elevated(
                      label: Text(eq.localizedName),
                      selected: equipment.contains(eq),
                      avatar: EquipmentIcon(equipment: eq),
                      onSelected: (_) {
                        setState(() {
                          if (equipment.contains(eq)) {
                            equipment.remove(eq);
                          } else {
                            equipment.add(eq);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: _getOnPressed(),
            child: Text("workoutGenerator.actions.generate".t),
          ),
        ],
      ),
    );
  }

  void Function()? _getOnPressed() {
    if (muscleGroups.isEmpty || equipment.isEmpty) {
      return null;
    }

    return () {
      Get.back(result: (muscleGroups, equipment));
    };
  }
}
