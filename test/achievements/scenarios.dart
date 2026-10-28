import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

import 'fixtures.dart';

/// Independent expectations: never derive thresholds or triggers from the rule.
class AchievementScenario {
  const AchievementScenario(
    this.id,
    this.level,
    this.trigger, {
    required this.locked,
    required this.earned,
    this.lockedProgress,
    this.earnedProgress,
    this.progressMax,
    this.alsoLocked = const {},
    this.alsoEarned = const {},
  });

  final String id;
  final int level;
  final AchievementTrigger trigger;
  final AchievementFixture locked, earned;
  final double? lockedProgress, earnedProgress, progressMax;
  final Map<String, AchievementFixture> alsoLocked, alsoEarned;
  String get key => '$id/$level';
}

List<AchievementScenario> achievementScenarios() {
  final ordinary = workout();
  final monthDays = [
    for (var day = 1; day <= 30; day++)
      workout(id: 'day-$day', date: DateTime(2024, 6, day)),
  ];
  final yearDays = [
    for (var day = 1; day <= 366; day++)
      workout(id: 'day-$day', date: DateTime(2024, 1, day)),
  ];
  AchievementFixture travel(double km, {bool cycling = false}) =>
      AchievementFixture(
        history: [
          workout(
            id: 'first',
            exercises: [distance(km / 2, cycling: cycling)],
          ),
          workout(
            id: 'last',
            exercises: [distance(km / 2, cycling: cycling)],
          ),
        ],
      );
  AchievementFixture lifting(
    double weight, {
    double? body,
    Weights unit = Weights.kg,
    bool done = true,
    GTSetParameters parameters = GTSetParameters.repsWeight,
  }) => AchievementFixture(
    weights: body == null ? [] : [bodyWeight(body)],
    history: [
      workout(
        weightUnit: unit,
        exercises: [strength(weight, done: done, parameters: parameters)],
      ),
    ],
  );
  AchievementFixture equipment({required bool mixed}) => AchievementFixture(
    routines: [
      routine(exercises: [strength(50)]),
    ],
    history: [
      workout(
        parentID: 'routine',
        exercises: [
          strength(50),
          if (mixed) strength(50, equipment: GTGymEquipment.dumbbell),
        ],
      ),
    ],
  );
  AchievementFixture bodyweight(int lastDay) => AchievementFixture(
    routines: [
      routine(
        exercises: [
          strength(
            0,
            parameters: GTSetParameters.freeBodyReps,
            equipment: GTGymEquipment.none,
          ),
        ],
      ),
    ],
    history: [
      for (final day in [1, lastDay])
        workout(
          id: 'day-$day',
          parentID: 'routine',
          date: DateTime(2024, 4, day),
          exercises: [
            strength(
              0,
              parameters: GTSetParameters.freeBodyReps,
              equipment: GTGymEquipment.none,
            ),
          ],
        ),
    ],
  );
  AchievementFixture seasonal(Duration duration) => AchievementFixture(
    history: [
      workout(
        date: DateTime(2024, 5, 1),
        duration: duration,
        exercises: [distance(5)],
      ),
    ],
  );

  return [
    AchievementScenario(
      'firstSteps',
      1,
      AchievementTrigger.workout,
      locked: AchievementFixture(routines: [routine()]),
      earned: AchievementFixture(history: [ordinary]),
    ),
    AchievementScenario(
      'firstSteps',
      2,
      AchievementTrigger.weight,
      locked: AchievementFixture(history: [ordinary]),
      earned: AchievementFixture(weights: [bodyWeight(80)]),
    ),
    AchievementScenario(
      'firstSteps',
      3,
      AchievementTrigger.food,
      locked: AchievementFixture(weights: [bodyWeight(80)]),
      earned: AchievementFixture(foods: [meal(DateTime(2024, 6, 15))]),
    ),
    for (final (index, days) in [2, 7, 30].indexed)
      AchievementScenario(
        'foodWatcher',
        index + 1,
        AchievementTrigger.food,
        locked: AchievementFixture(foods: consecutiveMeals(days - 1)),
        earned: AchievementFixture(foods: consecutiveMeals(days)),
        lockedProgress: days - 1.0,
        earnedProgress: days.toDouble(),
        progressMax: days.toDouble(),
      ),
    for (final (index, km) in [5.0, 21.0975, 42.195].indexed)
      AchievementScenario(
        'marathoner',
        index + 1,
        AchievementTrigger.workout,
        locked: AchievementFixture(
          history: [
            workout(exercises: [distance(km - 0.001)]),
          ],
        ),
        earned: AchievementFixture(
          history: [
            workout(exercises: [distance(km)]),
          ],
        ),
        alsoLocked: {
          'unfinished sets do not count': AchievementFixture(
            history: [
              workout(exercises: [distance(km, done: false)]),
            ],
          ),
          'earlier qualifying workout is not the latest': AchievementFixture(
            history: [
              workout(id: 'old', exercises: [distance(km)]),
              ordinary,
            ],
          ),
        },
        alsoEarned: {
          'miles are converted': AchievementFixture(
            history: [
              workout(distanceUnit: Distance.mi, exercises: [distance(km)]),
            ],
          ),
        },
      ),
    AchievementScenario(
      'earlyBird',
      1,
      AchievementTrigger.workout,
      locked: AchievementFixture(
        history: [workout(date: DateTime(2024, 6, 15, 8))],
      ),
      earned: AchievementFixture(
        history: [workout(date: DateTime(2024, 6, 15, 7, 59))],
      ),
    ),
    AchievementScenario(
      'nightOwl',
      1,
      AchievementTrigger.workout,
      locked: AchievementFixture(
        history: [workout(date: DateTime(2024, 6, 15, 19, 59))],
      ),
      earned: AchievementFixture(
        history: [workout(date: DateTime(2024, 6, 15, 20))],
      ),
    ),
    for (final (index, hours) in [100, 500, 1000].indexed)
      AchievementScenario(
        'realGymBro',
        index + 1,
        AchievementTrigger.workout,
        locked: AchievementFixture(
          history: [workout(duration: Duration(minutes: hours * 60 - 1))],
        ),
        earned: AchievementFixture(
          history: [
            workout(
              id: 'one',
              duration: Duration(hours: hours ~/ 2),
            ),
            workout(
              id: 'two',
              duration: Duration(hours: hours ~/ 2),
            ),
          ],
        ),
        lockedProgress: hours - 1 / 60,
        earnedProgress: hours.toDouble(),
        progressMax: hours.toDouble(),
      ),
    for (final (index, days) in [monthDays, yearDays].indexed)
      AchievementScenario(
        'workoutFreak',
        index + 1,
        AchievementTrigger.workout,
        locked: AchievementFixture(history: [...days.skip(1), days.last]),
        earned: AchievementFixture(history: days),
        lockedProgress: days.length - 1.0,
        earnedProgress: days.length.toDouble(),
        progressMax: days.length.toDouble(),
      ),
    for (final id in ['trailblazer', 'cycleChampion'])
      for (final (index, km) in [100.0, 500.0, 1000.0].indexed)
        AchievementScenario(
          id,
          index + 1,
          AchievementTrigger.workout,
          locked: travel(km - 0.001, cycling: id == 'cycleChampion'),
          earned: travel(km, cycling: id == 'cycleChampion'),
          lockedProgress: km - 0.001,
          earnedProgress: km,
          progressMax: km,
          alsoLocked: id == 'cycleChampion'
              ? {'running is not cycling': travel(km)}
              : {},
        ),
    for (final (index, multiplier) in [1.0, 1.5, 3.0].indexed)
      AchievementScenario(
        'professionalWeightlifter',
        index + 1,
        AchievementTrigger.workout,
        locked: lifting(80 * multiplier - 0.001, body: 80),
        earned: lifting(80 * multiplier, body: 80),
        alsoLocked: {
          'requires body weight': lifting(80 * multiplier),
          'assisted weight is excluded': lifting(
            80 * multiplier,
            body: 80,
            parameters: GTSetParameters.repsNegWeight,
          ),
          'unfinished sets are excluded': lifting(
            80 * multiplier,
            body: 80,
            done: false,
          ),
        },
        alsoEarned: {
          'pounds in workout and kilograms in measurement': lifting(
            80 * multiplier * 3,
            body: 80,
            unit: Weights.lb,
          ),
        },
      ),
    AchievementScenario(
      'programPlanner',
      1,
      AchievementTrigger.routines,
      locked: AchievementFixture(
        routines: [
          routine(id: 'one'),
          routine(id: 'two'),
        ],
      ),
      earned: AchievementFixture(
        routines: [
          routine(id: 'one'),
          routine(id: 'two'),
          routine(id: 'three'),
        ],
      ),
      lockedProgress: 2,
      earnedProgress: 3,
      progressMax: 3,
    ),
    AchievementScenario(
      'perfectPlanner',
      1,
      AchievementTrigger.routines,
      locked: AchievementFixture(routines: [routine()]),
      earned: AchievementFixture(hasFolders: true),
    ),
    for (final (index, months) in [3, 6, 12].indexed)
      AchievementScenario(
        'routineMaster',
        index + 1,
        AchievementTrigger.workout,
        locked: monthlyRoutine(months - 1),
        earned: monthlyRoutine(months),
        lockedProgress: months - 1.0,
        earnedProgress: months.toDouble(),
        progressMax: months.toDouble(),
      ),
    AchievementScenario(
      'pbBreaker',
      1,
      AchievementTrigger.workout,
      locked: personalBest(newWeight: 50),
      earned: personalBest(),
      alsoLocked: {
        'one workout cannot establish a record': AchievementFixture(
          history: [
            workout(exercises: [strength(60)]),
          ],
        ),
      },
    ),
    AchievementScenario(
      'intensityInnovator',
      1,
      AchievementTrigger.workout,
      locked: AchievementFixture(
        routines: [
          routine(exercises: [strength(70)]),
        ],
        history: personalBest().history,
      ),
      earned: personalBest(),
    ),
    AchievementScenario(
      'completionist',
      1,
      AchievementTrigger.workout,
      locked: libraryCompletion(complete: false),
      earned: libraryCompletion(complete: true),
      lockedProgress: exerciseStandardLibraryAsList.length - 1.0,
      earnedProgress: exerciseStandardLibraryAsList.length.toDouble(),
      progressMax: exerciseStandardLibraryAsList.length.toDouble(),
    ),
    AchievementScenario(
      'notDrunk',
      1,
      AchievementTrigger.workout,
      locked: personalBest(latestDate: DateTime(2024, 6, 9, 12)),
      earned: personalBest(),
      alsoLocked: {
        'Saturday morning is excluded': personalBest(
          latestDate: DateTime(2024, 6, 15, 10),
        ),
        'equal performance is not a record': personalBest(newWeight: 50),
      },
    ),
    AchievementScenario(
      'steamedHams',
      1,
      AchievementTrigger.workout,
      locked: personalBest(oldDuration: const Duration(minutes: 30)),
      earned: personalBest(),
      alsoLocked: {
        'faster without improvement is insufficient': personalBest(
          newWeight: 50,
        ),
      },
    ),
    AchievementScenario(
      'swimsuitSeason',
      1,
      AchievementTrigger.workout,
      locked: seasonal(const Duration(hours: 24)),
      earned: seasonal(const Duration(hours: 24, minutes: 1)),
      lockedProgress: 24,
      earnedProgress: 24 + 1 / 60,
      progressMax: 24,
      alsoLocked: {
        'cardio outside spring is excluded': AchievementFixture(
          history: [
            workout(
              date: DateTime(2024, 1, 1),
              duration: const Duration(hours: 25),
              exercises: [distance(5)],
            ),
          ],
        ),
      },
    ),
    for (final (index, unit) in [Weights.lb, Weights.kg].indexed)
      AchievementScenario(
        'sparta',
        index + 1,
        AchievementTrigger.workout,
        locked: lifting(299.999, unit: unit),
        earned: lifting(300, unit: unit),
        alsoLocked: {
          'assisted weight is excluded': lifting(
            300,
            unit: unit,
            parameters: GTSetParameters.repsNegWeight,
          ),
          'unfinished sets are excluded': lifting(300, unit: unit, done: false),
        },
      ),
    AchievementScenario(
      'midnightRain',
      1,
      AchievementTrigger.workout,
      locked: AchievementFixture(
        history: [
          workout(
            date: DateTime(2024, 6, 15, 23, 30),
            duration: const Duration(minutes: 29, seconds: 59),
          ),
        ],
      ),
      earned: AchievementFixture(
        history: [workout(date: DateTime(2024, 6, 15, 23, 30))],
      ),
    ),
    AchievementScenario(
      'equipmentSpecialist',
      1,
      AchievementTrigger.workout,
      locked: equipment(mixed: true),
      earned: equipment(mixed: false),
    ),
    AchievementScenario(
      'bodyweightBeast',
      1,
      AchievementTrigger.workout,
      locked: bodyweight(30),
      earned: bodyweight(31),
      alsoLocked: {
        'requires a routine': AchievementFixture(
          history: bodyweight(31).history,
        ),
      },
    ),
  ];
}
