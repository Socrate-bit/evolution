import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/habit/data/habit_status_appearance.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_repository.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/habit/habit_screen.dart';
import 'package:tracker_v1/recap/simple_recap_screen.dart';
import 'package:tracker_v1/recap/daily_recap_screen.dart';
import 'package:tracker_v1/recap/activity_recap_screen.dart';
import 'package:tracker_v1/theme.dart';

class HabitWidget extends ConsumerWidget {
  const HabitWidget(
      {required this.habit,
      this.date,
      this.isLastItem = false,
      this.timeMarker,
      this.habitList = false,
      super.key});

  final Habit habit;
  final bool isLastItem;
  final double? timeMarker;
  final DateTime? date;
  final bool habitList;

  void _startToEndSwiping(Habit habit, WidgetRef ref, context) {
    if (habit.validationType == HabitType.unique) {
      HabitRecap? trackedDay = ref.read(trackedDayProvider).firstWhereOrNull(
        (td) {
          return td.habitId == habit.habitId && td.date == date;
        },
      );

      if (trackedDay != null) {
        ref.read(trackedDayProvider.notifier).updateTrackedDay(trackedDay);
        return;
      }

      HabitRecap newTrackedDay = HabitRecap(
        userId: FirebaseAuth.instance.currentUser!.uid,
        habitId: habit.habitId,
        date: date!,
        done: Validated.yes,
        dateOnValidation: today,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(newTrackedDay);
    } else if (habit.validationType == HabitType.simple) {
      HabitRecap? oldTrackedDay =
          ref.read(trackedDayProvider).firstWhereOrNull((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => BasicRecapScreen(
          habit,
          date!,
          oldTrackedDay: oldTrackedDay,
          validated: oldTrackedDay?.done != null &&
                  oldTrackedDay?.done != Validated.notYet
              ? oldTrackedDay!.done
              : Validated.yes,
        ),
      );
    } else if (habit.validationType == HabitType.recap) {
      HabitRecap? oldTrackedDay =
          ref.read(trackedDayProvider).firstWhereOrNull((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => HabitRecapScreen(habit, date!,
            oldTrackedDay: oldTrackedDay,
            validated: oldTrackedDay?.done != null &&
                    oldTrackedDay?.done != Validated.notYet
                ? oldTrackedDay!.done
                : Validated.yes),
      );
    } else if (habit.validationType == HabitType.recapDay) {
      HabitRecap? oldTrackedDay = ref.read(trackedDayProvider).firstWhereOrNull(
        (td) {
          return td.habitId == habit.habitId && td.date == date;
        },
      );

      RecapDay? oldRecapDay = ref.read(recapDayProvider).firstWhereOrNull((td) {
        return td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => DailyRecapScreen(date!, habit,
            oldDailyRecap: oldRecapDay,
            oldTrackedDay: oldTrackedDay,
            validated: oldTrackedDay?.done != null &&
                    oldTrackedDay?.done != Validated.notYet
                ? oldTrackedDay!.done
                : Validated.yes),
      );
    }
  }

  void _endToStartSwiping(
      HabitRecap? trackedDay, Habit habit, WidgetRef ref, context) {
    if (trackedDay == null || trackedDay.done == Validated.notYet) {
      showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (ctx) => BasicRecapScreen(
                habit,
                date!,
                oldTrackedDay: trackedDay,
                validated: Validated.no,
              ));
      return;
    }
    ref.read(trackedDayProvider.notifier).deleteTrackedDay(trackedDay);
    if (habit.validationType == HabitType.recapDay) {
      RecapDay? oldRecapDay = ref.read(recapDayProvider).firstWhereOrNull(
        (td) {
          return td.date == date;
        },
      );
      if (oldRecapDay != null) {
        ref.read(recapDayProvider.notifier).deleteRecapDay(oldRecapDay);
      }
    }
  }

  String? _displayCurrentStreak(List<HabitRecap> trackedDays, ref) {
    int streak = getCurrentStreak(date!, habit, ref);

    if (streak < 1) {
      return null;
    } else if (streak < 7) {
      return '🔥${streak.toString()}';
    } else if (streak < 14) {
      return '🔥🔥${streak.toString()}';
    } else if (streak < 30) {
      return '🔥🔥🔥${streak.toString()}';
    } else if (streak < 61) {
      return '🔥🔥🔥🔥${streak.toString()}';
    } else if (streak < 122) {
      return '🔥🔥🔥🔥🔥${streak.toString()}';
    } else if (streak < 365) {
      return '🔥🔥🔥🔥🔥🔥${streak.toString()}';
    } else {
      return '🔥🔥🔥🔥🔥🔥🔥${streak.toString()}';
    }
  }

  bool _isPastCurrentTime(TimeOfDay? time) {
    return time == null
        ? DateTime(
              date!.year,
              date!.month,
              date!.day,
            ).compareTo(DateTime.now()) <=
            0
        : DateTime(date!.year, date!.month, date!.day, time.hour, time.minute)
                .compareTo(DateTime.now()) <=
            0;
  }

  HabitStatusAppearance _getStatusAppearance(
      HabitRecap? trackedDay, bool? pastCurrentTime, context, ref) {
    if (!habitList) {
      return trackedDay != null && trackedDay.done != Validated.notYet
          ? trackedDay.getStatusAppearance(Theme.of(context).colorScheme)
          : HabitStatusAppearance(
              backgroundColor:
                  habit.color.value == Color.fromARGB(255, 52, 52, 52).value
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : habit.color.withOpacity(0.1),
              elementsColor: pastCurrentTime != null && pastCurrentTime!
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),);
    } else {
      return HabitStatusAppearance(
          backgroundColor:
              habit.color.value == Color.fromARGB(255, 52, 52, 52).value
                  ? const Color.fromARGB(255, 52, 52, 52)
                  : habit.color.withOpacity(0.1),
          elementsColor: Colors.white,
          icon: ref.read(habitProvider.notifier).isHabitCurrentlyPaused(habit)
              ? const Icon(Icons.pause_circle_filled)
              : null);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? currentStreak;
    bool? pastCurrentTime;
    HabitStatusAppearance? appearance;
    HabitRecap? trackedDay;
    Schedule? schedule;
    TimeOfDay? time;
    List<HabitRecap> trackedDays;

    if (!habitList) {
      schedule = ref
          .watch(scheduledProvider.notifier)
          .getHabitTargetDaySchedule(habit, date!);
      trackedDays = ref.watch(trackedDayProvider);
      trackedDay = trackedDays.firstWhereOrNull((trackedDay) {
        return trackedDay.habitId == habit.habitId && trackedDay.date == date;
      });

      currentStreak = _displayCurrentStreak(
        trackedDays,
        ref,
      );

      time = schedule.timesOfTheDay?[date!.weekday - 1];
      pastCurrentTime = _isPastCurrentTime(time);
    } else {
      schedule =
          ref.watch(scheduledProvider.notifier).getHabitDefaultSchedule(habit);
      trackedDays = ref.watch(trackedDayProvider);
      time = schedule.timesOfTheDay?[0];
    }

    appearance = _getStatusAppearance(trackedDay, pastCurrentTime,context, ref);
    
    return Dismissible(
        direction:
            !habitList ? DismissDirection.horizontal : DismissDirection.none,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _startToEndSwiping(habit, ref, context);
          } else if (direction == DismissDirection.endToStart) {
            _endToStartSwiping(trackedDay, habit, ref, context);
          }
          return false;
        },
        key: ObjectKey(habit),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
          ),
        ),
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => HabitScreen(habit, dateOpened: date),
                ),
              );
            },
            child: Row(
              children: [
                TimeFrame(
                    time: time,
                    isLastItem: isLastItem,
                    timeMarker: timeMarker,
                    pastCurrentTime: pastCurrentTime,
                    appearance: appearance),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: HabitContainer(
                    habit: habit,
                    appearance: appearance,
                    currentStreak: currentStreak,
                  ),
                ),
              ],
            )));
  }
}

