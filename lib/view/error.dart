import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/utils/extensions.dart';

class ErrorView extends ConsumerWidget {
  static const routeName = "/error";

  const ErrorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(errorControllerProvider);
    final args = ErrorViewArguments.fromRouteArguments(
      GoRouterState.of(context).extra,
    );
    final stack = args.details?.stack ?? args.stack;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.errorView.shortTitle),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t.errorView.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.t.errorView.subtitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(context.t.errorView.body),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                context.t.errorView.stack,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                args.details?.exceptionAsString() ?? args.error.toString(),
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                  fontFamily: "monospace",
                  fontFamilyFallback: const ["Menlo", "Courier"],
                ),
              ),
              if (stack != null)
                Text(
                  "\n$stack",
                  style: TextStyle(
                    color: context.colorScheme.onSurfaceVariant,
                    fontFamily: "monospace",
                    fontFamilyFallback: const ["Menlo", "Courier"],
                  ),
                )
              else
                Text(
                  context.t.errorView.noStack,
                  style: Theme.of(context).textTheme.bodyMedium,
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

  factory ErrorViewArguments.fromRouteArguments(Object? arguments) {
    if (arguments is ErrorViewArguments) return arguments;

    // Route state can be restored in a serialized form, where custom argument
    // objects may arrive as a map instead of their original Dart type.
    return ErrorViewArguments(
      error: arguments ?? StateError("No error details were provided."),
    );
  }
}
