import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/logic/time_utility.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/weekly/logic/container_controller.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/daily/display/score_card_widget.dart';
import 'package:tracker_v1/weekly/display/day_container_widget.dart';

class WeeklyTable extends ConsumerWidget {
  const WeeklyTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

  List<dynamic> _getDayTrackingStatus(
      Habit habit,
      List<DateTime> offsetWeekDays,
      List<HabitRecap> trackedDays,
      WidgetRef ref) {
    List<bool> isTrackedFilter = range.map((index) {
      return ref
          .read(scheduledProvider.notifier)
          .getHabitTrackingStatusWithSchedule(
              habit.habitId, offsetWeekDays[index])
          .$1;
    }).toList();

    List<dynamic> result = range.map((index) {
      final trackedDay = trackedDays.firstWhereOrNull((td) =>
          td.habitId == habit.habitId &&
          td.date == offsetWeekDays[index] &&
          td.done != Validated.notYet);
      return trackedDay?.trackedDayId ?? isTrackedFilter[index];
    }).toList();

    return result;
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        SizedBox(),
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

  TableRow? _buildHabitRow(Habit habit, BuildContext context, WidgetRef ref,
      List<HabitRecap> trackedDays, List<RecapDay> recapList) {
    final trackingStatusList =
        _getDayTrackingStatus(habit, offsetWeekDays, trackedDays, ref);
    if (trackingStatusList.every((element) => element == false)) {
      return null;
    }

    return TableRow(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Icon(
                habit.icon,
                color: habit.color.withOpacity(0.25),
              ),
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
                color: containerInit[0].$1,
                displayedScore: containerInit[0].$3,
                element: containerInit[0].$2,
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

  TableRow _buildDailyRow(WidgetRef ref, double? ratioValidated) {
    List<(double?, bool, Color, DateTime)> scores =
        offsetWeekDays.map((DateTime date) {
      double? score = evalutationComputing([date], ref);
      double? ratio = completionComputing([date], ref);
      TimeOfDay? time = ref
          .read(scheduleCacheProvider(date).notifier)
          .getLastTimeOfTheDay(date);
      Color color = getScoreCardColor(ref, ratio == 100, time, date, score);
      return (score, ratio == 100, color, date);
    }).toList();
    return TableRow(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      children: [
        TableCell(
            child: Container(
          alignment: Alignment.center,
          width: 220,
          child: Text(
            ratioValidated == null ? '-' : '${ratioValidated.toInt()}%',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )),
        ...scores.map((entry) {
          return Container(
            color: !entry.$4.isAfter(today)
                ? entry.$3
                : const Color.fromARGB(255, 37, 37, 38),
            alignment: Alignment.center,
            child: Text(
              !entry.$4.isAfter(today) ? getDisplayedScore(entry.$1) : '-',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          );
        })
      ],
    );
  }

  List<TableRow> buildTableRows(List<Habit> activeHabits, WidgetRef ref,
      List<HabitRecap> trackedDays, List<RecapDay> recapList, context) {
    return activeHabits
        .map((habit) =>
            _buildHabitRow(habit, context, ref, trackedDays, recapList))
        .where((element) => element != null)
        .cast<TableRow>()
        .toList();
  }

  List<Habit> habitFilter(
      List<Habit> allHabits, List<DateTime> offsetWeekDays, WidgetRef ref) {
    return allHabits
      ..sort((a, b) {
        Schedule? aSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitDefaultSchedule(a.habitId)!;
        Schedule? bSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitDefaultSchedule(b.habitId)!;
        return compareTimeOfDay(
            aSchedule.timesOfTheDay?.first, bSchedule.timesOfTheDay?.first);
      });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitProvider);
    final trackedDays = ref.watch(trackedDayProvider);
    final recapList = ref.watch(recapDayProvider);

    double? ratioValidated = completionComputing(
        offsetWeekDays.where((d) => !d.isAfter(today)).toList(), ref);

    List<Habit> sortedHabits = habitFilter(allHabits, offsetWeekDays, ref);

    List<TableRow> rows =
        buildTableRows(sortedHabits, ref, trackedDays, recapList, context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
              if (rows.isNotEmpty) _buildDailyRow(ref, ratioValidated),
              if (rows.isNotEmpty) ...rows,
            ],
          ),
          if (rows.isEmpty)
            Container(
              alignment: Alignment.center,
              height: 400,
              child: const Center(
                child: Text('No habits this week 💤'),
              ),
            ),
        ],
      ),
    );
  }
}
