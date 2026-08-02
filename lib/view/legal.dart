import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/gen/assets.gen.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:markdown_widget/markdown_widget.dart';

enum LegalType { tos, privacy }

class TosViewerPage extends _LegalViewerPage {
  const TosViewerPage() : super(type: LegalType.tos);
}

class PrivacyViewerPage extends _LegalViewerPage {
  const PrivacyViewerPage() : super(type: LegalType.privacy);
}

class _LegalViewerPage extends StatefulWidget {
  final LegalType type;

  const _LegalViewerPage({required this.type});

  @override
  State<_LegalViewerPage> createState() => _LegalViewerPageState();
}

class _LegalViewerPageState extends State<_LegalViewerPage> {
  Future<String> _mdFuture = Future.value("");

  final tocController = TocController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadTos();
    });
  }

  Future<void> _loadTos() async {
    setState(() {
      _mdFuture = rootBundle.loadString(switch (Get.locale!.languageCode) {
        'en' => GTAssets.legal.en.let(
          (t) => switch (widget.type) {
            LegalType.tos => t.tos,
            LegalType.privacy => t.pp,
          },
        ),
        _ => GTAssets.legal.it.let(
          (t) => switch (widget.type) {
            LegalType.tos => t.tos,
            LegalType.privacy => t.pp,
          },
        ),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.type) {
          LegalType.tos => "appInfo.terms".t,
          LegalType.privacy => "appInfo.privacy".t,
        }),
      ),
      body: FutureBuilder<String>(
        future: _mdFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildOk(context, snapshot.data!);
          } else if (snapshot.hasError) {
            // return ErrorDisplay(error: snapshot.error);
            return Center(
              child: Text(
                "Error loading document: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildTocWidget() => TocWidget(controller: tocController);

  Widget buildMarkdown(BuildContext context, String data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    return MarkdownWidget(
      data: data,
      tocController: tocController,
      config: config.copy(
        configs: [isDark ? PreConfig.darkConfig : const PreConfig()],
      ),
      padding: const EdgeInsets.all(16).add(MediaQuery.viewPaddingOf(context)),
    );
  }

  Widget buildOk(BuildContext context, String data) {
    if (context.width < Breakpoints.m.screenWidth) {
      return buildMarkdown(context, data);
    }
    return Row(
      children: <Widget>[
        Expanded(child: buildTocWidget()),
        Expanded(flex: 3, child: buildMarkdown(context, data)),
      ],
    );
  }
}
