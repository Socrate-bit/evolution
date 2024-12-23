import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';
import 'package:tracker_v1/global/logic/compare_time.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/daily/display/score_card_widget.dart';

class DaySwitch extends ConsumerStatefulWidget {
  const DaySwitch({super.key});

  @override
  ConsumerState<DaySwitch> createState() => _DaySwitchState();
}

class _DaySwitchState extends ConsumerState<DaySwitch> {
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

  @override
  void initState() {
    _pageController = PageController(initialPage: 52);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Color getCircleColor(DateTime day, bool isFull, DateTime selectedDay,
      {TimeOfDay? time}) {
    // Compute the last habit time
    DateTime selectedDayNight = DateTime(
        today.year, today.month, today.day, time?.hour ?? 0, time?.minute ?? 0);

    // Empty case or future case
    if (ref.watch(habitProvider.notifier).getTodayHabit(day).isEmpty ||
        day.isAfter(today)) {
      return selectedDay == day
          ? const Color.fromARGB(255, 51, 51, 51)
          : Theme.of(context).colorScheme.surface;
    }

    // Today case or past case
    if (DateTime.now().isBefore(selectedDayNight) && day == today && !isFull) {
      return selectedDay == day
          ? const Color.fromARGB(255, 51, 51, 51)
          : Theme.of(context).colorScheme.surface;
    }
    return RatingDisplayUtility.ratingToColor(
      evalutationComputing([day], ref)! / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    DailyScreenState dailyScreenState = ref.watch(dailyScreenStateProvider);
    double? score = evalutationComputing([dailyScreenState.selectedDate], ref);
    double? ratio = completionComputing([dailyScreenState.selectedDate], ref);
    TimeOfDay? time;

    time = ref.watch(habitProvider.notifier).getLastTimeOfTheDay(today);

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

                    bool display = !dayList[item].isAfter(today) &&
                        ref
                            .watch(habitProvider.notifier)
                            .getTodayHabit(dayList[item])
                            .isNotEmpty;

                    bool accessedPreviousScore = previousFull;
                    if (display) {
                      isFull = completionComputing([dayList[item]], ref) == 100;
                      previousFull = isFull;
                    }

                    return InkWell(
                      onTap: () {
                        ref
                            .read(dailyScreenStateProvider.notifier)
                            .updateSelectedDate(dayList[item]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                dailyScreenState.selectedDate == dayList[item]
                                    ? const Color.fromARGB(255, 51, 51, 51)
                                    : null),
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                DaysOfTheWeekUtility
                                    .NumberToSign[dayList[item].weekday]!,
                                style: TextStyle(
                                    fontWeight: today == dayList[item]
                                        ? FontWeight.bold
                                        : null,
                                    fontSize: 14,
                                    color: today.compareTo(dayList[item]) >= 0
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
                                          color: RatingDisplayUtility
                                              .ratingToColor(
                                            evalutationComputing(
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
                                              ? RatingDisplayUtility
                                                  .ratingToColor(
                                                  evalutationComputing(
                                                          [dayList[item]],
                                                          ref)! /
                                                      2,
                                                )
                                              : dailyScreenState.selectedDate ==
                                                      dayList[item]
                                                  ? const Color.fromARGB(
                                                      255, 51, 51, 51)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 2,
                                            color: getCircleColor(
                                                dayList[item],
                                                isFull,
                                                dailyScreenState.selectedDate,
                                                time: time),
                                          )),
                                      child: Text(
                                        dayList[item].day.toString(),
                                        style: TextStyle(
                                            fontWeight: today == dayList[item]
                                                ? FontWeight.bold
                                                : null,
                                            color: isFull
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : today.compareTo(
                                                            dayList[item]) >=
                                                        0
                                                    ? Colors.white
                                                    : Colors.grey),
                                      )),
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
            dailyScreenState.selectedDate,
            score,
            full: ratio == 100,
            time: dailyScreenState.selectedDate == today ? time : null,
          )
        ],
      ),
    );
  }
}
