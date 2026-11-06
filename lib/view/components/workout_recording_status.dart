import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/native.dart';

/// Sensor confirmation is independent of the app's workout timer.
class WorkoutRecordingIndicator extends ConsumerWidget {
  const WorkoutRecordingIndicator({super.key, required this.workoutId});
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(recordingStatusProvider).value;
    if (update == null ||
        update.workoutId != workoutId ||
        update.state == RecordingState.confirmed ||
        update.state == RecordingState.finished) {
      return const SizedBox.shrink();
    }
    final unavailable = update.state == RecordingState.unavailable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            Icon(
              unavailable ? Icons.info_outline : Icons.hourglass_empty,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                unavailable
                    ? context.t.ongoingWorkout.info.recordingUnavailable
                    : context.t.ongoingWorkout.info.recordingPending,
              ),
            ),
            if (unavailable && update.message != null)
              IconButton(
                tooltip: context.t.ongoingWorkout.info.recordingUnavailable,
                icon: const Icon(Icons.help_outline, size: 18),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text(update.message!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
