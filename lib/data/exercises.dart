import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

class ExerciseCategory {
  final List<Exercise> exercises;
  final Widget Function(Translations t) iconGetter;
  final Color color;

  const ExerciseCategory({
    required this.exercises,
    required this.iconGetter,
    required this.color,
  });

  ExerciseCategory filtered(bool Function(Exercise) filter) => ExerciseCategory(
    exercises: exercises.where(filter).toList(),
    iconGetter: iconGetter,
    color: color,
  );

  ExerciseCategory copyWith({
    List<Exercise>? exercises,
    Widget Function(Translations t)? iconGetter,
    Color? color,
  }) => ExerciseCategory(
    exercises: exercises ?? this.exercises,
    iconGetter: iconGetter ?? this.iconGetter,
    color: color ?? this.color,
  );
}

// RUN tools/asset_expl.py TO GENERATE ASSET MAP IN pubspec.yaml
final Map<GTExerciseMuscleCategory, ExerciseCategory> exerciseStandardLibrary =
    {
      GTExerciseMuscleCategory.cardio: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.cardio.exercises.aerobics",
            name: t.library.cardio.exercises.aerobics,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.biking",
            name: t.library.cardio.exercises.biking,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
          // aka the weird cyclette
          Exercise.standard(
            id: "library.cardio.exercises.ergometer",
            name: t.library.cardio.exercises.ergometer,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.ergometerHorizontal",
            name: t.library.cardio.exercises.ergometerHorizontal,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.pilates",
            name: t.library.cardio.exercises.pilates,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.running",
            name: t.library.cardio.exercises.running,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.treadmill",
            name: t.library.cardio.exercises.treadmill,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.zumba",
            name: t.library.cardio.exercises.zumba,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.jumpRope",
            name: t.library.cardio.exercises.jumpRope,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.rowingMachine",
            name: t.library.cardio.exercises.rowingMachine,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.other,
          ),
        ],
        iconGetter: (t) => const Icon(GTIcons.cardio),
        color: Colors.orange,
      ),
      GTExerciseMuscleCategory.chest: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressFlat",
            name: t.library.chest.exercises.barbellBenchPressFlat,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressIncline",
            name: t.library.chest.exercises.barbellBenchPressIncline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressDecline",
            name: t.library.chest.exercises.barbellBenchPressDecline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressFlat",
            name: t.library.chest.exercises.smithMachineBenchPressFlat,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressIncline",
            name: t.library.chest.exercises.smithMachineBenchPressIncline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressDecline",
            name: t.library.chest.exercises.smithMachineBenchPressDecline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressFlat",
            name: t.library.chest.exercises.dumbbellBenchPressFlat,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressIncline",
            name: t.library.chest.exercises.dumbbellBenchPressIncline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {
              GTMuscleGroup.triceps,
              GTMuscleGroup.shoulders,
            },
            equipment: GTGymEquipment.dumbbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressDecline",
            name: t.library.chest.exercises.dumbbellBenchPressDecline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.chest.exercises.cableBenchPressFlat",
            name: t.library.chest.exercises.cableBenchPressFlat,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.cableBenchPressIncline",
            name: t.library.chest.exercises.cableBenchPressIncline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.cableBenchPressDecline",
            name: t.library.chest.exercises.cableBenchPressDecline,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.butterflyMachine",
            name: t.library.chest.exercises.butterflyMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellHexPress",
            name: t.library.chest.exercises.dumbbellHexPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineHexPress",
            name: t.library.chest.exercises.smithMachineHexPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.seatedCableChestFlys",
            name: t.library.chest.exercises.seatedCableChestFlys,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.chest.exercises.verticalChestPress",
            name: t.library.chest.exercises.verticalChestPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.chest.exercises.cableFlyCrossovers",
            name: t.library.chest.exercises.cableFlyCrossovers,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.chest.exercises.pushUps",
            name: t.library.chest.exercises.pushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {
              GTMuscleGroup.triceps,
              GTMuscleGroup.shoulders,
            },
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.pushUpsWeighted",
            name: t.library.chest.exercises.pushUpsWeighted,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {
              GTMuscleGroup.triceps,
              GTMuscleGroup.shoulders,
            },
            equipment: GTGymEquipment.plates,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          // Note to self: this is the one at the weird close together cable machines
          Exercise.standard(
            id: "library.chest.exercises.cableChestPress",
            name: t.library.chest.exercises.cableChestPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {
              GTMuscleGroup.triceps,
              GTMuscleGroup.shoulders,
            },
            equipment: GTGymEquipment.cable,
            muscleHighlight: {
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.declinePushUps",
            name: t.library.chest.exercises.declinePushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.chest.exercises.inclinePushUps",
            name: t.library.chest.exercises.inclinePushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.chest.exercises.lowCableFly",
            name: t.library.chest.exercises.lowCableFly,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.shoulders},
            equipment: GTGymEquipment.cable,
            muscleHighlight: {
              GTMuscleHighlight.upperPectoralis:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.chest.exercises.tBarPress",
            name: t.library.chest.exercises.tBarPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.landmine,
          ),
          Exercise.standard(
            id: "library.chest.exercises.inclineBenchFlys",
            name: t.library.chest.exercises.inclineBenchFlys,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.chest.exercises.benchFlys",
            name: t.library.chest.exercises.benchFlys,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.biceps},
            equipment: GTGymEquipment.dumbbell,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.chest.name.characters.first.toUpperCase()),
        color: Colors.teal,
      ),
      GTExerciseMuscleCategory.biceps: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.biceps.exercises.barbellBicepsCurl",
            name: t.library.biceps.exercises.barbellBicepsCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.spiderCurls",
            name: t.library.biceps.exercises.spiderCurls,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.singleArmCableHammerCurls",
            name: t.library.biceps.exercises.singleArmCableHammerCurls,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.cableBicepsCurl",
            name: t.library.biceps.exercises.cableBicepsCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.dumbbellBicepsCurl",
            name: t.library.biceps.exercises.dumbbellBicepsCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.bicepsCurlMachine",
            name: t.library.biceps.exercises.bicepsCurlMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.hammerCurlDumbbell",
            name: t.library.biceps.exercises.hammerCurlDumbbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.concentrationCurl",
            name: t.library.biceps.exercises.concentrationCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.scottCurl",
            name: t.library.biceps.exercises.scottCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.dualCableHighCurl",
            name: t.library.biceps.exercises.dualCableHighCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            equipment: GTGymEquipment.cable,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.biceps.name.characters.first.toUpperCase()),
        color: Colors.blue,
      ),
      GTExerciseMuscleCategory.abs: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.abs.exercises.crunches",
            name: t.library.abs.exercises.crunches,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.obliqueCrunches",
            name: t.library.abs.exercises.obliqueCrunches,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.kneeRaise",
            name: t.library.abs.exercises.kneeRaise,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.legRaise",
            name: t.library.abs.exercises.legRaise,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.legRaiseParallelBars",
            name: t.library.abs.exercises.legRaiseParallelBars,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.crunchMachine",
            name: t.library.abs.exercises.crunchMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.abs.exercises.heelsUpCrunch",
            name: t.library.abs.exercises.heelsUpCrunch,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.fullBodyCrunch",
            name: t.library.abs.exercises.fullBodyCrunch,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.plank",
            name: t.library.abs.exercises.plank,
            parameters: GTSetParameters.time,
            equipment: GTGymEquipment.none,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {
              GTMuscleGroup.shoulders,
              GTMuscleGroup.lats,
              GTMuscleGroup.triceps,
              GTMuscleGroup.traps,
              GTMuscleGroup.chest,
              GTMuscleGroup.biceps,
              GTMuscleGroup.glutes,
              GTMuscleGroup.quadriceps,
              GTMuscleGroup.hamstrings,
              GTMuscleGroup.calves,
            },
            muscleHighlight: {
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.obliques: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.longHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.trapsMiddle:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.gluteusMaximus:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.outerQuadricep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.medialHamstrings:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.soleus: GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.gastrocnemius:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.hollowBodyHold",
            name: t.library.abs.exercises.hollowBodyHold,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.russianTwist",
            name: t.library.abs.exercises.russianTwist,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            secondaryMuscleGroups: {GTMuscleGroup.abs},
            equipment: GTGymEquipment.plates,
          ),
          Exercise.standard(
            id: "library.abs.exercises.bicycleCrunches",
            name: t.library.abs.exercises.bicycleCrunches,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.extendedReverseCrunchWithLegExtension",
            name: t.library.abs.exercises.extendedReverseCrunchWithLegExtension,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.toeTouches",
            name: t.library.abs.exercises.toeTouches,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            secondaryMuscleGroups: {GTMuscleGroup.abs},
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.upperAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lowerAbdominals:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.obliques: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.abs.exercises.heelTouches",
            name: t.library.abs.exercises.heelTouches,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.deadBugHold",
            name: t.library.abs.exercises.deadBugHold,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.deadBugHoldCardio",
            name: t.library.abs.exercises.deadBugHoldCardio,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.hollowBodyHoldBentKnees",
            name: t.library.abs.exercises.hollowBodyHoldBentKnees,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.bicycleCrunchesCardio",
            name: t.library.cardio.exercises.bicycleCrunchesCardio,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.crunchesTimed",
            name: t.library.cardio.exercises.crunchesTimed,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.obliques.exercises.sidewaysPlank",
            name: t.library.obliques.exercises.sidewaysPlank,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.obliques.exercises.sidewaysPlankReachThrough",
            name: t.library.obliques.exercises.sidewaysPlankReachThrough,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.abs.exercises.lateralHyperextensions",
            name: t.library.abs.exercises.lateralHyperextensions,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.obliques,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.kettlebell,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.abs.name.characters.first.toUpperCase()),
        color: Colors.amber,
      ),
      GTExerciseMuscleCategory.calves: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseStanding",
            name: t.library.calves.exercises.calfRaiseStanding,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.calves,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseSeated",
            name: t.library.calves.exercises.calfRaiseSeated,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.calves,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.calves.exercises.calfPressLegPressMachine",
            name: t.library.calves.exercises.calfPressLegPressMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.calves,
            equipment: GTGymEquipment.machine,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.calves.name.characters.first.toUpperCase()),
        color: Colors.green,
      ),
      GTExerciseMuscleCategory.quadriceps: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.quadriceps.exercises.bodyweightSquats",
            name: t.library.quadriceps.exercises.bodyweightSquats,
            parameters: GTSetParameters.freeBodyReps,
            equipment: GTGymEquipment.none,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            muscleHighlight: {
              GTMuscleHighlight.outerQuadricep:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.innerQuadricep:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.gluteusMaximus:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.gluteusMedius:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.groin: GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.squatsBarbell",
            name: t.library.quadriceps.exercises.squatsBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.outerQuadricep:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.innerQuadricep:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.gluteusMaximus:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.gluteusMedius:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lowerback: GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.groin: GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.smithMachineLunges",
            name: t.library.quadriceps.exercises.smithMachineLunges,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.lunges",
            name: t.library.quadriceps.exercises.lunges,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress",
            name: t.library.quadriceps.exercises.legPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress45deg",
            name: t.library.quadriceps.exercises.legPress45deg,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legExtension",
            name: t.library.quadriceps.exercises.legExtension,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.frontSquats",
            name: t.library.quadriceps.exercises.frontSquats,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes, GTMuscleGroup.abs},
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.bulgarianSplitSquats",
            name: t.library.quadriceps.exercises.bulgarianSplitSquats,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.hackSquats",
            name: t.library.quadriceps.exercises.hackSquats,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
            equipment: GTGymEquipment.machine,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.quadriceps.name.characters.first.toUpperCase()),
        color: Colors.indigo,
      ),
      GTExerciseMuscleCategory.hamstrings: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlProne",
            name: t.library.hamstrings.exercises.legCurlProne,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlSeated",
            name: t.library.hamstrings.exercises.legCurlSeated,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.romanianDeadlift",
            name: t.library.hamstrings.exercises.romanianDeadlift,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
            secondaryMuscleGroups: {
              GTMuscleGroup.lowerBack,
              GTMuscleGroup.glutes,
            },
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.romanianDeadliftDumbbell",
            name: t.library.hamstrings.exercises.romanianDeadliftDumbbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
            secondaryMuscleGroups: {
              GTMuscleGroup.lowerBack,
              GTMuscleGroup.glutes,
            },
            equipment: GTGymEquipment.dumbbell,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.hamstrings.name.characters.first.toUpperCase()),
        color: Colors.deepPurple,
      ),
      GTExerciseMuscleCategory.shoulders: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.shoulders.exercises.shoulderPressMachine",
            name: t.library.shoulders.exercises.shoulderPressMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesInclinedBench",
            name: t.library.shoulders.exercises.latRaisesInclinedBench,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesCable",
            name: t.library.shoulders.exercises.latRaisesCable,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesDualCable",
            name: t.library.shoulders.exercises.latRaisesDualCable,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesDumbbells",
            name: t.library.shoulders.exercises.latRaisesDumbbells,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.reverseFlysInclinedBench",
            name: t.library.shoulders.exercises.reverseFlysInclinedBench,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.arnoldPress",
            name: t.library.shoulders.exercises.arnoldPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.shoulderPress",
            name: t.library.shoulders.exercises.shoulderPress,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.frontDumbbellRaise",
            name: t.library.shoulders.exercises.frontDumbbellRaise,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.uprightRow",
            name: t.library.shoulders.exercises.uprightRow,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.lateralDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperTrapezius:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.trapsMiddle:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.pikePushUps",
            name: t.library.shoulders.exercises.pikePushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.lateralDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.upperTrapezius:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.trapsMiddle:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.handstandPushUps",
            name: t.library.shoulders.exercises.handstandPushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.bentOverLateralRaises",
            name: t.library.shoulders.exercises.bentOverLateralRaises,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {
              GTMuscleGroup.upperBack,
              GTMuscleGroup.traps,
              GTMuscleGroup.biceps,
            },
            equipment: GTGymEquipment.cable,
            muscleHighlight: {
              GTMuscleHighlight.lateralDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.posteriorDeltoid:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.trapsMiddle:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.deltoidMachine",
            name: t.library.shoulders.exercises.deltoidMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.shrugsBarbell",
            name: t.library.shoulders.exercises.shrugsBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.upperTrapezius:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.trapsMiddle: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralDeltoid:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.posteriorDeltoid:
                  GTMuscleHighlightIntensity.secondary,
            },
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.militaryPressSmithMachine",
            name: t.library.shoulders.exercises.militaryPressSmithMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.militaryPressBarbell",
            name: t.library.shoulders.exercises.militaryPressBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.reverseButterfly",
            name: t.library.shoulders.exercises.reverseButterfly,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
            equipment: GTGymEquipment.machine,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.shoulders.name.characters.first.toUpperCase()),
        color: Colors.cyan,
      ),
      GTExerciseMuscleCategory.back: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.back.exercises.hyperExtensions",
            name: t.library.back.exercises.hyperExtensions,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.lowerBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.glutes,
              GTMuscleGroup.hamstrings,
            },
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.back.exercises.weightedHyperExtensions",
            name: t.library.back.exercises.weightedHyperExtensions,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lowerBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.glutes,
              GTMuscleGroup.hamstrings,
            },
            equipment: GTGymEquipment.plates,
          ),
          Exercise.standard(
            id: "library.back.exercises.deadlift",
            name: t.library.back.exercises.deadlift,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lowerBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.hamstrings,
              GTMuscleGroup.glutes,
              GTMuscleGroup.quadriceps,
              GTMuscleGroup.forearms,
            },
            equipment: GTGymEquipment.barbell,
            muscleHighlight: {
              GTMuscleHighlight.lowerback: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.medialHamstrings:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHamstrings:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.gluteusMaximus:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.outerQuadricep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.wristFlexors:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.wristExtensors:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.barbellRow",
            name: t.library.back.exercises.barbellRow,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.forearms,
            },
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.back.exercises.dumbbellRow",
            name: t.library.back.exercises.dumbbellRow,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.forearms,
            },
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.back.exercises.triangleBarLatPulldowns",
            name: t.library.back.exercises.triangleBarLatPulldowns,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.traps,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.upperBack,
            },
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.underhandGripLatPulldowns",
            name: t.library.back.exercises.underhandGripLatPulldowns,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.traps,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.upperBack,
            },
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.latPulldowns",
            name: t.library.back.exercises.latPulldowns,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.traps,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.upperBack,
            },
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.latPulldownsWideGrip",
            name: t.library.back.exercises.latPulldownsWideGrip,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.traps,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.upperBack,
            },
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.latPulldownsNarrowGrip",
            name: t.library.back.exercises.latPulldownsNarrowGrip,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.traps,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.upperBack,
            },
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.cableSeatedRowTriangleBar",
            name: t.library.back.exercises.cableSeatedRowTriangleBar,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {GTMuscleGroup.biceps, GTMuscleGroup.traps},
            equipment: GTGymEquipment.cable,
            muscleHighlight: {
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.straightArmCablePushdown",
            name: t.library.back.exercises.straightArmCablePushdown,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.back.exercises.pullUps",
            name: t.library.back.exercises.pullUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
            secondaryMuscleGroups: {GTMuscleGroup.biceps},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.back.exercises.tBarRow",
            name: t.library.back.exercises.tBarRow,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.lowerBack,
            },
            equipment: GTGymEquipment.landmine,
          ),
          Exercise.standard(
            id: "library.back.exercises.tBarRowWideProneGrip",
            name: t.library.back.exercises.tBarRowWideProneGrip,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.lowerBack,
            },
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.back.exercises.rowMachine",
            name: t.library.back.exercises.rowMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {GTMuscleGroup.biceps, GTMuscleGroup.traps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercise.dualLowRowMachine",
            name: t.library.back.exercise.dualLowRowMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {GTMuscleGroup.biceps, GTMuscleGroup.traps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.back.exercise.dualHighRowMachine",
            name: t.library.back.exercise.dualHighRowMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {GTMuscleGroup.biceps, GTMuscleGroup.traps},
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.longHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.shortHeadBicep:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.lowerTrapezius:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.biceps.exercises.chinUps",
            name: t.library.back.exercises.chinUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.lats,
            secondaryMuscleGroups: {
              GTMuscleGroup.biceps,
              GTMuscleGroup.forearms,
            },
            equipment: GTGymEquipment.none,
            muscleHighlight: {
              GTMuscleHighlight.lats: GTMuscleHighlightIntensity.primary,
              for (final h in GTMuscleHighlight.groupToHighlight(
                GTMuscleGroup.biceps,
              ))
                h: GTMuscleHighlightIntensity.secondary,
              for (final h in GTMuscleHighlight.groupToHighlight(
                GTMuscleGroup.triceps,
              ))
                h: GTMuscleHighlightIntensity.tertiary,
            },
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.back.name.characters.first.toUpperCase()),
        color: Colors.pink,
      ),
      GTExerciseMuscleCategory.triceps: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.triceps.exercises.dips",
            name: t.library.triceps.exercises.dips,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            secondaryMuscleGroups: {
              GTMuscleGroup.chest,
              GTMuscleGroup.shoulders,
            },
            equipment: GTGymEquipment.other,
            muscleHighlight: <GTMuscleHighlight, GTMuscleHighlightIntensity>{
              GTMuscleHighlight.longHeadTriceps:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.medialHeadTriceps:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.lateralHeadTriceps:
                  GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.midLowerPectoralis:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.upperPectoralis:
                  GTMuscleHighlightIntensity.secondary,
              GTMuscleHighlight.anteriorDeltoid:
                  GTMuscleHighlightIntensity.tertiary,
            },
          ),
          Exercise.standard(
            id: "library.triceps.exercises.overheadRopeTricepExtension",
            name: t.library.triceps.exercises.overheadRopeTricepExtension,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.tricepsRopePushdown",
            name: t.library.triceps.exercises.tricepsRopePushdown,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.cable,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.skullCrushers",
            name: t.library.triceps.exercises.skullCrushers,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.tricepKickbacks",
            name: t.library.triceps.exercises.tricepKickbacks,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.benchDips",
            name: t.library.triceps.exercises.benchDips,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.diamondPushUps",
            name: t.library.triceps.exercises.diamondPushUps,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            secondaryMuscleGroups: {GTMuscleGroup.chest},
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.tricepsMachine",
            name: t.library.triceps.exercises.tricepsMachine,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.overheadTricepExtension",
            name: t.library.triceps.exercises.overheadTricepExtension,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
            equipment: GTGymEquipment.dumbbell,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.triceps.name.characters.first.toUpperCase()),
        color: Colors.yellow,
      ),
      GTExerciseMuscleCategory.hips: ExerciseCategory(
        color: Colors.brown,
        iconGetter: (t) =>
            Text(t.library.hips.name.characters.first.toUpperCase()),
        exercises: [
          Exercise.standard(
            id: "library.hips.exercises.hipAdduction",
            name: t.library.hips.exercises.hipAdduction,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.thighs,
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.innerThigh: GTMuscleHighlightIntensity.primary,
              GTMuscleHighlight.groin: GTMuscleHighlightIntensity.primary,
            },
          ),
        ],
      ),
      GTExerciseMuscleCategory.forearms: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.forearms.exercises.wristCurlsBarbell",
            name: t.library.forearms.exercises.wristCurlsBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.reverseWristCurlsBarbell",
            name: t.library.forearms.exercises.reverseWristCurlsBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.wristCurlsDumbbell",
            name: t.library.forearms.exercises.wristCurlsDumbbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.reverseWristCurlsDumbbell",
            name: t.library.forearms.exercises.reverseWristCurlsDumbbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.wristRoller",
            name: t.library.forearms.exercises.wristRoller,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            equipment: GTGymEquipment.other,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.farmerWalk",
            name: t.library.forearms.exercises.farmerWalk,
            parameters: GTSetParameters.timeWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            secondaryMuscleGroups: {
              GTMuscleGroup.shoulders,
              GTMuscleGroup.traps,
            },
            equipment: GTGymEquipment.kettlebell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.platePinch",
            name: t.library.forearms.exercises.platePinch,
            parameters: GTSetParameters.timeWeight,
            primaryMuscleGroup: GTMuscleGroup.forearms,
            secondaryMuscleGroups: {},
            equipment: GTGymEquipment.plates,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.reverseCurls",
            name: t.library.forearms.exercises.reverseCurls,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            secondaryMuscleGroups: {GTMuscleGroup.forearms},
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.reverseCurlsDumbbell",
            name: t.library.forearms.exercises.reverseCurlsDumbbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            secondaryMuscleGroups: {GTMuscleGroup.forearms},
            equipment: GTGymEquipment.dumbbell,
          ),
          Exercise.standard(
            id: "library.forearms.exercises.cableSingleArmReverseCurl",
            name: t.library.forearms.exercises.cableSingleArmReverseCurl,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            secondaryMuscleGroups: {GTMuscleGroup.forearms},
            equipment: GTGymEquipment.dumbbell,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.forearms.name.characters.first.toUpperCase()),
        color: Colors.lime,
      ),
      GTExerciseMuscleCategory.glutes: ExerciseCategory(
        color: Colors.deepOrange,
        iconGetter: (t) =>
            Text(t.library.glutes.name.characters.first.toUpperCase()),
        exercises: [
          Exercise.standard(
            id: "library.hips.exercises.gluteBridge",
            name: t.library.glutes.exercises.gluteBridge,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
            equipment: GTGymEquipment.none,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipThrust",
            name: t.library.glutes.exercises.hipThrust,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
            equipment: GTGymEquipment.machine,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipThrustBarbell",
            name: t.library.glutes.exercises.hipThrustBarbell,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
            equipment: GTGymEquipment.barbell,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipAbduction",
            name: t.library.glutes.exercises.hipAbduction,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
            equipment: GTGymEquipment.machine,
            muscleHighlight: {
              GTMuscleHighlight.gluteusMedius:
                  GTMuscleHighlightIntensity.primary,
            },
          ),
          Exercise.standard(
            id: "library.hips.exercises.clamshells",
            name: t.library.glutes.exercises.clamshells,
            // With resistance band
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.glutes,
            equipment: GTGymEquipment.resistanceBand,
          ),
        ],
      ),
      GTExerciseMuscleCategory.other: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.other.exercises.stretching",
            name: t.library.other.exercises.stretching,
            parameters: GTSetParameters.setless,
            primaryMuscleGroup: GTMuscleGroup.none,
            equipment: GTGymEquipment.none,
          ),
        ],
        iconGetter: (t) =>
            Text(t.library.other.name.characters.first.toUpperCase()),
        color: Colors.grey,
      ),
    }.map(
      (key, value) => MapEntry(
        key,
        value.copyWith(
          exercises: value.exercises.map((e) => e.withCategory(key)).toList(),
        ),
      ),
    );

final List<Exercise> exerciseStandardLibraryAsList = exerciseStandardLibrary
    .values
    .fold(
      <Exercise>[],
      (previousValue, element) => [...previousValue, ...element.exercises],
    );

List<GTExerciseMuscleCategory> getSortedCategories(Translations t) =>
    [...exerciseStandardLibrary.keys]..sort(
      (a, b) => a
          .getLocalizedName(t)
          .toLowerCase()
          .compareTo(b.getLocalizedName(t).toLowerCase()),
    );

Exercise? getStandardExerciseByID(String id) => exerciseStandardLibraryAsList
    .firstWhereOrNull((element) => element.id == id);
