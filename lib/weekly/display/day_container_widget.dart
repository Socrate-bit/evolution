import 'package:flutter/material.dart';
import 'package:tracker_v1/theme.dart';

class DayContainer extends StatelessWidget {
  const DayContainer(
      {required this.color,
      this.displayedScore,
      this.element,
      required this.onLongPress,
      required this.onTap,
      super.key});

  final Color color;
  final double? displayedScore;
  final dynamic element;
  final void Function()? onLongPress;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 30,
        color: color,
        child: displayedScore != null
            ? Text(
                displayedScore.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w900,
                ),
              )
            : element != null
                ? Icon(element,
                    size: 16,
                    weight: 200,
                    color: Colors.white.withOpacity(0.45))
                : null,
      ),
    );
  }
}
