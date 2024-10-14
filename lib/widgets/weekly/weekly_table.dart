import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/container_controller.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/weekly/day_container.dart';

class WeeklyTable extends ConsumerWidget {
  const WeeklyTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

  /// Returns a list representing the tracking status of each day in the given `habit`.
  /// Each element is either `false` for not tracked, `true` for tracked, or the ID of the `TrackedDay` object if it exists.
  List<dynamic> _getDayTrackingStatus(Habit habit,
      List<DateTime> offsetWeekDays, List<TrackedDay> trackedDays) {
    List<bool> isTrackedFilter = range.map((index) {
      return HabitNotifier.getHabitTrackingStatus(habit, offsetWeekDays[index]);
    }).toList();

    List<dynamic> result = range.map((index) {
      final trackedDay = trackedDays.firstWhereOrNull((td) =>
          td.habitId == habit.habitId && td.date == offsetWeekDays[index]);
      return trackedDay?.trackedDayId ?? isTrackedFilter[index];
    }).toList();

    return result;
  }

  bool _isInTheWeek(DateTime date1, DateTime? date2) {
    final startBeforeEndOfWeek = date1.isBefore(offsetWeekDays.last) ||
        date1.isAtSameMomentAs(offsetWeekDays.last);
    final endAfterStartOfWeek = date2 == null ||
        date2.isAfter(offsetWeekDays.first) ||
        date2.isAtSameMomentAs(offsetWeekDays.first);
    return startBeforeEndOfWeek && endAfterStartOfWeek;
  }

  TableRow _buildTableHeader(String ratioValidated) {
    return TableRow(
      children: [
        TableCell(
            child: Container(
          alignment: Alignment.center,
          width: 200,
          child: Text(
            ratioValidated,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
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

  TableRow _buildHabitRow(Habit habit, BuildContext context, WidgetRef ref,
      List<TrackedDay> trackedDays, List<RecapDay> recapList) {
    final trackingStatusList =
        _getDayTrackingStatus(habit, offsetWeekDays, trackedDays);
    return TableRow(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Icon(habit.icon),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  habit.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ...range.map((index) {
          ContainerController containerController = ContainerController(
              habit: habit,
              date: offsetWeekDays[index],
              trackingStatus: trackingStatusList[index],
              trackedDays: trackedDays,
              colorScheme: Theme.of(context).colorScheme,
              dailyRecaps: recapList);
          final containerInit = containerController.initController(ref);
          return Center(
            child: DayContainer(
                fillColor: containerInit[0],
                onLongPress: containerInit[1].onLongPress is Widget
                    ? () {
                        showModalBottomSheet(
                            useSafeArea: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (ctx) => containerInit[1].onLongPress);
                      }
                    : containerInit[1].onLongPress,
                onTap: containerInit[1].onTap != null
                    ? () {
                        showModalBottomSheet(
                            useSafeArea: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (ctx) => containerInit[1].onTap);
                      }
                    : null),
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
        .where((habit) => _isInTheWeek(habit.startDate, habit.endDate))
        .toList()
      ..sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    final trackedDays = ref.watch(trackedDayProvider);
    final recapList = ref.watch(recapDayProvider);

    final int totalToValidate =
        activeHabits.fold(0, (total, habit) => total += habit.frequency);
    final int totalValidated = trackedDays
        .where((trackedDay) => _isInTheWeek(trackedDay.date, trackedDay.date))
        .length;
    final String ratioValidated =
        totalToValidate != 0 ? '$totalValidated/$totalToValidate' : '-';

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
              _buildTableHeader(ratioValidated),
              ...activeHabits.map((habit) =>
                  _buildHabitRow(habit, context, ref, trackedDays, recapList)),
            ],
          ),
          if (activeHabits.isEmpty)
            Container(
                alignment: Alignment.center,
                height: 400,
                child: Center(child: Text('No habits this week 💤'))),
          const SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}
