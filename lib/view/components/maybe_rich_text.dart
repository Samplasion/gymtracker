import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/rich_text.dart';
import 'package:gymtracker/utils/extensions.dart';

class MaybeRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MaybeRichText({required this.text, this.style, super.key});

  @override
  Widget build(BuildContext context) {
    final parsed = text.tryParseJson();
    final textStyle = style ?? context.textTheme.bodyMedium!;
    if (parsed == null) return Text(text, style: textStyle);

    return DefaultTextStyle(
      style: textStyle,
      child: AbsorbPointer(
        child: QuillEditor.basic(
          controller: QuillController(
            document: text.asQuillDocument(),
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          ),
          config: QuillEditorConfig(
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                textStyle,
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                null,
              ),
            ),
            showCursor: false,
            enableInteractiveSelection: false,
            enableSelectionToolbar: false,
            customStyleBuilder: (attr) {
              if (attr.key == highlightAttribute.key) {
                return getHighlightTextStyle(context);
              }
              return const TextStyle();
            },
          ),
        ),
      ),
    );
  }
}
