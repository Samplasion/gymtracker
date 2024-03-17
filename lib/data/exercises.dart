import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}

Map<String, ExerciseCategory> get exerciseStandardLibrary => {
      "library.cardio.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.cardio.exercises.aerobics",
            name: "library.cardio.exercises.aerobics".t,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.biking",
            name: "library.cardio.exercises.biking".t,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          // aka the weird cyclette
          Exercise.standard(
            id: "library.cardio.exercises.ergometer",
            name: "library.cardio.exercises.ergometer".t,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.ergometerHorizontal",
            name: "library.cardio.exercises.ergometerHorizontal".t,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.pilates",
            name: "library.cardio.exercises.pilates".t,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.running",
            name: "library.cardio.exercises.running".t,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.treadmill",
            name: "library.cardio.exercises.treadmill".t,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.zumba",
            name: "library.cardio.exercises.zumba".t,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
        ],
        icon: const Icon(Icons.directions_bike_rounded),
        color: Colors.orange,
      ),
      "library.chest.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressFlat",
            name: "library.chest.exercises.barbellBenchPressFlat".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressIncline",
            name: "library.chest.exercises.barbellBenchPressIncline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressDecline",
            name: "library.chest.exercises.barbellBenchPressDecline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressFlat",
            name: "library.chest.exercises.smithMachineBenchPressFlat".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressIncline",
            name: "library.chest.exercises.smithMachineBenchPressIncline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineBenchPressDecline",
            name: "library.chest.exercises.smithMachineBenchPressDecline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressFlat",
            name: "library.chest.exercises.dumbbellBenchPressFlat".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressIncline",
            name: "library.chest.exercises.dumbbellBenchPressIncline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressDecline",
            name: "library.chest.exercises.dumbbellBenchPressDecline".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.butterflyMachine",
            name: "library.chest.exercises.butterflyMachine".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellHexPress",
            name: "library.chest.exercises.dumbbellHexPress".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.smithMachineHexPress",
            name: "library.chest.exercises.smithMachineHexPress".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
          ),
          Exercise.standard(
            id: "library.chest.exercises.seatedCableChestFlys",
            name: "library.chest.exercises.seatedCableChestFlys".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.chest,
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.spiderCurls",
            name: "library.biceps.exercises.spiderCurls".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.biceps,
          ),
          Exercise.standard(
            id: "library.biceps.exercises.singleArmCableHammerCurls",
            name: "library.biceps.exercises.singleArmCableHammerCurls".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.biceps,
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
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.kneeRaise",
            name: "library.abs.exercises.kneeRaise".t,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.legRaise",
            name: "library.abs.exercises.legRaise".t,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.crunchMachine",
            name: "library.abs.exercises.crunchMachine".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.abs,
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.calves,
          ),
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseSeated",
            name: "library.calves.exercises.calfRaiseSeated".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.calves,
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
            secondaryMuscleGroups: {MuscleGroup.glutes},
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.smithMachineLunges",
            name: "library.quadriceps.exercises.smithMachineLunges".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.lunges",
            name: "library.quadriceps.exercises.lunges".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress",
            name: "library.quadriceps.exercises.legPress".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress45deg",
            name: "library.quadriceps.exercises.legPress45deg".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legExtension",
            name: "library.quadriceps.exercises.legExtension".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.hamstrings,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlSeated",
            name: "library.hamstrings.exercises.legCurlSeated".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.hamstrings,
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesInclinedBench",
            name: "library.shoulders.exercises.latRaisesInclinedBench".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesCable",
            name: "library.shoulders.exercises.latRaisesCable".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.shoulders.exercises.latRaisesDualCable",
            name: "library.shoulders.exercises.latRaisesDualCable".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
              id: "library.shoulders.exercises.reverseFlysInclinedBench",
              name: "library.shoulders.exercises.reverseFlysInclinedBench".t,
              parameters: SetParameters.repsWeight,
              primaryMuscleGroup: MuscleGroup.shoulders,
              secondaryMuscleGroups: {MuscleGroup.upperBack}),
        ],
        icon: Text("library.shoulders.name".t.characters.first.toUpperCase()),
        color: Colors.cyan,
      ),
      "library.back.name".t: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.back.exercises.hyperExtensions",
            name: "library.back.exercises.hyperExtensions".t,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.lowerBack,
            secondaryMuscleGroups: {MuscleGroup.glutes, MuscleGroup.hamstrings},
          ),
          Exercise.standard(
            id: "library.back.exercises.weightedHyperExtensions",
            name: "library.back.exercises.weightedHyperExtensions".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.lowerBack,
            secondaryMuscleGroups: {MuscleGroup.glutes, MuscleGroup.hamstrings},
          ),
          Exercise.standard(
            id: "library.back.exercises.barbellRow",
            name: "library.back.exercises.barbellRow".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.triangleBarLatPulldowns",
            name: "library.back.exercises.triangleBarLatPulldowns".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.underhandGripLatPulldowns",
            name: "library.back.exercises.underhandGripLatPulldowns".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.latPulldowns",
            name: "library.back.exercises.latPulldowns".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.cableSeatedRowTriangleBar",
            name: "library.back.exercises.cableSeatedRowTriangleBar".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
          ),
          Exercise.standard(
            id: "library.back.exercises.straightArmCablePushdown",
            name: "library.back.exercises.straightArmCablePushdown".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.upperBack,
            secondaryMuscleGroups: {MuscleGroup.triceps},
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
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.triceps,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.overheadRopeTricepExtension",
            name: "library.triceps.exercises.overheadRopeTricepExtension".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.triceps,
          ),
          Exercise.standard(
            id: "library.triceps.exercises.tricepsRopePushdown",
            name: "library.triceps.exercises.tricepsRopePushdown".t,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.triceps,
          ),
        ],
        icon: Text("library.triceps.name".t.characters.first.toUpperCase()),
        color: Colors.yellow,
      ),
    };

Exercise? getStandardExerciseByID(String id) =>
    exerciseStandardLibrary.values.fold(
        <Exercise>[],
        (previousValue, element) => [
              ...previousValue,
              ...element.exercises,
            ]).firstWhereOrNull((element) => element.id == id);
