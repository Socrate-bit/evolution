import 'package:flutter/material.dart';
import 'package:tracker_v1/models/appearance.dart';

class HabitWidget extends StatelessWidget {
  const HabitWidget(
      {required this.name,
      required this.icon,
      required this.appearance,
      super.key});

  final String name;
  final IconData icon;
  final StatusAppearance appearance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      height: 40,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: appearance.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(icon, color: appearance.elementsColor),
        const SizedBox(
          width: 16,
        ),
        Text(
          name,
          style: TextStyle(
              color: appearance.elementsColor,
              decoration: appearance.lineThrough,
              decorationThickness: 2.5,
              decorationColor: appearance.elementsColor,
              fontSize: 16),
        ),
        const Spacer(),
        if (appearance.icon != null) appearance.icon!,
      ]),
    );
  }
}
