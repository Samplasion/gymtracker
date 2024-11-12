import 'dart:convert';
import 'dart:ui';

import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/model.dart';

class BoutiqueSettings {
  final String compatibility;

  BoutiqueSettings({
    required this.compatibility,
  });

  factory BoutiqueSettings.fromJson(Map<String, dynamic> json) {
    return BoutiqueSettings(
      compatibility: json['compatibility'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compatibility': compatibility,
    };
  }
}

class BoutiqueCategory {
  final String id;
  final Map<String, String> name;
  final String? icon;
  final Color? color;
  final bool isHidden;

  const BoutiqueCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.isHidden = false,
  });

  factory BoutiqueCategory.fromJson(Map<String, dynamic> json) {
    return BoutiqueCategory(
      id: json['id'],
      name: Map<String, String>.from(json['name']),
      icon: json['icon'],
      color: json['color'] != null ? Color(json['color']) : null,
      isHidden: json['is_hidden'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color?.value,
      'is_hidden': isHidden,
    };
  }
}

class BoutiquePackage {
  final String id;
  final String name;
  final String description;
  final List<Workout> routines;

  const BoutiquePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.routines,
  });

  factory BoutiquePackage.fromJson(Map<String, dynamic> json, String language) {
    return BoutiquePackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      routines: (json['routines'] as List).map((e) {
        final exercises = databaseExercisesToExercises((e['exercises'] as List)
            .map((e) => ConcreteExercise(
                  id: e['id'],
                  routineId: e['routine_id'],
                  name: "${e['name']}",
                  parameters: GTSetParameters.values.byName(e['parameters']),
                  sets: (e['sets'] as List)
                      .map((e) => GTSet.fromJson(e))
                      .toList(),
                  primaryMuscleGroup: e['is_superset'] == 1 ? null: 
                      GTMuscleGroup.values.byName(e['primary_muscle_group']),
                  secondaryMuscleGroups: {
                    if (e['secondary_muscle_groups'] != null)
                      for (final e in jsonDecode(e['secondary_muscle_groups']))
                        GTMuscleGroup.values.byName(e),
                  },
                  restTime: e['rest_time'],
                  isCustom: false,
                  libraryExerciseId: e['library_exercise_id'],
                  customExerciseId: null,
                  notes: e['notes'],
                  isSuperset: e['is_superset'] == 1,
                  isInSuperset: e['is_in_superset'] == 1,
                  supersetId: e['superset_id'],
                  sortOrder: e['sort_order'],
                  supersedesId: null,
                  rpe: null,
                  equipment: e['is_superset'] == 1 ? null :
                  GTGymEquipment.values.byName(e['equipment']),
                ))
            .toList());
        return Workout.fromJson({
          ...e,
          'exercises': [],
        }.cast<String, dynamic>())
            .copyWith(exercises: exercises);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'routines': routines.map((e) => e.toJson()).toList(),
    };
  }
}
