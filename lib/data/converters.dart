import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';

extension _String on String {
  String? get camelCase {
    return split(RegExp(r"[^a-zA-Z0-9_\-]+"))
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join();
  }
}

typedef ConvertedHevyWorkoutData = ({
  List<Workout> workouts,
  List<Exercise> customExercises,
});

typedef ConvertedHevyMeasurementData = ({
  List<WeightMeasurement> weightMeasurements,
  List<BodyMeasurement> bodyMeasurements,
});

ConvertedHevyWorkoutData convertHevyWorkoutData(List<List> rowsAsListOfValues) {
  // Workout ID => (Workout Object, List of Exercises)
  Map<String, (Workout, List<Exercise>)> workouts = {};

  // Exercise ID => List of Sets
  Map<String, List<GTSet>> sets = {};

  // Exercise ID => List of RPEs
  Map<String, List<double>> rpes = {};

  // Workout ID => List of Exercise Names (for ID generation purposes)
  Map<String, List<String>> exerciseNames = {};

  // Exercise ID => Exercise Object (to add to the Library)
  Map<String, Exercise> exercisesToAdd = {};

  for (var row in rowsAsListOfValues) {
    final title = row[0];
    final startTime = row[1];
    final endTime = row[2];
    final description = row[3];
    final exerciseTitle = "${row[4]}";
    final supersetID = row[5];
    final exerciseNotes = row[6];
    // final setIndex = row[7];
    final setType = row[8];
    final weightKg = "${row[9] ?? ""}";
    final reps = "${row[10] ?? ""}";
    final distanceKm = "${row[11] ?? ""}";
    final durationSeconds = "${row[12] ?? ""}";
    final rpe = row[13];

    final key = "$title $startTime $endTime";
    final workoutDbKey = "hevy_${key.camelCase!}";

    if (!workouts.containsKey(key)) {
      workouts[key] = (
        Workout(
          id: workoutDbKey,
          name: title,
          exercises: [],
          parentID: null,
          infobox:
              "${description ?? ""}\n\n${"settings.options.import.utils.hevy.notes".t}"
                  .trim(),
          startingDate: _parseHevyDateTime(startTime),
          duration: _parseHevyDateTime(endTime)
              .difference(_parseHevyDateTime(startTime)),
          weightUnit: Weights.kg,
          distanceUnit: Distance.km,
        ),
        [],
      );

      exerciseNames[workouts[key]!.$1.id] = [];
    }

    final parentExerciseDbKey = "hevy_${exerciseTitle.camelCase}";

    if (exerciseNames[workouts[key]!.$1.id]!.isEmpty ||
        exerciseNames[workouts[key]!.$1.id]!.last != exerciseTitle) {
      exerciseNames[workouts[key]!.$1.id]!.add(exerciseTitle);
    }

    final exerciseDbKey =
        "${workoutDbKey}_ex_${parentExerciseDbKey}_${exerciseNames[workouts[key]!.$1.id]!.length}";

    if (workouts[key]!.$2.isEmpty ||
        !workouts[key]!.$2.last.asExercise.name.startsWith(exerciseTitle)) {
      workouts[key]!.$2.add(
            Exercise.custom(
              id: exerciseDbKey,
              parentID: parentExerciseDbKey,
              name:
                  "$exerciseTitle ${"settings.options.import.utils.hevy.titles".t}",
              parameters: _guessParams(
                weight: weightKg,
                reps: reps,
                distance: distanceKm,
                time: durationSeconds,
              ),
              primaryMuscleGroup: GTMuscleGroup.none,
              secondaryMuscleGroups: {},
              sets: [],
              restTime: Duration.zero,
              notes: exerciseNotes,
              supersetID: supersetID == null || "$supersetID".isEmpty
                  ? null
                  : "${workoutDbKey}_superset_$supersetID",
              workoutID: workoutDbKey,
              equipment: GTGymEquipment.none,
            ),
          );

      if (exercisesToAdd[workouts[key]!.$2.last.parentID] == null) {
        exercisesToAdd[workouts[key]!.$2.last.parentID!] =
            workouts[key]!.$2.last.copyWith(
                  id: workouts[key]!.$2.last.parentID,
                  parentID: null,
                  notes: null,
                );
      }
    }

    final kind = _getKind(setType);
    final params = _guessParams(
      weight: weightKg,
      reps: reps,
      distance: distanceKm,
      time: durationSeconds,
    );
    final set = GTSet(
      kind: kind,
      parameters: params,
      weight: weightKg.isNotEmpty ? weightKg.tryParseDouble() : 0,
      reps: reps.isNotEmpty ? reps.tryParseDouble()?.round() : 0,
      distance: distanceKm.isNotEmpty ? distanceKm.tryParseDouble() : 0,
      time: durationSeconds.isNotEmpty
          ? Duration(seconds: durationSeconds.tryParseDouble()?.round() ?? 0)
          : Duration.zero,
      done: true,
    );

    if (sets[exerciseDbKey] == null) {
      sets[exerciseDbKey] = [];
    }
    sets[exerciseDbKey]!.add(set);

    rpes[exerciseDbKey] = rpes[exerciseDbKey] ?? [];
    if (rpe != null && "$rpe".isNotEmpty) {
      rpes[exerciseDbKey]!.add((rpe as num).toDouble());
    }
  }

  final res = <Workout>[];

  for (final workout in workouts.entries) {
    final exs = <WorkoutExercisable>[];
    final supers = <String, List<Exercise>>{};

    for (final e in workout.value.$2) {
      final exerciseParameters =
          _getStrongestParameter(sets[e.id]!.map((e) => e.parameters).toList());
      final obj = e.copyWith(
        sets: sets[e.id]!
            .map((e) => e.copyWith(parameters: exerciseParameters))
            .toList(),
        parameters: _getStrongestParameter(
          sets[e.id]!.map((e) => e.parameters).toList(),
        ),
        rpe: rpes[e.id] == null || rpes[e.id]!.isEmpty
            ? null
            : (rpes[e.id]!.reduce((a, b) => a + b) / rpes[e.id]!.length)
                .round(),
      );

      if (obj.supersetID == null) {
        if (supers.isNotEmpty) {
          exs.add(
            Superset(
              exercises: supers.values.first,
              restTime: supers.values.first.first.restTime,
              workoutID: supers.values.first.first.workoutID,
            ),
          );
          supers.clear();
        }

        exs.add(obj);
      } else {
        supers[obj.supersetID!] = supers[obj.supersetID!] ?? [];
        supers[obj.supersetID!]!.add(obj);
      }
    }

    if (supers.isNotEmpty) {
      exs.add(
        Superset(
          exercises: supers.values.first,
          restTime: supers.values.first.first.restTime,
          workoutID: supers.values.first.first.workoutID,
        ),
      );
      supers.clear();
    }

    res.add(workout.value.$1.copyWith(
      exercises: exs,
    ));
  }

  final customExercises = exercisesToAdd.values.toList();
  return (
    workouts: res,
    customExercises: customExercises,
  );
}

