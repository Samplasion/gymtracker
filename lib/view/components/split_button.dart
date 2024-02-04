import 'package:flutter/material.dart';

class SplitButton extends StatelessWidget {
  final List<SplitButtonSegment> segments;

  const SplitButton({super.key, required this.segments})
      : assert(segments.length > 1);

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      spacing: 8,
      alignment: MainAxisAlignment.spaceEvenly,
      overflowSpacing: 8,
      overflowAlignment: OverflowBarAlignment.center,
      children: [
        for (final segment in segments) segment._buildButton(context),
      ],
    );
  }
}

enum SplitButtonSegmentType { filled, tonal, elevated, outlined, text }

class SplitButtonSegment {
  final String title;
  final VoidCallback onTap;
  final SplitButtonSegmentType type;

  const SplitButtonSegment({
    required this.title,
    required this.onTap,
    this.type = SplitButtonSegmentType.elevated,
  });

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case SplitButtonSegmentType.filled:
        return FilledButton(
          onPressed: onTap,
          child: Text(title),
        );
      case SplitButtonSegmentType.tonal:
        return FilledButton.tonal(
          onPressed: onTap,
          child: Text(title),
        );
      case SplitButtonSegmentType.elevated:
        return ElevatedButton(
          onPressed: onTap,
          child: Text(title),
        );
      case SplitButtonSegmentType.outlined:
        return OutlinedButton(
          onPressed: onTap,
          child: Text(title),
        );
      case SplitButtonSegmentType.text:
        return TextButton(
          onPressed: onTap,
          child: Text(title),
        );
    }
  }
}
