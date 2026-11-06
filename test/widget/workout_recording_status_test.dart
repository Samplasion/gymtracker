import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/view/components/workout_recording_status.dart';

void main() {
  testWidgets(
    'pending confirmation is informational and scoped to the current workout',
    (tester) async {
      LocaleSettings.setLocale(AppLocale.it);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recordingStatusProvider.overrideWith(
              (ref) => Stream.value(
                const RecordingUpdate('A', RecordingState.pending),
              ),
            ),
          ],
          child: TranslationProvider(
            child: const MaterialApp(
              home: Scaffold(body: WorkoutRecordingIndicator(workoutId: 'A')),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Registrazione in attesa di conferma'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('a stale status cannot label another workout', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordingStatusProvider.overrideWith(
            (ref) => Stream.value(
              const RecordingUpdate('old', RecordingState.unavailable),
            ),
          ),
        ],
        child: TranslationProvider(
          child: const MaterialApp(
            home: Scaffold(body: WorkoutRecordingIndicator(workoutId: 'new')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Text), findsNothing);
  });
}
