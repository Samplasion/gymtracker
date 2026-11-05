import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/purchases.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/components/routine_import_content.dart';

class ImportRoutineModal extends ConsumerStatefulWidget {
  final Workout workout;

  const ImportRoutineModal({required this.workout, super.key});

  @override
  ConsumerState<ImportRoutineModal> createState() => _ImportRoutineModalState();
}

class _ImportRoutineModalState extends ConsumerState<ImportRoutineModal> {
  Workout get workout => widget.workout;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(workout.name),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: () => Go.back(),
      ),
    ),
    body: RoutineImportContent(routines: [workout]),
    bottomNavigationBar: ProBuilder(
      builder: (context, subscription) => RoutineImportActionBar(
        isPro: subscription?.hasProFeatures == true,
        onPressed: () {
          if (subscription?.hasProFeatures != true) {
            ref.read(purchasesControllerProvider).presentPaywall();
            return;
          }
          Go.back();
          ref.read(routinesControllerProvider).importWorkout(workout);
          Go.snack(context.t.importRoutine.import.done);
        },
      ),
    ),
  );
}
