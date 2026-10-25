import 'package:flutter_test/flutter_test.dart';
import 'card_scenarios.dart';

void main() {
  testWidgets(
    'Italian hydration: presets, shared goals, progress and separate history',
    exerciseHydrationCard,
  );
}
