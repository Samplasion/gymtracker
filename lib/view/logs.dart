import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/logger_controller.dart';
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

  static const _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder(
        init: controller,
        builder: (_) {
          return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar.large(
                  title: const Text("Logs"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearLogs,
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: controller.showLevelRadioModal,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            backgroundColor: _getLevelColors(
                              context,
                              controller.level,
                            ).$1,
                            radius: 8,
                            child: Text(
                              controller.filteredLogs.length.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getLevelColors(
                                  context,
                                  controller.level,
                                ).$2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    List.generate(
                      controller.filteredLogs.length,
                      (index) => _buildLogTile(context, index),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, int index) {
    final log = controller.filteredLogs[index];

    var spans = [
      if (log.message.trim().isNotEmpty) TextSpan(text: log.message),
    ];

    if (log.error != null) {
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      spans.add(TextSpan(text: log.error.toString()));
    }

    if (log.stackTrace != null) {
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      spans.add(TextSpan(text: log.stackTrace.toString()));
    }

    var (back, fore) = _getLevelColors(context, log.level);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: back,
        foregroundColor: fore,
        child: Text(
          log.level.name.characters.first.toUpperCase(),
        ),
      ),
      title: Text(
        '[${log.object.runtimeType}] ${log.object}',
        style: monospace.copyWith(fontSize: _fontSize),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: spans),
              style: monospace.copyWith(fontSize: _fontSize),
            ),
          ),
          Text(
            '${DateFormat.yMd(Get.locale!.languageCode).format(log.timestamp)}\n${DateFormat.Hms().format(log.timestamp)}',
            style: context.theme.textTheme.labelSmall,
            textAlign: TextAlign.right,
          ),
        ],
      ),
      // trailing: ,
      isThreeLine: true,
    );
  }

  (Color, Color) _getLevelColors(BuildContext context, Level level) {
    var back = getContainerColor(context, level.color);
    var fore = getOnContainerColor(context, level.color);

    if (level == Level.fatal) {
      back = Colors.red;
      fore = Colors.white;
    }

    return (back, fore);
  }
}
