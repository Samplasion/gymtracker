import 'package:gymtracker/model/set.dart';
import 'package:test/test.dart';

void main() {
  group('ExSet model', () {
    group("one rep max", () {
      test("is calculated correctly", () {
        final set = GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 10,
          weight: 100,
        );
        // We don't need to test the exact formula, just that it's calculated
        // correctly (precision errors and all that)
        expect(set.oneRepMax!.toStringAsFixed(0), "133");
      });

      test("is null if reps is 0", () {
        final set = GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 0,
          weight: 100,
        );
        expect(set.oneRepMax, null);
      });

      test("is 0 if weight is 0", () {
        final set = GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 10,
          weight: 0,
        );
        expect(set.oneRepMax, 0);
      });

      test("throws if parameters are not repsWeight", () {
        for (final parameters in GTSetParameters.values) {
          if (parameters == GTSetParameters.repsWeight) {
            continue;
          }
          expect(
            () => GTSet(
              kind: GTSetKind.normal,
              parameters: parameters,
              // Specify all parameters to avoid assertion error
              reps: 10,
              weight: 100,
              time: const Duration(seconds: 10),
              distance: 100,
            ).oneRepMax,
            throwsA(isA<SetParametersError>()),
          );
        }
      });

      test("throws if the set is malformed", () {
        expect(
          () => GTSet(
            kind: GTSetKind.normal,
            parameters: GTSetParameters.repsWeight,
          ).oneRepMax,
          throwsA(anything),
        );
      });
    });
  });
}
