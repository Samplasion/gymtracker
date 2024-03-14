import 'package:flutter/material.dart';

enum _SectionTitleColor { primary, tertiary }

class SectionTitle extends StatelessWidget {
  final String data;

  final _SectionTitleColor _color;

  const SectionTitle(this.data, {super.key})
      : _color = _SectionTitleColor.primary;
  const SectionTitle.tertiary(this.data, {super.key})
      : _color = _SectionTitleColor.tertiary;

  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: _getColor(context),
            ));
  }

  Color _getColor(BuildContext context) => switch (_color) {
        _SectionTitleColor.primary => Theme.of(context).colorScheme.primary,
        _SectionTitleColor.tertiary => Theme.of(context).colorScheme.tertiary,
      };
}
