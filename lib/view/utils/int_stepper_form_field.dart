import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';

String _defaultBuilder(int value) => "$value";

class IntStepperFormField extends StatefulWidget {
  final int value;
  final ValueChanged<int?> onChanged;
  final InputDecoration decoration;
  final int min, max;
  final String Function(int) labelBuilder;

  const IntStepperFormField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decoration,
    this.min = 1,
    this.max = 100,
    this.labelBuilder = _defaultBuilder,
  });

  @override
  State<IntStepperFormField> createState() => _IntStepperFormFieldState();
}

class _IntStepperFormFieldState extends State<IntStepperFormField> {
  @override
  Widget build(BuildContext context) {
    final listOffset = widget.min;
    return InkWell(
      mouseCursor: WidgetStateMouseCursor.clickable,
      customBorder: const StadiumBorder(),
      onTap: () => Go.showBottomSheet(
        (context) => _IntStepperFormFieldSheetContent(
          decoration: widget.decoration,
          listOffset: listOffset,
          value: widget.value,
          min: widget.min,
          max: widget.max,
          onChanged: widget.onChanged,
          labelBuilder: widget.labelBuilder,
        ),
      ),
      child: InputDecorator(
        decoration: widget.decoration.copyWith(
          contentPadding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
          prefixIcon: IconButton(
            icon: const Icon(GTIcons.decrease),
            onPressed: _decrease,
          ),
          suffixIcon: IconButton(
            icon: const Icon(GTIcons.increase),
            onPressed: _increase,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  _decrease() {
    if (widget.value > widget.min) {
      widget.onChanged(widget.value - 1);
    }
  }

  _increase() {
    if (widget.value < widget.max) {
      widget.onChanged(widget.value + 1);
    }
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        widget.labelBuilder(widget.value),
      ),
    );
  }
}

class _IntStepperFormFieldSheetContent extends StatefulWidget {
  const _IntStepperFormFieldSheetContent({
    required this.decoration,
    required this.listOffset,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.labelBuilder,
  });

  final InputDecoration decoration;
  final int listOffset;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String Function(int) labelBuilder;

  @override
  State<_IntStepperFormFieldSheetContent> createState() =>
      _IntStepperFormFieldSheetContentState();
}

class _IntStepperFormFieldSheetContentState
    extends State<_IntStepperFormFieldSheetContent> {
  late final controller = FixedExtentScrollController(
    initialItem: (widget.value - widget.min)..logger.d('initialItem'),
  );

  @override
  Widget build(BuildContext context) {
    final listOffset = widget.listOffset;
    return Column(
      children: [
        if (widget.decoration.label != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: widget.decoration.label,
          )
        else if (widget.decoration.labelText != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.decoration.labelText!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        Expanded(
          child: CupertinoPicker.builder(
            scrollController: controller,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            itemExtent: 32,
            onSelectedItemChanged: (index) {
              widget.onChanged(index + listOffset);
            },
            childCount: widget.max - widget.min + 1,
            itemBuilder: (context, index) =>
                Center(child: Text(widget.labelBuilder(index + listOffset))),
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background:
                  Theme.of(context).colorScheme.secondary.withAlpha(128),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
