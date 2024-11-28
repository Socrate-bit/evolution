import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/reordered_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/reordered_day.dart';
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
  late DateTime selectedDate;
  DateTime now = DateTime.now();
  final _formater = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();

    if (now.hour >= 2) {
      selectedDate = DateTime(now.year, now.month, now.day);
    } else {
      selectedDate = DateTime(now.year, now.month, now.day - 1);
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
    final List<Habit> todayHabitsList =
        ref.watch(habitProvider.notifier).getTodayHabit(selectedDate);
    final ReorderedDay? loadedHabitOrder = ref
        .watch(ReorderedDayProvider)
        .firstWhereOrNull((e) =>
            e.userId == FirebaseAuth.instance.currentUser!.uid &&
            e.date == selectedDate);

    final List<Habit> todayHabitListCopy =
        todayHabitsList.map((habit) => habit.copy()).toList();

    if (loadedHabitOrder != null) {
      for (Habit habit in todayHabitListCopy) {
        if (loadedHabitOrder.habitOrder[habit.habitId] != null) {
          habit.timeOfTheDay = loadedHabitOrder.habitOrder[habit.habitId]!.$1;
          habit.orderIndex = loadedHabitOrder.habitOrder[habit.habitId]!.$2;
        }
      }
    }

    Widget content;

    if (todayHabitListCopy.isNotEmpty) {
      content = HabitList(
        displayedHabitList: todayHabitListCopy,
        selectedDate: selectedDate,
        habitsPersonalisedOrder: loadedHabitOrder?.habitOrder,
      );
    } else {
      content = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              height: 200,
            ),
            habitsList.isNotEmpty
                ? const Text('No habits today 💤')
                : const Text('No habits yet, create one!')
          ]));
    }

    return Column(
      children: [
        DaySwitch((value) {
          setState(
            () {
              selectedDate = value;
              widget.dateDisplay(_displayedDate(value));
            },
          );
        }, selectedDate),
        Expanded(child: Center(child: content)),
      ],
    );
  }
}
