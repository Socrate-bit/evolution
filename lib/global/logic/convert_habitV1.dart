import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model_old.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';

Schedule _convertHabitToSchedule(HabitOld habit) {
  return Schedule(
    habitId: habit.habitId,
    userId: habit.userId,
    startDate: habit.startDate!,
    endingDate: habit.endDate,
    paused: false,
    type: FrequencyType.Weekly,
    period1: 1,
    whenever: false,
    period2: 1,
    daysOfTheWeek: habit.weekdays,
    timesOfTheDay: habit.timeOfTheDay != null
        ? [for (int x = 0; x < 7; x++) habit.timeOfTheDay!]
        : null,
  );
}

Future<bool> v1Converter(List<HabitOld> habits, Ref ref) async {
  for (HabitOld habit in habits) {
    List<Schedule> scheduleList =
        ref.read(scheduledProvider.notifier).getHabitAllSchedule(habit.habitId);

    if (scheduleList.isEmpty &&
        habit.startDate != null &&
        habit.weekdays != null &&
        habit.weekdays!.isNotEmpty) {
      Schedule schedule = _convertHabitToSchedule(habit);
      await ref.read(scheduledProvider.notifier).addSchedule(schedule);
    }
  }
  return true;
}
