import 'dart:convert';
import 'dart:ui';

import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/extensions.dart';

String _localizedBoutiqueText(Object? value, String language) {
  if (value == null) return '';
  Object? decoded = value;
  if (value is String) {
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return value;
    }
  }
  if (decoded is Map) {
    return (decoded[language] ?? decoded['en'] ?? '').toString();
  }
  return decoded is String ? decoded : value.toString();
}

List<dynamic> _boutiqueList(Object? value) {
  if (value is List) return value;
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is List) return decoded;
  }
  return [];
}

bool _boutiqueFlag(Object? value) => value == true || value == 1;

class BoutiqueSettings {
  final String compatibility;
  final bool enabled;

  const BoutiqueSettings({required this.compatibility, required this.enabled});

  static const defaultSettings = BoutiqueSettings(
    compatibility: "0.0.0",
    enabled: false,
  );

  factory BoutiqueSettings.fromJson(Map<String, dynamic> json) {
    return BoutiqueSettings(
      compatibility: json['compatibility'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'compatibility': compatibility, 'enabled': enabled};
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
      'color': color?.hexValue,
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
      name: _localizedBoutiqueText(json['name'], language),
      description: _localizedBoutiqueText(json['description'], language),
      routines: ((json['routines'] ?? json['boutique_routines']) as List).map((
        e,
      ) {
        final routine = (e as Map).cast<String, dynamic>();
        final exercises = databaseExercisesToExercises(
          ((routine['exercises'] ?? routine['boutique_routine_exercises'])
                  as List)
              .map((rawExercise) {
                final exercise = (rawExercise as Map).cast<String, dynamic>();
                final isSuperset = _boutiqueFlag(exercise['is_superset']);
                return ConcreteExercise(
                  id: exercise['id'],
                  routineId: exercise['routine_id'],
                  name: _localizedBoutiqueText(exercise['name'], language),
                  parameters: isSuperset
                      ? null
                      : GTSetParameters.values.byName(exercise['parameters']),
                  sets: _boutiqueList(exercise['sets'])
                      .map(
                        (set) => GTSet.fromJson(
                          (set as Map).cast<String, dynamic>(),
                        ),
                      )
                      .toList(),
                  primaryMuscleGroup: isSuperset
                      ? null
                      : GTMuscleGroup.values.byName(
                          exercise['primary_muscle_group'],
                        ),
                  secondaryMuscleGroups: {
                    for (final group in _boutiqueList(
                      exercise['secondary_muscle_groups'],
                    ))
                      GTMuscleGroup.values.byName(group as String),
                  },
                  restTime: exercise['rest_time'],
                  isCustom: _boutiqueFlag(exercise['is_custom']),
                  libraryExerciseId: exercise['library_exercise_id'],
                  customExerciseId: exercise['custom_exercise_id'],
                  notes: _localizedBoutiqueText(exercise['notes'], language),
                  isSuperset: isSuperset,
                  isInSuperset: _boutiqueFlag(exercise['is_in_superset']),
                  supersetId: exercise['superset_id'],
                  sortOrder: exercise['sort_order'],
                  supersedesId: exercise['supersedes_id'],
                  rpe: exercise['rpe'],
                  progression: parseExerciseProgression(
                    exercise['progression'],
                  ),
                  equipment: isSuperset
                      ? null
                      : GTGymEquipment.values.byName(exercise['equipment']),
                );
              })
              .toList(),
        );
        return Workout.fromJson({
          ...routine,
          'name': _localizedBoutiqueText(routine['name'], language),
          'infobox': _localizedBoutiqueText(routine['infobox'], language),
          'weightUnit': routine['weightUnit'] ?? routine['weight_unit'],
          'distanceUnit': routine['distanceUnit'] ?? routine['distance_unit'],
          'exercises': [],
        }).copyWith(exercises: exercises);
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
