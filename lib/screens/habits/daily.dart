import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/widgets/daily/day_switch.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/global/habits_reorderable_list.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen(this.dateDisplay, {super.key});
  final Function dateDisplay;

  @override
  ConsumerState<DailyScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<DailyScreen> {
  late DateTime date;
  DateTime now = DateTime.now();
  final _formater = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();

    if (now.hour >= 2) {
      date = DateTime(now.year, now.month, now.day);
    } else {
      date = DateTime(now.year, now.month, now.day - 1);
    }
  }

  String _displayedDate(DateTime value) {
    if (DateTime(now.year, now.month, now.day) == value) {
      return 'Today';
    } else if (DateTime(now.year, now.month, now.day + 1) == value) {
      return 'Tomorrow';
    } else if (DateTime(now.year, now.month, now.day - 1) == value) {
      return 'Yesterday';
    } else {
      return _formater.format(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsList = ref.watch(habitProvider);
    final todayHabitsList =
        ref.watch(habitProvider.notifier).getTodayHabit(date);
    Widget content;

    if (todayHabitsList.isNotEmpty) {
      content = HabitsReorderableList(
        habitsList: todayHabitsList,
        date: date,
        dailyHabits: true,
      );
    } else if (habitsList.isNotEmpty) {
      content = const Align(child: Text('No habits today 💤'));
    } else {
      content = const Align(
        child: Text('No habits yet, create one!'),
      );
    }

    return Column(
      children: [
        DaySwitch((value) {
          setState(
            () {
              date = value;
              widget.dateDisplay(_displayedDate(value));
            },
          );
        }, date),
        Expanded(child: content),
      ],
    );
  }
}
