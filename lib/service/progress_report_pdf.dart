import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final progressReportPdfProvider = Provider((ref) => ProgressReportPdf());

/// Light, print-friendly translation of the app's neutral Material surfaces,
/// 12pt cards, restrained typography and user-selected theme accent.
class ProgressReportPdf {
  Future<Uint8List> generate(ProgressReport report, Translations t) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final design = _ReportDesign(report.accentColor);
    final doc = pw.Document(
      title: t.reports.title,
      author: 'Gym Bro',
      creator: 'Gym Bro',
    );
    final l = t.reports;
    String date(DateTime d) => DateFormat.yMMMd(report.locale).format(d);
    final period = report.request.period;
    final end = DateTime(period.end.year, period.end.month, period.end.day - 1);
    final range = '${date(period.start)} – ${date(end)}';
    final content = <pw.Widget>[
      pw.SizedBox(height: 14),
      pw.Text(
        l.title,
        style: pw.TextStyle(
          fontSize: 30,
          color: design.ink,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 9),
      pw.Text(
        range,
        style: pw.TextStyle(fontSize: 14, color: design.secondary),
      ),
      pw.SizedBox(height: 9),
      pw.Text(
        '${l.generated}: ${DateFormat.yMMMd(report.locale).add_Hm().format(report.generatedAt)} · ${report.timeZone}',
        style: design.small,
      ),
      pw.SizedBox(height: 18),
      pw.Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final section in report.request.sections)
            design.chip(
              [l.training, l.nutrition, l.measurements][section.index],
            ),
        ],
      ),
      if (period.containsInstant(report.generatedAt)) ...[
        pw.SizedBox(height: 12),
        pw.Text(l.partial, style: design.small),
      ],
      if (report.isEmpty) ...[pw.SizedBox(height: 14), design.notice(l.empty)],
      for (final table in report.summaries) ...[
        pw.NewPage(freeSpace: 200),
        design.section(table.title),
        if (table.title == l.training &&
            !report.isEmpty &&
            table.rows.first.first != l.status)
          design.trainingSummary(table)
        else if (table.title == l.nutrition && report.recordedFoodDays > 0)
          design.nutritionSummary(
            table,
            l.coverage,
            report.recordedFoodDays,
            report.days.length,
            l.total,
          )
        else
          design.table(table),
      ],
    ];
    if (report.request.kind != ReportPeriodKind.day &&
        report.charts.isNotEmpty) {
      content.add(pw.NewPage());
      content.add(design.section(l.summary));
      content.add(pw.Text(l.chartNote, style: design.small));
      content.add(pw.SizedBox(height: 14));
      for (final chart in report.charts) {
        content.add(
          pw.Inseparable(
            child: pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.fromLTRB(16, 13, 16, 10),
              decoration: design.cardDecoration,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          chart.title,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: design.ink,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(chart.unit, style: design.small),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  design.chart(chart, report),
                ],
              ),
            ),
          ),
        );
      }
    }
    content.add(pw.NewPage());
    content.add(design.section(l.daily));
    for (final day in report.days) {
      content.add(pw.NewPage(freeSpace: 190));
      content.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 18, bottom: 6),
          child: pw.Text(
            date(day.date),
            style: pw.TextStyle(fontSize: 18, color: design.ink),
          ),
        ),
      );
      for (final table in day.tables) {
        content.add(pw.NewPage(freeSpace: 130));
        content.add(design.subsection(table.title));
        content.add(design.table(table, day: date(day.date)));
      }
    }
    // Calculation policy remains in the document without dominating its overview.
    content.add(pw.NewPage(freeSpace: 200));
    content.add(design.section(l.units));
    content.add(
      pw.Text(
        '${report.weightUnit.name} · ${report.distanceUnit.name} · cm · % · kcal · g',
        style: design.body,
      ),
    );
    content.add(pw.SizedBox(height: 10));
    content.add(pw.Text(l.criteria, style: design.small));
    final rowCount = [
      ...report.summaries,
      ...report.days.expand((d) => d.tables),
    ].fold<int>(0, (a, table) => a + table.rows.length);
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 30, 40, 32),
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
          buildForeground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  left: 40,
                  right: 40,
                  top: 30,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 14,
                          decoration: pw.BoxDecoration(
                            color: design.accent,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                        pw.SizedBox(width: 7),
                        pw.Text(
                          'Gym Bro',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: design.ink,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(range, style: design.small),
                      ],
                    ),
                  ),
                ),
                pw.Positioned(
                  left: 40,
                  right: 40,
                  bottom: 32,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(top: 12),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          l.privacy,
                          style: pw.TextStyle(
                            fontSize: 6.5,
                            color: design.secondary,
                          ),
                        ),
                        pw.Text(
                          '${context.pageNumber} / ${context.pagesCount}',
                          style: design.small,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        maxPages: math.max(100, rowCount * 4 + report.charts.length + 20),
        header: (_) => pw.SizedBox(height: 26),
        footer: (_) => pw.SizedBox(height: 20),
        build: (_) => content,
      ),
    );
    return doc.save();
  }
}

