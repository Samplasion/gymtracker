import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends ControlledState<LogView, LoggerController> {
  Logger get logger =>
      throw Exception("Are you trying to cause an infinite loop?");

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollDown();
      Future.delayed(const Duration(milliseconds: 250), () {
        _scrollDown();
      });
    });

    sub = controller.onLogsUpdated.listen((_) {
      if (_isAlreadyDown()) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scrollDown();
        });
      }
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isAlreadyDown() {
    if (!_scrollController.hasClients) return false;

    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 3 * kToolbarHeight;
  }

  Future<void> _scrollDown() async {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
    );
  }

  static const _fontSize = 13.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        final levelColors = _getLevelColors(
          context,
          controller.level,
          useM3: true,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text("settings.advanced.options.logs.title".t),
            actions: [
              Badge(
                label: Text("${controller.filteredLogs.length}"),
                backgroundColor: levelColors.$1,
                textColor: levelColors.$2,
                child: IconButton(
                  icon: const Icon(GTIcons.filter_list),
                  onPressed: controller.showLevelRadioModal,
                ),
              ),
              IconButton(
                icon: const Icon(GTIcons.delete_forever),
                onPressed: controller.clearLogs,
              ),
              IconButton(
                icon: const Icon(GTIcons.share),
                onPressed: controller.shareLogs,
              ),
              if (kDebugMode)
                IconButton(
                  icon: const Icon(Icons.all_inclusive),
                  onPressed: controller.dumpAllLevels,
                ),
            ],
          ),
          body: ColoredBox(
            color: Colors.black,
            child: SelectableRegion(
              focusNode: _focusNode,
              selectionControls: materialTextSelectionControls,
              child: SafeArea(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: controller.filteredLogs.length,
                  itemBuilder: (context, index) =>
                      _buildLogTile(context, index),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  padding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _indentedLines(String text, int indent) {
    return text.split("\n").map((line) => " " * indent + line).join("\n");
  }

  Widget _buildLogTile(BuildContext context, int index) {
    final log = controller.filteredLogs[index];

    const prefix = "";
    const indent = prefix.length;

    var spans = [
      if (log.message.trim().isNotEmpty)
        TextSpan(text: _indentedLines(log.message, indent)),
    ];

    if (log.error != null) {
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      spans.add(TextSpan(text: _indentedLines(log.error.toString(), indent)));
    }

    if (log.stackTrace != null) {
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      spans.add(
          TextSpan(text: _indentedLines(log.stackTrace.toString(), indent)));
    }

    var (back, fore) = _getLevelColors(context, log.level);

    var obj = log.object.toString();
    if (obj.split("\n").length > 1) {
      obj = _indentedLines(obj, indent).trimLeft();
    }

    final firstLine =
        '$prefix[${log.level.shortName}] [${log.object.runtimeType}] $obj';
    final textStyle = monospace.copyWith(
      color: fore,
      fontSize: _fontSize,
    );

    return Container(
      color: back,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  firstLine,
                  style: textStyle,
                ),
              ),
              Text(
                " ${DateFormat.Md(Get.locale!.languageCode).format(log.timestamp)} "
                "${DateFormat.Hms().format(log.timestamp)} ",
                style:
                    textStyle.copyWith(color: fore.withAlpha(0.7 * 255 ~/ 100)),
              ),
            ],
          ),
          Text.rich(
            TextSpan(children: spans),
            style: textStyle,
          ),
        ],
      ),
    );
  }

  (Color, Color) _getLevelColors(
    BuildContext context,
    Level level, {
    bool useM3 = false,
  }) {
    var back = useM3 ? getContainerColor(context, level.color) : Colors.black;
    var fore = useM3 ? getOnContainerColor(context, level.color) : level.color;

    if (level == Level.fatal) {
      back = Colors.red;
      fore = Colors.white;
    }

    return (back, fore);
  }
}
