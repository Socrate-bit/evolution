import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class ColorFillProgress extends ConsumerStatefulWidget {
  final LinkedHashMap<Habit, (Schedule, HabitRecap?)> todayHabitsSchedulesMap;

  const ColorFillProgress({required this.todayHabitsSchedulesMap, super.key});

  @override
  ConsumerState<ColorFillProgress> createState() => _ColorFillProgressState();
}

class _ColorFillProgressState extends ConsumerState<ColorFillProgress> {
  late Timer timer;
  late DisplayManager displayManager;

  @override
  void initState() {
    displayManager = DisplayManager(
        todayHabitsSchedule: widget.todayHabitsSchedulesMap,
        nextOtherDayHabit: null,
        ref: ref);
    displayManager.nextSchedule();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        displayManager.decreaseCountdown();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerSize = 200;
    double fillHeight = displayManager.getFillHeight();
    String countDownDisplay = displayManager.getCountDownDisplay();
    Color habitColor = displayManager.fillerColor;
    String habitName = displayManager.habitName;
    IconData habitIcon = displayManager.habitIcon;

    Widget displayedElements = Container(
      width: containerSize,
      height: containerSize,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            habitIcon,
            color: Colors.white,
            size: 50,
          ),
          SizedBox(height: 32),
          Text(
            countDownDisplay,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(habitName,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 8),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Partial Color Fill with Clipping")),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Rounded border
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.45),
                ),
              ),
              AnimatedContainer(
                duration: Duration(seconds: 2),
                width: containerSize,
                height: containerSize * fillHeight,
                color: habitColor,
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: displayedElements,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayManager {
  final LinkedHashMap<Habit, (Schedule, HabitRecap?)> todayHabitsSchedule;
  final MapEntry<Habit, (Schedule, HabitRecap?)>? nextOtherDayHabit;
  WidgetRef ref;

  DisplayManager(
      {required this.todayHabitsSchedule,
      required this.nextOtherDayHabit,
      required this.ref});

  MapEntry<Habit, (Schedule, HabitRecap?)>? actualHabitSchedule;
  DateTime? dateTimeEnd;
  DateTime? dateTimeStart;
  Duration? durationSinceStarted;
  Duration? durationLasting;
  static const Duration defaultDuration = Duration(hours: 3);
  Color fillerColor = Colors.grey;
  String habitName = 'No schedule';
  IconData habitIcon = Icons.nights_stay_outlined;

  void nextSchedule() {
    for (MapEntry<Habit, (Schedule, HabitRecap?)> habitSchedule
        in todayHabitsSchedule.entries) {

      HabitRecap? habitRecap = ref
          .read(habitRecapProvider.notifier)
          .getTargetDayHabitRecap(today, habitSchedule.key);

      if (habitRecap?.done != Validated.notYet) {
        continue;
      }

      Duration? habitDuration = habitSchedule.key.duration;
      TimeOfDay? timeStart =
          habitSchedule.value.$1.timesOfTheDay?[now.weekday - 1];

      // Case for unscheduled habit
      if (timeStart == null) {
        _setUnscheduledHabit(habitSchedule);
        break;
      }

      // Case for scheduled habit 
      DateTime dateStart = DateTime(
          now.year, now.month, now.day, timeStart.hour, timeStart.minute);
      DateTime dateEnd = dateStart.add(habitDuration ?? defaultDuration);

      if (now.isAfter(dateEnd)) {
        continue;
      }

      _setScheduledHabit(habitSchedule, dateStart, dateEnd);
      _initColor();
      break;
    }
  }

  void _setUnscheduledHabit(MapEntry<Habit, (Schedule, HabitRecap?)> habitSchedule) {
    actualHabitSchedule = habitSchedule;
    durationSinceStarted = null;
    durationLasting = null;
    dateTimeEnd = null;
    habitIcon = actualHabitSchedule?.key.icon ?? habitIcon;
    habitName = actualHabitSchedule?.key.name ?? habitName;
    _initColor();
  }

  void _setScheduledHabit(
      MapEntry<Habit, (Schedule, HabitRecap?)> habitSchedule, DateTime start, DateTime end) {
    actualHabitSchedule = habitSchedule;
    dateTimeStart = start;
    dateTimeEnd = end;
    durationSinceStarted = now.difference(start);
    durationLasting = end.difference(now);
    habitIcon = actualHabitSchedule?.key.icon ?? habitIcon;
    habitName = actualHabitSchedule?.key.name ?? habitName;
    _initColor();
  }

  void _initColor() {
    if (durationSinceStarted != null && durationSinceStarted!.inSeconds < 0) {
      fillerColor = const Color.fromARGB(255, 20, 20, 20);
    } else {
      fillerColor = actualHabitSchedule?.key.color ?? fillerColor;
    }
  }

  String getCountDownDisplay() {
    if (durationLasting == null || durationLasting!.inSeconds <= 0) {
      return 'Next habit:';
    } else if (durationSinceStarted! > Duration.zero) {
      int hours = durationLasting!.inHours;
      int minutes = durationLasting!.inMinutes % 60;
      int seconds = durationLasting!.inSeconds % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      int hours = durationSinceStarted!.inHours.abs();
      int minutes = durationSinceStarted!.inMinutes.abs() % 60;
      int seconds = durationSinceStarted!.inSeconds.abs() % 60;
      return 'Start in ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  double getFillHeight() {
    if (durationLasting == null || actualHabitSchedule == null) {
      return 0.0;
    }
    double fillHeight = 1 -
        (durationLasting!.inSeconds) /
            (actualHabitSchedule?.key.duration?.inSeconds ??
                defaultDuration.inSeconds);
    return fillHeight.clamp(0.0, 1.0);
  }

  void decreaseCountdown() {
    if (durationLasting == null || dateTimeEnd == null) {
      return;
    }

    durationLasting = dateTimeEnd?.difference(now);
    durationSinceStarted = now.difference(dateTimeStart ?? now);

    _initColor();

    if (durationLasting!.inSeconds <= 0) {
      nextSchedule();
    }
  }
}
