import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';

class Infobox extends StatelessWidget {
  final String text;
  final VoidCallback? onLongPress;

  const Infobox({required this.text, this.onLongPress, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(children: [
                    WidgetSpan(
                      child: Icon(
                        GymTrackerIcons.notes,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const TextSpan(text: "  "),
                    TextSpan(text: "infobox.label".t),
                  ]),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                MaybeRichText(text: text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
