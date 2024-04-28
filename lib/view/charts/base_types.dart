import 'package:flutter/material.dart';

class LineChartCategory {
  final String title;
  final Widget icon;

  LineChartCategory({
    required this.title,
    required this.icon,
  });
}

class LineChartPoint {
  final DateTime date;
  final double value;

  LineChartPoint({
    required this.date,
    required this.value,
  });
}
