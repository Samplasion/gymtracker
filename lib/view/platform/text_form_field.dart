import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformTextFormField extends PlatformStatelessWidget {
  final TextEditingController textController;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final InputDecoration? materialDecoration;
  final BoxDecoration? cupertinoDecoration;
  final Widget? cupertinoPrefix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTapOutside;
  final TextStyle? style;
  final bool readOnly;
  final String? Function(String?)? validator;

  PlatformTextFormField({
    super.key,
    required TextEditingController controller,
    this.focusNode,
    required this.keyboardType,
    this.materialDecoration,
    this.cupertinoDecoration,
    this.cupertinoPrefix,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onTapOutside,
    this.style,
    this.readOnly = false,
    this.validator,
  }) : textController = controller;

  @override
  Widget buildMaterial(BuildContext context) {
    return TextFormField(
      controller: textController,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: materialDecoration,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTap: onTapOutside,
      style: style,
      readOnly: readOnly,
      validator: validator,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoTextFormFieldRow(
      padding: EdgeInsets.zero,
      controller: textController,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: (cupertinoDecoration ?? const BoxDecoration()).copyWith(
        border: Border.all(
          color: CupertinoColors.systemGrey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      prefix: cupertinoPrefix,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTap: onTapOutside,
      style: style,
      readOnly: readOnly,
      validator: validator,
    );
  }
}
