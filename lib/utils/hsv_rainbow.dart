import 'package:flutter/material.dart';
import 'package:gymtracker/utils/utils.dart';

class HSVRainbow {
  final List<HSVColor> _spectrum;
  final double _rangeStart;
  final double _rangeEnd;

  /// Construct a new Rainbow
  ///
  /// @param spectrum The list of color stops in the transitioning color range.
  /// @param rangeStart The beginning of the numerical domain to map.
  /// @param rangeEnd The end of the numerical domain to map.
  HSVRainbow({
    List<Color>? spectrum,
    rangeStart = 0.0,
    rangeEnd = 1.0,
  })  : _spectrum = spectrum == null
            ? [
                HSVColor.fromColor(const Color(0xFF000000)),
                HSVColor.fromColor(const Color(0xFFFFFFFF)),
              ]
            : [
                for (final color in spectrum) HSVColor.fromColor(color),
              ],
        _rangeStart = rangeStart,
        _rangeEnd = rangeEnd {
    assert(_spectrum.length >= 2);
    assert(rangeStart != rangeEnd);
    assert(rangeStart != null && rangeEnd != null);
  }

  /// the gradient definition
  List<Color> get spectrum =>
      _spectrum.map((h) => h.toColor()).toList(growable: false);

  /// the range start
  num get rangeStart => _rangeStart;

  /// the range end
  num get rangeEnd => _rangeEnd;

  /// Return the interpolated color along the spectrum for domain item.
  /// If the number is outside the bounds of the domain, then the nearest
  /// edge color is returned.
  Color operator [](num number) => _colorAt(number).toColor();

  HSVColor _colorAt(num number) {
    final v = mapRange(
        number.toDouble(), _rangeStart, _rangeEnd, 0, _spectrum.length - 1);
    final lower = v.floor();
    final upper = v.ceil();
    return HSVColor.lerp(_spectrum[lower], _spectrum[upper], v - lower)!;
  }

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is Rainbow && runtimeType == other.runtimeType && _rb == other._rb;

  // @override
  // int get hashCode => _rb.hashCode;
}
