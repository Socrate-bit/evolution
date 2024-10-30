import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/Scores/score_computing.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/daily/score.dart';

class DaySwitch extends ConsumerStatefulWidget {
  final Function switchDay;
  final DateTime _selectedDay;

  const DaySwitch(this.switchDay, this._selectedDay, {super.key});

  @override
  ConsumerState<DaySwitch> createState() => _DaySwitchState();
}

class _DaySwitchState extends ConsumerState<DaySwitch> {
  final DateTime _now = DateTime.now();
  late DateTime _today;
  late DateTime _selectedDay;
  late PageController _pageController;
  int weekIndex = 0;

  List<DateTime> get _getOffsetWeekDays {
    DateTime now = DateTime.now();
    int weekShift = weekIndex * 7;
    return List.generate(
        7,
        (i) => DateTime(
            now.year, now.month, now.day - now.weekday + 1 + i + weekShift));
  }

  void _pickDay(pickedDay) {
    setState(() {
      _selectedDay = pickedDay;
    });
    widget.switchDay(pickedDay);
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 52);
    _selectedDay = widget._selectedDay;
    _today = DateTime(_now.year, _now.month, _now.day);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Color getCircleColor(DateTime day, bool isFull, {TimeOfDay? time}) {
    DateTime selectedDayNight = DateTime(today.year, today.month, today.day,
        time?.hour ?? 20, time?.minute ?? 0);

    if (day.isAfter(_now) ||
        (now.isBefore(selectedDayNight) &&
            !isFull &&
            day.isAtSameMomentAs(today)) ||
        ref.watch(habitProvider.notifier).getTodayHabit(day).isEmpty) {
      if (now.isBefore(selectedDayNight) && day.isAtSameMomentAs(today)) {
        return Colors.white;
      }
      return _selectedDay == day
          ? const Color.fromARGB(255, 51, 51, 51)
          : Theme.of(context).colorScheme.surface;
    } else {
      return RatingUtility.getRatingColor(
        notationComputing([day], ref)! / 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double? score = notationComputing([_selectedDay], ref);
    double? ratio = ratioComputing([_selectedDay], ref);
    TimeOfDay? time;

    if (_selectedDay == today) {
      List<Habit> todayHabit = ref
          .watch(habitProvider.notifier)
          .getTodayHabit(_selectedDay)
          .where((h) => h.timeOfTheDay != null)
          .toList();
      List<TimeOfDay?> timeOfDay = todayHabit
          .map((h) => h.timeOfTheDay)
          .toList()
        ..sort((a, b) => compareTimeOfDay(a, b));
      if (todayHabit.isNotEmpty) {
        time = timeOfDay.last;
      }
    }

    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      height: 60,
      child: Row(
        children: [
          Container(
            width: 300,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (ctx, item) {
                weekIndex = item - 52;
                final List<DateTime> dayList = _getOffsetWeekDays;
                bool previousFull = false;
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (ctx, item) {
                    bool isFull = false;

                    bool display = !dayList[item].isAfter(_today) &&
                        ref
                            .watch(habitProvider.notifier)
                            .getTodayHabit(dayList[item])
                            .isNotEmpty;

                    bool accessedPreviousScore = previousFull;
                    if (display) {
                      isFull = ratioComputing([dayList[item]], ref) == 100;
                      previousFull = isFull;
                    }

                    return InkWell(
                      onTap: () {
                        _pickDay(dayList[item]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedDay == dayList[item]
                                ? const Color.fromARGB(255, 51, 51, 51)
                                : null),
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                DaysUtility
                                    .NumberToSign[dayList[item].weekday]!,
                                style: TextStyle(
                                    // fontWeight: _today == dayList[item]
                                    //     ? FontWeight.bold
                                    //     : null,
                                    fontSize: 14,
                                    color: _today.compareTo(dayList[item]) >= 0
                                        ? Colors.white
                                        : Colors.grey)),
                            const SizedBox(height: 3),
                            Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  if (accessedPreviousScore &&
                                      isFull &&
                                      display)
                                    Positioned(
                                        right: 20,
                                        child: Container(
                                          width: 20,
                                          height: 4,
                                          color: RatingUtility.getRatingColor(
                                            notationComputing(
                                                    [dayList[item]], ref)! /
                                                2,
                                          ),
                                        )),
                                  Container(
                                      alignment: Alignment.center,
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                          color: display && isFull
                                              ? RatingUtility.getRatingColor(
                                                  notationComputing(
                                                          [dayList[item]],
                                                          ref)! /
                                                      2,
                                                )
                                              : _selectedDay == dayList[item]
                                                  ? const Color.fromARGB(
                                                      255, 51, 51, 51)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2,
                                            color: getCircleColor(
                                                dayList[item], isFull,
                                                time: time),
                                          )),
                                      child: Text(dayList[item].day.toString(),
                                          style: TextStyle(
                                            color: isFull
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : null,
                                          ))),
                                ])
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ScoreCard(
            _selectedDay,
            score,
            full: ratio == 100,
            time: time,
          )
        ],
      ),
    );
  }
}
