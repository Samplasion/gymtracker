import 'package:flutter/material.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';

/// A recoverable error with user-facing copy, without technical diagnostics.
class RetryView extends StatelessWidget {
  const RetryView({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ContentUnavailableView(
        icon: const Icon(Icons.error_outline),
        title: Text(title),
        description: Text(description),
      ),
      FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(context.t.error.retry),
      ),
    ],
  );
}
