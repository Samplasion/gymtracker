import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const size = 192.0;
    const padding = 32.0;
    final boxSize = min(size, context.width - 2 * padding);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: SizedBox(
                height: boxSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: GTColors.appIcon,
                    borderRadius: BorderRadius.circular(boxSize * 0.2),
                  ),
                  child: Transform.scale(
                    scale: 1.5,
                    child: const GBLoadingIndicator(size: size),
                  ),
                ),
              ),
            ),
            Text(
              "appName".t,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
