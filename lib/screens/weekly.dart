import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/habit.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/widgets/day_container.dart';

class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key});

  @override
  ConsumerState<WeeklyScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<WeeklyScreen> {
  int weekIndex = 0;
  final formatter = DateFormat.Md();
  final List range = List.generate(7, (index) => index);

  List<DateTime> get getDayOfTheWeek {
    DateTime now = DateTime.now();
    int shift = weekIndex * 7;
    return [
      for (var i = 0; i < 7; i++)
        DateTime(
          now.year,
          now.month,
          now.day - now.weekday + 1 + i + shift,
        )
    ];
  }

  List _createTrackingStatusList(Habit habit, dayOfTheWeek) {
    // Create a list of all the day of the target week

    // Check if the habit is tracked during each day, and exchange the days that has been tracked with their TrackedDay object
    Map trackedDays = habit.trackedDays;
    List isTrackedFilter = range.map((index) {
      return habit.startDate.compareTo(dayOfTheWeek[index]) > 0
          ? false
          : habit.weekdays.contains(WeekDay.values[index]);
    }).toList();

    List result = dayOfTheWeek
        .asMap()
        .map((index, weekDay) {
          if (isTrackedFilter[index]) {
            return MapEntry(index,
                trackedDays.containsKey(weekDay) ? trackedDays[weekDay] : true);
          } else {
            return MapEntry(index, false);
          }
        })
        .values
        .toList();

    return result;
  }

  Color _getDailyColor(trackedDays, targetDay) {
    int totalDailyHabit = 0;
    int validatedDailyHabit = 0;

    for (TrackedDay trackedDay in trackedDays.values) {
      DateTime date = trackedDay.date;
      DateTime day = DateTime(date.year, date.month, date.day);
      if (day == targetDay) {
        totalDailyHabit += 1;
        if (trackedDay.done == Validated.yes) {
          validatedDailyHabit += 1;
        }
      }
    }

    if (totalDailyHabit == 0) {
      return Theme.of(context).iconTheme.color!;
    }

    double ratioValidated = validatedDailyHabit / totalDailyHabit;

    if (ratioValidated < 0.25) {
      return Colors.redAccent.withOpacity(0.6);
    } else if (ratioValidated < 0.5) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.75);
    } else if (ratioValidated < 0.75) {
      return Theme.of(context).colorScheme.tertiary.withOpacity(0.75);
    } else {
      return Theme.of(context).colorScheme.secondary.withOpacity(0.75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dayOfTheWeek = getDayOfTheWeek;
    List<Habit> habitList = ref.watch(habitProvider).where((habit) {
      bool startBeforeEndOfWeek = habit.startDate.isBefore(dayOfTheWeek.last);
      bool endAfterStartOfWeek =
          habit.endDate == null || habit.endDate!.isAfter(dayOfTheWeek.first);
      return startBeforeEndOfWeek && endAfterStartOfWeek;
    }).toList();



    final List range = List.generate(7, (index) => index);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      weekIndex -= 1;
                    });
                  },
                  icon: const Icon(Icons.arrow_left_rounded, size: 60),
                ),
                Text(
                    '${formatter.format(dayOfTheWeek.first)} - ${formatter.format(dayOfTheWeek.last)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      weekIndex += 1;
                    });
                  },
                  icon: const Icon(Icons.arrow_right_rounded, size: 60),
                )
              ]),
              Table(
                key: ObjectKey(dayOfTheWeek.first),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {0: FixedColumnWidth(100)},
                border: TableBorder.all(
                    color: const Color.fromARGB(255, 62, 62, 62),
                    width: 2,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: SizedBox(
                          width: 200,
                        ),
                      ),
                      ...range.map((item) => Column(
                            children: [
                              Container(
                                child: Text(
                                  weekDayToSign[WeekDay.values[item]]!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                  ...habitList.map(
                    (habit) {
                      List trackingStatusList =
                          _createTrackingStatusList(habit, dayOfTheWeek);
                      return TableRow(
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                Icon(habit.icon),
                                const SizedBox(
                                  width: 8,
                                ),
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
                          ...range.map(
                            (index) => Center(
                                child: DayContainer(habit, dayOfTheWeek[index],
                                    trackingStatusList[index])),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
              // if (habitList.any((habit) => habit.name == 'Daily recap'))
              //   const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
