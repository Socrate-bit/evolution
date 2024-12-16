import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/daily/data/custom_day_model.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/daily/data/reorderedday_provider.dart';
import 'package:tracker_v1/daily/display/day_switcher_widget.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DailyScreenState dailyScreenState = ref.watch(dailyScreenStateProvider);
    final habitsList = ref.watch(habitProvider);
    final List<Habit> todayHabitsList = ref
        .watch(habitProvider.notifier)
        .getTodayHabit(dailyScreenState.selectedDate);

    final CustomDay? loadedHabitOrder = ref
        .watch(reorderedDayProvider)
        .firstWhereOrNull((e) =>
            e.userId == FirebaseAuth.instance.currentUser!.uid &&
            e.date == dailyScreenState.selectedDate);

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
        selectedDate: dailyScreenState.selectedDate,
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
        DaySwitch(),
        Expanded(child: Center(child: content)),
      ],
    );
  }
}
