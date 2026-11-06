import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/provider/progress_overview.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/progress_overview.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart' show firstDayOfWeekFor;
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/retry_view.dart';
import 'package:intl/intl.dart' show DateFormat;

class StatisticsOverviewTab extends ConsumerWidget {
  const StatisticsOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(
      progressOverviewProvider(firstDayOfWeekFor(context.locale)),
    );
    return overview.when(
      data: (data) => _OverviewContent(data: data),
      loading: () => const Center(child: GBLoadingIndicator()),
      error: (_, _) => SafeArea(
        top: false,
        child: Center(
          child: RetryView(
            title: context.t.me.stats.overview.loadError,
            description: context.t.me.stats.overview.retryDescription,
            onRetry: () => ref.invalidate(historyWorkoutsProvider),
          ),
        ),
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.data});
  final ProgressOverview data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t.me.stats.overview;
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey('statistics-overview-scroll'),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList.list(
              children: [
                Text(
                  t.thisWeek,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _WeeklyVolumeCard(data: data),
                const SizedBox(height: 16),
                Tooltip(
                  message: t.recordCriteria,
                  child: Text(
                    t.personalRecords,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (data.records.isEmpty)
                  _OverviewCard(
                    child: Text(
                      t.emptyRecords,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final record in data.records.take(2)) ...[
                    _PersonalRecordCard(record: record, data: data),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyVolumeCard extends StatelessWidget {
  const _WeeklyVolumeCard({required this.data});
  final ProgressOverview data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maximum = data.days.fold<double>(
      0,
      (value, day) => math.max(value, day.volume),
    );
    return _OverviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t.me.stats.overview.volume,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in data.days)
                Expanded(
                  child: _VolumeDay(day: day, maximum: maximum, data: data),
                ),
            ],
          ),
          if (maximum == 0) ...[
            const SizedBox(height: 12),
            Text(
              context.t.me.stats.overview.emptyWeek,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VolumeDay extends StatelessWidget {
  const _VolumeDay({
    required this.day,
    required this.maximum,
    required this.data,
  });
  final DailyTrainingVolume day;
  final double maximum;
  final ProgressOverview data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMMd(
      context.locale.languageCode,
    ).format(day.date);
    final value = day.volume.getUserFacingWeight(context.t, data.weightUnit);
    final description = '$date · $value';
    final color = day.volume == 0
        ? scheme.outlineVariant.withValues(alpha: .6)
        : day.volume == maximum
        ? scheme.primaryFixedDim
        : scheme.primary;
    return Semantics(
      label: description,
      excludeSemantics: true,
      child: Tooltip(
        message: description,
        triggerMode: TooltipTriggerMode.tap,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              SizedBox(
                height: 120,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    key: ValueKey(
                      'weekly-volume-${day.date.year}-${day.date.month}-${day.date.day}',
                    ),
                    width: (constraints.maxWidth * .6).clamp(12.0, 40.0),
                    height: maximum == 0 || day.volume == 0
                        ? 6
                        : math.max(6, day.volume / maximum * 120),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat.E(
                  context.locale.languageCode,
                ).format(day.date).characters.first.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalRecordCard extends StatelessWidget {
  const _PersonalRecordCard({required this.record, required this.data});
  final PersonalLoadRecord record;
  final ProgressOverview data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          record.exercise.getDisplayName(context.t),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat.yMMMd(context.locale.languageCode).format(record.date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final value = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        '${record.weightIn(data.weightUnit).getUserFacingWeight(context.t, data.weightUnit)} × ${record.reps}',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.brightness == Brightness.dark
              ? theme.colorScheme.primaryFixedDim
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    return _OverviewCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [details, const SizedBox(height: 8), value],
            );
          }
          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * .48,
                ),
                child: value,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}
