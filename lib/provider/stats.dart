import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats.g.dart';

@riverpod
// TODO: Remove when GetX is removed
Stream<List<Workout>> workoutsStream(Ref ref) async* {
  final list = Get.find<HistoryController>().history.subject;
  final sub = list.listen((_) {
    ref.invalidateSelf(asReload: true);
  });
  ref.onDispose(sub.cancel);
  yield list.value ?? [];
}

enum MajorLiftType { benchPress, squat, deadlift }

@riverpod
Future<Map<DateTime, List<GTSet>>> exerciseDataStream(
  Ref ref,
  String exerciseID,
) async {
  final workouts = await ref.watch(
    workoutsStreamProvider.future,
    // workoutsStreamProvider,
  );
  // .maybeWhen(orElse: () => [], data: (data) => data);

  return compute((workouts) {
    final perWorkoutData = workouts.expand((workout) {
      final data = <(DateTime, List<GTSet>)>[];
      final exercises = workout.exercises.expand(
        (ex) => ex is Exercise ? [ex] : (ex as Superset).exercises,
      );
      for (final ex in exercises) {
        if (ex.parentID == exerciseID) {
          data.add((workout.startingDate ?? DateTime(1900), ex.sets));
        }
      }
      return data;
    });

    final groupedData = groupBy(
      perWorkoutData,
      (e) => e.$1,
    ).map((key, value) => MapEntry(key, value.expand((e) => e.$2).toList()));

    return groupedData;
  }, workouts);
}

/// Returns a stream of the 1RM data for each of the three main exercises (bench
/// press, squat, deadlift) over time. The stream emits a list of tuples, where
/// each tuple contains a [DateTime] representing the week and a map of
/// [MajorLiftType] to the corresponding 1RM value.
@riverpod
Future<Map<DateTime, Map<MajorLiftType, double>>> majorThreeDataStream(
  Ref ref,
) async {
  final bpStream = ref.watch(
    exerciseDataStreamProvider(
      GTStandardLibrary.chest.barbellBenchPressFlat,
    ).future,
  );
  final sqStream = ref.watch(
    exerciseDataStreamProvider(
      GTStandardLibrary.quadriceps.squatsBarbell,
    ).future,
  );
  final dlStream = ref.watch(
    exerciseDataStreamProvider(GTStandardLibrary.back.deadlift).future,
  );

  final result = <DateTime, Map<MajorLiftType, double>>{};

  final bpData = await bpStream;
  final sqData = await sqStream;
  final dlData = await dlStream;

  return compute(
    (liftData) {
      for (final (lift, data) in liftData) {
        for (final MapEntry(key: date, value: sets) in data.entries) {
          final oneRM = sets
              .map((set) => set.oneRepMax ?? 0)
              .reduce((a, b) => a > b ? a : b);
          result[date] ??= {};
          result[date]![lift] = oneRM;
        }
      }

      return result;
    },
    [
      (MajorLiftType.benchPress, bpData),
      (MajorLiftType.squat, sqData),
      (MajorLiftType.deadlift, dlData),
    ],
  );
}

@riverpod
Future<Map<MajorLiftType, Map<DateTime, double>>> majorThreeChartData(Ref ref, int firstDayOfWeek) async {
  final data = await ref.watch(majorThreeDataStreamProvider.future);
  return _processMajorThreeData((data, firstDayOfWeek));
  
}

Map<MajorLiftType, Map<DateTime, double>> _processMajorThreeData((Map<DateTime, Map<MajorLiftType, double>>, int) message) {
  final (data, firstDayOfWeek) = message;
  final result = <MajorLiftType, Map<DateTime, double>>{};
  for (final MapEntry(key: date, value: lifts) in data.entries) {
    final weekStartDate = getLastFirstDayOfWeek(date, firstDayOfWeek);
    for (final MapEntry(key: lift, value: weight) in lifts.entries) {
      result[lift] ??= {};
      result[lift]![weekStartDate] ??= 0;
      if (weight > result[lift]![weekStartDate]!) {
        result[lift]![weekStartDate] = weight;
      }
    }
  }
  return result;
}