import 'dart:ui';

import 'package:flutter/cupertino.dart';

class TranslucentCard extends StatelessWidget {
  final Widget child;

  const TranslucentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 16,
              sigmaY: 16,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context)
                    .barBackgroundColor
                    .withOpacity(0.5),
                border: Border.all(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  // width: 0.5,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
