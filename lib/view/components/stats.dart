import 'package:flutter/material.dart';
import 'package:gymtracker/utils/extensions.dart';

class StatsRow extends StatelessWidget {
  final List<Stats> stats;

  const StatsRow({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats
            .map((s) => Expanded(child: s))
            .separated(
              separatorBuilder: (_) =>
                  VerticalDivider(color: context.colorScheme.outlineVariant),
            ),
      ),
    );
  }
}

class Stats extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const Stats({
    required this.value,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: context.theme.textTheme.labelMedium!.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: context.theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