class _ReportDesign {
  final PdfColor accent;
  _ReportDesign(int argb) : accent = PdfColor.fromInt(argb);
  final ink = const PdfColor.fromInt(0xff1d1b1b);
  final secondary = const PdfColor.fromInt(0xff686868);
  final surface = const PdfColor.fromInt(0xfff6f6f6);
  final divider = const PdfColor.fromInt(0xffe5e5e5);
  pw.TextStyle get small =>
      pw.TextStyle(fontSize: 8, color: secondary, lineSpacing: 2);
  pw.TextStyle get body => pw.TextStyle(fontSize: 9, color: ink);
  pw.BoxDecoration get cardDecoration => pw.BoxDecoration(
    color: surface,
    borderRadius: pw.BorderRadius.circular(12),
  );

  pw.Widget chip(String label) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: pw.BoxDecoration(
      color: surface,
      borderRadius: pw.BorderRadius.circular(20),
    ),
    child: pw.Text(label, style: pw.TextStyle(fontSize: 8, color: ink)),
  );
  pw.Widget section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 22, bottom: 12),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 15,
        fontWeight: pw.FontWeight.bold,
        color: ink,
      ),
    ),
  );
  pw.Widget subsection(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 10, bottom: 8),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: ink,
      ),
    ),
  );
  pw.Widget notice(String text) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: cardDecoration,
    child: pw.Text(text, style: small),
  );

  pw.Widget trainingSummary(ReportTable table) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: cardDecoration,
    child: pw.Wrap(
      spacing: 14,
      runSpacing: 16,
      children: [
        for (final row in table.rows)
          pw.SizedBox(
            width: 145,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(row.first, style: small),
                pw.SizedBox(height: 5),
                pw.Text(
                  row.last,
                  style: pw.TextStyle(fontSize: 21, color: ink),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  pw.Widget nutritionSummary(
    ReportTable table,
    String coverage,
    int recorded,
    int totalDays,
    String totalLabel,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          for (var i = 1; i < table.headers.length; i++) ...[
            if (i > 1) pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: cardDecoration,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(table.headers[i], style: small),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      table.rows[1][i],
                      style: pw.TextStyle(fontSize: 20, color: ink),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('$totalLabel ${table.rows[0][i]}', style: small),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        '${table.rows[1].first} · $coverage: $recorded/$totalDays',
        style: small,
      ),
    ],
  );

  pw.Widget table(ReportTable table, {String? day}) {
    if (table.rows.length == 1 &&
        table.rows.single.skip(1).every((cell) => cell == '—')) {
      return notice(table.rows.single.first);
    }
    List<String> chunks(String value) {
      final chars = value.runes.toList();
      if (chars.isEmpty) return [''];
      final result = <String>[];
      var offset = 0;
      while (offset < chars.length) {
        var end = math.min(offset + 120, chars.length);
        if (end < chars.length) {
          for (var i = end - 1; i > offset + 60; i--) {
            if (chars[i] == 32) {
              end = i + 1;
              break;
            }
          }
        }
        result.add(String.fromCharCodes(chars.sublist(offset, end)));
        offset = end;
      }
      return result;
    }

    final rows = <List<String>>[];
    for (final row in table.rows) {
      final cells = row.map(chunks).toList();
      final count = cells.fold<int>(1, (a, c) => math.max(a, c.length));
      for (var i = 0; i < count; i++) {
        rows.add([for (final c in cells) i < c.length ? c[i] : '']);
      }
    }
    return pw.TableHelper.fromTextArray(
      headers: [
        for (var i = 0; i < table.headers.length; i++)
          i == 0 && day != null
              ? '$day\n${table.headers[i]}'
              : table.headers[i],
      ],
      data: rows,
      headerStyle: pw.TextStyle(
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: secondary,
      ),
      cellStyle: pw.TextStyle(fontSize: 8, color: ink, lineSpacing: 1.5),
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: divider, width: 0.4),
      ),
      headerDecoration: pw.BoxDecoration(color: surface),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      cellAlignments: {
        for (var i = 0; i < table.headers.length; i++)
          i: i == 0 ? pw.Alignment.topLeft : pw.Alignment.topRight,
      },
      headerAlignments: {
        for (var i = 0; i < table.headers.length; i++)
          i: i == 0 ? pw.Alignment.topLeft : pw.Alignment.topRight,
      },
      columnWidths: table.headers.length >= 5
          ? {
              0: const pw.FlexColumnWidth(2.4),
              for (var i = 1; i < table.headers.length; i++)
                i: const pw.FlexColumnWidth(1),
            }
          : null,
    );
  }

  pw.Widget chart(ReportChart chart, ProgressReport report) {
    final values = chart.values.whereType<double>().toList();
    final observedMin = values.reduce(math.min),
        observedMax = values.reduce(math.max);
    final minValue = chart.zeroBaseline
        ? math.min(0.0, observedMin)
        : observedMin - math.max(0.5, (observedMax - observedMin) * 0.1);
    final maxValue = math.max(
      minValue + 1,
      observedMax + (chart.zeroBaseline ? 0 : 0.3),
    );
    const width = 475.0, height = 90.0;
    double x(int i) => 38 + 429 * i / math.max(1, chart.values.length - 1);
    double y(double value) =>
        18 + (value - minValue) / (maxValue - minValue) * 62;
    return pw.SizedBox(
      width: width,
      height: height,
      child: pw.Stack(
        children: [
          pw.Positioned.fill(
            child: pw.CustomPaint(
              painter: (canvas, size) {
                canvas.setStrokeColor(divider);
                canvas.setLineWidth(0.4);
                for (var i = 0; i < 3; i++) {
                  final value = minValue + (maxValue - minValue) * i / 2;
                  canvas.drawLine(38, y(value), 467, y(value));
                  canvas.strokePath();
                }
                canvas.setStrokeColor(accent);
                canvas.setFillColor(accent);
                canvas.setLineWidth(1.6);
                // Adjacent observations share a line; missing dates always break it.
                for (var i = 0; i < chart.values.length; i++) {
                  final value = chart.values[i];
                  if (value == null) continue;
                  if (i > 0 && chart.values[i - 1] != null) {
                    canvas.drawLine(
                      x(i - 1),
                      y(chart.values[i - 1]!),
                      x(i),
                      y(value),
                    );
                    canvas.strokePath();
                  }
                  canvas.drawEllipse(x(i), y(value), 2, 2);
                  canvas.fillPath();
                }
              },
            ),
          ),
          for (var i = 0; i < 3; i++)
            pw.Positioned(
              left: 0,
              top: height - y(minValue + (maxValue - minValue) * i / 2) - 4,
              child: pw.Text(
                NumberFormat(
                  '0.#',
                  report.locale,
                ).format(minValue + (maxValue - minValue) * i / 2),
                style: pw.TextStyle(fontSize: 7, color: secondary),
              ),
            ),
          for (var i = 0; i < chart.values.length; i++)
            if (i == 0 ||
                i == chart.values.length - 1 ||
                i % math.max(1, (chart.values.length / 6).ceil()) == 0)
              pw.Positioned(
                left: x(i) - 3,
                bottom: 0,
                child: pw.Text(
                  '${report.days[i].date.day}',
                  style: pw.TextStyle(fontSize: 7, color: secondary),
                ),
              ),
        ],
      ),
    );
  }
}
