import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class CustomHeatMap extends ConsumerWidget {
  const CustomHeatMap(this.habit, {super.key});

  final Habit habit;

  List<DateTime> generateDateList() {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year - 1, now.month, now.day);

    // Find the end of the current week (Sunday)
    DateTime endOfWeek = now.add(Duration(days: DateTime.sunday - now.weekday));
    endOfWeek = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

    List<DateTime> dateList = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endOfWeek) ||
        currentDate.isAtSameMomentAs(endOfWeek)) {
      dateList
          .add(DateTime(currentDate.year, currentDate.month, currentDate.day));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dateList;
  }

  Map<DateTime, int> getHeatMapDataSet(WidgetRef ref) {
    Map<DateTime, int> heatMapDataSet = {};
    List<TrackedDay> trackedDays =
        ref.watch(trackedDayProvider).where((trackedDay) {
      return trackedDay.habitId == habit.habitId &&
          trackedDay.done == Validated.yes;
    }).toList();

    List<DateTime> dates = generateDateList();

    for (DateTime date in dates) {
      bool trackingStatus = HabitNotifier.getHabitTrackingStatus(habit, date);

      if (trackingStatus == false || date.isAfter(today)) {
        heatMapDataSet[date] = 0;
      } else {
        TrackedDay? trackedDay = trackedDays.firstWhereOrNull((td) {
          return td.date == date;
        });

        if (trackedDay == null) {
          heatMapDataSet[date] = 1;
        } else {
          trackedDay.notation == null
              ? heatMapDataSet[date] = 6
              : heatMapDataSet[date] = RatingDisplayUtility.ratingToHeatmapNumber(
                  trackedDay.totalRating()! / 2,
                );
        }
      }
    }
    return heatMapDataSet;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<DateTime, int> heatMapDataSet = getHeatMapDataSet(ref);

    return HeatMap(
        startDate: DateTime(today.year - 1, today.month, today.day),
        endDate: today,
        datasets: heatMapDataSet,
        colorMode: ColorMode.color,
        size: 10,
        borderRadius: 2,
        margin: const EdgeInsets.all(1.75),
        scrollable: true,
        showColorTip: false,
        fontSize: 0,
        defaultColor: const Color.fromARGB(255, 52, 52, 52).withOpacity(0.2),
        colorsets: const {
          1: Color.fromARGB(255, 52, 52, 52),
          2: Colors.red,
          3: Colors.orange,
          4: Color.fromARGB(255, 248, 189, 51),
          5: Colors.green,
          6: Colors.blue,
          7: Colors.purple,
        });
  }
}
