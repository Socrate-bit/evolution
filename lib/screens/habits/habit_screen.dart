import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/habits/new_habit.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/outlined_button.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(currentHabit.name, style: Theme.of(context).textTheme.titleLarge),
              Text(
                  habit.description!.isEmpty
                      ? 'No description'
                      : currentHabit.description!,
                  style: Theme.of(context).textTheme.bodyMedium),
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
              CustomElevatedButton(
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
    );
  }
}
