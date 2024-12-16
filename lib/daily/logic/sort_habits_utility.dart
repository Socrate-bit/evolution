import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/compare_time.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';

List<Habit> sortHabits(List<Habit> habitList, DateTime? date, WidgetRef ref) {
  List<Habit> sortedList = List.from(habitList)
    ..sort((a, b) {
      Schedule aSchedule;
      Schedule bSchedule;

      if (date == null) {
        aSchedule =
            ref.read(scheduledProvider.notifier).getHabitDefaultSchedule(a);
        bSchedule =
            ref.read(scheduledProvider.notifier).getHabitDefaultSchedule(b);
      } else {
        aSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitTargetDaySchedule(a, date);
        bSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitTargetDaySchedule(b, date);
      }

      if (aSchedule.timesOfTheDay == null && bSchedule.timesOfTheDay == null) {
        return a.orderIndex.compareTo(b.orderIndex);
      } else {
        return compareTimeOfDay(aSchedule.timesOfTheDay?[(date?.weekday ?? 1) - 1],
            bSchedule.timesOfTheDay?[(date?.weekday ?? 1) - 1]);
      }
    });
  return sortedList;
}
