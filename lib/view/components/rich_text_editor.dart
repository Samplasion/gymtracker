import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/rich_text.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';

class GTRichTextEditor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isLarge =
        Breakpoints.currentBreakpoint.screenWidth > Breakpoints.m.screenWidth;
    return InputDecorator(
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: "ongoingWorkout.finish.fields.infobox.label".t,
        alignLabelWithHint: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              multiRowsDisplay: isLarge,
              toolbarSize: kToolbarHeight,
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
              controller: infoboxController,
              sharedConfigurations: QuillSharedConfigurations(
                locale: Get.locale!,
              ),
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  // TODO: Figure out how to make this appear on when the text is highlighted
                  icon: const Icon(Icons.highlight_rounded),
                  tooltip: "richText.highlight".t,
                  onPressed: () {
                    // If the selection is already highlighted, remove the highlight
                    final attr = infoboxController.getSelectionStyle();
                    final isHighlighted =
                        attr.containsKey(highlightAttribute.key);
                    if (isHighlighted) {
                      infoboxController.selectStyle(
                        highlightAttribute,
                        false,
                      );
                      infoboxController.formatSelection(
                        Attribute.clone(highlightAttribute, null),
                      );
                    } else {
                      infoboxController.selectStyle(
                        highlightAttribute,
                        true,
                      );
                      infoboxController.formatSelection(highlightAttribute);
                    }
                  },
                )
              ],
            ),
          ),
          const Divider(),
          QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              controller: infoboxController,
              readOnly: false,
              sharedConfigurations: QuillSharedConfigurations(
                locale: Get.locale!,
              ),
              minHeight: context.textTheme.bodyMedium!.height! *
                  context.textTheme.bodyMedium!.fontSize! *
                  3,
              scrollable: true,
              expands: false,
              isOnTapOutsideEnabled: true,
              autoFocus: autofocus,
              onTapOutside: (_, __) {
                onTapOutside?.call();
              },
              customStyleBuilder: (attr) {
                if (attr.key == highlightAttribute.key) {
                  return getHighlightTextStyle(context);
                }
                return const TextStyle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
