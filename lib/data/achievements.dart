import 'package:flutter/material.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

// Metadata remains available to remote feed decoding without application state.
final Map<String, Achievement> achievements = AchievementRules().catalog;

/// Rules read feature data supplied by their owner, never a global container.
class AchievementRules {
  AchievementRules({
    DateTime Function()? clock,
    List<Workout> Function()? history,
    List<Workout> Function()? routines,
    bool Function()? hasFolders,
    List<WeightMeasurement> Function()? weights,
    List<TaggedFood> Function()? foods,
    List<Exercise> Function()? customExercises,
    this.distanceUnit = Distance.km,
    this.weightUnit = Weights.kg,
  }) : clock = clock ?? DateTime.now,
       history = history ?? (() => const []),
       routines = routines ?? (() => const []),
       hasFolders = hasFolders ?? (() => false),
       weights = weights ?? (() => const []),
       foods = foods ?? (() => const []),
       customExercises = customExercises ?? (() => const []);

  final DateTime Function() clock;
  final List<Workout> Function() history;
  final List<Workout> Function() routines;
  final bool Function() hasFolders;
  final List<WeightMeasurement> Function() weights;
  final List<TaggedFood> Function() foods;
  final List<Exercise> Function() customExercises;
  final Distance distanceUnit;
  final Weights weightUnit;

