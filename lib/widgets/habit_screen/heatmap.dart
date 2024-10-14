import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/rating_utility.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class CustomHeatMap extends ConsumerWidget {
  final Habit habit;

  const CustomHeatMap(this.habit, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TrackedDay> trackedDays =
        ref.watch(trackedDayProvider).where((trackedDay) {
      return trackedDay.habitId == habit.habitId;
    }).toList();

    Map<DateTime, int> heatMapDataSet = Map.fromEntries(
      trackedDays.map(
        (TrackedDay trackedDay) => MapEntry(
          trackedDay.date,
          RatingUtility.getRatingNumber(
            trackedDay.notation == null
                ? 4
                : trackedDay.totalRating()! / 2,
          ),
        ),
      ),
    );

    return HeatMap(
        startDate: DateTime(today.year-1, today.month, today.day),
        endDate:today,
        datasets: heatMapDataSet,
        colorMode: ColorMode.color,
        size: 10,
        borderRadius: 2,
        margin: const EdgeInsets.all(1.75),
        scrollable: true,
        showColorTip: false,
        fontSize: 0,
        defaultColor: const Color.fromARGB(255, 52, 52, 52).withOpacity(0.5),
        colorsets: const {
          0: Colors.red,
          1: Colors.orange,
          2: Color.fromARGB(255, 248, 189, 51),
          3: Colors.green,
          4: Colors.blue
        });
  }
}
