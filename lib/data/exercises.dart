import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';

class ExerciseCategory {
  final List<Exercise> exercises;
  final Widget icon;
  final Color color;

  const ExerciseCategory({
    required this.exercises,
    required this.icon,
    required this.color,
  });

  ExerciseCategory filtered(bool Function(Exercise) filter) => ExerciseCategory(
        exercises: exercises.where(filter).toList(),
        icon: icon,
        color: color,
      );
}

Map<String, ExerciseCategory> get exerciseStandardLibrary => {
      "library.cardio.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.cardio.exercises.aerobics",
            name: "library.cardio.exercises.aerobics".t,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.biking",
            name: "library.cardio.exercises.biking".t,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          // aka the weird cyclette
          Exercise.standard(
            id: "library.cardio.exercises.ergometer",
            name: "library.cardio.exercises.ergometer".t,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.ergometerHorizontal",
            name: "library.cardio.exercises.ergometerHorizontal".t,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.pilates",
            name: "library.cardio.exercises.pilates".t,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.running",
            name: "library.cardio.exercises.running".t,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.treadmill",
            name: "library.cardio.exercises.treadmill".t,
            parameters: GTSetParameters.distance,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.zumba",
            name: "library.cardio.exercises.zumba".t,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.none,
          ),
        ],
        icon: const Icon(GymTrackerIcons.cardio),
        color: Colors.orange,
      ),
      "library.chest.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressFlat",
            name: "library.chest.exercises.barbellBenchPressFlat".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressIncline",
            name: "library.chest.exercises.barbellBenchPressIncline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressDecline",
            name: "library.chest.exercises.barbellBenchPressDecline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressFlat",
            name: "library.chest.exercises.smithMachineBenchPressFlat".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressIncline",
            name: "library.chest.exercises.smithMachineBenchPressIncline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressDecline",
            name: "library.chest.exercises.smithMachineBenchPressDecline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressFlat",
            name: "library.chest.exercises.dumbbellBenchPressFlat".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressIncline",
            name: "library.chest.exercises.dumbbellBenchPressIncline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressDecline",
            name: "library.chest.exercises.dumbbellBenchPressDecline".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.butterflyMachine",
            name: "library.chest.exercises.butterflyMachine".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellHexPress",
            name: "library.chest.exercises.dumbbellHexPress".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineHexPress",
            name: "library.chest.exercises.smithMachineHexPress".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.seatedCableChestFlys",
            name: "library.chest.exercises.seatedCableChestFlys".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.verticalChestPress",
            name: "library.chest.exercises.verticalChestPress".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.cableFlyCrossovers",
            name: "library.chest.exercises.cableFlyCrossovers".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.pushUps",
            name: "library.chest.exercises.pushUps".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
          ),
          Exercise.standard(
            id: "library.chest.exercises.pushUpsWeighted",
            name: "library.chest.exercises.pushUpsWeighted".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.chest,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
          ),
        ],
        icon: Text("library.chest.name".t.characters.first.toUpperCase()),
        color: Colors.teal,
      ),
      "library.biceps.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.biceps.exercises.barbellBicepsCurl",
            name: "library.biceps.exercises.barbellBicepsCurl".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.spiderCurls",
            name: "library.biceps.exercises.spiderCurls".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.singleArmCableHammerCurls",
            name: "library.biceps.exercises.singleArmCableHammerCurls".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.cableBicepsCurl",
            name: "library.biceps.exercises.cableBicepsCurl".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.dumbbellBicepsCurl",
            name: "library.biceps.exercises.dumbbellBicepsCurl".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.bicepsCurlMachine",
            name: "library.biceps.exercises.bicepsCurlMachine".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.chinUps",
            name: "library.biceps.exercises.chinUps".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.hammerCurlDumbbell",
            name: "library.biceps.exercises.hammerCurlDumbbell".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.biceps,
            secondaryMuscleGroups: {},
          ),
        ],
        icon: Text("library.biceps.name".t.characters.first.toUpperCase()),
        color: Colors.blue,
      ),
      "library.abs.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.abs.exercises.crunches",
            name: "library.abs.exercises.crunches".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.kneeRaise",
            name: "library.abs.exercises.kneeRaise".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.legRaise",
            name: "library.abs.exercises.legRaise".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.crunchMachine",
            name: "library.abs.exercises.crunchMachine".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.heelsUpCrunch",
            name: "library.abs.exercises.heelsUpCrunch".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.fullBodyCrunch",
            name: "library.abs.exercises.fullBodyCrunch".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.plank",
            name: "library.abs.exercises.plank".t,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
          ),
          Exercise.standard(
            id: "library.abs.exercises.hollowBodyHold",
            name: "library.abs.exercises.hollowBodyHold".t,
            parameters: GTSetParameters.time,
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
          ),
        ],
        icon: Text("library.abs.name".t.characters.first.toUpperCase()),
        color: Colors.amber,
      ),
      "library.calves.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseStanding",
            name: "library.calves.exercises.calfRaiseStanding".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.calves,
          ),
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseSeated",
            name: "library.calves.exercises.calfRaiseSeated".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.calves,
          ),
        ],
        icon: Text("library.calves.name".t.characters.first.toUpperCase()),
        color: Colors.green,
      ),
      "library.quadriceps.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.quadriceps.exercises.squatsBarbell",
            name: "library.quadriceps.exercises.squatsBarbell".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
            secondaryMuscleGroups: {GTMuscleGroup.glutes},
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.smithMachineLunges",
            name: "library.quadriceps.exercises.smithMachineLunges".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.lunges",
            name: "library.quadriceps.exercises.lunges".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress",
            name: "library.quadriceps.exercises.legPress".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress45deg",
            name: "library.quadriceps.exercises.legPress45deg".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legExtension",
            name: "library.quadriceps.exercises.legExtension".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.quadriceps,
          ),
        ],
        icon: Text("library.quadriceps.name".t.characters.first.toUpperCase()),
        color: Colors.indigo,
      ),
      "library.hamstrings.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlProne",
            name: "library.hamstrings.exercises.legCurlProne".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlSeated",
            name: "library.hamstrings.exercises.legCurlSeated".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.hamstrings,
          ),
        ],
        icon: Text("library.hamstrings.name".t.characters.first.toUpperCase()),
        color: Colors.deepPurple,
      ),
      "library.shoulders.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.shoulders.exercises.shoulderPressMachine",
            name: "library.shoulders.exercises.shoulderPressMachine".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesInclinedBench",
            name: "library.shoulders.exercises.latRaisesInclinedBench".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesCable",
            name: "library.shoulders.exercises.latRaisesCable".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesDualCable",
            name: "library.shoulders.exercises.latRaisesDualCable".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.reverseFlysInclinedBench",
            name: "library.shoulders.exercises.reverseFlysInclinedBench".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.arnoldPress",
            name: "library.shoulders.exercises.arnoldPress".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.upperBack},
          ),
        ],
        icon: Text("library.shoulders.name".t.characters.first.toUpperCase()),
        color: Colors.cyan,
      ),
      "library.back.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.back.exercises.hyperExtensions",
            name: "library.back.exercises.hyperExtensions".t,
            parameters: GTSetParameters.freeBodyReps,
            primaryMuscleGroup: GTMuscleGroup.lowerBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.glutes,
              GTMuscleGroup.hamstrings
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.weightedHyperExtensions",
            name: "library.back.exercises.weightedHyperExtensions".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.lowerBack,
            secondaryMuscleGroups: {
              GTMuscleGroup.glutes,
              GTMuscleGroup.hamstrings
            },
          ),
          Exercise.standard(
            id: "library.back.exercises.barbellRow",
            name: "library.back.exercises.barbellRow".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.triangleBarLatPulldowns",
            name: "library.back.exercises.triangleBarLatPulldowns".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.underhandGripLatPulldowns",
            name: "library.back.exercises.underhandGripLatPulldowns".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.latPulldowns",
            name: "library.back.exercises.latPulldowns".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.cableSeatedRowTriangleBar",
            name: "library.back.exercises.cableSeatedRowTriangleBar".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.straightArmCablePushdown",
            name: "library.back.exercises.straightArmCablePushdown".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.upperBack,
            secondaryMuscleGroups: {GTMuscleGroup.triceps},
          ),
        ],
        icon: Text("library.back.name".t.characters.first.toUpperCase()),
        color: Colors.pink,
      ),
      "library.triceps.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.triceps.exercises.dips",
            name: "library.triceps.exercises.dips".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.overheadRopeTricepExtension",
            name: "library.triceps.exercises.overheadRopeTricepExtension".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.tricepsRopePushdown",
            name: "library.triceps.exercises.tricepsRopePushdown".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.triceps,
          ),
        ],
        icon: Text("library.triceps.name".t.characters.first.toUpperCase()),
        color: Colors.yellow,
      ),
      "library.hips.name".t: ExerciseCategory(
        color: Colors.brown,
        icon: Text("library.hips.name".t.characters.first.toUpperCase()),
        exercises: [
          Exercise.standard(
            id: "library.hips.exercises.gluteBridge",
            name: "library.hips.exercises.gluteBridge".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipThrust",
            name: "library.hips.exercises.hipThrust".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipAdduction",
            name: "library.hips.exercises.hipAdduction".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.thighs,
          ),
          Exercise.standard(
            id: "library.hips.exercises.hipAbduction",
            name: "library.hips.exercises.hipAbduction".t,
            parameters: GTSetParameters.repsWeight,
            primaryMuscleGroup: GTMuscleGroup.glutes,
          ),
        ],
      ),
    };

Exercise? getStandardExerciseByID(String id) =>
    exerciseStandardLibrary.values.fold(
        <Exercise>[],
        (previousValue, element) => [
              ...previousValue,
              ...element.exercises,
            ]).firstWhereOrNull((element) => element.id == id);
