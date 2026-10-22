import 'package:flutter/material.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/utils/go.dart';
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
  final muscleGroups = <GTMuscleGroup>{};
  final equipment = GTGymEquipment.values.toSet();

  @override
  Widget build(BuildContext context) {
    final allMuscleGroups = GTMuscleGroup.values.toList();
    allMuscleGroups.sort(
      (a, b) => a
          .getLocalizedName(context.t)
          .compareTo(b.getLocalizedName(context.t)),
    );
    return ThemedSubtree(
      color: getThemedColor(context, GTColors.ai),
      child: AlertDialog(
        title: Text(context.t.workoutGenerator.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t.workoutGenerator.muscleGroups),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in allMuscleGroups)
                    ChoiceChip.elevated(
                      label: Text(group.getLocalizedName(context.t)),
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
              Text(context.t.workoutGenerator.equipment),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final eq in GTGymEquipment.values)
                    ChoiceChip.elevated(
                      label: Text(eq.getLocalizedName(context.t)),
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
            child: Text(context.t.workoutGenerator.actions.generate),
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
      Go.back(result: (muscleGroups, equipment));
    };
  }
}
