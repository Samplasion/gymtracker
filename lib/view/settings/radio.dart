import 'package:flutter/material.dart';
import 'package:gymtracker/utils/go.dart';

typedef OnChange<T> = void Function(T value);

/// A [SettingsTile] that allows the user to select a value among many.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class RadioModalTile<T> extends StatefulWidget {
  final Text title;
  final Widget? subtitle;
  final Map<T, String> values;
  final T selectedValue;
  final OnChange<T>? onChange;

  const RadioModalTile({
    super.key,
    this.onChange,
    this.subtitle,
    required this.title,
    required this.values,
    required this.selectedValue,
  });

  @override
  State<RadioModalTile<T>> createState() => _RadioModalTileState<T>();
}

class _RadioModalTileState<T> extends State<RadioModalTile<T>>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get subtitle {
    final entries = widget.values.entries;
    if (entries.any((element) => element.key == widget.selectedValue)) {
      return entries
          .firstWhere((element) => element.key == widget.selectedValue)
          .value;
    } else {
      return widget.selectedValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle ?? Text(subtitle),
      trailing: const Icon(Icons.arrow_right_rounded),
      onTap: () {
        Go.showRadioModal(
          selectedValue: widget.selectedValue,
          values: widget.values,
          title: widget.title,
          onChange: (value) {
            if (value != null && mounted) {
              setState(() {
                widget.onChange?.call(value);
              });
            }
          },
        );
      },
    );
  }
}
