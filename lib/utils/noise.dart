import 'dart:math';

import 'package:fast_noise/fast_noise.dart';

List<double> noiseSeries(int n) {
  assert(n > 0);

  final perlin = PerlinNoise(seed: 1989, frequency: 0.7239);

  final zero = Random().nextInt(1000);

  return [
    for (var i = 1 + zero; i <= n + zero; i++)
      perlin.getNoise2(i.toDouble(), 0),
  ];
}
