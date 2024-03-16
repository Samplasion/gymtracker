import 'package:flutter/material.dart';
import 'package:gymtracker/service/localizations.dart';

class Infobox extends StatelessWidget {
  final String text;

  const Infobox({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.note_alt_outlined,
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
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
