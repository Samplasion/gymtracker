import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gymtracker/utils/extensions.dart';

const highlightAttribute = Attribute(
  "highlighted",
  AttributeScope.inline,
  "primary",
);
TextStyle getHighlightTextStyle(BuildContext context) => TextStyle(
      backgroundColor: context.colorScheme.primary,
      color: context.colorScheme.onPrimary,
    );
