import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/repository/progress_report.dart';
import 'package:gymtracker/service/progress_report_export.dart';
import 'package:gymtracker/service/progress_report_pdf.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ProgressReportsView extends ConsumerStatefulWidget {
  const ProgressReportsView({super.key});
  @override
  ConsumerState<ProgressReportsView> createState() =>
      _ProgressReportsViewState();
}

class _ProgressReportsViewState extends ConsumerState<ProgressReportsView> {
  ReportPeriodKind _kind = ReportPeriodKind.month;
  DateTime _reference = DateTime.now();
  final Set<ReportSection> _sections = ReportSection.values.toSet();
  ProgressReport? _report;
  Uint8List? _bytes;
  String? _owner;
  bool _loading = false, _exporting = false, _failed = false;
  int _generation = 0;
  String? _presentationLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale.toLanguageTag();
    if (_presentationLocale != null && _presentationLocale != locale) {
      _invalidate();
    }
    _presentationLocale = locale;
  }

  void _invalidate() {
    _generation++;
    _bytes = null;
    _report = null;
    _loading = false;
    _failed = false;
  }

  Future<void> _generate() async {
    final prefs = ref.read(appPreferencesProvider).asData?.value;
    if (prefs == null || _sections.isEmpty) return;
    final locale = context.locale.toLanguageTag();
    final translations = context.t;
    final request = ReportRequest(
      kind: _kind,
      period: ReportPeriod.forDate(
        _kind,
        _reference,
        firstDayOfWeek: firstDayOfWeekFor(context.locale),
      ),
      sections: _sections,
    );
    final owner = ref.read(appDatabaseProvider).currentUserId;
    setState(() {
      _invalidate();
      _loading = true;
    });
    final generation = _generation;
    try {
      final report = await ref
          .read(progressReportRepositoryProvider)
          .load(
            request,
            translations: translations,
            locale: locale,
            preferences: prefs,
            generatedAt: DateTime.now(),
            owner: owner,
          );
      if (!mounted ||
          generation != _generation ||
          ref.read(appDatabaseProvider).currentUserId != owner) {
        return;
      }
      final bytes = await ref
          .read(progressReportPdfProvider)
          .generate(report, translations);
      if (!mounted ||
          generation != _generation ||
          ref.read(appDatabaseProvider).currentUserId != owner) {
        return;
      }
      setState(() {
        _report = report;
        _bytes = bytes;
        _owner = owner;
        _loading = false;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  Future<void> _export(bool share, BuildContext buttonContext) async {
    final bytes = _bytes, report = _report;
    if (bytes == null || report == null || _exporting) return;
    if (ref.read(appDatabaseProvider).currentUserId != _owner) {
      setState(_invalidate);
      return;
    }
    final generation = _generation;
    final filename =
        'GymBro_${DateFormat('yyyy-MM-dd').format(report.request.period.start)}_${report.request.kind.name}.pdf';
    final box = buttonContext.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _exporting = true);
    try {
      final service = ref.read(progressReportExportProvider);
      if (share) {
        await service.share(bytes, filename, origin);
      } else {
        final saved = await service.save(bytes, filename);
        if (saved && mounted && generation == _generation) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.t.reports.saved)));
        }
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.t.reports.exportError)));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportOwnerProvider, (previous, next) {
      if (previous?.asData?.value != next.asData?.value) setState(_invalidate);
    });
    ref.listen(appPreferencesProvider, (previous, next) {
      if (previous?.asData?.value != next.asData?.value) setState(_invalidate);
    });
    final preferences = ref.watch(appPreferencesProvider);
    final l = context.t.reports;
    final period = ReportPeriod.forDate(
      _kind,
      _reference,
      firstDayOfWeek: firstDayOfWeekFor(context.locale),
    );
    final last = DateTime(
      period.end.year,
      period.end.month,
      period.end.day - 1,
    );
    final locale = context.locale.toLanguageTag();
    final periodLabels = [l.day, l.week, l.month];
    final sectionLabels = [l.training, l.nutrition, l.measurements];
    const sectionIcons = [
      Icons.fitness_center,
      Icons.restaurant_outlined,
      Icons.monitor_weight_outlined,
    ];
    final busy = _exporting;
    final previewBytes = _bytes;
    final range = _kind == ReportPeriodKind.day
        ? DateFormat.yMMMd(locale).format(period.start)
        : '${DateFormat.yMMMd(locale).format(period.start)} – ${DateFormat.yMMMd(locale).format(last)}';

    Widget configurationCard(String title, Widget child) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
    final configuration = SingleChildScrollView(
      key: const PageStorageKey('report-configuration'),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l.configureDescription,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            configurationCard(
              l.period,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<ReportPeriodKind>(
                    segments: [
                      for (final kind in ReportPeriodKind.values)
                        ButtonSegment(
                          value: kind,
                          label: Text(periodLabels[kind.index]),
                        ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: busy
                        ? null
                        : (selection) => setState(() {
                            _kind = selection.single;
                            _invalidate();
                          }),
                  ),
                  const SizedBox(height: 16),
                  Card.outlined(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      key: const ValueKey('report-reference-date'),
                      title: Text(l.reference),
                      subtitle: Text(
                        DateFormat.yMMMMd(locale).format(_reference),
                      ),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      enabled: !busy,
                      onTap: busy
                          ? null
                          : () async {
                              final selected = await showDatePicker(
                                context: context,
                                initialDate: _reference,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2200),
                                helpText: l.reference,
                              );
                              if (selected != null && mounted) {
                                setState(() {
                                  _reference = selected;
                                  _invalidate();
                                });
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.includedPeriod,
                    style: context.theme.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    range,
                    key: const ValueKey('report-period-range'),
                    style: context.theme.textTheme.bodyLarge,
                  ),
                  if (_kind != ReportPeriodKind.day) ...[
                    const SizedBox(height: 8),
                    Text(
                      _kind == ReportPeriodKind.week
                          ? l.weekReferenceHint
                          : l.monthReferenceHint,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            configurationCard(
              l.selection,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.selectionHint,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final section in ReportSection.values)
                        FilterChip(
                          showCheckmark: true,
                          label: Text(sectionLabels[section.index]),
                          avatar: Icon(sectionIcons[section.index], size: 18),
                          selected: _sections.contains(section),
                          onSelected: busy
                              ? null
                              : (selected) => setState(() {
                                  if (selected) {
                                    _sections.add(section);
                                  } else {
                                    _sections.remove(section);
                                  }
                                  _invalidate();
                                }),
                        ),
                    ],
                  ),
                  if (_sections.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.chooseSection,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (preferences.isLoading) const LinearProgressIndicator(),
            if (preferences.hasError) ...[
              Text(l.error),
              TextButton(
                onPressed: () => ref.invalidate(appPreferencesProvider),
                child: Text(l.retry),
              ),
            ],
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_failed ? l.retry : l.preview),
              onPressed:
                  _loading || busy || _sections.isEmpty || !preferences.hasValue
                  ? null
                  : _generate,
            ),
            if (_failed) ...[
              const SizedBox(height: 12),
              Text(l.error, style: TextStyle(color: context.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
    Widget preview() => Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  l.previewTitle,
                  style: context.theme.textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Builder(
                      builder: (buttonContext) => TextButton.icon(
                        icon: const Icon(Icons.save_alt),
                        label: Text(l.save),
                        onPressed: busy
                            ? null
                            : () => _export(false, buttonContext),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => TextButton.icon(
                        icon: const Icon(Icons.share_outlined),
                        label: Text(l.share),
                        onPressed: busy
                            ? null
                            : () => _export(true, buttonContext),
                      ),
                    ),
                    if (busy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PdfPreview(
              key: ValueKey(previewBytes),
              build: (_) => previewBytes!,
              initialPageFormat: PdfPageFormat.a4,
              useActions: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              scrollViewDecoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
              ),
              loadingWidget: const Center(child: CircularProgressIndicator()),
              onError: (_, _) => Center(child: Text(l.error)),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (previewBytes == null) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: configuration,
              ),
            );
          }
          if (constraints.maxWidth >= 1000) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 380, child: configuration),
                Expanded(child: preview()),
              ],
            );
          }
          return Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.42,
                ),
                child: configuration,
              ),
              Expanded(child: preview()),
            ],
          );
        },
      ),
    );
  }
}
