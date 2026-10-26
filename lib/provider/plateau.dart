import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/plateau_analysis.dart';

final plateauAnalysisProvider =
    Provider.autoDispose<AsyncValue<List<PlateauResult>>>((ref) {
      // Refresh recency while the statistics screen stays open.
      final timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => ref.invalidateSelf(),
      );
      ref.onDispose(timer.cancel);
      final now = ref.watch(trainingClockProvider)();
      return ref
          .watch(historyWorkoutsProvider)
          .whenData((history) => analyzePlateaus(history, now: now));
    });
