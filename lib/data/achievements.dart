import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:intl/intl.dart';
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
            checkCompletion: (progress) =>
                Get.find<HistoryController>().history.isNotEmpty,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.firstSteps.title",
            descriptionKey: "achievements.firstSteps.description.2",
            trigger: AchievementTrigger.weight,
            checkCompletion: (progress) =>
                Get.find<MeController>().weightMeasurements.isNotEmpty,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.firstSteps.title",
            descriptionKey: "achievements.firstSteps.description.3",
            trigger: AchievementTrigger.food,
            checkCompletion: (progress) =>
                Get.find<FoodController>().foods$.value.isNotEmpty,
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
            progress: () {
              final periodFoods = _foodWatcher();
              return periodFoods.length.toDouble();
            },
            progressMax: () => 2,
            progressText: (value) => "time.days".plural(value.toInt()),
            checkCompletion: (progress) {
              const days = 2;
              return progress! >= days;
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.foodWatcher.title",
            descriptionKey: "achievements.foodWatcher.description.2",
            trigger: AchievementTrigger.food,
            progress: () {
              final periodFoods = _foodWatcher();
              return periodFoods.length.toDouble();
            },
            progressMax: () => 7,
            progressText: (value) => "time.days".plural(value.toInt()),
            checkCompletion: (progress) {
              const days = 7;
              return progress! >= days;
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.foodWatcher.title",
            descriptionKey: "achievements.foodWatcher.description.3",
            trigger: AchievementTrigger.food,
            progress: () {
              final periodFoods = _foodWatcher();
              return periodFoods.length.toDouble();
            },
            progressMax: () => 30,
            progressText: (value) => "time.days".plural(value.toInt()),
            checkCompletion: (progress) {
              const days = 30;
              return progress! >= days;
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
            checkCompletion: (progress) {
              final history = Get.find<HistoryController>().history;
              if (history.isEmpty) return false;
              final latestWorkout = history.last;
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
            checkCompletion: (progress) {
              final history = Get.find<HistoryController>().history;
              if (history.isEmpty) return false;
              final latestWorkout = history.last;
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
            checkCompletion: (progress) {
              final history = Get.find<HistoryController>().history;
              if (history.isEmpty) return false;
              final latestWorkout = history.last;
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
            checkCompletion: (progress) {
              var history = Get.find<HistoryController>().history;
              if (history.isEmpty) return false;
              final latestWorkout = history.last;
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
            checkCompletion: (progress) {
              var history = Get.find<HistoryController>().history;
              if (history.isEmpty) return false;
              final latestWorkout = history.last;
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
            progress: () {
              final workouts = Get.find<HistoryController>().history;
              if (workouts.isEmpty) return 0;
              return workouts
                      .map((e) => e.duration!)
                      .reduce((value, element) => value + element)
                      .inMinutes /
                  60;
            },
            progressMax: () => 100,
            progressText: (value) => "time.justHours".plural(value.toInt()),
            checkCompletion: (progress) => progress! >= 100,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.realGymBro.title",
            descriptionKey: "achievements.realGymBro.description.2",
            trigger: AchievementTrigger.workout,
            progress: () {
              final workouts = Get.find<HistoryController>().history;
              if (workouts.isEmpty) return 0;
              return workouts
                      .map((e) => e.duration!)
                      .reduce((value, element) => value + element)
                      .inMinutes /
                  60;
            },
            progressMax: () => 500,
            progressText: (value) => "time.justHours".plural(value.toInt()),
            checkCompletion: (progress) => progress! >= 500,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.realGymBro.title",
            descriptionKey: "achievements.realGymBro.description.3",
            trigger: AchievementTrigger.workout,
            progress: () {
              final workouts = Get.find<HistoryController>().history;
              if (workouts.isEmpty) return 0;
              return workouts
                      .map((e) => e.duration!)
                      .reduce((value, element) => value + element)
                      .inMinutes /
                  60;
            },
            progressMax: () => 1000,
            progressText: (value) => "time.justHours".plural(value.toInt()),
            checkCompletion: (progress) => progress! >= 1000,
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
            progress: () {
              return _workoutFreak(_WorkoutFreakPeriod.month).length.toDouble();
            },
            progressMax: () {
              final today = DateTime.now();
              return DateTime(today.year, today.month + 1, 0).day.toDouble();
            },
            progressText: (value) => "time.days".plural(value.toInt()),
            checkCompletion: (progress) {
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
            progress: () {
              return _workoutFreak(_WorkoutFreakPeriod.month).length.toDouble();
            },
            progressMax: () {
              final today = DateTime.now();
              return today.isLeapYear ? 366 : 365;
            },
            progressText: (value) => "time.days".plural(value.toInt()),
            checkCompletion: (progress) {
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
            progress: _trailblazer,
            progressMax: () => 100,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 100,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.trailblazer.title",
            descriptionKey: "achievements.trailblazer.description.2",
            trigger: AchievementTrigger.workout,
            progress: _trailblazer,
            progressMax: () => 500,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 500,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.trailblazer.title",
            descriptionKey: "achievements.trailblazer.description.3",
            trigger: AchievementTrigger.workout,
            progress: _trailblazer,
            progressMax: () => 1000,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 1000,
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
            progress: _cycleChampion,
            progressMax: () => 100,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 100,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.cycleChampion.title",
            descriptionKey: "achievements.cycleChampion.description.2",
            trigger: AchievementTrigger.workout,
            progress: _cycleChampion,
            progressMax: () => 500,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 500,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.cycleChampion.title",
            descriptionKey: "achievements.cycleChampion.description.3",
            trigger: AchievementTrigger.workout,
            progress: _cycleChampion,
            progressMax: () => 1000,
            progressText: (value) => "exerciseList.fields.distance".trParams({
              "distance": NumberFormat.compact(locale: Get.locale!.languageCode)
                  .format(value),
              "unit": "units.${settingsController.distanceUnit.value.name}".t,
            }),
            checkCompletion: (progress) => progress! >= 1000,
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
            checkCompletion: (progress) {
              return _professionalWeightlifter(1);
            },
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.professionalWeightlifter.title",
            descriptionKey:
                "achievements.professionalWeightlifter.description.2",
            trigger: AchievementTrigger.workout,
            checkCompletion: (progress) {
              return _professionalWeightlifter(1.5);
            },
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.professionalWeightlifter.title",
            descriptionKey:
                "achievements.professionalWeightlifter.description.3",
            trigger: AchievementTrigger.workout,
            checkCompletion: (progress) {
              return _professionalWeightlifter(3);
            },
          ),
        ],
      ),
      // Create three routines
      "programPlanner": Achievement(
        id: "programPlanner",
        nameKey: "achievements.programPlanner.title",
        iconKey: "programPlanner",
        color: Colors.blue,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.programPlanner.title",
            descriptionKey: "achievements.programPlanner.description",
            trigger: AchievementTrigger.routines,
            progress: () =>
                Get.find<RoutinesController>().workouts.length.toDouble(),
            progressMax: () => 3,
            progressText: (value) => value.toInt().toString(),
            checkCompletion: (progress) {
              return progress! >= 3;
            },
          ),
        ],
      ),
      // Create a routine folder
      "perfectPlanner": Achievement(
        id: "perfectPlanner",
        nameKey: "achievements.perfectPlanner.title",
        iconKey: "perfectPlanner",
        color: const Color.fromARGB(255, 233, 187, 2),
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.perfectPlanner.title",
            descriptionKey: "achievements.perfectPlanner.description",
            trigger: AchievementTrigger.routines,
            checkCompletion: (progress) {
              return Get.find<RoutinesController>().folders.isNotEmpty;
            },
          ),
        ],
      ),
      // Routine Master
      // 1. Follow a routine for 3 consecutive months
      // 2. Follow a routine for 6 consecutive months
      // 2. Follow a routine for 12 consecutive months
      "routineMaster": Achievement(
        id: "routineMaster",
        nameKey: "achievements.routineMaster.title",
        iconKey: "routineMaster",
        color: Colors.pink,
        levels: [
          AchievementLevel(
            level: 1,
            nameKey: "achievements.routineMaster.title",
            descriptionKey: "achievements.routineMaster.description.1",
            trigger: AchievementTrigger.workout,
            progress: () => _routineMaster().length.toDouble(),
            progressMax: () => 3,
            progressText: (v) => v.toInt().toString(),
            checkCompletion: (progress) => progress! >= 3,
          ),
          AchievementLevel(
            level: 2,
            nameKey: "achievements.routineMaster.title",
            descriptionKey: "achievements.routineMaster.description.2",
            trigger: AchievementTrigger.workout,
            progress: () => _routineMaster().length.toDouble(),
            progressMax: () => 6,
            progressText: (v) => v.toInt().toString(),
            checkCompletion: (progress) => progress! >= 6,
          ),
          AchievementLevel(
            level: 3,
            nameKey: "achievements.routineMaster.title",
            descriptionKey: "achievements.routineMaster.description.3",
            trigger: AchievementTrigger.workout,
            progress: () => _routineMaster().length.toDouble(),
            progressMax: () => 12,
            progressText: (v) => v.toInt().toString(),
            checkCompletion: (progress) => progress! >= 12,
          ),
        ],
      ),
    };

List<DateTime> _foodWatcher() {
  final today = DateTime.now().startOfDay;

  final foodController = Get.find<FoodController>();
  if (foodController.foods$.value.isEmpty) return [];

  // Return the longest continuous streak of days of all time
  final streaks = <List<DateTime>>[];
  var currentStreak = <DateTime>[];
  final difference =
      foodController.firstDay!.startOfDay.difference(today).abs().inDays;
  for (var i = 0; i < difference; i++) {
    final day = today.subtract(Duration(days: i));
    if (foodController.getFoodsForDay(day).isNotEmpty) {
      currentStreak.add(day);
    } else {
      if (currentStreak.isNotEmpty) {
        streaks.add(currentStreak);
        currentStreak = [];
      }
    }
  }

  if (currentStreak.isNotEmpty) {
    streaks.add(currentStreak);
  }

  return streaks.isEmpty
      ? []
      : streaks.reduce(
          (value, element) => value.length > element.length ? value : element);
}

enum _WorkoutFreakPeriod { month, year }

List<DateTime> _workoutFreak(_WorkoutFreakPeriod period) {
  final today = DateTime.now().startOfDay;

  final historyController = Get.find<HistoryController>();

  final periodWorkouts = historyController.history.where((element) {
    final yearMatches = element.startingDate!.year == today.year;
    if (period == _WorkoutFreakPeriod.year) return yearMatches;
    return yearMatches && element.startingDate!.month == today.month;
  }).toList();

  return periodWorkouts.map((w) => w.startingDate!.startOfDay).toSet().toList();
}

double _trailblazer() {
  final workouts = Get.find<HistoryController>().history;
  if (workouts.isEmpty) return 0.0;
  return workouts
      .map((e) => Distance.convert(
            value: e.distanceRun,
            from: e.distanceUnit,
            to: Distance.km,
          ))
      .reduce((value, element) => value + element);
}

double _cycleChampion() {
  final workouts = Get.find<HistoryController>().history;
  if (workouts.isEmpty) return 0.0;
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
  return sumOfDistances;
}

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

List _routineMaster() {
  final routines = Get.find<RoutinesController>().workouts;
  if (routines.isEmpty) return [];

  int longestStreak = 0;
  List<DateTime> longestStreakDates = [];
  String longestStreakRoutineName = '';

  for (var routine in routines) {
    final workouts = Get.find<HistoryController>()
        .history
        .where((wo) => wo.parentID == routine.id);
    if (workouts.isEmpty) continue;

    // Group workouts by year and month
    final Map<String, List<Workout>> groupedWorkouts = {};
    for (var workout in workouts) {
      final yearMonth =
          '${workout.startingDate!.year}-${workout.startingDate!.month.toString().padLeft(2, "0")}';
      if (!groupedWorkouts.containsKey(yearMonth)) {
        groupedWorkouts[yearMonth] = [];
      }
      groupedWorkouts[yearMonth]!.add(workout);
    }

    // Check for the longest streak of at least n consecutive months
    final sortedKeys = groupedWorkouts.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      int currentStreak = 1;
      List<DateTime> currentStreakDates = groupedWorkouts[sortedKeys[i]]!
          .map((wo) => wo.startingDate!)
          .toList();

      for (int j = i; j < sortedKeys.length - 1; j++) {
        final current = DateTime.parse('${sortedKeys[j]}-01');
        final next = DateTime.parse('${sortedKeys[j + 1]}-01');
        if ((next.month == current.month + 1 && next.year == current.year) ||
            (next.month == 1 &&
                current.month == 12 &&
                next.year == current.year + 1)) {
          currentStreak++;
          currentStreakDates.addAll(groupedWorkouts[sortedKeys[j + 1]]!
              .map((wo) => wo.startingDate!)
              .toList());
        } else {
          break;
        }
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        longestStreakDates = currentStreakDates;
        longestStreakRoutineName = routine.name;
      }
    }
  }

  if (longestStreakRoutineName.isNotEmpty) {
    print('Longest streak routine: $longestStreakRoutineName');
  }

  final Set<String> yearMonthPairs = {};

  for (var date in longestStreakDates) {
    final yearMonth = '${date.year}-${date.month}';
    yearMonthPairs.add(yearMonth);
  }

  return yearMonthPairs.toList();
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
