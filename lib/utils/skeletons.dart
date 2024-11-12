import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:skeletonizer/skeletonizer.dart';

GTRoutineFolder skeletonFolder([int? seed]) => GTRoutineFolder.generate(
      name: BoneMock.words(Random(seed).nextInt(3) + 1),
    );

Workout skeletonWorkout([int? seed]) => Workout(
      name: BoneMock.words(Random(seed).nextInt(2) + 1),
      duration: Duration(minutes: Random(seed).nextInt(60)),
      startingDate: DateTime.now(),
      exercises: List.generate(
        Random(seed).nextInt(3) + 3,
        (index) => skeletonExercise(
          id: BoneMock.chars(10),
          name: BoneMock.words(2),
          notes: BoneMock.words(10),
          seed: seed,
        ),
      ),
    );

Exercise skeletonExercise({
  required String id,
  required String name,
  required String notes,
  int? seed,
}) =>
    Exercise.raw(
      standard: false,
      supersedesID: null,
      id: BoneMock.chars(10),
      name: BoneMock.words(2),
      parameters: GTSetParameters.repsWeight,
      primaryMuscleGroup: GTMuscleGroup.abs,
      restTime: Duration(seconds: Random(seed).nextInt(120)),
      notes: BoneMock.words(10),
      supersetID: null,
      workoutID: null,
      sets: List.generate(
        3,
        (index) => GTSet(
          parameters: GTSetParameters.repsWeight,
          kind: GTSetKind.normal,
          reps: Random(seed).nextInt(10) + 1,
          weight: Random(seed).nextDouble() * 100,
        ),
      ),
      skeleton: true,
      equipment: GTGymEquipment.none,
    );

List<Food> skeletonFoods(int length) => ([
      for (int i = 0; i < (length / 5).ceil(); i++) ...const [
        Food(
          name: "Whole grain sliced bread",
          brand: "Unknown brand",
          amount: 50,
          nutritionalValuesPer100g: NutritionValues(
            calories: 258,
            fat: 5.1,
            saturatedFat: 0.6,
            carbs: 39,
            sugar: 4.7,
            protein: 10,
            salt: 1.2,
          ),
        ),
        Food(
          name: "Egg",
          amount: 44,
          nutritionalValuesPer100g: NutritionValues(
            calories: 166,
            fat: 11.2,
            saturatedFat: 3.3,
            carbs: 0.9,
            sugar: 0.9,
            protein: 14.2,
            salt: 0.4,
          ),
        ),
        Food(
          name: "Empty croissant",
          amount: 60,
          nutritionalValuesPer100g: NutritionValues(
            calories: 300,
            fat: 16.7,
            saturatedFat: 0,
            carbs: 41.7,
            sugar: 41.7,
            protein: 6.7,
          ),
        ),
        Food(
          name: "Whole grain rice",
          brand: "questi valori stanno qui per renderizzare lo skeleton loader",
          amount: 100,
          nutritionalValuesPer100g: NutritionValues(
            calories: 355,
            fat: 2.4,
            saturatedFat: 0,
            carbs: 73,
            sugar: 0,
            protein: 9.1,
          ),
        ),
        Food(
          name: "Turkey breast slices",
          amount: 130,
          nutritionalValuesPer100g: NutritionValues(
            calories: 107,
            fat: 1.2,
            saturatedFat: 0,
            carbs: 0,
            sugar: 0,
            protein: 24,
          ),
        ),
      ],
    ]);

BoutiqueCategory skeletonBoutiqueCategory([int? seed]) => BoutiqueCategory(
  id: BoneMock.chars(10),
  name: {
    "en": BoneMock.words(Random(seed).nextInt(2) + 1),
  },
  color: [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
  ][Random(seed).nextInt(6)],
);
