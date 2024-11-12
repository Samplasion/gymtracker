import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/boutique_debug_converter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BoutiqueController extends GetxController with ServiceableController {
  final _BoutiqueRepository _repository = _BoutiqueRepositoryImpl();

  Future<void> _checkVersion() async {
    final settings = await _repository.getSettings();
    final range = VersionConstraint.parse(settings.compatibility);
    if (!range.allows(Version.parse(VersionService().packageInfo.version))) {
      throw BoutiqueError.version;
    }
  }

  BoutiqueApiResponse<List<BoutiqueCategory>> getCategories() async {
    try {
      await _checkVersion();
      final response = await _repository.getCategories();
      return BoutiqueResponse.success(response);
    } catch (e, s) {
      logger.e("ERROR", error: e, stackTrace: s);
      return BoutiqueResponse.error(
          e is BoutiqueError ? e : BoutiqueError.unknown);
    }
  }

  BoutiqueApiResponse<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  }) async {
    try {
      await _checkVersion();
      final response =
          await _repository.getPackages(categoryId, language: language);
      return BoutiqueResponse.success(response);
    } catch (e, s) {
      logger.e("ERROR", error: e, stackTrace: s);
      return BoutiqueResponse.error(
          e is BoutiqueError ? e : BoutiqueError.unknown);
    }
  }

  void install(BoutiquePackage package) {
    coordinator.installRoutines(package.routines);
    Go.popUntil((route) => route.isFirst);
    Go.snack("boutique.package.installed".t);
  }

  void routineConverter(String categoryID) async {
    final packages = (await getPackages(categoryID, language: 'en')).success!;
    Go.to(() => BoutiqueDebugConverter(
          packages: packages,
          onPicked: (routine, package) {
            final packageID = package.id;
            final sql = _boutiqueSql(routine, packageID);
            Clipboard.setData(ClipboardData(text: sql));
          },
        ));
  }

  String _boutiqueSql(Workout routine, String packageID) {
    String _generateUUID() {
      return const Uuid().v4();
    }

    final routineID = _generateUUID();

    String result = '';
    result += """
INSERT INTO
  boutique_routines (
    id,
    name,
    infobox,
    weight_unit,
    distance_unit,
    sort_order,
    package_id
  )
values
  (
    '$routineID',
    '{"en":"${routine.name}"}',
    '{"en":${routine.infobox == null ? '""' : jsonEncode(routine.infobox)}}',
    '${routine.weightUnit.name}',
    '${routine.distanceUnit.name}',
    0,
    '$packageID'
  );
  """;

    void _handleExercise(Exercise exercise, Superset? superset, int sortOrder) {
      result += """
INSERT INTO boutique_routine_exercises (
  id,
  routine_id,
  name,
  parameters,
  sets,
  primary_muscle_group,
  secondary_muscle_groups,
  rest_time,
  is_custom,
  library_exercise_id,
  notes,
  is_superset,
  is_in_superset,
  superset_id,
  sort_order,
  supersedes_id,
  rpe,
  equipment
) values (
  '${_generateUUID()}',
  '$routineID',
  '{"en":"${exercise.name}"}',
  '${exercise.parameters.name}',
  '${jsonEncode(exercise.sets.map((s) => s.copyWith(
                id: _generateUUID(),
                weight: 0,
              )).toList())}',
  '${exercise.primaryMuscleGroup.name}',
  '${jsonEncode(exercise.secondaryMuscleGroups.map((e) => e.name).toList())}',
  ${exercise.restTime.inSeconds},
  0,
  '${exercise.parentID!}',
  '${exercise.notes.isEmpty ? "{}" : exercise.notes}',
  0,
  ${superset == null ? 0 : 1},
  ${superset == null ? 'NULL' : "'${superset.id}'"},
  $sortOrder,
  NULL,
  NULL,
  '${exercise.gymEquipment.name}'
);\n\n""";
    }

    final flattened = routine.exercises;

    for (int i = 0; i < flattened.length; i++) {
      final exercise = flattened[i];
      if (exercise is Exercise) {
        _handleExercise(exercise, null, i);
      } else {
        final superset = exercise as Superset;
        final supersetID = _generateUUID();
        result += """
INSERT INTO boutique_routine_exercises (
  id,
  routine_id,
  name,
  parameters,
  sets,
  primary_muscle_group,
  secondary_muscle_groups,
  rest_time,
  is_custom,
  library_exercise_id,
  notes,
  is_superset,
  is_in_superset,
  superset_id,
  sort_order,
  supersedes_id,
  rpe,
  equipment
) values (
  '$supersetID',
  '$routineID',
  '{}',
  'repsWeight',
  '[]',
  '',
  '[]',
  ${superset.restTime.inSeconds},
  0,
  NULL,
  '${superset.notes.isEmpty ? "{}" : superset.notes}',
  1,
  0,
  NULL,
  $i,
  NULL,
  NULL,
  NULL
);\n\n""";

        for (int j = 0; j < superset.exercises.length; j++) {
          _handleExercise(
              superset.exercises[j], superset.copyWith.id(supersetID), j);
        }
      }
    }

    return result;
  }

  @override
  void onServiceChange() {}
}

