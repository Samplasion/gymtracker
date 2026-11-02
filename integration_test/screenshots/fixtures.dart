import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';

class ScreenshotFixtures {
  ScreenshotFixtures(this.language, this.now);
  final String language;
  final DateTime now;
  String tr(String it, String en) => language == 'it' ? it : en;
  late final folders = [
    GTRoutineFolder(
      id: 'demo-folder-strength',
      name: tr('Forza e potenza', 'Strength and power'),
      sortOrder: 0,
      notes: '',
    ),
    GTRoutineFolder(
      id: 'demo-folder-control',
      name: tr('Tecnica e controllo', 'Technique and control'),
      sortOrder: 1,
      notes: '',
    ),
  ];
  late final routines = [
    for (var day = 0; day < 3; day++)
      Workout(
        id: 'demo-routine-$day',
        folder: day == 0 ? null : folders[day - 1],
        name: [
          tr('Spinta · Forza', 'Push · Strength'),
          tr('Gambe · Potenza', 'Legs · Power'),
          tr('Trazione · Controllo', 'Pull · Control'),
        ][day],
        exercises: exercises('demo-routine-$day', day: day),
      ),
  ];
  List<Exercise> exercises(
    String owner, {
    int week = 11,
    int day = 0,
    bool done = false,
  }) {
    final names = [
      tr('Panca piana', 'Bench press'),
      tr('Squat con bilanciere', 'Barbell squat'),
      tr('Stacco da terra', 'Deadlift'),
    ];
    final ids = [
      GTStandardLibrary.chest.barbellBenchPressFlat,
      GTStandardLibrary.quadriceps.squatsBarbell,
      GTStandardLibrary.back.deadlift,
    ];
    return [
      for (var i = 0; i < 3; i++)
        Exercise.custom(
          id: '$owner-ex-$i',
          name: names[(i + day) % 3],
          parentID: ids[(i + day) % 3],
          parameters: GTSetParameters.repsWeight,
          primaryMuscleGroup: [
            GTMuscleGroup.chest,
            GTMuscleGroup.quadriceps,
            GTMuscleGroup.lats,
          ][(i + day) % 3],
          restTime: const Duration(seconds: 90),
          notes: '',
          supersetID: null,
          workoutID: owner,
          equipment: GTGymEquipment.barbell,
          sets: [
            for (var s = 0; s < 3; s++)
              GTSet(
                id: '$owner-$i-$s',
                kind: GTSetKind.normal,
                parameters: GTSetParameters.repsWeight,
                reps: 8,
                weight: 45.0 + week * 2.5 + i * 10,
                done: done || (i == 0 && s == 0),
              ),
          ],
        ),
    ];
  }

