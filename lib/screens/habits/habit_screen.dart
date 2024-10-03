import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/habits/new_habit.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/outlined_button.dart';
import 'package:tracker_v1/widgets/habit_screen/heatmap.dart';
import 'package:tracker_v1/widgets/habit_screen/recap_list.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen(this.habit, {super.key});
  final Habit habit;

  void showNewHabit(Habit targetHabit, context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewHabitScreen(
        habit: targetHabit,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void resetData() {
      ref.read(trackedDayProvider.notifier).deleteHabitTrackedDays(habit);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data deleted')));
    }

    final currentHabit = ref.watch(habitProvider).firstWhere(
          (h) => h.habitId == habit.habitId,
          orElse: () => habit,
        );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  habit.icon,
                  size: 50,
                ),
                const SizedBox(height: 16),
                Text(currentHabit.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                    textAlign: TextAlign.center,
                    habit.description!.isEmpty
                        ? 'No description'
                        : currentHabit.description!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                        )),
                const SizedBox(
                  height: 18,
                ),
                CustomHeatMap(habit),
                const SizedBox(
                  height: 6,
                ),
                RecapList(habit),
                const SizedBox(
                  height: 32,
                ),
                CustomElevatedButton(
                  submit: () {
                    showNewHabit(currentHabit, context);
                  },
                  text: 'Edit habit',
                ),
                const SizedBox(
                  height: 8,
                ),
                if (habit.frequencyChanges.values
                        .toList()
                        .reversed
                        .toList()[0] ==
                    0)
                  CustomElevatedButton(
                    submit: () {
                      ref.read(habitProvider.notifier).pauseHabit(habit, true);
                    },
                    text: 'Unpause habit',
                  )
                else
                  CustomElevatedButton(
                    submit: () {
                      ref.read(habitProvider.notifier).pauseHabit(habit, false);
                    },
                    text: 'Pause habit',
                  ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: resetData,
                  text: 'Reset data',
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: () {
                    ref.read(habitProvider.notifier).deleteHabit(habit);
                    Navigator.of(context).pop();
                  },
                  text: 'Delete habit',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
