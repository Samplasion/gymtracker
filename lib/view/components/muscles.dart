import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/gen/assets.gen.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class MusclesView extends StatefulWidget {
  final Map<GTMuscleHighlight, double> muscles;
  final Curve curve;

  const MusclesView({
    super.key,
    required this.muscles,
    this.curve = Curves.linear,
  });

  @override
  State<MusclesView> createState() => _MusclesViewState();
}

class _MusclesViewState extends State<MusclesView> {
  late Future<(String, String)> _svgFuture =
      Future.value(("#ffffff", "#ffffff"));

  @override
  initState() {
    assert(widget.muscles.isNotEmpty);

    super.initState();
    _svgFuture = _loadSvg();
  }

  @override
  didUpdateWidget(MusclesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muscles != widget.muscles ||
        oldWidget.curve != widget.curve) {
      _svgFuture = _loadSvg();
    }
  }

  Future<(String, String)> _loadSvg() async {
    Completer<(String, String)> completer = Completer();
    await Future.delayed(Duration.zero);
    if (!mounted || !context.mounted) {
      completer.complete((
        "",
        "",
      ));
      return completer.future;
    }
    final dividerColor = Theme.of(context).colorScheme.outline;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final themeColor = Rainbow(spectrum: _gradientColors);

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
    if (!mounted) return [Colors.black, Colors.black];
    return [
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.tertiary,
    ];
  }

  String _processSvg(
    String rawSvg, {
    required Rainbow gradient,
    required Color divider,
  }) {
    final xml = XmlDocument.parse(rawSvg);
    const names = GTMuscleHighlight.values;

    xml.xpath("//*[@stroke]").forEach((e) {
      e.setAttribute(
          "stroke", "#${divider.hexValue.toRadixString(16).substring(2)}");
    });

    for (final highlight in names) {
      final value = widget.muscles[highlight] ?? 0;
      xml.xpath("//g[@data-name=\"${highlight.svgName}\"]/path").forEach((e) {
        e.setAttribute("fill",
            "#${gradient[widget.curve.transform(value.isNaN ? 0 : value)].hexValue.toRadixString(16).substring(2)}");
        e.setAttribute(
            "opacity", value == 0 ? "0" : _getOpacity(value).toString());
      });
    }

    return xml.toXmlString(pretty: true);
  }

  double _getOpacity(double value) {
    return 1;
    // const steep = 2;
    // return ((value + steep - 1) / steep);
  }

  @override
  Widget build(BuildContext context) {
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
                        _gradientColors[i].withAlpha(((i == 0
                                    ? 0
                                    : _getOpacity(
                                        i / (_gradientColors.length - 1))) *
                                255)
                            .round()),
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

Map<GTMuscleHighlight, double> getIntensities(List<Exercise> exercises) {
  final intensities = <GTMuscleHighlight, double>{
    for (final muscle in GTMuscleHighlight.values) muscle: 0,
  };

  for (final exercise in exercises) {
    var highlight = exercise.muscleHighlight;
    if (exercise.isStandardLibraryExercise) {
      final standard = getStandardExerciseByID(exercise.id);
      if (standard != null) {
        highlight = standard.muscleHighlight;
      }
    } else {
      final parent = exercise.getParent();
      highlight = parent?.muscleHighlight ?? highlight;
    }

    for (final muscle in highlight.keys) {
      intensities[muscle] = intensities[muscle]! +
          (highlight[muscle]!.value * exercise.doneSets.length);
    }
  }

  final max = intensities.values
      .reduce((value, element) => value > element ? value : element);

  for (final muscle in GTMuscleHighlight.values) {
    intensities[muscle] = intensities[muscle]! / max;
  }

  return intensities;
}
