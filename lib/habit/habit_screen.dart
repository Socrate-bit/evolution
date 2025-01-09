import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/custom_surface_container.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/display/outlined_button_widget.dart';
import 'package:tracker_v1/habit/display/heatmap_widget.dart';
import 'package:tracker_v1/habit/display/recap_list_widget.dart';
import 'package:tracker_v1/recap_display/daily_recap_synthesis.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen(this.initialHabit,
      {this.dateOpened, super.key, this.isAddHabit = false});
  final Habit initialHabit;
  final DateTime? dateOpened;
  final bool isAddHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit? habit = ref
        .watch(habitProvider)
        .firstWhereOrNull((h) => h.habitId == initialHabit.habitId);

    if (habit == null) {
      return Container();
    }

    List<HabitRecap> trackedDays =
        ref.watch(trackedDayProvider).where((trackedDay) {
      return trackedDay.habitId == habit.habitId;
    }).toList()
          ..sort((a, b) => a.date.isAfter(b.date) ? -1 : 1);

    TextStyle textStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey);
    ref.watch(scheduledProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  habit.icon,
                  size: 80,
                  color: habit.color,
                ),
                const SizedBox(height: 32),
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(width: 10,),
                    DailyScore(habit: habit, date: null),
                    Spacer(),
                    _RecapListButton(habit, trackedDays)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: CustomHeatMap(habit),
                ),
                const SizedBox(height: 16),
                CustomContainer(
                  title: 'Description',
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      habit.description!.isEmpty
                          ? 'No description'
                          : habit.description!,
                      style: textStyle,
                    )),
                  ),
                
                const SizedBox(height: 16),
                CustomContainer(
                  title: 'Modalities',
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Habit type: ${habit.validationType.name.capitalizeString()}',
                            style: textStyle),
                        Text(
                            'Priority: ${Ponderation.values.toList()[habit.ponderation - 1].name.capitalizeString()}',
                            style: textStyle),
                        if (habit.validationType == HabitType.recap)
                          Text(
                            'Focus: ${habit.newHabit == null || habit.newHabit!.isEmpty ? 'No focus specified' : habit.newHabit}',
                            style: textStyle,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                _HabitScreenButtons(habit, dateOpened),
                const SizedBox(
                  height: 64,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitScreenButtons extends ConsumerWidget {
  const _HabitScreenButtons(this.habit, this.dateOpened, {super.key});
  final Habit habit;
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
    return Column(
      children: [
        CustomElevatedButton(
          color: habit.color,
          submit: () {
            _showNewHabit(habit, context);
          },
          text: 'Edit habit',
        ),
        const SizedBox(
          height: 8,
        ),
        if (habit.validationType != HabitType.unique)
          if (ref.read(habitProvider.notifier).isHabitCurrentlyPaused(habit))
            CustomElevatedButton(
              color: habit.color,
              submit: () {
                ref.read(habitProvider.notifier).togglePause(habit, true);
              },
              text: 'Unpause habit',
            )
          else
            CustomElevatedButton(
              color: habit.color,
              submit: () {
                ref.read(habitProvider.notifier).togglePause(habit, false);
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
    );
  }
}

class _RecapListButton extends ConsumerWidget {
  const _RecapListButton(this.habit, this.trackedDays);
  final Habit habit;
  final List<HabitRecap> trackedDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return TextButton(
        onPressed: () {
          HapticFeedback.selectionClick();

          List<MapEntry<Habit, HabitRecap?>> entries =
              trackedDays.map((e) => MapEntry(habit, e)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) =>
                  DailySynthesis(entries: entries, habit: habit)));
        },
        child: Text('Recap List',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: habit.color)));
  }
}
