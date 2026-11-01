import 'dart:convert';

/// Wire v1: whole-set replacements, phone-owned structure, millisecond stamps.
/// Unknown exercise/set fields survive round trips through both native apps.
class WearableTrainingDocument {
  static const version = 1;
  static Map<String, dynamic> copy(Map value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

  static List<Map<String, dynamic>> exercises(Map document) => [
    for (final group in document['exercises'] as List? ?? const [])
      if (group['type'] == 'superset')
        for (final child in group['exercises'] as List)
          Map<String, dynamic>.from(child)
      else
        Map<String, dynamic>.from(group),
  ];

  static Object? _ordered(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      // Property-list transports omit JSON null dictionary fields. Restoring
      // defaults on Flutter is not a new phone edit and must not win over an
      // offline wearable result merely because it happened at launch time.
      return {
        for (final key in keys)
          if (value[key] != null) key: _ordered(value[key]),
      };
    }
    if (value is List) return value.map(_ordered).toList();
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      return value.toInt();
    }
    return value;
  }

  static String canonical(Object? value) => jsonEncode(_ordered(value));

  static String _setContent(Map? value) => canonical(
    value == null
        ? null
        : {
            ...value,
            // Flutter's model restores nullable/absent numeric parameters as zero.
            for (final key in ['reps', 'weight', 'time', 'distance'])
              key: value[key] ?? 0,
            'done': value['done'] ?? false,
          },
  );

  static String structure(Map exercise) => canonical({
    for (final key in [
      'id',
      'name',
      'parameters',
      'parentID',
      'supersedesID',
      'supersetID',
      'restTime',
      'notes',
      'progression',
      'primaryMuscleGroup',
      'secondaryMuscleGroups',
      'category',
      'equipment',
    ])
      key: exercise[key],
    'sets': [
      for (final set in exercise['sets'] as List)
        {'id': set['id'], 'parameters': set['parameters'], 'kind': set['kind']},
    ],
  });

  static Map<String, String> structuresIn(Map document) {
    final result = <String, String>{};
    for (final group in document['exercises'] as List? ?? []) {
      final children = group['type'] == 'superset'
          ? group['exercises'] as List
          : [group];
      for (final child in children) {
        result[child['id'] as String] = jsonEncode({
          'exercise': structure(child as Map),
          'group': group['id'],
          if (group['type'] == 'superset')
            'members': [for (final member in children) member['id']],
          'rest': group['restTime'],
        });
      }
    }
    return result;
  }

  static Map<String, dynamic> capture(
    Map<String, dynamic> next,
    Map<String, dynamic>? previous,
    int now,
  ) {
    final result = copy(next);
    final stamps = Map<String, dynamic>.from(previous?['stamps'] as Map? ?? {});
    final old = {for (final e in exercises(previous ?? {})) e['id']: e};
    final beforeStructures = structuresIn(previous ?? {});
    final nextStructures = structuresIn(result);
    final structures = Map<String, dynamic>.from(
      previous?['structures'] as Map? ?? {},
    );
    var changed =
        previous == null ||
        canonical(beforeStructures.keys.toList()..sort()) !=
            canonical(nextStructures.keys.toList()..sort());
    for (final exercise in exercises(result)) {
      final id = exercise['id'] as String;
      final before = old[id];
      final changedStructure =
          before == null || beforeStructures[id] != nextStructures[id];
      if (changedStructure) {
        changed = true;
        structures[id] = '${now}_${(previous?['sequence'] as int? ?? 0) + 1}';
      }
      final oldSets = {
        for (final s in before?['sets'] as List? ?? []) s['id']: s,
      };
      for (final set in exercise['sets'] as List) {
        if (changedStructure ||
            _setContent(oldSets[set['id']] as Map?) !=
                _setContent(set as Map)) {
          changed = true;
          stamps[set['id']] = {
            'time': now,
            'device': 'phone',
            'sequence': (previous?['sequence'] as int? ?? 0) + 1,
          };
        }
      }
    }
    result['structures'] = structures;
    result['stamps'] = stamps;
    for (final key in [
      'cursor',
      'restStart',
      'restEnd',
      'name',
      'status',
      'globalStopwatchPaused',
      'globalStopwatchNominalDuration',
    ]) {
      if ((key == 'restStart' || key == 'restEnd') &&
          result['restEnd'] == null &&
          previous?['restEnd'] is num &&
          (previous!['restEnd'] as num) <= now) {
        // An elapsed countdown disappearing on launch is not a navigation edit.
        continue;
      }
      if (canonical(result[key]) != canonical(previous?[key])) changed = true;
    }
    result['sequence'] =
        (previous?['sequence'] as int? ?? 0) + (changed ? 1 : 0);
    result['epoch'] = previous?['epoch'] ?? 0;
    // Reading/restoring an unchanged ongoing is not a new phone operation.
    // Otherwise a cold launch steals cursor/rest ownership from offline edits.
    result['modified'] = changed ? now : previous?['modified'] ?? now;
    return result;
  }

  static bool newer(Map? watch, Map? phone) {
    if (watch == null) return false;
    if (phone == null) return true;
    final time = (watch['time'] as num).compareTo(phone['time'] as num);
    if (time != 0) return time > 0;
    if (watch['device'] != phone['device']) return watch['device'] == 'phone';
    return (watch['sequence'] as num).compareTo(phone['sequence'] as num) > 0;
  }

  static Map<String, dynamic> merge(
    Map<String, dynamic> phone,
    Map<String, dynamic> incomingWatch,
  ) {
    // StandardMessageCodec decodes nested dictionaries as Map<Object?, Object?>.
    // A whole-set replacement must be detached JSON too, otherwise it reintroduces
    // those maps into the copied phone document and generated fromJson casts fail.
    final watch = copy(incomingWatch);
    if (phone['id'] != watch['id'] ||
        phone['ownerScope'] != watch['ownerScope']) {
      throw StateError('Cannot merge different workout identities');
    }
    final result = copy(phone);
    final incoming = {for (final e in exercises(watch)) e['id']: e};
    final stamps = Map<String, dynamic>.from(phone['stamps'] as Map? ?? {});
    final remoteStamps = watch['stamps'] as Map? ?? {};
    final structures = phone['structures'] as Map? ?? {};
    final remoteStructures = watch['structures'] as Map? ?? {};
    void mergeExercise(Map exercise) {
      final remote = incoming[exercise['id']];
      if (remote == null ||
          structures[exercise['id']] != remoteStructures[exercise['id']]) {
        return;
      }
      final remoteSets = {for (final s in remote['sets'] as List) s['id']: s};
      final sets = exercise['sets'] as List;
      for (var i = 0; i < sets.length; i++) {
        final id = sets[i]['id'];
        if (remoteSets[id] != null &&
            (phone['status'] == 'active' ||
                ((remoteStamps[id] as Map?)?['time'] as num? ?? 0) <=
                    (phone['end'] as num? ?? 0)) &&
            newer(remoteStamps[id] as Map?, stamps[id] as Map?)) {
          sets[i] = remoteSets[id];
          stamps[id] = remoteStamps[id];
        }
      }
    }

    for (final group in result['exercises'] as List) {
      if (group['type'] == 'superset') {
        for (final child in group['exercises'] as List) {
          mergeExercise(child as Map);
        }
      } else {
        mergeExercise(group as Map);
      }
    }
    result['stamps'] = stamps;
    for (final key in ['sequence', 'epoch']) {
      final local = phone[key] as int? ?? 0;
      final remote = watch[key] as int? ?? 0;
      result[key] = local > remote ? local : remote;
    }
    if ((watch['modified'] as num? ?? 0) > (phone['modified'] as num? ?? 0)) {
      for (final key in ['cursor', 'restStart', 'restEnd', 'modified']) {
        result[key] = watch[key];
      }
    }
    // Completion/discard cannot be undone by a late active snapshot.
    if (phone['status'] == 'active' && watch['status'] != 'active') {
      result['status'] = watch['status'];
      result['end'] = watch['end'];
      result['duration'] = watch['duration'];
    }
    return result;
  }
}
