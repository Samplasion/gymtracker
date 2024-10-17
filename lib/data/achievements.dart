import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

// TODO: Change to final field once I'm done adding the bulk of achievements
Map<String, Achievement> get achievements => {
      "firstSteps": Achievement(
        id: "firstSteps",
        nameKey: "achievements.firstSteps.title",
        iconKey: "firstSteps",
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.firstSteps.title",
            descriptionKey: "achievements.firstSteps.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () => true,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.firstSteps.title",
            descriptionKey: "achievements.firstSteps.description.2",
            trigger: AchievementTrigger.weight,
            checkCompletion: () => true,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.firstSteps.title",
            descriptionKey: "achievements.firstSteps.description.3",
            trigger: AchievementTrigger.food,
            checkCompletion: () => true,
          ),
        ],
      ),
      // 1. Log your meals two days in a row
      // 2. Log your meals a week in a row
      // 3. Log your meals a month in a row
      "foodWatcher": Achievement(
        id: "foodWatcher",
        nameKey: "achievements.foodWatcher.title",
        iconKey: "foodWatcher",
        color: Colors.orange,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.foodWatcher.title",
            descriptionKey: "achievements.foodWatcher.description.1",
            trigger: AchievementTrigger.food,
            checkCompletion: () {
              final today = DateTime.now();
              final yesterday = today.subtract(const Duration(days: 1));

              final foodController = Get.find<FoodController>();

              final todayFoods = foodController.foods$.value
                  .where((element) => element.date.isSameDay(today))
                  .toList();
              final yesterdayFoods = foodController.foods$.value
                  .where((element) => element.date.isSameDay(yesterday))
                  .toList();

              return todayFoods.isNotEmpty && yesterdayFoods.isNotEmpty;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.foodWatcher.title",
            descriptionKey: "achievements.foodWatcher.description.2",
            trigger: AchievementTrigger.food,
            checkCompletion: () {
              final today = DateTime.now();
              final weekAgo =
                  today.subtract(const Duration(days: 6)).startOfDay;

              final foodController = Get.find<FoodController>();

              final thisWeekFoods = foodController.foods$.value
                  .where((element) =>
                      element.date.isAfterOrAtSameMomentAs(weekAgo) &&
                      element.date.isBefore(
                          today.add(const Duration(days: 1)).startOfDay))
                  .toList();

              for (var i = 0; i < 7; i++) {
                final day = weekAgo.add(Duration(days: i));
                if (!thisWeekFoods
                    .any((element) => element.date.isSameDay(day))) {
                  return false;
                }
              }

              return true;
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.foodWatcher.title",
            descriptionKey: "achievements.foodWatcher.description.3",
            trigger: AchievementTrigger.food,
            checkCompletion: () {
              final today = DateTime.now();
              final weekAgo =
                  today.subtract(const Duration(days: 29)).startOfDay;

              final foodController = Get.find<FoodController>();

              final thisWeekFoods = foodController.foods$.value
                  .where((element) =>
                      element.date.isAfterOrAtSameMomentAs(weekAgo) &&
                      element.date.isBefore(
                          today.add(const Duration(days: 1)).startOfDay))
                  .toList();

              for (var i = 0; i < 30; i++) {
                final day = weekAgo.add(Duration(days: i));
                if (!thisWeekFoods
                    .any((element) => element.date.isSameDay(day))) {
                  return false;
                }
              }

              return true;
            },
          ),
        ],
      ),
      // 1. Run a 5k
      // 2. Run half a marathon
      // 3. Run a full marathon
      "marathoner": Achievement(
        id: "marathoner",
        nameKey: "achievements.marathoner.title",
        iconKey: "marathoner",
        color: Colors.red,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.marathoner.title",
            descriptionKey: "achievements.marathoner.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final latestWorkout = Get.find<HistoryController>().history.last;
              return Distance.convert(
                      value: latestWorkout.distanceRun,
                      from: latestWorkout.distanceUnit,
                      to: Distance.km) >=
                  5;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.marathoner.title",
            descriptionKey: "achievements.marathoner.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final latestWorkout = Get.find<HistoryController>().history.last;
              return Distance.convert(
                    value: latestWorkout.distanceRun,
                    from: latestWorkout.distanceUnit,
                    to: Distance.km,
                  ) >=
                  21.0975;
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.marathoner.title",
            descriptionKey: "achievements.marathoner.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final latestWorkout = Get.find<HistoryController>().history.last;
              return Distance.convert(
                    value: latestWorkout.distanceRun,
                    from: latestWorkout.distanceUnit,
                    to: Distance.km,
                  ) >=
                  42.195;
            },
          ),
        ],
      ),
      "earlyBird": Achievement(
        id: "earlyBird",
        nameKey: "achievements.earlyBird.title",
        iconKey: "earlyBird",
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.earlyBird.title",
            descriptionKey: "achievements.earlyBird.description",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final latestWorkout = Get.find<HistoryController>().history.last;
              return latestWorkout.startingDate!.hour < 8;
            },
          ),
        ],
      ),
      "nightOwl": Achievement(
        id: "nightOwl",
        nameKey: "achievements.nightOwl.title",
        iconKey: "nightOwl",
        color: Colors.deepPurple,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.nightOwl.title",
            descriptionKey: "achievements.nightOwl.description",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final latestWorkout = Get.find<HistoryController>().history.last;
              return latestWorkout.startingDate!.hour >= 20;
            },
          ),
        ],
      ),
      "realGymBro": Achievement(
        id: "realGymBro",
        nameKey: "achievements.realGymBro.title",
        iconKey: "realGymBro",
        color: Colors.cyan,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.realGymBro.title",
            descriptionKey: "achievements.realGymBro.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDurations = workouts
                  .map((e) => e.duration!)
                  .reduce((value, element) => value + element);

              return sumOfDurations >= const Duration(hours: 100);
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.realGymBro.title",
            descriptionKey: "achievements.realGymBro.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDurations = workouts
                  .map((e) => e.duration!)
                  .reduce((value, element) => value + element);

              return sumOfDurations >= const Duration(hours: 500);
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.realGymBro.title",
            descriptionKey: "achievements.realGymBro.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDurations = workouts
                  .map((e) => e.duration!)
                  .reduce((value, element) => value + element);

              return sumOfDurations >= const Duration(hours: 1000);
            },
          ),
        ],
      ),
      // 1. Log a workout every day of a month
      // 2. Log a workout every day of a year
      "workoutFreak": Achievement(
        id: "workoutFreak",
        nameKey: "achievements.workoutFreak.title",
        iconKey: "workoutFreak",
        color: Colors.green,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.workoutFreak.title",
            descriptionKey: "achievements.workoutFreak.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final today = DateTime.now().startOfDay;
              if (today.month != today.add(const Duration(days: 1)).month) {
                return false;
              }
              final monthStart = today.subtract(
                Duration(days: today.day - 1),
              );

              final historyController = Get.find<HistoryController>();

              final thisMonthWorkouts = historyController.history
                  .where((element) =>
                      element.startingDate!
                          .isAfterOrAtSameMomentAs(monthStart) &&
                      element.startingDate!
                          .isBefore(today.add(const Duration(days: 1))))
                  .toList();

              for (var i = 0; i < today.day; i++) {
                final day = monthStart.add(Duration(days: i));
                if (kDebugMode) {
                  globalLogger.d(
                      "(achievements.workoutFreak.1) Checking for $day: ${thisMonthWorkouts.where((element) => element.startingDate!.isSameDay(day)).length} workout");
                }
                if (!thisMonthWorkouts
                    .any((element) => element.startingDate!.isSameDay(day))) {
                  return false;
                }
              }

              return true;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.workoutFreak.title",
            descriptionKey: "achievements.workoutFreak.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final today = DateTime.now().startOfDay;
              if (today.year != today.add(const Duration(days: 1)).year) {
                return false;
              }
              final yearStart = DateTime(today.year, 1, 1);

              final historyController = Get.find<HistoryController>();

              final thisYearWorkouts = historyController.history
                  .where((element) =>
                      element.startingDate!
                          .isAfterOrAtSameMomentAs(yearStart) &&
                      element.startingDate!
                          .isBefore(today.add(const Duration(days: 1))))
                  .toList();

              final diff = today.difference(yearStart).inDays;
              for (var i = 0; i < diff; i++) {
                final day = yearStart.add(Duration(days: i));
                if (kDebugMode) {
                  globalLogger.d(
                      "(achievements.workoutFreak.2) Checking for $day: ${thisYearWorkouts.where((element) => element.startingDate!.isSameDay(day)).length} workout");
                }
                if (!thisYearWorkouts
                    .any((element) => element.startingDate!.isSameDay(day))) {
                  return false;
                }
              }

              return true;
            },
          ),
        ],
      ),
      // Trailblazer:
      // 1. Run or bike a total of 100km
      // 2. Run or bike a total of 500km
      // 3. Run or bike a total of 1000km
      "trailblazer": Achievement(
        id: "trailblazer",
        nameKey: "achievements.trailblazer.title",
        iconKey: "trailblazer",
        color: Colors.brown,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.trailblazer.title",
            descriptionKey: "achievements.trailblazer.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => Distance.convert(
                        value: e.distanceRun,
                        from: e.distanceUnit,
                        to: Distance.km,
                      ))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 100;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.trailblazer.title",
            descriptionKey: "achievements.trailblazer.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => Distance.convert(
                        value: e.distanceRun,
                        from: e.distanceUnit,
                        to: Distance.km,
                      ))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 500;
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.trailblazer.title",
            descriptionKey: "achievements.trailblazer.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => Distance.convert(
                        value: e.distanceRun,
                        from: e.distanceUnit,
                        to: Distance.km,
                      ))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 1000;
            },
          ),
        ],
      ),
      // Cycle Champion
      // 1. Cycle a total of 100km
      // 2. Cycle a total of 500km
      // 3. Cycle a total of 1000km
      "cycleChampion": Achievement(
        id: "cycleChampion",
        nameKey: "achievements.cycleChampion.title",
        iconKey: "cycleChampion",
        color: Colors.blue,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.cycleChampion.title",
            descriptionKey: "achievements.cycleChampion.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => _distanceByFiltering(e, filter: (e) {
                        return e.isStandardLibraryExercise &&
                            [
                              GTStandardLibrary.cardio.biking,
                              GTStandardLibrary.cardio.ergometer,
                              GTStandardLibrary.cardio.ergometerHorizontal,
                            ].contains(e.parentID);
                      }))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 100;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.cycleChampion.title",
            descriptionKey: "achievements.cycleChampion.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => _distanceByFiltering(e,
                      filter: (e) =>
                          e.isStandardLibraryExercise &&
                          [
                            GTStandardLibrary.cardio.biking,
                            GTStandardLibrary.cardio.ergometer,
                            GTStandardLibrary.cardio.ergometerHorizontal,
                          ].contains(e.parentID)))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 500;
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.cycleChampion.title",
            descriptionKey: "achievements.cycleChampion.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              final workouts = Get.find<HistoryController>().history;
              final sumOfDistances = workouts
                  .map((e) => _distanceByFiltering(e,
                      filter: (e) =>
                          e.isStandardLibraryExercise &&
                          [
                            GTStandardLibrary.cardio.biking,
                            GTStandardLibrary.cardio.ergometer,
                            GTStandardLibrary.cardio.ergometerHorizontal,
                          ].contains(e.parentID)))
                  .reduce((value, element) => value + element);

              return sumOfDistances >= 1000;
            },
          ),
        ],
      ),
      // Professional Weightlifter
      // 1. Lift 1x your body weight in a single set
      // 2. Lift 1.5x your body weight in a single set
      // 3. Lift 3x your body weight in a single set
      "professionalWeightlifter": Achievement(
        id: "professionalWeightlifter",
        nameKey: "achievements.professionalWeightlifter.title",
        iconKey: "professionalWeightlifter",
        color: Colors.blueGrey,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.professionalWeightlifter.title",
            descriptionKey:
                "achievements.professionalWeightlifter.description.1",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              return _professionalWeightlifter(1);
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.professionalWeightlifter.title",
            descriptionKey:
                "achievements.professionalWeightlifter.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              return _professionalWeightlifter(1.5);
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.professionalWeightlifter.title",
            descriptionKey:
                "achievements.professionalWeightlifter.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: () {
              return _professionalWeightlifter(3);
            },
          ),
        ],
      ),
    };