ConvertedHevyMeasurementData convertHevyMeasurementData(
    List<List> rowsAsListOfValues) {
  final now = DateTime.now().millisecondsSinceEpoch;

  // "date","weight_kg","fat_percent","neck_cm","shoulder_cm","chest_cm","left_bicep_cm","right_bicep_cm","left_forearm_cm","right_forearm_cm","abdomen_cm","waist_cm","hips_cm","left_thigh_cm","right_thigh_cm","left_calf_cm","right_calf_cm"
  final weightMeasurements = <WeightMeasurement>[];
  final bodyMeasurements = <BodyMeasurement>[];

  for (var row in rowsAsListOfValues) {
    final date = _parseHevyDateTime("${row[0]}");
    final weightKg = "${row[1]}".tryParseDouble();
    const types = [
      BodyMeasurementPart.bodyFat,
      BodyMeasurementPart.neck,
      BodyMeasurementPart.shoulder,
      BodyMeasurementPart.chest,
      BodyMeasurementPart.leftBicep,
      BodyMeasurementPart.rightBicep,
      BodyMeasurementPart.leftForearm,
      BodyMeasurementPart.rightForearm,
      BodyMeasurementPart.abdomen,
      BodyMeasurementPart.waist,
      BodyMeasurementPart.hips,
      BodyMeasurementPart.leftThigh,
      BodyMeasurementPart.rightThigh,
      BodyMeasurementPart.leftCalf,
      BodyMeasurementPart.rightCalf,
    ];

    if (weightKg != null) {
      weightMeasurements.add(
        WeightMeasurement(
          id: "hevy_wt_${date.millisecondsSinceEpoch}_$now",
          time: date,
          weight: weightKg,
          weightUnit: Weights.kg,
        ),
      );
    }

    for (int i = 0; i < types.length; i++) {
      final value = "${row[i + 2]}".tryParseDouble();

      if (value == null) continue;

      bodyMeasurements.add(
        BodyMeasurement(
          id: "hevy_bm_${date.millisecondsSinceEpoch}_$now",
          time: date,
          value: value,
          type: types[i],
        ),
      );
    }
  }

  return (
    weightMeasurements: weightMeasurements,
    bodyMeasurements: bodyMeasurements,
  );
}

