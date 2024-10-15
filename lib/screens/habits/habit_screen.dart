import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_launcher/cli_commands.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/habits/new_habit.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/outlined_button.dart';
import 'package:tracker_v1/widgets/habit_screen/heatmap.dart';
import 'package:tracker_v1/widgets/habit_screen/recap_list.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen(this.initialHabit, {super.key});
  final Habit initialHabit;

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
    Habit habit = ref.watch(habitProvider).firstWhere((h) => h.habitId == initialHabit.habitId);

    void resetData() {
      ref.read(trackedDayProvider.notifier).deleteHabitTrackedDays(habit);
      ref.read(habitProvider.notifier).updateHabit(
          habit,
          habit.copy()
            ..frequencyChanges = {today: habit.frequency}
            ..startDate = today);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data deleted')));
    }

    final currentHabit = ref.watch(habitProvider).firstWhere(
          (h) => h.habitId == habit.habitId,
          orElse: () => habit,
        );

    void showConfirmationDialog(
        context, ref, Function() function, String text) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [CustomOutlinedButton(submit: function, text: text)],
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure? This operation is irreversible.'),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  habit.icon,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(currentHabit.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                    habit.description!.isEmpty
                        ? 'No description'
                        : currentHabit.description!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                        )),
                const SizedBox(height: 8),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge, // Base style
                            children: [
                              const TextSpan(
                                text:
                                    'Priority: ', // First part (regular style)
                              ),
                              TextSpan(
                                text: Ponderation.values
                                    .toList()[habit.ponderation - 1]
                                    .name
                                    .capitalize(), // Second part (italic style)
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ))),
                Divider(
                  color: Colors.grey.withOpacity(0.2), // Line color
                  height: 20, // Space around the divider
                  thickness: 0.5, // Line thickness
                  indent: 3, // Left spacing
                  endIndent: 3, // Right spacing
                ),
                if (habit.validationType != HabitType.unique)
                  Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge, // Base style
                              children: [
                                const TextSpan(
                                  text:
                                      'Frequency: ', // First part (regular style)
                                ),
                                TextSpan(
                                  text:
                                      '${habit.weekdays.map((e) => DaysUtility.weekDayToAbrev[e]).toString().replaceAll('(', '').replaceAll(')', '')}', // Second part (italic style)
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ))),
                if (habit.validationType != HabitType.unique)
                  Divider(
                    color: Colors.grey.withOpacity(0.2), // Line color
                    height: 20, // Space around the divider
                    thickness: 0.5, // Line thickness
                    indent: 3, // Left spacing
                    endIndent: 3, // Right spacing
                  ),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge, // Base style
                            children: [
                              const TextSpan(
                                text:
                                    'Habit type: ', // First part (regular style)
                              ),
                              TextSpan(
                                text:
                                    '${habit.validationType.name.capitalize()}', // Second part (italic style)
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ))),
                Divider(
                  color: Colors.grey.withOpacity(0.2), // Line color
                  height: 20, // Space around the divider
                  thickness: 0.5, // Line thickness
                  indent: 3, // Left spacing
                  endIndent: 3, // Right spacing
                ),
                if (habit.validationType == HabitType.recap)
                  Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge, // Base style
                              children: [
                                const TextSpan(
                                  text:
                                      'Focus of the week: ', // First part (regular style)
                                ),
                                TextSpan(
                                  text:
                                      '${habit.newHabit == null || habit.newHabit!.isEmpty ? 'Add a focus of the week' : habit.newHabit}', // Second part (italic style)
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ))),
                if (habit.validationType == HabitType.recap)
                  Divider(
                    color: Colors.grey.withOpacity(0.2), // Line color
                    height: 20, // Space around the divider
                    thickness: 0.5, // Line thickness
                    indent: 3, // Left spacing
                    endIndent: 3, // Right spacing
                  ),
                const SizedBox(
                  height: 18,
                ),
                if (habit.validationType != HabitType.unique)
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
                if (habit.validationType != HabitType.unique)
                  if (habit.frequencyChanges.values
                          .toList()
                          .reversed
                          .toList()[0] ==
                      0)
                    CustomElevatedButton(
                      submit: () {
                        ref
                            .read(habitProvider.notifier)
                            .pauseHabit(habit, true);
                      },
                      text: 'Unpause habit',
                    )
                  else
                    CustomElevatedButton(
                      submit: () {
                        ref
                            .read(habitProvider.notifier)
                            .pauseHabit(habit, false);
                      },
                      text: 'Pause habit',
                    ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: () {
                    showConfirmationDialog(context, ref, () {
                      resetData;
                      Navigator.of(context).pop();
                    }, 'Yes I want to reset data for this habit');
                  },
                  text: 'Reset data',
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: () {
                    showConfirmationDialog(context, ref, () {
                      ref.read(habitProvider.notifier).deleteHabit(habit);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }, 'Yes I want to delete this habit and its data');
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
