import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

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
        color: Colors.deepOrange,
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
    };
