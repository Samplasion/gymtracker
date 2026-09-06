import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/repository/routines.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routines.g.dart';

@riverpod
Stream<List<Workout>> routinesStream(Ref ref) {
  return ref.watch(routinesRepositoryProvider).watchRoutines();
}

@riverpod
Stream<List<GTRoutineFolder>> foldersStream(Ref ref) {
  return ref.watch(routinesRepositoryProvider).watchFolders();
}

@riverpod
AsyncValue<Map<String, List<Workout>>> routinesByFolder(Ref ref) {
  final routines = ref.watch(routinesStreamProvider);
  final folders = ref.watch(foldersStreamProvider);

  // When either DB stream emits, this recomputes automatically
  return routines.whenData((routineList) {
    return folders.maybeWhen(
      data: (folderList) {
        final map = <String, List<Workout>>{};
        for (final folder in folderList) {
          map[folder.id] = routineList
              .where((r) => r.folder?.id == folder.id)
              .toList();
        }
        return map;
      },
      orElse: () => {},
    );
  });
}
