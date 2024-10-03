import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

List scoreComputing(DateTime date, WidgetRef ref) {
  final List<Habit> todayHabitsList =
      ref.watch(habitProvider.notifier).getTodayHabit(date);
  final List<TrackedDay> todayTrackedDaysList =
      ref.watch(trackedDayProvider).where((t) => t.date == date).toList();


  bool fullComplete = !todayHabitsList
      .map((Habit habit) =>
          todayTrackedDaysList.firstWhereOrNull((element) {
            return element.habitId == habit.habitId;
          }) ==
          null)
      .any((element) => element == true) && todayHabitsList.isNotEmpty;

  double totalMax =
      todayHabitsList.fold(0, (double sum, b) => sum + b.ponderation);
  double total = 0;

  for (Habit habit in todayHabitsList) {
    TrackedDay? trackedDay = todayTrackedDaysList
        .firstWhereOrNull((t) => t.habitId == habit.habitId);
    if (trackedDay == null) {
      continue;
    } else {
      if (habit.validationType == ValidationType.evaluation) {
        total += (habit.ponderation * trackedDay.totalRating()! / 10);
      } else {
        total += habit.ponderation;
      }
    }
  }

  double totalNormalized = total / totalMax * 10;
  return [totalNormalized, fullComplete];
}
