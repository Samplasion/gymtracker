import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show Provider, FutureProvider;
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats.g.dart';

@riverpod
Stream<List<Workout>> workoutsStream(Ref ref) =>
    ref.watch(databaseServiceProvider).db.getAllHistoryWorkouts();

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
          final completedSets = ex.sets.where((set) => set.done).map((set) {
            if (workout.weightUnit == Weights.kg || set.weight == null)
              return set;
            return set.copyWith(
              weight: Weights.convert(
                value: set.weight!,
                from: workout.weightUnit,
                to: Weights.kg,
              ),
            );
          }).toList();
          if (completedSets.isNotEmpty) {
            data.add((workout.startingDate ?? DateTime(1900), completedSets));
          }
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
          if (sets.isEmpty) continue;
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

/// Aggregated lift data uses kilograms; display conversion follows preferences.
final statsWeightUnitProvider = Provider<Weights>(
  (ref) => ref.watch(appPreferencesProvider).value?.weightUnit ?? Weights.kg,
);

final majorThreeDisplayChartDataProvider = FutureProvider.autoDispose
    .family<Map<MajorLiftType, Map<DateTime, double>>, int>((
      ref,
      firstDayOfWeek,
    ) async {
      final unit = ref.watch(statsWeightUnitProvider);
      final data = await ref.watch(
        majorThreeChartDataProvider(firstDayOfWeek).future,
      );
      return data.map(
        (lift, points) => MapEntry(
          lift,
          points.map(
            (date, kg) => MapEntry(
              date,
              Weights.convert(value: kg, from: Weights.kg, to: unit),
            ),
          ),
        ),
      );
    });

@riverpod
Future<Map<MajorLiftType, Map<DateTime, double>>> majorThreeChartData(
  Ref ref,
  int firstDayOfWeek,
) async {
  final data = await ref.watch(majorThreeDataStreamProvider.future);
  return _processMajorThreeData((data, firstDayOfWeek));
}

Map<MajorLiftType, Map<DateTime, double>> _processMajorThreeData(
  (Map<DateTime, Map<MajorLiftType, double>>, int) message,
) {
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
  // History arrives newest first. Charts connect points and select the latest
  // value in list order, so expose weekly points in chronological order.
  return result.map((lift, weeks) {
    final entries = weeks.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return MapEntry(lift, Map.fromEntries(entries));
  });
}
