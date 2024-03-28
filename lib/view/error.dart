import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';

class ErrorView extends GetWidget<ErrorController> {
  final FlutterErrorDetails? details;
  final Object? error;
  final StackTrace? stack;

  ErrorView({this.details, this.error, this.stack, super.key})
      : assert(() {
          if (details == null && error == null) {
            throw ArgumentError("Either details or error must be provided");
          }
          return true;
        }());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("errorView.shortTitle".t),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "errorView.title".t,
              style: Get.textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "errorView.subtitle".t,
              style: Get.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text("errorView.body".t),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("Back"),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              "errorView.stack".t,
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (details != null) ...[
              Text(
                details!.exceptionAsString(),
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontFamily: "monospace",
                  fontFamilyFallback: const ["Menlo", "Courier"],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                details!.stack.toString(),
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontFamily: "monospace",
                  fontFamilyFallback: const ["Menlo", "Courier"],
                ),
              ),
            ] else
              Text(
                error.toString(),
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontFamily: "monospace",
                  fontFamilyFallback: const ["Menlo", "Courier"],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
