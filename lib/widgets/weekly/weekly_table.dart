import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/container_controller.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';
import 'package:tracker_v1/statistics_screen/logics/score_computing_service.dart';
import 'package:tracker_v1/models/utilities/is_in_the_week.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/daily/scoreCard.dart';
import 'package:tracker_v1/widgets/weekly/day_container.dart';

class WeeklyTable extends ConsumerWidget {
  const WeeklyTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

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

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        SizedBox(),
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
      TimeOfDay? time =
          ref.read(habitProvider.notifier).getLastTimeOfTheDay(date);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref
        .watch(habitProvider)
        .where((habit) => habit.validationType != HabitType.unique)
        .toList();
    final activeHabits = allHabits
        .where((habit) =>
            isInTheWeek(habit.startDate, habit.endDate, offsetWeekDays) &&
            !HabitNotifier.isPaused(
                habit, offsetWeekDays.first, offsetWeekDays.last))
        .toList()
      ..sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    final trackedDays = ref.watch(trackedDayProvider);
    final recapList = ref.watch(recapDayProvider);

    double? ratioValidated = completionComputing(
        offsetWeekDays.where((d) => !d.isAfter(today)).toList(), ref);

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
              if (activeHabits.isNotEmpty) _buildDailyRow(ref, ratioValidated),
              if (activeHabits.isNotEmpty)
                ...activeHabits.map((habit) => _buildHabitRow(
                    habit, context, ref, trackedDays, recapList)),
            ],
          ),
          if (activeHabits.isEmpty)
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
