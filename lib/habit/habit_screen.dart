import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/daily_screen.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/display/outlined_button_widget.dart';
import 'package:tracker_v1/habit/display/heatmap_widget.dart';
import 'package:tracker_v1/habit/display/recap_list_widget.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen(this.initialHabit, {this.dateOpened, super.key});
  final Habit initialHabit;
  final DateTime? dateOpened;

  void _showNewHabit(Habit targetHabit, context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewHabitScreen(
        habit: targetHabit,
        dateOpened: dateOpened,
      ),
    );
  }

  void _resetData(WidgetRef ref, BuildContext context, Habit habit) {
    if (habit.validationType == HabitType.recapDay) {
      ref.read(recapDayProvider.notifier).deleteAllRecapDays();
    }

    ref.read(trackedDayProvider.notifier).deleteHabitTrackedDays(habit);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data deleted')));
  }

  void _showConfirmationDialog(context, ref, Function() function, String text) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit? habit = ref
        .watch(habitProvider)
        .firstWhereOrNull((h) => h.habitId == initialHabit.habitId);

    if (habit == null) {
      return Container();
    }

    ref.watch(scheduledProvider);

    final currentHabit = ref.read(habitProvider).firstWhere(
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  habit.icon,
                  size: 50,
                  color: habit.color,
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
                                    .capitalizeString(), // Second part (italic style)
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
                                text: habit.validationType.name
                                    .capitalizeString(), // Second part (italic style)
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
                    _showNewHabit(currentHabit, context);
                  },
                  text: 'Edit habit',
                ),
                const SizedBox(
                  height: 8,
                ),
                if (habit.validationType != HabitType.unique)
                  if (ref
                      .read(habitProvider.notifier)
                      .isHabitCurrentlyPaused(habit))
                    CustomElevatedButton(
                      submit: () {
                        ref
                            .read(habitProvider.notifier)
                            .togglePause(habit, true);
                      },
                      text: 'Unpause habit',
                    )
                  else
                    CustomElevatedButton(
                      submit: () {
                        ref
                            .read(habitProvider.notifier)
                            .togglePause(habit, false);
                      },
                      text: 'Pause habit',
                    ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: () {
                    _showConfirmationDialog(context, ref, () {
                      _resetData(ref, context, habit);
                      Navigator.of(context).pop();
                    }, 'Yes I want to reset data for this habit');
                  },
                  text: 'Reset all data',
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomOutlinedButton(
                  submit: () {
                    _showConfirmationDialog(context, ref, () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(habitProvider.notifier).deleteHabit(habit);
                      });
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
