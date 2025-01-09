import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/recap/simple_recap_screen.dart';
import 'package:tracker_v1/recap/daily_recap_screen.dart';
import 'package:tracker_v1/recap/habit_recap_screen.dart';
import 'package:tracker_v1/recap_display/daily_recap_synthesis.dart';

class RecapList extends ConsumerWidget {
  const RecapList(this.habit, {super.key});
  final Habit habit;

  void _onTap(Habit habit, BuildContext context, HabitRecap oldTrackedDay,
      WidgetRef ref) {
    DateTime date = oldTrackedDay.date;

    if (habit.validationType == HabitType.simple) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => BasicRecapScreen(
          habit,
          date,
          oldTrackedDay: oldTrackedDay,
          validated: oldTrackedDay.done,
        ),
      );
    } else if (habit.validationType == HabitType.recap) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => HabitRecapScreen(habit, date,
            oldTrackedDay: oldTrackedDay, validated: oldTrackedDay.done),
      );
    } else if (habit.validationType == HabitType.recapDay) {
      RecapDay? oldRecapDay = ref.read(recapDayProvider).firstWhereOrNull((td) {
        return td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => DailyRecapScreen(date, habit,
            oldDailyRecap: oldRecapDay,
            oldTrackedDay: oldTrackedDay,
            validated: oldTrackedDay.done),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<HabitRecap> trackedDays =
        ref.watch(trackedDayProvider).where((trackedDay) {
      return trackedDay.habitId == habit.habitId;
    }).toList()
          ..sort((a, b) => a.date.isAfter(b.date) ? -1 : 1);

    return Column(
      children: [
        Row(
          children: [
            CustomToolTipTitle(title: 'Recaps List', content: 'Recaps List'),
            Spacer(),
            _AllImprovementSynthesis(habit, trackedDays),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 52, 52, 52).withOpacity(0.5),
          ),
          height: 100,
          child: trackedDays.isEmpty
              ? const Center(
                  child: Text(
                    'No recap yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: trackedDays.length,
                  itemBuilder: (ctx, item) => InkWell(
                      onTap: () {
                        _onTap(habit, context, trackedDays[item], ref);
                      },
                      child: _RecapCard(trackedDay: trackedDays[item])),
                ),
        ),
      ],
    );
  }
}

class _AllImprovementSynthesis extends ConsumerWidget {
  const _AllImprovementSynthesis(this.habit, this.trackedDays);
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
            builder: (ctx) => DailySynthesis(entries: entries, habit: habit)));
      },
      child: Text('Synthesis',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: habit.color)),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({super.key, required this.trackedDay});
  final HabitRecap trackedDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                formater4.format(trackedDay.date),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: trackedDay
                    .getStatusAppearance(Theme.of(context).colorScheme)
                    .backgroundColor,
              ),
              height: 12,
              width: 20,
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
