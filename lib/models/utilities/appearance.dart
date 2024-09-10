import 'package:flutter/material.dart';

class StatusAppearance {
  StatusAppearance({required this.backgroundColor, required this.elementsColor, this.icon, lineThroughCond = false})
      : lineThrough = lineThroughCond ? TextDecoration.lineThrough : null;

  final Color backgroundColor;
  final Color elementsColor;
  final Widget? icon;
  final TextDecoration? lineThrough;
}