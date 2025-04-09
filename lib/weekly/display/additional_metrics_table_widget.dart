import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

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
          width: 220,
        )),
        ...range.map(
          (item) => Column(
            children: [
              Text(
                DaysOfTheWeekUtility.weekDayToSign[WeekDay.values[item]]!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _getDayTrackingStatus(
      (Habit, String) metric,
      List<DateTime> offsetWeekDays,
      List<HabitRecap> trackedDays,
      List<DailyRecap> recapDays,
      WidgetRef ref) {
    List<dynamic> result;
    List<bool> isTrackedFilter = range.map((index) {
      return ref
          .read(scheduledProvider.notifier)
          .getHabitTrackingStatusWithSchedule(
              metric.$1.habitId, offsetWeekDays[index])
          .$1;
    }).toList();

    if (metric.$1.validationType == HabitType.recapDay) {
      result = range.map((index) {
        final recapDay = recapDays
            .firstWhereOrNull((td) => td.date == offsetWeekDays[index]);
        return recapDay?.additionalMetrics?[metric.$2] ??
            isTrackedFilter[index];
      }).toList();
    } else {
      result = range.map((index) {
        final trackedDay = trackedDays.firstWhereOrNull((td) =>
            td.habitId == metric.$1.habitId &&
            td.date == offsetWeekDays[index]);
        return trackedDay?.additionalMetrics?[metric.$2] ??
            isTrackedFilter[index];
      }).toList();
    }

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
              const SizedBox(width: 6),
              Icon(
                entry.$1.icon,
                color: entry.$1.color.withOpacity(0.25),
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  entry.$2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 6)
            ],
          ),
        ),
        ...metricList.map((index) {
          return Container(
            color: index != false
                ? Theme.of(context).colorScheme.surface
                : const Color.fromARGB(255, 62, 62, 62),
            height: 30,
            width: double.infinity,
            child: Center(
                child: Text(
              index == true || index == ''
                  ? '-'
                  : index == false
                      ? ''
                      : index,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            )),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackedDays = ref.watch(habitRecapProvider);
    final recapDays = ref.watch(dailyRecapProvider);

    final List<(Habit, String)> additionalMetrics =
        ref.read(habitProvider.notifier).getAllAdditionalMetrics();

    return Column(
      children: [
        Table(
          key: ObjectKey(offsetWeekDays.first),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: FixedColumnWidth(100)},
          border: TableBorder.all(
              color: const Color.fromARGB(255, 62, 62, 62),
              width: 2,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          children: [
            _buildTableHeader(),
            ...additionalMetrics.map((entry) => _buildHabitRow(
                entry,
                context,
                _getDayTrackingStatus(
                    entry, offsetWeekDays, trackedDays, recapDays, ref))),
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
    );
  }
}
