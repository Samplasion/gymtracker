import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/exercise.dart';

class ExerciseFormPicker extends StatelessWidget {
  final Exercise? exercise;
  final ValueChanged<Exercise?> onChanged;
  final InputDecoration decoration;
  final ExercisePickerFilter filter;
  final ExerciseFilter? individualFilter;

  const ExerciseFormPicker({
    super.key,
    required this.exercise,
    required this.onChanged,
    required this.decoration,
    this.filter = ExercisePickerFilter.all,
    this.individualFilter,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      onTap: _callback,
      child: InputDecorator(
        decoration: decoration.copyWith(
          contentPadding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
        ),
        child: _buildBody(),
      ),
    );
  }

  _callback() async {
    final exs = await Go.to<List<Exercise>>(() => ExercisePicker(
          singlePick: true,
          allowNone: true,
          filter: filter,
          individualFilter: individualFilter,
        ));
    if (exs == null) return;
    onChanged(exs.firstOrNull);
  }

  Widget _buildBody() {
    if (exercise == null) {
      return ListTile(
        title: Text(
          "exerciseFormPicker.fields.exercise.options.none".t,
        ),
        trailing: const Icon(GTIcons.lt_chevron),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        mouseCursor: MouseCursor.defer,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ExerciseListTile(
        exercise: exercise!,
        selected: false,
        isConcrete: false,
        trailing: const Icon(GTIcons.lt_chevron),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        mouseCursor: MouseCursor.defer,
      ),
    );
  }
}
