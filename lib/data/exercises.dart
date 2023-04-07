import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/set.dart';

import '../model/exercise.dart';

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
      "library.cardio.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.cardio.exercises.aerobics",
            name: "library.cardio.exercises.aerobics".tr,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.biking",
            name: "library.cardio.exercises.biking".tr,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          // aka the weird cyclette
          Exercise.standard(
            id: "library.cardio.exercises.ergometer",
            name: "library.cardio.exercises.ergometer".tr,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.ergometerHorizontal",
            name: "library.cardio.exercises.ergometerHorizontal".tr,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.pilates",
            name: "library.cardio.exercises.pilates".tr,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.running",
            name: "library.cardio.exercises.running".tr,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.treadmill",
            name: "library.cardio.exercises.treadmill".tr,
            parameters: SetParameters.distance,
            primaryMuscleGroup: MuscleGroup.none,
          ),
          Exercise.standard(
            id: "library.cardio.exercises.zumba",
            name: "library.cardio.exercises.zumba".tr,
            parameters: SetParameters.time,
            primaryMuscleGroup: MuscleGroup.none,
          ),
        ],
        icon: const Icon(Icons.directions_bike_rounded),
        color: Colors.orange,
      ),
      "library.chest.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressFlat",
            name: "library.chest.exercises.barbellBenchPressFlat".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressIncline",
            name: "library.chest.exercises.barbellBenchPressIncline".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.chest.exercises.barbellBenchPressDecline",
            name: "library.chest.exercises.barbellBenchPressDecline".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressFlat",
            name: "library.chest.exercises.dumbbellBenchPressFlat".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressIncline",
            name: "library.chest.exercises.dumbbellBenchPressIncline".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
          Exercise.standard(
            id: "library.chest.exercises.dumbbellBenchPressDecline",
            name: "library.chest.exercises.dumbbellBenchPressDecline".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.shoulders,
          ),
        ],
        icon: Text("library.chest.name".tr.characters.first.toUpperCase()),
        color: Colors.teal,
      ),
      "library.biceps.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.biceps.exercises.barbellBicepsCurl",
            name: "library.biceps.exercises.barbellBicepsCurl".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.biceps,
          ),
        ],
        icon: Text("library.biceps.name".tr.characters.first.toUpperCase()),
        color: Colors.blue,
      ),
      "library.abs.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.abs.exercises.crunches",
            name: "library.abs.exercises.crunches".tr,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.kneeRaise",
            name: "library.abs.exercises.kneeRaise".tr,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.legRaise",
            name: "library.abs.exercises.legRaise".tr,
            parameters: SetParameters.freeBodyReps,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
          Exercise.standard(
            id: "library.abs.exercises.crunchMachine",
            name: "library.abs.exercises.crunchMachine".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.abs,
          ),
        ],
        icon: Text("library.abs.name".tr.characters.first.toUpperCase()),
        color: Colors.amber,
      ),
      "library.calves.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseStanding",
            name: "library.calves.exercises.calfRaiseStanding".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.calves,
          ),
          Exercise.standard(
            id: "library.calves.exercises.calfRaiseSeated",
            name: "library.calves.exercises.calfRaiseSeated".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.calves,
          ),
        ],
        icon: Text("library.calves.name".tr.characters.first.toUpperCase()),
        color: Colors.green,
      ),
      "library.quadriceps.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.quadriceps.exercises.squatsBarbell",
            name: "library.quadriceps.exercises.squatsBarbell".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
            secondaryMuscleGroups: {MuscleGroup.glutes},
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legPress",
            name: "library.quadriceps.exercises.legPress".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
          Exercise.standard(
            id: "library.quadriceps.exercises.legExtension",
            name: "library.quadriceps.exercises.legExtension".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.quadriceps,
          ),
        ],
        icon: Text("library.quadriceps.name".tr.characters.first.toUpperCase()),
        color: Colors.indigo,
      ),
      "library.hamstrings.name".tr: ExerciseCategory(
        exercises: [
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlProne",
            name: "library.hamstrings.exercises.legCurlProne".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.hamstrings,
          ),
          Exercise.standard(
            id: "library.hamstrings.exercises.legCurlSeated",
            name: "library.hamstrings.exercises.legCurlSeated".tr,
            parameters: SetParameters.repsWeight,
            primaryMuscleGroup: MuscleGroup.hamstrings,
          ),
        ],
        icon: Text("library.hamstrings.name".tr.characters.first.toUpperCase()),
        color: Colors.deepPurple,
      ),
    };
