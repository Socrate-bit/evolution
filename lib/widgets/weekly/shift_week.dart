import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekShifter extends StatelessWidget {
  const WeekShifter(
      {required this.dateFormatter,
      required this.offsetWeekDays,
      required this.updateWeekIndex,
      super.key});

  final DateFormat dateFormatter;
  final List<DateTime> offsetWeekDays;
  final void Function(int value) updateWeekIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      height: 60,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                updateWeekIndex(-1);
              },
              icon: const Icon(Icons.arrow_left_rounded, size: 60),
            ),
            Text(
                '${dateFormatter.format(offsetWeekDays.first)} - ${dateFormatter.format(offsetWeekDays.last)}',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            IconButton(
              onPressed: () {
                updateWeekIndex(1);
              },
              icon: const Icon(Icons.arrow_right_rounded, size: 60),
            )
          ]),
    );
  }
}
