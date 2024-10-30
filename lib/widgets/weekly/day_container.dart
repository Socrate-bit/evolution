import 'package:flutter/material.dart';
import 'package:tracker_v1/widgets/daily/score.dart';

class DayContainer extends StatelessWidget {
  const DayContainer(
      {required this.fillColor,
      required this.onLongPress,
      required this.onTap,
      super.key});

  final (Color, dynamic) fillColor;
  final void Function()? onLongPress;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 27,
        height: 27,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: fillColor.$1, borderRadius: BorderRadius.circular(6)),
        child: fillColor.$2 != null
            ? Text(
                displayedScore(fillColor.$2),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w900,
                    fontSize: 12),
              )
            : null,
      ),
    );
  }
}
