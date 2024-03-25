import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
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
              showFontFamily: false,
              showSearchButton: false,
              showCodeBlock: false,
              showIndent: false,
              showInlineCode: false,
              showHeaderStyle: false,
              toolbarIconAlignment: WrapAlignment.start,
              showSuperscript: false,
              showSubscript: false,
              toolbarSectionSpacing: 0,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
              ),
              controller: infoboxController,
              sharedConfigurations: QuillSharedConfigurations(
                locale: Get.locale!,
              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
