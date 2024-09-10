import 'package:flutter/material.dart';

class DayContainer extends StatelessWidget {
  const DayContainer(
      {
      required this.fillColor,
      required this.onLongPress,
      required this.onTap,
      super.key});

  final Color fillColor;
  final void Function()? onLongPress;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        width: 27,
        height: 27,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: fillColor, borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
