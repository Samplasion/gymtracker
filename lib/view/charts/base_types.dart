import 'package:flutter/material.dart';

class LineChartCategory {
  final String title;
  final Widget icon;
  final String? info;

  LineChartCategory({
    required this.title,
    required this.icon,
    this.info,
  });
}

class LineChartPoint {
  final DateTime date;
  final double value;

  LineChartPoint({
    required this.date,
    required this.value,
  });

  @override
  String toString() {
    return "LineChartPoint(date: $date, value: $value)";
  }
}
