import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/logs.dart';

class ErrorViewComponent extends StatelessWidget {
  ErrorViewComponent({
    super.key,
    this.title,
    required this.error,
    this.retryCallback,
  }) {
    globalLogger.e("ErrorViewComponent: $error");
  }

  final String? title;
  final Object? error;
  final void Function()? retryCallback;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: .min,
            children: [
              Icon(Icons.error, size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),

              Text(
                title ?? "error.title".t,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              if (error != null) ...[
                const SizedBox(height: 16),

                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              if (retryCallback != null)
                FilledButton.icon(
                  onPressed: retryCallback,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text("error.retry".t),
                ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: () {
                  Go.to(() => const LogView());
                },
                icon: const Icon(GTIcons.logs),
                label: Text("error.logs".t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
