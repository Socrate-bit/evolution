import 'package:flutter/material.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';

class CircleToggleDay extends StatefulWidget {
  const CircleToggleDay(this.enteredWeekdays, this.weekday, {super.key});

  final WeekDay weekday;
  final List<WeekDay> enteredWeekdays;

  @override
  State<CircleToggleDay> createState() => _CircleToggleDayState();
}

class _CircleToggleDayState extends State<CircleToggleDay> {
  void toggleDay() {
    setState(() {
      if (widget.enteredWeekdays.contains(widget.weekday)) {
        widget.enteredWeekdays.remove(widget.weekday);
      } else {
        widget.enteredWeekdays.add(widget.weekday);
      }
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggleDay();
      },
      child: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.enteredWeekdays.contains(widget.weekday)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceBright),
        child: Text(
          DaysOfTheWeekUtility.weekDayToSign[widget.weekday]!,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