// Parses "16 Mar 2024, 09:50"
DateTime _parseHevyDateTime(String dateTime) {
  final parts = dateTime.split(" ");
  final day = int.parse(parts[0]);
  final month = parts[1];
  final year = int.parse(parts[2].split(",")[0]);
  final time = parts[3];
  final hour = int.parse(time.split(":")[0]);
  final minute = int.parse(time.split(":")[1]);

  return DateTime(
    year,
    {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,
    }[month]!,
    day,
    hour,
    minute,
  );
}

GTSetParameters _guessParams({
  required String weight,
  required String reps,
  required String distance,
  required String time,
}) {
  if (time.isNotEmpty) {
    if (weight.isNotEmpty) {
      return GTSetParameters.timeWeight;
    } else {
      return GTSetParameters.time;
    }
  } else if (reps.isNotEmpty) {
    if (weight.isNotEmpty) {
      return GTSetParameters.repsWeight;
    } else {
      return GTSetParameters.freeBodyReps;
    }
  } else if (distance.isNotEmpty) {
    return GTSetParameters.distance;
  }

  throw "Could not guess parameters for wt: $weight, reps: $reps, dist: $distance, time: $time";
}

GTSetKind _getKind(String setType) {
  switch (setType) {
    case "warmup":
      return GTSetKind.warmUp;
    case "failure":
      return GTSetKind.failure;
    case "dropset":
      return GTSetKind.drop;
    case "normal":
    default:
      return GTSetKind.normal;
  }
}

/// Returns the strongest parameter from a list of parameters
///
/// For example, if the list contains [freeBodyReps, repsWeight],
/// it will return repsWeight.
///
/// Throws an error if the list is empty, or if it contains
/// incompatible parameters.
GTSetParameters _getStrongestParameter(List<GTSetParameters> params) {
  if (params.isEmpty) {
    throw "No parameters to choose from";
  }

  if (params.length == 1) {
    return params.first;
  }

  GTSetParameters strongest = params.first;

  const compatible = {
    GTSetParameters.freeBodyReps: GTSetParameters.repsWeight,
    GTSetParameters.time: GTSetParameters.timeWeight,
  };

  for (final param in params) {
    if (param == strongest) continue;

    // Upgrade the strongest parameter if the current one is compatible
    if (compatible[strongest] == param) {
      strongest = compatible[strongest]!;
    } else {
      throw "Incompatible parameters: $params";
    }
  }

  return strongest;
}
