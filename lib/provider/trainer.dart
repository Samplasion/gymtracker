import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final trainerServiceProvider = Provider<TrainerService>(
  (ref) =>
      TrainerService(ref.watch(appDatabaseProvider), Supabase.instance.client),
);
final trainerStateProvider = StreamProvider<TrainerState>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final owner = ref.watch(currentUserIdProvider);
  if (owner == null) {
    yield TrainerState.empty;
    return;
  }
  yield await db.trainerState();
  // Refresh is also performed before sync, covering screens outside this page.

  final table = db.allTables.firstWhere(
    (t) => t.actualTableName == 'trainer_caches',
  );
  await for (final _
      in db
          .customSelect(
            'SELECT payload FROM trainer_caches WHERE owner = ?',
            variables: [Variable(owner)],
            readsFrom: {table},
          )
          .watch()) {
    if (db.currentUserId != owner) return;
    yield await db.trainerState();
  }
});

/// Subscribe for rebuilds; use only the current owner's hydrated snapshot.
bool trainerControls(WidgetRef ref, String? id) {
  ref.watch(trainerStateProvider);
  return id != null &&
      ref.watch(appDatabaseProvider).cachedTrainerState.controls.contains(id);
}

bool trainerProtectsExercise(WidgetRef ref, String? id) {
  ref.watch(trainerStateProvider);
  return id != null &&
      ref
          .watch(appDatabaseProvider)
          .cachedTrainerState
          .protectedExercises
          .contains(id);
}

/// UI state survives page reloads in this app session, isolated by account and
/// relationship. Folder IDs keep expansion attached to the same folder on sort.
final trainerFolderExpansionProvider =
    NotifierProvider<
      TrainerFolderExpansion,
      Map<(String, String), Set<String>>
    >(TrainerFolderExpansion.new);

class TrainerFolderExpansion
    extends Notifier<Map<(String, String), Set<String>>> {
  @override
  Map<(String, String), Set<String>> build() => {};

  void setExpanded(String owner, String link, String folder, bool expanded) {
    final key = (owner, link);
    final folders = {...?state[key]};
    if (expanded) {
      folders.add(folder);
    } else {
      folders.remove(folder);
    }
    state = {...state, key: folders};
  }
}
