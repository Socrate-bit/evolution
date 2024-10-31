import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/get_offset_weekdays.dart';
import 'package:tracker_v1/models/utilities/is_in_the_week.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

double? ratioComputing(
  List<DateTime> dates,
  WidgetRef ref,
) {
  int totalToValidate = 0;
  int totalValidated = 0;

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    List<Habit> todayHabitList =
        ref.watch(habitProvider.notifier).getTodayHabit(date);
    List<String> todayHabitIds = todayHabitList.map((h) => h.habitId).toList();
    List<TrackedDay> todayTrackedDays = ref
        .watch(trackedDayProvider)
        .where((t) => date == t.date && todayHabitIds.contains(t.habitId))
        .toList();

    totalToValidate += todayHabitList.length;
    totalValidated += todayTrackedDays.length;
  }

  // Compute the ratio
  final double? ratioValidated =
      totalToValidate != 0 ? totalValidated / totalToValidate * 100 : null;
  return ratioValidated;
}

double? notationComputing(
  List<DateTime> dates,
  WidgetRef ref,
) {
  const List<int> importancePonderation = [1, 2, 4, 8, 16];
  double maximumScore = 0;
  double actualScore = 0;

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    List<Habit> todayHabitList =
        ref.watch(habitProvider.notifier).getTodayHabit(date);
    List<String> todayHabitIds = todayHabitList.map((h) => h.habitId).toList();
    List<TrackedDay> todayTrackedDays = ref
        .watch(trackedDayProvider)
        .where((t) => date == t.date && todayHabitIds.contains(t.habitId))
        .toList();

    maximumScore += todayHabitList.fold(
        0, (sum, h) => sum + importancePonderation[h.ponderation - 1]);

    for (TrackedDay t in todayTrackedDays) {
      Habit habit = todayHabitList.firstWhere((h) => h.habitId == t.habitId);
      if (habit.validationType == HabitType.recap) {
        actualScore += (importancePonderation[habit.ponderation - 1] *
            (t.totalRating() ?? 10) /
            10);
      } else {
        actualScore += importancePonderation[habit.ponderation - 1];
      }
    }
  }

  // Compute the ratio
  final double? notation =
      maximumScore != 0 ? actualScore / maximumScore * 10 : null;
  return notation;
}

int getCurrentStreak(DateTime date, Habit habit, ref) {
  int streak = -1;

  List<TrackedDay> habitPastTrackedDays = ref
      .read(trackedDayProvider)
      .where((t) =>
          t.habitId == habit.habitId &&
          (t.date.isBefore(date) || t.date.isAtSameMomentAs(date)))
      .toList();

  habitPastTrackedDays.sort((a, b) {
    return a.date.isAfter(b.date) ? -1 : 1;
  });

  DateTime start = date;

  for (TrackedDay trackeDay in habitPastTrackedDays) {
    start = DateTime(start.year, start.month, start.day);
    if (!habitPastTrackedDays.map((e) => e.date).contains(start)) break;
    if (trackeDay.date != start) continue;
    streak += 1;
    start = trackeDay.date.subtract(const Duration(days: 1));
    while (!habit.weekdays
        .map(
          (e) => DaysUtility.weekDayToNumber[e],
        )
        .contains(start.weekday)) {
      start = start.subtract(const Duration(days: 1));
    }
  }
  return streak > 0 ? streak : 0;
}

int? sumStreaksComputing(ref, {List<DateTime>? dates}) {
  dates ??= getOffsetWeekDays().where((d) => !d.isAfter(today)).toList();

  int totalStreaks = 0;

  final activeHabits = ref
      .read(habitProvider)
      .where((habit) =>
          isInTheWeek(habit.startDate, habit.endDate, dates!) &&
          !HabitNotifier.isPaused(habit, dates.first, dates.last))
      .toList();

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    List<Habit> todayHabitList =
        ref.read(habitProvider.notifier).getTodayHabit(date);
    for (Habit h in todayHabitList) {
      totalStreaks += getCurrentStreak(date, h, ref);
    }
  }

  return activeHabits.isNotEmpty ? totalStreaks : null;
}