class TimeFrame extends StatelessWidget {
  const TimeFrame({
    this.time,
    required this.isLastItem,
    required this.timeMarker,
    required this.pastCurrentTime,
    required this.appearance,
    super.key,
  });

  final TimeOfDay? time;
  final bool isLastItem;
  final double? timeMarker;
  final bool? pastCurrentTime;
  final HabitStatusAppearance? appearance;

  @override
  Widget build(BuildContext context) {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Vertical line
          if (!isLastItem)
            Positioned(
                top: 38,
                child: Container(
                  color: pastCurrentTime != null && pastCurrentTime!
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  width: 1,
                  height: 24,
                )),

          // Time marker
          if (timeMarker != null)
            Positioned(
                top: 34 + 24 - (24 * (1 - timeMarker!)),
                child: Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  height: 8,
                  width: 8,
                )),

          // Time of the day
          Container(
            alignment: Alignment.center,
            height: 48,
            width: 50,
            child: time != null
                ? Text(
                    '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: pastCurrentTime != null && pastCurrentTime!
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        decorationThickness: 2.5,
                        decorationColor: appearance!.elementsColor,
                        fontSize: 16),
                  )
                : Icon(Icons.circle_outlined,
                    size: 25,
                    color: pastCurrentTime != null && pastCurrentTime!
                        ? Colors.white
                        : Colors.white.withOpacity(0.45)),
          )
        ]);
  }
}

class HabitContainer extends StatelessWidget {
  const HabitContainer({
    required this.habit,
    required this.appearance,
    required this.currentStreak,
    super.key,
  });

  final Habit habit;
  final HabitStatusAppearance appearance;
  final String? currentStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      height: 48,
      decoration: BoxDecoration(
          boxShadow: appearance.icon != null ? [basicShadow] : null,
          shape: BoxShape.rectangle,
          color: appearance.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(habit.icon, color: appearance.elementsColor),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          width: 200,
          child: Text(
            habit.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: appearance.elementsColor,
                decoration: appearance.lineThrough,
                decorationThickness: 2.5,
                decorationColor: appearance.elementsColor,
                fontSize: 16),
          ),
        ),
        const Spacer(),
        if (appearance.icon != null)
          SizedBox(
              height: 30,
              child: HabitStatusTrailingElement(
                currentStreak: currentStreak,
                appearance: appearance,
              )),
      ]),
    );
  }
}

class HabitStatusTrailingElement extends StatelessWidget {
  final String? currentStreak;
  final HabitStatusAppearance appearance;

  const HabitStatusTrailingElement({
    required this.currentStreak,
    required this.appearance,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (currentStreak != null)
          Positioned(
            top: -6,
            right: 18,
            child: Text(
              currentStreak!,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.w900),
            ),
          ),
        appearance.icon!,
      ],
    );
  }
}