  late final Map<String, Achievement> catalog = {
    "firstSteps": Achievement(
      id: "firstSteps",
      nameKey: "achievements.firstSteps.title",
      iconKey: "firstSteps",
      levels: [
        AchievementLevel(
          achievementID: "firstSteps",
          level: 1,
          nameKey: "achievements.firstSteps.title",
          descriptionKey: "achievements.firstSteps.description.k1",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) => history().isNotEmpty,
        ),
        AchievementLevel(
          achievementID: "firstSteps",
          level: 2,
          nameKey: "achievements.firstSteps.title",
          descriptionKey: "achievements.firstSteps.description.k2",
          trigger: AchievementTrigger.weight,
          checkCompletion: (progress) => weights().isNotEmpty,
        ),
        AchievementLevel(
          achievementID: "firstSteps",
          level: 3,
          nameKey: "achievements.firstSteps.title",
          descriptionKey: "achievements.firstSteps.description.k3",
          trigger: AchievementTrigger.food,
          checkCompletion: (progress) => foods().isNotEmpty,
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
          achievementID: "foodWatcher",
          level: 1,
          nameKey: "achievements.foodWatcher.title",
          descriptionKey: "achievements.foodWatcher.description.k1",
          trigger: AchievementTrigger.food,
          progress: () {
            final periodFoods = _foodWatcher();
            return periodFoods.length.toDouble();
          },
          progressMax: () => 2,
          progressText: (t, value) => t.time.days(n: value.toInt()),
          checkCompletion: (progress) {
            const days = 2;
            return progress! >= days;
          },
        ),
        AchievementLevel(
          achievementID: "foodWatcher",
          level: 2,
          nameKey: "achievements.foodWatcher.title",
          descriptionKey: "achievements.foodWatcher.description.k2",
          trigger: AchievementTrigger.food,
          progress: () {
            final periodFoods = _foodWatcher();
            return periodFoods.length.toDouble();
          },
          progressMax: () => 7,
          progressText: (t, value) => t.time.days(n: value.toInt()),
          checkCompletion: (progress) {
            const days = 7;
            return progress! >= days;
          },
        ),
        AchievementLevel(
          achievementID: "foodWatcher",
          level: 3,
          nameKey: "achievements.foodWatcher.title",
          descriptionKey: "achievements.foodWatcher.description.k3",
          trigger: AchievementTrigger.food,
          progress: () {
            final periodFoods = _foodWatcher();
            return periodFoods.length.toDouble();
          },
          progressMax: () => 30,
          progressText: (t, value) => t.time.days(n: value.toInt()),
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
          achievementID: "marathoner",
          level: 1,
          nameKey: "achievements.marathoner.title",
          descriptionKey: "achievements.marathoner.description.k1",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            final history = this.history();
            if (history.isEmpty) return false;
            final latestWorkout = history.last;
            return Distance.convert(
                  value: latestWorkout.distanceRun,
                  from: latestWorkout.distanceUnit,
                  to: Distance.km,
                ) >=
                5;
          },
        ),
        AchievementLevel(
          achievementID: "marathoner",
          level: 2,
          nameKey: "achievements.marathoner.title",
          descriptionKey: "achievements.marathoner.description.k2",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            final history = this.history();
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
          achievementID: "marathoner",
          level: 3,
          nameKey: "achievements.marathoner.title",
          descriptionKey: "achievements.marathoner.description.k3",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            final history = this.history();
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
          achievementID: "earlyBird",
          level: 1,
          nameKey: "achievements.earlyBird.title",
          descriptionKey: "achievements.earlyBird.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            var history = this.history();
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
          achievementID: "nightOwl",
          level: 1,
          nameKey: "achievements.nightOwl.title",
          descriptionKey: "achievements.nightOwl.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            var history = this.history();
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
          achievementID: "realGymBro",
          level: 1,
          nameKey: "achievements.realGymBro.title",
          descriptionKey: "achievements.realGymBro.description.k1",
          trigger: AchievementTrigger.workout,
          progress: () {
            final workouts = history();
            if (workouts.isEmpty) return 0;
            return workouts
                    .map((e) => e.duration!)
                    .reduce((value, element) => value + element)
                    .inMinutes /
                60;
          },
          progressMax: () => 100,
          progressText: (t, value) => t.time.justHours(n: value.toInt()),
          checkCompletion: (progress) => progress! >= 100,
        ),
        AchievementLevel(
          achievementID: "realGymBro",
          level: 2,
          nameKey: "achievements.realGymBro.title",
          descriptionKey: "achievements.realGymBro.description.k2",
          trigger: AchievementTrigger.workout,
          progress: () {
            final workouts = history();
            if (workouts.isEmpty) return 0;
            return workouts
                    .map((e) => e.duration!)
                    .reduce((value, element) => value + element)
                    .inMinutes /
                60;
          },
          progressMax: () => 500,
          progressText: (t, value) => t.time.justHours(n: value.toInt()),
          checkCompletion: (progress) => progress! >= 500,
        ),
        AchievementLevel(
          achievementID: "realGymBro",
          level: 3,
          nameKey: "achievements.realGymBro.title",
          descriptionKey: "achievements.realGymBro.description.k3",
          trigger: AchievementTrigger.workout,
          progress: () {
            final workouts = history();
            if (workouts.isEmpty) return 0;
            return workouts
                    .map((e) => e.duration!)
                    .reduce((value, element) => value + element)
                    .inMinutes /
                60;
          },
          progressMax: () => 1000,
          progressText: (t, value) => t.time.justHours(n: value.toInt()),
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
          achievementID: "workoutFreak",
          level: 1,
          nameKey: "achievements.workoutFreak.title",
          descriptionKey: "achievements.workoutFreak.description.k1",
          trigger: AchievementTrigger.workout,
          progress: () {
            return _workoutFreak(_WorkoutFreakPeriod.month).length.toDouble();
          },
          progressMax: () {
            final today = clock();
            return DateTime(today.year, today.month + 1, 0).day.toDouble();
          },
          progressText: (t, value) => t.time.days(n: value.toInt()),
          checkCompletion: (progress) {
            final today = clock().startOfDay;
            final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
            return progress! >= daysInMonth;
          },
        ),
        AchievementLevel(
          achievementID: "workoutFreak",
          level: 2,
          nameKey: "achievements.workoutFreak.title",
          descriptionKey: "achievements.workoutFreak.description.k2",
          trigger: AchievementTrigger.workout,
          progress: () {
            return _workoutFreak(_WorkoutFreakPeriod.year).length.toDouble();
          },
          progressMax: () {
            final today = clock();
            return today.isLeapYear ? 366 : 365;
          },
          progressText: (t, value) => t.time.days(n: value.toInt()),
          checkCompletion: (progress) {
            final today = clock().startOfDay;
            final daysInYear = today.isLeapYear ? 366 : 365;
            return progress! >= daysInYear;
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
          achievementID: "trailblazer",
          level: 1,
          nameKey: "achievements.trailblazer.title",
          descriptionKey:
              "achievements.trailblazer.description.k1.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 100, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _trailblazer,
          progressMax: () => 100,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
          checkCompletion: (progress) => progress! >= 100,
        ),
        AchievementLevel(
          achievementID: "trailblazer",
          level: 2,
          nameKey: "achievements.trailblazer.title",
          descriptionKey:
              "achievements.trailblazer.description.k2.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 500, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _trailblazer,
          progressMax: () => 500,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
          checkCompletion: (progress) => progress! >= 500,
        ),
        AchievementLevel(
          achievementID: "trailblazer",
          level: 3,
          nameKey: "achievements.trailblazer.title",
          descriptionKey:
              "achievements.trailblazer.description.k3.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 1000, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _trailblazer,
          progressMax: () => 1000,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
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
          achievementID: "cycleChampion",
          level: 1,
          nameKey: "achievements.cycleChampion.title",
          descriptionKey:
              "achievements.cycleChampion.description.k1.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 100, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _cycleChampion,
          progressMax: () => 100,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
          checkCompletion: (progress) => progress! >= 100,
        ),
        AchievementLevel(
          achievementID: "cycleChampion",
          level: 2,
          nameKey: "achievements.cycleChampion.title",
          descriptionKey:
              "achievements.cycleChampion.description.k2.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 500, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _cycleChampion,
          progressMax: () => 500,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
          checkCompletion: (progress) => progress! >= 500,
        ),
        AchievementLevel(
          achievementID: "cycleChampion",
          level: 3,
          nameKey: "achievements.cycleChampion.title",
          descriptionKey:
              "achievements.cycleChampion.description.k3.${distanceUnit.name}",
          descriptionParameters: (t) => [
            Distance.mi.format(
              t,
              Distance.convert(value: 1000, from: Distance.km, to: Distance.mi),
            ),
          ],
          trigger: AchievementTrigger.workout,
          progress: _cycleChampion,
          progressMax: () => 1000,
          progressText: (t, value) => Distance.convert(
            value: value,
            from: Distance.km,
            to: distanceUnit,
          ).getUserFacingDistance(t, distanceUnit),
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
          achievementID: "professionalWeightlifter",
          level: 1,
          nameKey: "achievements.professionalWeightlifter.title",
          descriptionKey:
              "achievements.professionalWeightlifter.description.k1",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            return _professionalWeightlifter(1);
          },
        ),
        AchievementLevel(
          achievementID: "professionalWeightlifter",
          level: 2,
          nameKey: "achievements.professionalWeightlifter.title",
          descriptionKey:
              "achievements.professionalWeightlifter.description.k2",
          trigger: AchievementTrigger.workout,
          checkCompletion: (progress) {
            return _professionalWeightlifter(1.5);
          },
        ),
        AchievementLevel(
          achievementID: "professionalWeightlifter",
          level: 3,
          nameKey: "achievements.professionalWeightlifter.title",
          descriptionKey:
              "achievements.professionalWeightlifter.description.k3",
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
          achievementID: "programPlanner",
          level: 1,
          nameKey: "achievements.programPlanner.title",
          descriptionKey: "achievements.programPlanner.description",
          trigger: AchievementTrigger.routines,
          progress: () => routines().length.toDouble(),
          progressMax: () => 3,
          progressText: (t, value) => value.toInt().toString(),
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
          achievementID: "perfectPlanner",
          level: 1,
          nameKey: "achievements.perfectPlanner.title",
          descriptionKey: "achievements.perfectPlanner.description",
          trigger: AchievementTrigger.routines,
          checkCompletion: (progress) {
            return hasFolders();
          },
        ),
      ],
    ),
    // Routine Master
    // 1. Follow a routine for 3 consecutive months
    // 2. Follow a routine for 6 consecutive months
    // 3. Follow a routine for 12 consecutive months
    "routineMaster": Achievement(
      id: "routineMaster",
      nameKey: "achievements.routineMaster.title",
      iconKey: "routineMaster",
      color: Colors.pink,
      levels: [
        AchievementLevel(
          achievementID: "routineMaster",
          level: 1,
          nameKey: "achievements.routineMaster.title",
          descriptionKey: "achievements.routineMaster.description.k1",
          trigger: AchievementTrigger.workout,
          progress: () => _routineMaster().length.toDouble(),
          progressMax: () => 3,
          progressText: (t, v) => v.toInt().toString(),
          checkCompletion: (progress) => progress! >= 3,
        ),
        AchievementLevel(
          achievementID: "routineMaster",
          level: 2,
          nameKey: "achievements.routineMaster.title",
          descriptionKey: "achievements.routineMaster.description.k2",
          trigger: AchievementTrigger.workout,
          progress: () => _routineMaster().length.toDouble(),
          progressMax: () => 6,
          progressText: (t, v) => v.toInt().toString(),
          checkCompletion: (progress) => progress! >= 6,
        ),
        AchievementLevel(
          achievementID: "routineMaster",
          level: 3,
          nameKey: "achievements.routineMaster.title",
          descriptionKey: "achievements.routineMaster.description.k3",
          trigger: AchievementTrigger.workout,
          progress: () => _routineMaster().length.toDouble(),
          progressMax: () => 12,
          progressText: (t, v) => v.toInt().toString(),
          checkCompletion: (progress) => progress! >= 12,
        ),
      ],
    ),
    // Personal Best Breaker
    // Set a new one-rep max personal record in one exercise
    "pbBreaker": Achievement(
      id: "pbBreaker",
      nameKey: "achievements.pbBreaker.title",
      iconKey: "pbBreaker",
      color: Colors.orangeAccent,
      levels: [
        AchievementLevel(
          achievementID: "pbBreaker",
          level: 1,
          nameKey: "achievements.pbBreaker.title",
          descriptionKey: "achievements.pbBreaker.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) => _pbBreaker(history()).isNotEmpty,
        ),
      ],
    ),
    // Intensity innovator
    // Update a routine
    "intensityInnovator": Achievement(
      id: "intensityInnovator",
      nameKey: "achievements.intensityInnovator.title",
      iconKey: "intensityInnovator",
      color: Colors.teal,
      levels: [
        AchievementLevel(
          achievementID: "intensityInnovator",
          level: 1,
          nameKey: "achievements.intensityInnovator.title",
          descriptionKey: "achievements.intensityInnovator.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            final routines = this.routines();
            final workouts = history();
            if (routines.isEmpty || workouts.isEmpty) return false;

            for (final routine in routines) {
              final rHistory = workouts
                  .where((wo) => wo.parentID == routine.id)
                  .toList();
              if (rHistory.length < 2) continue;

              for (int i = rHistory.length - 1; i > 0; i--) {
                final newW = rHistory[i];
                final oldW = rHistory[i - 1];

                // Check that the current newer workout is the same as the routine
                if (!WorkoutDifference.fromWorkouts(
                  oldWorkout: newW,
                  newWorkout: routine,
                ).isEmpty) {
                  continue;
                }

                if (!WorkoutDifference.fromWorkouts(
                  oldWorkout: oldW,
                  newWorkout: newW,
                ).isEmpty) {
                  return true;
                }
              }
            }

            return false;
          },
        ),
      ],
    ),
    "completionist": Achievement(
      id: "completionist",
      nameKey: "achievements.completionist.title",
      iconKey: "completionist",
      color: Colors.green,
      levels: [
        AchievementLevel(
          achievementID: "completionist",
          level: 1,
          nameKey: "achievements.completionist.title",
          descriptionKey: "achievements.completionist.description",
          trigger: AchievementTrigger.workout,
          progress: () {
            final exercises = <String>{};
            final history = this.history();
            for (final wo in history) {
              final exs = wo.flattenedExercises.whereType<Exercise>();
              for (final ex in exs) {
                if (ex.isStandardLibraryExercise && ex.parentID != null) {
                  exercises.add(ex.parentID!);
                }
              }
            }
            return exercises.length.toDouble();
          },
          progressMax: () => exerciseStandardLibraryAsList.length.toDouble(),
          progressText: (t, v) => v.toInt().toString(),
          checkCompletion: (progress) {
            return progress! >= exerciseStandardLibraryAsList.length;
          },
        ),
      ],
    ),
    "notDrunk": Achievement(
      id: "notDrunk",
      nameKey: "achievements.notDrunk.title",
      iconKey: "notDrunk",
      color: Colors.purpleAccent,
      levels: [
        AchievementLevel(
          achievementID: "notDrunk",
          level: 1,
          nameKey: "achievements.notDrunk.title",
          descriptionKey: "achievements.notDrunk.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            // Work out...
            final history = this.history();
            if (history.length < 2) return false;

            // ...on a Sunday morning...
            final workout = history.last;
            final date = workout.startingDate!;
            if (date.hour > 12 || (date.hour == 12 && date.minute >= 00)) {
              return false;
            }
            if (date.weekday != DateTime.sunday) return false;

            // ...breaking a personal best
            final exercises = workout.flattenedExercises
                .whereType<Exercise>()
                .where(
                  (exercise) =>
                      exercise.parameters.hasDistance ||
                      (exercise.parameters.hasWeight &&
                          exercise.parameters != GTSetParameters.repsNegWeight),
                );
            if (exercises.isEmpty) return false;
            for (final exercise in exercises) {
              final params = exercise.parameters;

              final previousExercises = getHistoryOf(
                exercise,
              ).where((data) => data.$3.startingDate!.isBefore(date));
              for (final (previousEx, _, _) in previousExercises) {
                // If the previous exercise is "better" than the current one
                // then we haven't broken the PB. Return false
                if (params.hasDistance) {
                  if ((previousEx.distanceRun ?? 0) >= exercise.distanceRun!) {
                    return false;
                  }
                } else if (params.hasWeight) {
                  if ((previousEx.liftedWeight ?? 0) >=
                      exercise.liftedWeight!) {
                    return false;
                  }
                }
              }
            }

            return true;
          },
        ),
      ],
    ),
    "steamedHams": Achievement(
      id: "steamedHams",
      nameKey: "achievements.steamedHams.title",
      iconKey: "steamedHams",
      color: Colors.orange.shade400,
      levels: [
        AchievementLevel(
          achievementID: "steamedHams",
          level: 1,
          nameKey: "achievements.steamedHams.title",
          descriptionKey: "achievements.steamedHams.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            final routines = this.routines();
            if (routines.isEmpty) return false;

            final history = this.history();
            if (history.isEmpty) return false;

            return history.map((w) => _steamedHams(w, history)).any((el) => el);
          },
        ),
      ],
    ),
    "swimsuitSeason": Achievement(
      id: "swimsuitSeason",
      nameKey: "achievements.swimsuitSeason.title",
      iconKey: "swimsuitSeason",
      color: Colors.blueAccent,
      levels: [
        AchievementLevel(
          achievementID: "swimsuitSeason",
          level: 1,
          nameKey: "achievements.swimsuitSeason.title",
          descriptionKey: "achievements.swimsuitSeason.description",
          trigger: AchievementTrigger.workout,
          progress: () {
            final year = clock().year;
            final history = this.history();
            if (history.isEmpty) return 0;
            final subset = history.where(
              (workout) =>
                  workout.startingDate!.isAfter(DateTime(year, 3, 1)) &&
                  workout.endingDate!.isBefore(DateTime(year, 7, 1)),
            );
            if (subset.isEmpty) return 0;
            return _swimsuitSeason(subset).inMinutes / 60;
          },
          progressMax: () => 24,
          progressText: (t, value) => t.time.justHours(n: value),
          checkCompletion: (_) {
            const trigger = Duration(hours: 24);

            // Work out...
            final history = this.history();
            if (history.isEmpty) return false;

            for (
              int year = clock().year;
              year >= history.first.startingDate!.year;
              year--
            ) {
              final subset = history.where(
                (workout) =>
                    workout.startingDate!.isAfter(DateTime(year, 3, 1)) &&
                    workout.endingDate!.isBefore(DateTime(year, 7, 1)),
              );
              if (subset.isEmpty) return false;
              final hours = _swimsuitSeason(subset);
              if (hours > trigger) return true;
            }

            return false;
          },
        ),
      ],
    ),
    "sparta": Achievement(
      id: "sparta",
      nameKey: "achievements.sparta.title",
      iconKey: "sparta",
      color: GTColors.burgundy.shade400,
      levels: [
        AchievementLevel(
          achievementID: "sparta",
          level: 1,
          nameKey: "achievements.sparta.title",
          descriptionKey:
              "achievements.sparta.description.k1.${weightUnit.name}",
          descriptionParameters: (t) => [
            Weights.kg.format(
              t,
              Weights.convert(value: 300, from: Weights.lb, to: Weights.kg),
            ),
          ],
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) => _sparta(Weights.lb),
        ),
        AchievementLevel(
          achievementID: "sparta",
          level: 2,
          nameKey: "achievements.sparta.title",
          descriptionKey:
              "achievements.sparta.description.k2.${weightUnit.name}",
          descriptionParameters: (t) => [
            Weights.lb.format(
              t,
              Weights.convert(value: 300, from: Weights.kg, to: Weights.lb),
            ),
          ],
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) => _sparta(Weights.kg),
        ),
      ],
    ),
    "midnightRain": Achievement(
      id: "midnightRain",
      nameKey: "achievements.midnightRain.title",
      iconKey: "midnightRain",
      color: GTColors.midnights.shade400,
      levels: [
        AchievementLevel(
          achievementID: "midnightRain",
          level: 1,
          nameKey: "achievements.midnightRain.title",
          descriptionKey: "achievements.midnightRain.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            final history = this.history();
            if (history.isEmpty) return false;

            _logic(Workout workout) {
              final startingDay = workout.startingDate!.startOfDay;
              final endingDay = workout.endingDate!.startOfDay;

              return startingDay != endingDay;
            }

            return history.any(_logic);
          },
        ),
      ],
    ),
    "equipmentSpecialist": Achievement(
      id: "equipmentSpecialist",
      nameKey: "achievements.equipmentSpecialist.title",
      iconKey: "equipmentSpecialist",
      color: Colors.lightGreen,
      levels: [
        AchievementLevel(
          achievementID: "equipmentSpecialist",
          level: 1,
          nameKey: "achievements.equipmentSpecialist.title",
          descriptionKey: "achievements.equipmentSpecialist.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            final history = this.history();
            if (history.isEmpty) return false;

            final routines = this.routines();
            if (routines.isEmpty) return false;

            bool _checksOut(Workout w) {
              return w.flattenedExercises
                          .whereType<Exercise>()
                          .map((exercise) {
                            return exercise.gymEquipment;
                          })
                          .toSet()
                          .length ==
                      1 &&
                  w.flattenedExercises
                          .whereType<Exercise>()
                          .first
                          .asExercise
                          .gymEquipment !=
                      GTGymEquipment.none;
            }

            _logic(Workout routine) {
              final routineHistory = history.where(
                (workout) => workout.parentID == routine.id,
              );
              if (routineHistory.isEmpty) return false;

              return _checksOut(routine) && routineHistory.every(_checksOut);
            }

            return routines.any(_logic);
          },
        ),
      ],
    ),
    "bodyweightBeast": Achievement(
      id: "bodyweightBeast",
      nameKey: "achievements.bodyweightBeast.title",
      iconKey: "bodyweightBeast",
      color: GTColors.peach,
      levels: [
        AchievementLevel(
          achievementID: "bodyweightBeast",
          level: 1,
          nameKey: "achievements.bodyweightBeast.title",
          descriptionKey: "achievements.bodyweightBeast.description",
          trigger: AchievementTrigger.workout,
          checkCompletion: (_) {
            final history = this.history();
            if (history.isEmpty) return false;

            final routines = this.routines();
            if (routines.isEmpty) return false;

            bool _checksOut(Workout w) {
              return w.flattenedExercises.whereType<Exercise>().every((
                exercise,
              ) {
                return exercise.gymEquipment == GTGymEquipment.none;
              });
            }

            _logic(Workout routine) {
              final routineHistory = history.where(
                (workout) => workout.parentID == routine.id,
              );
              if (routineHistory.length < 2) return false;

              final firstStart = routineHistory.first.startingDate!;
              final daysInMonth = DateTime(
                firstStart.year,
                firstStart.month + 1,
                0,
              ).day;

              final lastStart = routineHistory.last.startingDate!;

              return _checksOut(routine) &&
                  routineHistory.every(_checksOut) &&
                  lastStart.difference(firstStart).inDays >= daysInMonth;
            }

            return routines.any(_logic);
          },
        ),
      ],
    ),
  };

  double _calculate1RM(Exercise exercise, Weights unit) {
    assert(exercise.parameters == GTSetParameters.repsWeight);
    var value = exercise.sets
        .where((set) => set.done)
        .map((set) => set.oneRepMax)
        .whereType<num>()
        .safeMax
        ?.toDouble();
    return value == null
        ? -1
        : Weights.convert(value: value, from: unit, to: Weights.kg);
  }

  List<DateTime> _foodWatcher() {
    final now = clock();
    // Compare calendar days in UTC to avoid daylight-saving time changing
    // the duration between two consecutive local dates.
    final today = DateTime.utc(now.year, now.month, now.day);
    final days =
        foods()
            .map(
              (food) =>
                  DateTime.utc(food.date.year, food.date.month, food.date.day),
            )
            .where((day) => !day.isAfter(today))
            .toSet()
            .toList()
          ..sort();

    var longestStreak = <DateTime>[];
    var currentStreak = <DateTime>[];
    for (final day in days) {
      if (currentStreak.isNotEmpty &&
          day.difference(currentStreak.last).inDays != 1) {
        currentStreak = [];
      }
      currentStreak.add(day);
      if (currentStreak.length > longestStreak.length) {
        longestStreak = currentStreak.toList();
      }
    }

    return longestStreak;
  }

  List<DateTime> _workoutFreak(_WorkoutFreakPeriod period) {
    final today = clock().startOfDay;

    final periodWorkouts = history().where((element) {
      final yearMatches = element.startingDate!.year == today.year;
      if (period == _WorkoutFreakPeriod.year) return yearMatches;
      return yearMatches && element.startingDate!.month == today.month;
    });

    return periodWorkouts
        .map((w) => w.startingDate!.startOfDay)
        .toSet()
        .toList();
  }

  double _trailblazer() {
    final workouts = history();
    if (workouts.isEmpty) return 0.0;
    return workouts
        .map(
          (e) => Distance.convert(
            value: e.distanceRun,
            from: e.distanceUnit,
            to: Distance.km,
          ),
        )
        .reduce((value, element) => value + element);
  }

  double _cycleChampion() {
    final workouts = history();
    if (workouts.isEmpty) return 0.0;
    final sumOfDistances = workouts
        .map(
          (e) => _distanceByFiltering(
            e,
            filter: (e) {
              return e.isStandardLibraryExercise &&
                  [
                    GTStandardLibrary.cardio.biking,
                    GTStandardLibrary.cardio.ergometer,
                    GTStandardLibrary.cardio.ergometerHorizontal,
                  ].contains(e.parentID);
            },
          ),
        )
        .reduce((value, element) => value + element);
    return sumOfDistances;
  }

  bool _professionalWeightlifter(double coefficient) {
    final weight = weights().lastOrNull;
    if (weight == null) return false;

    final history = this.history();
    if (history.isEmpty) return false;

    final latestWorkout = history.last;
    final exercises = latestWorkout.flattenedExercises.whereType<Exercise>();

    for (final ex in exercises) {
      for (final set in ex.doneSets) {
        if (set.parameters != GTSetParameters.repsNegWeight &&
            set.weight != null &&
            Weights.convert(
                  value: set.weight!,
                  from: latestWorkout.weightUnit,
                  to: Weights.kg,
                ) >=
                Weights.convert(
                      value: weight.weight,
                      from: weight.weightUnit,
                      to: Weights.kg,
                    ) *
                    coefficient) {
          return true;
        }
      }
    }

    return false;
  }

  List _routineMaster() {
    final routines = this.routines();
    if (routines.isEmpty) return [];

    int longestStreak = 0;
    List<DateTime> longestStreakDates = [];
    String longestStreakRoutineName = '';

    for (var routine in routines) {
      final workouts = history().where((wo) => wo.parentID == routine.id);
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
            currentStreakDates.addAll(
              groupedWorkouts[sortedKeys[j + 1]]!
                  .map((wo) => wo.startingDate!)
                  .toList(),
            );
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
      globalLogger.d('Longest streak routine: $longestStreakRoutineName');
    }

    final Set<String> yearMonthPairs = {};

    for (var date in longestStreakDates) {
      final yearMonth = '${date.year}-${date.month}';
      yearMonthPairs.add(yearMonth);
    }

    return yearMonthPairs.toList();
  }

  List<Exercise> _pbBreaker(List<Workout> history) {
    if (history.isEmpty) return [];

    List<Exercise> _exercisesBreaking1RM(Workout workout) {
      if (workout.parentID == null) return [];
      final workoutHistory = history.where(
        (w) => w.startingDate!.isBefore(workout.startingDate!),
      );
      if (workoutHistory.isEmpty) return [];

      List<Exercise> maxExercises = [];
      bool _exFilter(Exercise ex) =>
          ex.parameters == GTSetParameters.repsWeight;
      for (final exercise
          in workout.flattenedExercises.whereType<Exercise>().where(
            _exFilter,
          )) {
        final cur1RM = _calculate1RM(exercise, workout.weightUnit);

        // I'm running out of good short variable names LMAO
        final historySameExercises = workoutHistory
            .map(
              (w) => w.flattenedExercises
                  .where(
                    (e) =>
                        e.isExercise &&
                        e.asExercise.parentID == exercise.parentID,
                  )
                  .map((ex) => (ex.asExercise, w.weightUnit))
                  .toList(),
            )
            .expand((e) => e)
            .cast<(Exercise, Weights)>();
        if (historySameExercises.isEmpty) continue;
        final oldMax = historySameExercises
            .map((tuple) => _calculate1RM(tuple.$1, tuple.$2))
            .max;
        if (cur1RM > oldMax) maxExercises.add(exercise);
      }

      return maxExercises;
    }

    return history
        .map(_exercisesBreaking1RM)
        .fold(
          [],
          (max, potential) => potential.length > max.length ? potential : max,
        );
  }

  bool _steamedHams(Workout workout, List<Workout> history) {
    if (workout.parentID == null) return false;
    final workoutHistory = history
        .where((w) {
          return w.parentID == workout.parentID;
        })
        .where((w) => w.startingDate!.isBefore(workout.startingDate!));
    if (workoutHistory.isEmpty) return false;

    bool _exFilter(Exercise ex) => ex.parameters == GTSetParameters.repsWeight;
    for (final historyWorkout in workoutHistory) {
      if (historyWorkout.duration! <= workout.duration!) return false;

      for (final exercise
          in workout.flattenedExercises.whereType<Exercise>().where(
            _exFilter,
          )) {
        final cur1RM = _calculate1RM(exercise, workout.weightUnit);

        for (final oldExercise
            in historyWorkout.flattenedExercises
                .whereType<Exercise>()
                .where(_exFilter)
                .where((ex) => ex.isTheSameAs(exercise))) {
          final old1RM = _calculate1RM(oldExercise, historyWorkout.weightUnit);
          if (old1RM < cur1RM) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Duration _swimsuitSeason(Iterable<Workout> subset) {
    return subset.fold(Duration.zero, (duration, workout) {
      final cardioExercises = workout.flattenedExercises
          .whereType<Exercise>()
          .where(
            (ex) =>
                ex.parentID != null &&
                GTStandardLibrary.cardio.values.contains(ex.parentID!),
          );

      if (cardioExercises.length == workout.flattenedExercises.length) {
        return workout.duration! + duration;
      }

      var timedCardio = cardioExercises.where((ex) => ex.parameters.hasTime);
      var untimedCardio = cardioExercises.where((ex) => !ex.parameters.hasTime);

      final timedDuration = timedCardio.isEmpty
          ? Duration.zero
          : timedCardio.map((ex) => ex.time!).reduce((a, b) => a + b);
      final untimedDuration = untimedCardio.isEmpty
          ? Duration.zero
          : untimedCardio
                .map(
                  (exercise) =>
                      workout.duration! *
                      exercise.doneSets.length *
                      (1 / workout.doneSets.length),
                )
                .reduce((a, b) => a + b);

      return duration + timedDuration + untimedDuration;
    });
  }

  bool _sparta(Weights unit) {
    const threshold = 300.0;

    final history = this.history();
    if (history.isEmpty) return false;

    final latestWorkout = history.last;
    final exercises = latestWorkout.flattenedExercises.whereType<Exercise>();

    for (final ex in exercises) {
      for (final set in ex.doneSets) {
        if (set.parameters != GTSetParameters.repsNegWeight &&
            set.weight != null &&
            Weights.convert(
                  value: set.weight!,
                  from: latestWorkout.weightUnit,
                  to: Weights.kg,
                ) >=
                Weights.convert(value: threshold, from: unit, to: Weights.kg)) {
          return true;
        }
      }
    }

    return false;
  }

  static bool _defaultFilter(Exercise _) => true;
  double _distanceByFiltering(
    Workout workout, {
    bool Function(Exercise) filter = _defaultFilter,
  }) {
    var filteredExercises = workout.flattenedExercises
        .whereType<Exercise>()
        .where(filter)
        .map((e) {
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

  List<(Exercise, int, Workout)> getHistoryOf(Exercise exercise) {
    final parent = exercise.isAbstract
        ? exercise
        : exercise.getParent(customExercises()) ?? exercise;
    final matches = <(Exercise, int, Workout)>[];
    for (final workout in history()) {
      for (var i = 0; i < workout.exercises.length; i++) {
        final entry = workout.exercises[i];
        final exercises = entry.isExercise
            ? [entry.asExercise]
            : entry.asSuperset.exercises;
        for (final candidate in exercises) {
          if (parent.isTheSameAs(candidate)) {
            matches.add((candidate, i, workout));
          }
        }
      }
    }
    matches.sort((a, b) => b.$3.startingDate!.compareTo(a.$3.startingDate!));
    return matches;
  }
}

enum _WorkoutFreakPeriod { month, year }
