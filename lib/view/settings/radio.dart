import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  late T _value = widget.selectedValue;
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
        T oldValue = widget.selectedValue;
        showModalBottomSheet<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, innerSetState) {
                final outerSetState = setState;
                void _setState(void Function() func) {
                  innerSetState(func);
                  outerSetState(func);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleLarge!,
                        child: widget.title,
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final entry in widget.values.entries)
                              RadioListTile<T>(
                                title: Text(entry.value),
                                value: entry.key,
                                groupValue: _value,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                onChanged: (value) {
                                  _setState(() {
                                    if (value != null) {
                                      _value = value;
                                      widget.onChange?.call(value);
                                    }
                                  });
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    _setState(() {});
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          children: [
                            TextButton(
                              child: Text(MaterialLocalizations.of(context)
                                  .cancelButtonLabel),
                              onPressed: () {
                                widget.onChange?.call(oldValue);
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text(MaterialLocalizations.of(context)
                                  .okButtonLabel),
                              onPressed: () {
                                if (widget.onChange != null) {
                                  widget.onChange!(widget.selectedValue);
                                }
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ).then((result) {
          if (result == null || !result) {
            widget.onChange?.call(oldValue);
            setState(() {
              _value = oldValue;
            });
          }
        });
      },
    );
  }
}
