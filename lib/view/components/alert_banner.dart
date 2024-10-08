import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/utils/colors.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';

class AlertColor {
  Color foreground;
  Color background;

  AlertColor(this.background, this.foreground);

  factory AlertColor.fromMaterialColor(
    BuildContext context,
    MaterialColor color,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fgShade = dark ? 200 : 900;

    return AlertColor(
      dark ? color[400]!.withOpacity(25 / 255) : color[100]!,
      color[fgShade]!,
    );
  }

  factory AlertColor.secondary(context) => AlertColor(
        Theme.of(context).colorScheme.secondaryContainer,
        Theme.of(context).colorScheme.onSecondaryContainer,
      );

  factory AlertColor.tertiary(context) => AlertColor(
        Theme.of(context).colorScheme.tertiaryContainer,
        Theme.of(context).colorScheme.onTertiaryContainer,
      );

  factory AlertColor.quaternary(context) => AlertColor(
        Theme.of(context).colorScheme.quaternaryContainer,
        Theme.of(context).colorScheme.onQuaternaryContainer,
      );

  factory AlertColor.quinary(context) => AlertColor(
        Theme.of(context).colorScheme.quinaryContainer,
        Theme.of(context).colorScheme.onQuinaryContainer,
      );

  factory AlertColor.error(context) => AlertColor(
        Theme.of(context).colorScheme.errorContainer,
        Theme.of(context).colorScheme.onErrorContainer,
      );
}

class AlertBanner extends StatelessWidget {
  AlertBanner({
    super.key,
    required this.title,
    this.text,
    dynamic color,
    this.selectable = false,
    this.textBuilder,
  })  : assert((text == null) != (textBuilder == null),
            "Either text or textBuilder must be null, but not both"),
        assert(
          color == null ||
              (color is AlertColor ||
                  color is MaterialColor ||
                  color is GTMaterialColor),
          "color must be either a MaterialColor, an AlertColor, or a GTMaterialColor. You provided: ${color.runtimeType}",
        ),
        _color = color;

  final String title;
  final Widget? text;
  final Widget? Function(BuildContext context)? textBuilder;
  final dynamic _color;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final AlertColor color = _color == null
        ? AlertColor(
            scheme.primaryContainer,
            scheme.onPrimaryContainer,
          )
        : _color is GTMaterialColor
            ? AlertColor(
                _color.getBackground(context), _color.getForeground(context))
            : _color is MaterialColor
                ? AlertColor.fromMaterialColor(context, _color)
                : _color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: color.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (context) {
              final txt = text ?? textBuilder!(context);
              double textOpacity = 0.86;
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: txt == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16, left: 8, top: 8, bottom: 8),
                    child: Icon(
                      GTIcons.info_outline,
                      color: color.foreground,
                    ),
                  ),
                  Expanded(
                    child: Theme(
                      data: ThemeData(
                        textTheme: Theme.of(context).textTheme.copyWith(
                              bodyMedium: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: color.foreground,
                                  ),
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color.foreground,
                            ),
                          ),
                          if (txt != null) ...[
                            if (txt is RichText)
                              selectable
                                  ? SelectableText.rich(
                                      TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                          color: color.foreground
                                              .withOpacity(textOpacity),
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                          color: color.foreground
                                              .withOpacity(textOpacity),
                                        ),
                                      ),
                                    )
                            else
                              txt,
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