bool _professionalWeightlifter(double coefficient) {
  final weight = Get.find<MeController>().latestWeightMeasurement;
  if (weight == null) return false;

  final latestWorkout = Get.find<HistoryController>().history.last;
  final exercises = latestWorkout.flattenedExercises.whereType<Exercise>();

  for (final ex in exercises) {
    for (final set in ex.doneSets) {
      if (set.weight != null &&
          Weights.convert(
                  value: set.weight!,
                  from: latestWorkout.weightUnit,
                  to: Weights.kg) >=
              Weights.convert(
                      value: weight.weight,
                      from: weight.weightUnit,
                      to: Weights.kg) *
                  coefficient) return true;
    }
  }

  return false;
}

bool _defaultFilter(Exercise _) => true;
double _distanceByFiltering(
  Workout workout, {
  bool Function(Exercise) filter = _defaultFilter,
}) {
  var filteredExercises =
      workout.flattenedExercises.whereType<Exercise>().where(filter).map((e) {
    final sets = e.sets
        .where((element) => element.done || !workout.isConcrete)
        .map((e) => e.distance ?? 0);
    return sets.isEmpty
        ? 0.0
        : sets.reduce((value, element) => value + element);
  });
  return Distance.convert(
    value: filteredExercises.isEmpty
        ? 0
        : filteredExercises.reduce((value, element) => value + element),
    from: workout.distanceUnit,
    to: Distance.km,
  );
}
