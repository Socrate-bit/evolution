import 'package:flutter/material.dart';

class HabitStatusAppearance {
  HabitStatusAppearance({required this.backgroundColor, required this.elementsColor, this.icon, lineThroughCond = false})
      : lineThrough = lineThroughCond ? TextDecoration.lineThrough : null;

  final Color backgroundColor;
  Color elementsColor;
  Widget? icon;
  final TextDecoration? lineThrough;
}