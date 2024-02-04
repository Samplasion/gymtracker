import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef OnChange<T> = void Function(T value);

/// A [SettingsTile] that allows the user to select a value among many.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class ColorModalTile extends StatefulWidget {
  final Text title;
  final Widget? subtitle;
  final Color selectedValue;
  final OnChange<Color>? onChange;

  const ColorModalTile({
    super.key,
    this.onChange,
    this.subtitle,
    required this.title,
    required this.selectedValue,
  });

  @override
  State<ColorModalTile> createState() => _ColorModalTileState();
}

class _ColorModalTileState extends State<ColorModalTile>
    with SingleTickerProviderStateMixin {
  late Color _value = widget.selectedValue;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get subtitle {
    return ColorTools.nameThatColor(widget.selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle ?? Text(subtitle),
      trailing: ColorIndicator(
        width: 40,
        height: 40,
        borderRadius: 4,
        color: widget.selectedValue,
      ),
      onTap: () {
        Color oldValue = widget.selectedValue;
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: ColorPicker(
                          color: _value,
                          onColorChanged: (Color value) {
                            _setState(() {
                              _value = value;
                              widget.onChange?.call(value);
                            });
                          },
                          width: 40,
                          height: 40,
                          borderRadius: 4,
                          spacing: 5,
                          runSpacing: 5,
                          wheelDiameter: 155,
                          heading: Text(
                            "settings.colorPicker.heading.label".trParams(
                              {"color": ColorTools.nameThatColor(_value)},
                            ),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                            longPressMenu: true,
                          ),
                          materialNameTextStyle:
                              Theme.of(context).textTheme.bodySmall,
                          colorNameTextStyle:
                              Theme.of(context).textTheme.bodySmall,
                          colorCodeTextStyle:
                              Theme.of(context).textTheme.bodySmall,
                          enableShadesSelection: false,
                          pickersEnabled: const <ColorPickerType, bool>{
                            ColorPickerType.both: false,
                            ColorPickerType.primary: true,
                            ColorPickerType.accent: false,
                            ColorPickerType.bw: false,
                            ColorPickerType.custom: false,
                            ColorPickerType.wheel: false,
                          },
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
