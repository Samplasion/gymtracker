import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/stats.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/progress_overview.dart';

final progressOverviewProvider = Provider.autoDispose
    .family<AsyncValue<ProgressOverview>, int>((ref, firstDayOfWeek) {
      final now = ref.watch(trainingClockProvider)();
      final local = now.toLocal();
      final nextDay = DateTime(local.year, local.month, local.day + 1);
      final timer = Timer(nextDay.difference(now), ref.invalidateSelf);
      ref.onDispose(timer.cancel);
      final unit = ref.watch(statsWeightUnitProvider);
      return ref
          .watch(historyWorkoutsProvider)
          .whenData(
            (history) => buildProgressOverview(
              history,
              now: now,
              weightUnit: unit,
              firstDayOfWeek: firstDayOfWeek,
            ),
          );
    });
