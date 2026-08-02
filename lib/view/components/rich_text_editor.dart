import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/rich_text.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class GTRichTextEditor extends StatefulWidget {
  const GTRichTextEditor({
    super.key,
    required this.infoboxController,
    required this.decoration,
    this.onTapOutside,
    this.autofocus = false,
  });

  final QuillController infoboxController;
  final InputDecoration decoration;
  final VoidCallback? onTapOutside;
  final bool autofocus;

  @override
  State<GTRichTextEditor> createState() => _GTRichTextEditorState();
}

class _GTRichTextEditorState extends State<GTRichTextEditor> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowToolbar = _focusNode.hasPrimaryFocus;
    return InputDecorator(
      decoration: GymTrackerInputDecoration(
        labelText: "ongoingWorkout.finish.fields.infobox.label".t,
        alignLabelWithHint: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuillEditor.basic(
            focusNode: _focusNode,
            controller: widget.infoboxController,
            config: QuillEditorConfig(
              minHeight: context.textTheme.bodyMedium!.height! *
                  context.textTheme.bodyMedium!.fontSize! *
                  3,
              scrollable: true,
              expands: false,
              onTapOutsideEnabled: true,
              autoFocus: widget.autofocus,
              keyboardAppearance: context.theme.brightness,
              onTapOutside: (_, __) {
                widget.onTapOutside?.call();
              },
              customStyleBuilder: (attr) {
                if (attr.key == highlightAttribute.key) {
                  return getHighlightTextStyle(context);
                }
                return const TextStyle();
              },
            ),
          ),
          if (shouldShowToolbar) ...[
            const Divider(),
            QuillSimpleToolbar(
              controller: widget.infoboxController,
              config: QuillSimpleToolbarConfig(
                showDividers: false,
                showFontFamily: false,
                showSearchButton: false,
                showCodeBlock: false,
                showIndent: false,
                showInlineCode: false,
                showHeaderStyle: false,
                showBackgroundColorButton: false,
                showColorButton: false,
                showFontSize: false,
                toolbarIconAlignment: WrapAlignment.start,
                showSuperscript: false,
                showSubscript: false,
                toolbarSectionSpacing: 0,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    // TODO: Figure out how to make this appear on when the text is highlighted
                    icon: const Icon(GTIcons.highlight),
                    tooltip: "richText.highlight".t,
                    onPressed: () {
                      // If the selection is already highlighted, remove the highlight
                      final attr = widget.infoboxController.getSelectionStyle();
                      final isHighlighted =
                          attr.containsKey(highlightAttribute.key);
                      if (isHighlighted) {
                        widget.infoboxController.formatSelection(
                          Attribute.clone(highlightAttribute, null),
                        );
                      } else {
                        widget.infoboxController
                            .formatSelection(highlightAttribute);
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