typedef BoutiqueApiResponse<T> = Future<BoutiqueResponse<T, BoutiqueError>>;

enum BoutiqueError {
  unknown,
  version,
}

sealed class BoutiqueResponse<Ok, Error> {
  const BoutiqueResponse();

  factory BoutiqueResponse.success(Ok data) => _BoutiqueResponseSuccess(data);
  factory BoutiqueResponse.error(Error error) => _BoutiqueResponseError(error);

  Ok? get success => this is _BoutiqueResponseSuccess
      ? (this as _BoutiqueResponseSuccess).data
      : null;
  Error? get error => this is _BoutiqueResponseError
      ? (this as _BoutiqueResponseError).error
      : null;

  bool get isSuccess => this is _BoutiqueResponseSuccess;
  bool get isError => this is _BoutiqueResponseError;
}

class _BoutiqueResponseSuccess<T> extends BoutiqueResponse<T, Never> {
  final T data;

  _BoutiqueResponseSuccess(this.data);
}

class _BoutiqueResponseError<T> extends BoutiqueResponse<Never, T> {
  @override
  final T error;

  _BoutiqueResponseError(this.error);
}

abstract class _BoutiqueRepository {
  Future<BoutiqueSettings> getSettings();
  Future<List<BoutiqueCategory>> getCategories();
  Future<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  });
}

class _BoutiqueRepositoryImpl implements _BoutiqueRepository {
  final _db = Supabase.instance.client;

  @override
  Future<BoutiqueSettings> getSettings() async {
    final response = await _db.from('boutique_settings').select().single();
    return BoutiqueSettings.fromJson(response);
  }

  @override
  Future<List<BoutiqueCategory>> getCategories() async {
    final response = await _db
        .from('boutique_categories')
        .select()
        .order('order', ascending: true);
    return response.map((e) => BoutiqueCategory.fromJson(e)).toList();
  }

  @override
  Future<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  }) async {
    final response = await _db
        .from('boutique_packages')
        .select("*, boutique_routines(*, boutique_routine_exercises(*))")
        .eq('category_id', categoryId);
    return response
        .map((e) {
          return {
            ...e,
            'name': e['name'][language] ?? e['name']['en'] ?? "",
            'description':
                e['description'][language] ?? e['description']['en'] ?? "",
            'routines': [
              for (final json in e['boutique_routines'])
                {
                  ...json,
                  'name': json['name'][language] ?? json['name']['en'] ?? "",
                  'infobox':
                      json['infobox'][language] ?? json['infobox']['en'] ?? "",
                  'exercises': [
                    for (final json in json['boutique_routine_exercises'])
                      {
                        ...json,
                        'type':
                            json['is_superset'] == 1 ? 'superset' : 'exercise',
                        'name':
                            json['name'][language] ?? json['name']['en'] ?? "",
                        'notes': json['notes']?[language] ??
                            json['notes']?['en'] ??
                            "",
                        'sets': jsonDecode(json['sets']),
                      }.cast<String, dynamic>(),
                  ],
                },
            ],
          };
        })
        .map((e) => BoutiquePackage.fromJson(e, language))
        .toList();
  }
}
