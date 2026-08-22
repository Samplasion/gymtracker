import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/utils/utils.dart' show reorderNew;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routines.g.dart';

class RoutinesRepository {
  final GTDatabase _db;
  RoutinesRepository(this._db);

  Stream<List<Workout>> watchRoutines() {
    return _db.getAllRoutines();
  }

  Stream<List<GTRoutineFolder>> watchFolders() {
    return _db.watchRoutineFolders();
  }

  Future<void> addRoutine(Workout routine) {
    return _db.insertRoutine(routine);
  }

  Future<void> editRoutine(Workout routine) {
    return _db.updateRoutine(routine);
  }

  Future<void> deleteRoutine(String id) {
    return _db.deleteRoutine(id);
  }

  Future<void> moveRoutineToFolder(Workout routine, GTRoutineFolder? folder) {
    return _db.updateRoutine(routine.copyWith.folder(folder));
  }

  Future<void> updateFolder(GTRoutineFolder folder) {
    return _db.updateRoutineFolder(folder);
  }

  Future<void> reorderFolder(
    GTRoutineFolder? folder,
    int oldIndex,
    int newIndex,
  ) async {
    var allRoutines = (await _db.getAllRoutinesFuture());
    var thisFoldersRoutines = allRoutines
        .where((routine) => routine.folder?.id == folder?.id)
        .toList();
    var otherRoutines = allRoutines
        .where((routine) => routine.folder?.id != folder?.id)
        .toList();
    reorderNew(thisFoldersRoutines, oldIndex, newIndex);
    return _db.writeAllRoutines([...thisFoldersRoutines, ...otherRoutines]);
  }
}

// Expose the repository
@Riverpod(keepAlive: true)
RoutinesRepository routinesRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoutinesRepository(db);
}
