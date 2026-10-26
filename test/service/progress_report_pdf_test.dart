import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/progress_report_pdf.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'progress_report_test.dart'
    show reportBuilder, reportRequest, reportExercise, reportFood;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting());
  for (final locale in [AppLocale.it, AppLocale.en]) {
    for (final kind in [ReportPeriodKind.day, ReportPeriodKind.month]) {
      test(
        'renders ${locale.name} ${kind.name} with complete multipage detail',
        () async {
          final request = reportRequest(
            kind: kind,
            reference: DateTime(2026, 10, 1),
          );
          final workouts = <Workout>[];
          final foods = <TaggedFood>[];
          final weights = <WeightMeasurement>[];
          final body = <BodyMeasurement>[];
          for (final date in request.period.days) {
            // Leave genuine gaps in the month; still emit daily detail for them.
            if (date.day % 5 == 0) continue;
            workouts.add(
              Workout(
                name: 'Sessione àèìòù – ${date.day}',
                duration: const Duration(minutes: 45),
                startingDate: date,
                exercises: [
                  reportExercise(
                    List.generate(
                      12,
                      (i) => GTSet(
                        kind: GTSetKind.normal,
                        parameters: GTSetParameters.repsWeight,
                        reps: 10,
                        weight: 25 + i.toDouble(),
                        done: i < 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
            foods.addAll([
              for (var i = 0; i < 4; i++)
                TaggedFood(
                  date: date,
                  value: reportFood(
                    name: i == 0
                        ? 'Alimento molto lungo àèìòù ${'descrizione senza perdita di contenuto ' * 12}'
                        : 'Pasta integrale $i',
                  ),
                ),
            ]);
            weights.add(
              WeightMeasurement.generateID(
                weight: 80 - date.day / 10,
                time: date,
                weightUnit: Weights.kg,
              ),
            );
            body.add(
              BodyMeasurement.generateID(
                value: 90 - date.day / 10,
                time: date,
                type: BodyMeasurementPart.waist,
              ),
            );
          }
          final report = reportBuilder(locale).build(
            request,
            generatedAt: DateTime(2026, 10, 25, 15),
            timeZone: 'Europe/Rome',
            workouts: workouts,
            foods: foods,
            weights: weights,
            body: body,
          );
          final bytes = await ProgressReportPdf().generate(
            report,
            locale.buildSync(),
          );
          expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
          expect(bytes.length, greaterThan(10000));
          // Retain fixtures for Poppler rendering and independent text checks.
          final output = Directory('/tmp/gymbro-report-qa');
          await output.create(recursive: true);
          await File(
            '${output.path}/${locale.name}-${kind.name}.pdf',
          ).writeAsBytes(bytes);
        },
      );
    }
  }
}