  late final history = [
    for (var week = 0; week < 12; week++)
      for (var day = 0; day < 3; day++)
        Workout(
          id: 'demo-history-$week-$day',
          name: routines[day].name,
          parentID: routines[day].id,
          exercises: exercises(
            'demo-history-$week-$day',
            week: week,
            day: day,
            done: true,
          ),
          startingDate: now.subtract(
            Duration(days: (11 - week) * 7 + 6 - day * 2, hours: 1),
          ),
          duration: Duration(minutes: 48 + day * 4),
        ),
  ];
  late final weights = [
    for (var week = 0; week < 12; week++)
      WeightMeasurement(
        id: 'demo-weight-$week',
        weight: 82 - week * .3,
        time: now.subtract(Duration(days: (11 - week) * 7)),
        weightUnit: Weights.kg,
        updatedAt: now,
      ),
  ];
  TrainerState get trainer => TrainerState(
    link: {'id': 'demo-link', 'trainer_name': 'Alex Morgan'},
    controls: {routines.first.id},
    shares: [
      {'routine_id': routines.last.id},
    ],
  );
  Future<void> seed(DatabaseService service) async {
    for (final folder in folders) {
      await service.addFolder(folder);
    }
    await service.setAllRoutines(routines);
    await service.writeAllHistory(history);
    await service.addWeightMeasurements(weights);
    // All measurement selectors have real history, including paired limbs.
    const baseline = [
      88.0,
      19.0,
      38.0,
      116.0,
      101.0,
      34.0,
      34.5,
      28.0,
      28.5,
      90.0,
      99.0,
      58.0,
      58.5,
      38.0,
      38.5,
    ];
    await service.addBodyMeasurements([
      for (final part in BodyMeasurementPart.values)
        for (var week = 0; week < 12; week++)
          BodyMeasurement(
            id: 'demo-${part.name}-$week',
            value:
                baseline[part.index] +
                week *
                    (switch (part) {
                      BodyMeasurementPart.waist ||
                      BodyMeasurementPart.abdomen => -.4,
                      BodyMeasurementPart.bodyFat => -.2,
                      BodyMeasurementPart.hips => -.15,
                      _ => .1,
                    }),
            type: part,
            time: now.subtract(Duration(days: (11 - week) * 7)),
            updatedAt: now,
          ),
    ]);
    await service.addNutritionGoal(
      TaggedNutritionGoal(
        date: DateTime(2026, 1, 1),
        value: const NutritionGoal(
          dailyCalories: 2400,
          dailyFat: 80,
          dailyCarbs: 270,
          dailyProtein: 150,
          dailyWater: 2500,
        ),
      ),
    );
    final breakfast = tr('Colazione', 'Breakfast');
    final lunch = tr('Pranzo', 'Lunch');
    await service.setNutritionCategoriesForDay(DateTime(2026, 1, 1), {
      breakfast: NutritionCategory(
        name: breakfast,
        dailyPercentage: 30,
        icon: NutritionCategoryIcon.fork_and_spoon,
      ),
      lunch: NutritionCategory(
        name: lunch,
        dailyPercentage: 40,
        icon: NutritionCategoryIcon.fork_and_spoon,
      ),
      tr('Cena', 'Dinner'): NutritionCategory(
        name: tr('Cena', 'Dinner'),
        dailyPercentage: 30,
        icon: NutritionCategoryIcon.fork_and_spoon,
      ),
    });
    final meals = [
      (
        tr('Yogurt greco', 'Greek yogurt'),
        breakfast,
        200.0,
        97.0,
        9.0,
        4.0,
        5.0,
      ),
      (
        tr('Fiocchi di avena', 'Rolled oats'),
        breakfast,
        80.0,
        375.0,
        13.0,
        60.0,
        7.0,
      ),
      (tr('Riso basmati', 'Basmati rice'), lunch, 100.0, 350.0, 8.0, 77.0, 1.0),
      (
        tr('Petto di pollo', 'Chicken breast'),
        lunch,
        180.0,
        165.0,
        31.0,
        0.0,
        3.6,
      ),
    ];
    for (var day = 0; day < 14; day++) {
      for (var i = 0; i < meals.length; i++) {
        final m = meals[i];
        await service.addFood(
          DateTagged(
            date: DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(Duration(days: day)),
            value: Food(
              id: 'demo-food-$day-$i',
              name: m.$1,
              category: m.$2,
              amount: m.$3,
              nutritionalValuesPer100g: NutritionValues(
                sugar: 0,
                saturatedFat: 0,
                calories: m.$4,
                protein: m.$5,
                carbs: m.$6,
                fat: m.$7,
              ),
            ),
          ),
        );
      }
    }
  }

  List<AchievementCompletion> completions(List<TaggedFood> foods) {
    final catalog = AchievementRules(
      clock: () => now,
      history: () => history,
      routines: () => routines,
      weights: () => weights,
      foods: () => foods,
    ).catalog;
    return [
      for (final achievement in catalog.values)
        for (final level in achievement.levels)
          if (level.checkCompletion(level.progress?.call()))
            AchievementCompletion(
              id: 'demo-${achievement.id}-${level.level}',
              achievementID: achievement.id,
              level: level.level,
              completedAt: now.subtract(const Duration(days: 1)),
            ),
    ];
  }
}
