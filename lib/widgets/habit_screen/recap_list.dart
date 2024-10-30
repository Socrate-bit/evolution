import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/recaps/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/habit_recap.dart';

class RecapList extends ConsumerWidget {
  final Habit habit;
  RecapList(this.habit, {super.key});
  final _formater = DateFormat.yMd();

  void _onTap(Habit habit, BuildContext context, TrackedDay oldTrackedDay,
      WidgetRef ref) {
    DateTime date = oldTrackedDay.date;

    if (habit.validationType == HabitType.simple) {
      return;
    } else if (habit.validationType == HabitType.recap) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) =>
            HabitRecapScreen(habit, date, oldTrackedDay: oldTrackedDay),
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
            oldDailyRecap: oldRecapDay, oldTrackedDay: oldTrackedDay),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TrackedDay> trackedDays =
        ref.watch(trackedDayProvider).where((trackedDay) {
      return trackedDay.habitId == habit.habitId;
    }).toList()..sort((a, b) => a.date.isAfter(b.date) ? -1 : 1);

    return Container(
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
                child: Card(
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
                            _formater.format(trackedDays[item].date),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: trackedDays[item]
                                .getStatusAppearance(
                                    Theme.of(context).colorScheme)
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
                ),
              ),
            ),
    );
  }
}
