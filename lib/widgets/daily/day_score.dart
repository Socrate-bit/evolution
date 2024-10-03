import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  double _scoreComputing(DateTime date, WidgetRef ref) {
    final List<Habit> todayHabitsList =
        ref.watch(habitProvider.notifier).getTodayHabit(date);
    final List<TrackedDay> todayTrackedDaysList =
        ref.watch(trackedDayProvider).where((t) => t.date == date).toList();

    double totalMax =
        todayHabitsList.fold(0, (double sum, b) => sum + b.ponderation);
    double total = 0;
    
    for (Habit habit in todayHabitsList) {
      TrackedDay? trackedDay = todayTrackedDaysList
          .firstWhereOrNull((t) => t.habitId == habit.habitId);
      if (trackedDay == null) {
        continue;
      } else {
        if (habit.validationType == ValidationType.recapDay) {
          total += (habit.ponderation * trackedDay.totalRating()! / 5);
        } else {
          total += habit.ponderation;
        }
      }
    }

    double totalNormalized = total / totalMax * 100;
    return totalNormalized;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}
