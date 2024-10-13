import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gymtracker/gen/assets.gen.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/utils/hsv_rainbow.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class MusclesView extends StatefulWidget {
  final Map<GTMuscleHighlight, GTMuscleHighlightIntensity> muscles;

  const MusclesView({super.key, required this.muscles});

  @override
  State<MusclesView> createState() => _MusclesViewState();
}

class _MusclesViewState extends State<MusclesView> {
  late final Future<(String, String)> _svgFuture;

  @override
  initState() {
    assert(widget.muscles.isNotEmpty);

    super.initState();
    _svgFuture = _loadSvg();
  }

  Future<(String, String)> _loadSvg() async {
    Completer<(String, String)> completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final themeColor = HSVRainbow(spectrum: _gradientColors);
      final dividerColor = Theme.of(context).colorScheme.outline;

      var frontSvg = await rootBundle.loadString(GTAssets.svg.bodyFront);
      var backSvg = await rootBundle.loadString(GTAssets.svg.bodyBack);

      frontSvg =
          _processSvg(frontSvg, gradient: themeColor, divider: dividerColor);
      backSvg =
          _processSvg(backSvg, gradient: themeColor, divider: dividerColor);

      completer.complete((frontSvg, backSvg));
    });

    return completer.future;
  }

  List<Color> get _gradientColors {
    return [
      Theme.of(context).colorScheme.primary.withAlpha(0),
      // Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.quaternary,
      Theme.of(context).colorScheme.quinary,
    ];
  }

  String _processSvg(
    String rawSvg, {
    required HSVRainbow gradient,
    required Color divider,
  }) {
    final xml = XmlDocument.parse(rawSvg);
    const names = GTMuscleHighlight.values;

    xml.xpath("//*[@stroke]").forEach((e) {
      e.setAttribute(
          "stroke", "#${divider.value.toRadixString(16).substring(2)}");
    });

    for (final highlight in names) {
      final value = widget.muscles[highlight]?.value ?? 0;
      xml.xpath("//g[@data-name=\"${highlight.svgName}\"]/path").forEach((e) {
        e.setAttribute("fill",
            "#${gradient[value].toColor().value.toRadixString(16).substring(2)}");
        e.setAttribute(
            "opacity", value == 0 ? "0" : _getOpacity(value).toString());
      });
    }

    return xml.toXmlString(pretty: true);
  }

  double _getOpacity(double value) => ((value + 3) / 4);

  @override
  Widget build(BuildContext context) {
    print([
      for (double i = 0; i <= 1; i += 1 / (_gradientColors.length - 1))
        _getOpacity(i)
    ]);
    return FutureBuilder<(String, String)>(
      future: _svgFuture,
      builder: (context, snapshot) {
        final frontSvg = snapshot.data?.$1;
        final backSvg = snapshot.data?.$2;
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.string(
                          frontSvg!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.string(
                          backSvg!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      for (int i = 0; i < _gradientColors.length; i++)
                        _gradientColors[i].withOpacity(i == 0
                            ? 0
                            : _getOpacity(i / (_gradientColors.length - 1))),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const SizedBox(height: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (double i = 0;
                      i <= 1;
                      i += 1 / (_gradientColors.length - 1))
                    Text(
                      "${(i * 100).toStringAsFixed(0)}%",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
