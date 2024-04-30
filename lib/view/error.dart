import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';

class ErrorView extends GetWidget<ErrorController> {
  static const routeName = "/error";

  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    ErrorViewArguments args =
        ModalRoute.of(context)!.settings.arguments as ErrorViewArguments;
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    controller.dumpError(args);
                  },
                  child: const Text("Dump error to console"),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                "errorView.stack".t,
                style: Get.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (args.details != null) ...[
                Text(
                  args.details!.exceptionAsString(),
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                    fontFamily: "monospace",
                    fontFamilyFallback: const ["Menlo", "Courier"],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  args.details!.stack.toString(),
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                    fontFamily: "monospace",
                    fontFamilyFallback: const ["Menlo", "Courier"],
                  ),
                ),
              ] else
                Text(
                  args.error.toString(),
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                    fontFamily: "monospace",
                    fontFamilyFallback: const ["Menlo", "Courier"],
                  ),
                ),
              if (args.stack != null)
                Text(
                  "\n${args.stack!.toString()}",
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                    fontFamily: "monospace",
                    fontFamilyFallback: const ["Menlo", "Courier"],
                  ),
                )
              else
                Text(
                  "errorView.noStack".t,
                  style: Get.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorViewArguments {
  final FlutterErrorDetails? details;
  final Object? error;
  final StackTrace? stack;

  ErrorViewArguments({this.details, this.error, this.stack})
      : assert(() {
          if (details == null && error == null) {
            throw ArgumentError("Either details or error must be provided");
          }
          return true;
        }());
}
