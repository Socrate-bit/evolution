import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/logic/offset_days.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/daily/display/score_card_widget.dart';

class DailyUpperBarWidget extends ConsumerWidget {
  const DailyUpperBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dailyScreenStateProvider);
    ref.watch(trackedDayProvider);

    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      height: 60,
      child: Row(
        children: [
          _DailyPages(),
          _DailyScoreCard(),
        ],
      ),
    );
  }
}

class _DailyScoreCard extends ConsumerWidget {
  const _DailyScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DailyScreenState dailyScreenState = ref.read(dailyScreenStateProvider);
    ref.watch(trackedDayProvider);

    double? score = evalutationComputing([dailyScreenState.selectedDate], ref);
    double? ratio = completionComputing([dailyScreenState.selectedDate], ref);

    TimeOfDay? selectedDayTime = ref
        .watch(scheduleCacheProvider(dailyScreenState.selectedDate).notifier)
        .getLastTimeOfTheDay(dailyScreenState.selectedDate);

    return ScoreCard(
      dailyScreenState.selectedDate,
      score,
      full: ratio == 100,
      time: dailyScreenState.selectedDate == today ? selectedDayTime : null,
    );
  }
}

class _DailyPages extends ConsumerStatefulWidget {
  const _DailyPages({super.key});

  @override
  ConsumerState<_DailyPages> createState() => _DailyPagesState();
}

class _DailyPagesState extends ConsumerState<_DailyPages> {
  int weekShifts = 0;

  @override
  Widget build(BuildContext context) {
    DailyScreenState dailyScreenState = ref.read(dailyScreenStateProvider);

    return SizedBox(
      width: 300,
      child: PageView.builder(
        controller: dailyScreenState.pageIndex,
        itemBuilder: (ctx, item) {
          weekShifts = item - 52;
          final List<DateTime> weeklyDayList =
              OffsetDays.getWeekDaysFromOffset(-weekShifts);

          bool isPreviousDayFullCompletedState = false;

          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (ctx, item) {
              // Display variables initialization
              bool isFullCompleted = false;
              bool isDisplaying = !weeklyDayList[item].isAfter(today) &&
                  ref
                      .watch(scheduleCacheProvider(weeklyDayList[item]))
                      .isNotEmpty;

              bool isPreviousDayFullCompleted = isPreviousDayFullCompletedState;

              if (isDisplaying) {
                isFullCompleted =
                    completionComputing([weeklyDayList[item]], ref) == 100;
                isPreviousDayFullCompletedState = isFullCompleted;
              }

              return InkWell(
                onTap: () {
                  ref
                      .read(dailyScreenStateProvider.notifier)
                      .updateSelectedDate(weeklyDayList[item]);
                },
                child: _DailyItem(
                  weeklyDay: weeklyDayList[item],
                  isFullCompleted: isFullCompleted,
                  isDisplaying: isDisplaying,
                  isPreviousDayFullCompleted: isPreviousDayFullCompleted,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DailyItem extends ConsumerWidget {
  const _DailyItem({
    required this.weeklyDay,
    required this.isFullCompleted,
    required this.isDisplaying,
    required this.isPreviousDayFullCompleted,
  });

  final DateTime weeklyDay;
  final bool isFullCompleted;
  final bool isDisplaying;
  final bool isPreviousDayFullCompleted;

  Color _getCircleColor(DateTime day, bool isFull, DateTime selectedDay,
      BuildContext context, WidgetRef ref,
      {TimeOfDay? time}) {
    // Compute the last habit time
    DateTime selectedDayNight = DateTime(
        today.year, today.month, today.day, time?.hour ?? 0, time?.minute ?? 0);

    // Empty case or future case
    if (ref.watch(scheduleCacheProvider(day)).isEmpty || day.isAfter(today)) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    DailyScreenState dailyScreenState = ref.read(dailyScreenStateProvider);
    TimeOfDay? lastTimeOfTheDay = ref
        .watch(scheduleCacheProvider(weeklyDay).notifier)
        .getLastTimeOfTheDay(weeklyDay);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: dailyScreenState.selectedDate == weeklyDay
              ? const Color.fromARGB(255, 51, 51, 51)
              : null),
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DaysOfTheWeekUtility.NumberToSign[weeklyDay.weekday]!,
              style: TextStyle(
                  fontWeight: today == weeklyDay ? FontWeight.bold : null,
                  fontSize: 14,
                  color: today.compareTo(weeklyDay) >= 0
                      ? Colors.white
                      : Colors.grey)),
          const SizedBox(height: 3),
          Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isPreviousDayFullCompleted &&
                    isFullCompleted &&
                    isDisplaying)
                  Positioned(
                      right: 20,
                      child: Container(
                        width: 20,
                        height: 4,
                        color: RatingDisplayUtility.ratingToColor(
                          evalutationComputing([weeklyDay], ref)! / 2,
                        ),
                      )),
                Container(
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: isDisplaying && isFullCompleted
                            ? RatingDisplayUtility.ratingToColor(
                                evalutationComputing([weeklyDay], ref)! / 2,
                              )
                            : dailyScreenState.selectedDate == weeklyDay
                                ? const Color.fromARGB(255, 51, 51, 51)
                                : Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: _getCircleColor(weeklyDay, isFullCompleted,
                              dailyScreenState.selectedDate, context, ref,
                              time: lastTimeOfTheDay),
                        )),
                    child: Text(
                      weeklyDay.day.toString(),
                      style: TextStyle(
                          fontWeight:
                              today == weeklyDay ? FontWeight.bold : null,
                          color: isFullCompleted
                              ? Theme.of(context).colorScheme.surface
                              : today.compareTo(weeklyDay) >= 0
                                  ? Colors.white
                                  : Colors.grey),
                    )),
              ])
        ],
      ),
    );
  }
}
