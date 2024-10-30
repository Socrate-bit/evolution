import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class AdditionalMetricsTable extends ConsumerWidget {
  const AdditionalMetricsTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

  bool _isInTheWeek(DateTime date1, {DateTime? date2}) {
    final startBeforeEndOfWeek = date1.isBefore(offsetWeekDays.last) ||
        date1.isAtSameMomentAs(offsetWeekDays.last);
    final endAfterStartOfWeek = date2 == null ||
        date2.isAfter(offsetWeekDays.first) ||
        date2.isAtSameMomentAs(offsetWeekDays.first);

    return startBeforeEndOfWeek && endAfterStartOfWeek;
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        TableCell(
            child: Container(
          alignment: Alignment.center,
          width: 200,
        )),
        ...range.map(
          (item) => Column(
            children: [
              Text(
                DaysUtility.weekDayToSign[WeekDay.values[item]]!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _getDayTrackingStatus((Habit, String) metric,
      List<DateTime> offsetWeekDays, List<TrackedDay> trackedDays) {
    List<bool> isTrackedFilter = range.map((index) {
      return HabitNotifier.getHabitTrackingStatus(metric.$1, offsetWeekDays[index]);
    }).toList();

    List<dynamic> result = range.map((index) {
      final trackedDay = trackedDays.firstWhereOrNull((td) =>
          td.habitId == metric.$1.habitId && td.date == offsetWeekDays[index]);
      return trackedDay?.additionalMetrics?[metric.$2] ?? isTrackedFilter[index];
    }).toList();

    return result;
  }

  TableRow _buildHabitRow((Habit, String) entry, context, List metricList) {
    return TableRow(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Icon(entry.$1.icon, color: entry.$1.color.withOpacity(0.25),),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  entry.$2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ...metricList.map((index) {
          return SizedBox(
            height: 43,
            width: 43,
            child: Center(
              child: Text(index == true || index == ''
                  ? 'N/A'
                  : index == false
                      ? '' : index, softWrap: true, overflow: TextOverflow.ellipsis, )
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref
        .watch(habitProvider)
        .where((habit) => habit.validationType != HabitType.unique)
        .toList();
    final activeHabits = allHabits
        .where((habit) =>
            _isInTheWeek(habit.startDate, date2: habit.endDate) &&
            !HabitNotifier.isPaused(
                habit, offsetWeekDays.first, offsetWeekDays.last))
        .toList()
      ..sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    final trackedDays = ref.watch(trackedDayProvider);

    final List<(Habit, String)> additionalMetrics = [];
    for (Habit habit in activeHabits) {
      if (habit.additionalMetrics == null) continue;
      for (String metric in habit.additionalMetrics!) {
        additionalMetrics.add((habit, metric));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Table(
            key: ObjectKey(offsetWeekDays.first),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {0: FixedColumnWidth(100)},
            border: TableBorder.all(
                color: const Color.fromARGB(255, 62, 62, 62),
                width: 2,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            children: [
              _buildTableHeader(),
              ...additionalMetrics.map((entry) => _buildHabitRow(
                  entry, context, _getDayTrackingStatus(entry, offsetWeekDays, trackedDays))),
            ],
          ),
          if (additionalMetrics.isEmpty)
            Container(
              alignment: Alignment.center,
              height: 400,
              child: const Center(
                child: Text('You don\'t track additional metrics yet !'),
              ),
            ),
        ],
      ),
    );
  }
}
