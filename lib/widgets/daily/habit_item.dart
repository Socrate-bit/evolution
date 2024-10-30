import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/habits/habit_screen.dart';
import 'package:tracker_v1/screens/recaps/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/habit_recap.dart';

class HabitWidget extends ConsumerWidget {
  const HabitWidget(
      {required this.habit,
      this.date,
      this.last = false,
      this.cursor,
      this.habitList = false,
      super.key});

  final Habit habit;
  final bool last;
  final double? cursor;
  final DateTime? date;
  final bool habitList;

  void _startToEndSwiping(Habit habit, WidgetRef ref, context) {
    if (habit.validationType == HabitType.simple ||
        habit.validationType == HabitType.unique) {
      TrackedDay? trackedDay = ref.read(trackedDayProvider).firstWhereOrNull(
        (td) {
          return td.habitId == habit.habitId && td.date == date;
        },
      );

      if (trackedDay != null) {
        ref.read(trackedDayProvider.notifier).updateTrackedDay(trackedDay);
        return;
      }

      TrackedDay newTrackedDay = TrackedDay(
        userId: FirebaseAuth.instance.currentUser!.uid,
        habitId: habit.habitId,
        date: date!,
        done: Validated.yes,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(newTrackedDay);
    } else if (habit.validationType == HabitType.recap) {
      TrackedDay? oldTrackedDay =
          ref.read(trackedDayProvider).firstWhereOrNull((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) =>
            HabitRecapScreen(habit, date!, oldTrackedDay: oldTrackedDay),
      );
    } else if (habit.validationType == HabitType.recapDay) {
      TrackedDay? trackedDay = ref.read(trackedDayProvider).firstWhereOrNull(
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
            oldDailyRecap: oldRecapDay, oldTrackedDay: trackedDay),
      );
    }
  }

  void _endToStartSwiping(TrackedDay? trackedDay, Habit habit, WidgetRef ref) {
    if (trackedDay == null) return;
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

  String? getCurrentStreak(List<TrackedDay> trackedDays, Habit habit) {
    int streak = -1;
    List<TrackedDay> habitTrackedDays = trackedDays
        .where((TrackedDay trackedDay) =>
            trackedDay.habitId == habit.habitId &&
            (trackedDay.date.isBefore(date!) ||
                trackedDay.date.isAtSameMomentAs(date!)))
        .toList();
    habitTrackedDays.sort((a, b) {
      return a.date.isAfter(b.date) ? -1 : 1;
    });

    DateTime start = date!;
    
    for (TrackedDay trackeDay in habitTrackedDays) {
      start = DateTime(start.year, start.month, start.day);
      if (!habitTrackedDays.map((e) => e.date).contains(start)) {
        break;
      }
      
      if (trackeDay.date != start) continue;
      streak += 1;
      start = trackeDay.date.subtract(const Duration(days: 1));
      while (!habit.weekdays
          .map(
            (e) => DaysUtility.weekDayToNumber[e],
          )
          .contains(start.weekday)) {
        start = start.subtract(const Duration(days: 1));
      }
    }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? streak;
    bool? active;
    StatusAppearance? appearance;
    TrackedDay? trackedDay;
    List<TrackedDay> trackedDays;

    if (!habitList) {
      trackedDays = ref.watch(trackedDayProvider);
      trackedDay = trackedDays.firstWhereOrNull((trackedDay) {
        return trackedDay.habitId == habit.habitId && trackedDay.date == date;
      });
      appearance = trackedDay != null
          ? trackedDay.getStatusAppearance(Theme.of(context).colorScheme)
          : StatusAppearance(
              backgroundColor:
                  habit.color.value == Color.fromARGB(255, 52, 52, 52).value
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : habit.color.withOpacity(0.1),
              elementsColor: Colors.white);

      streak = getCurrentStreak(
        trackedDays,
        habit,
      );

      active = habit.timeOfTheDay == null
          ? DateTime(
                date!.year,
                date!.month,
                date!.day,
              ).compareTo(DateTime.now()) <=
              0
          : DateTime(date!.year, date!.month, date!.day,
                      habit.timeOfTheDay!.hour, habit.timeOfTheDay!.minute)
                  .compareTo(DateTime.now()) <=
              0;
    } else {
      appearance = StatusAppearance(
          backgroundColor:
              habit.color.value == Color.fromARGB(255, 52, 52, 52).value
                  ? const Color.fromARGB(255, 52, 52, 52)
                  : habit.color.withOpacity(0.1),
          elementsColor: Colors.white,
          icon: habit.frequencyChanges.values.toList().reversed.toList()[0] == 0
              ? const Icon(Icons.pause_circle_filled)
              : null);
    }

    Widget content = GestureDetector(
        onTap: () {
          if (!habitList && habit.validationType != HabitType.unique) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => HabitScreen(habit),
            ),
          );
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (!last)
                  Positioned(
                      top: 38,
                      child: Container(
                        color: active != null && active
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        width: 1,
                        height: 24,
                      )),
                if (cursor != null)
                  Positioned(
                      top: 34 + 24 - (24 * (1 - cursor!)),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        height: 8,
                        width: 8,
                      )),
                Container(
                  alignment: Alignment.center,
                  height: 48,
                  width: 50,
                  child: habit.timeOfTheDay != null
                      ? Text(
                          '${habit.timeOfTheDay!.hour.toString().padLeft(2, '0')}:${habit.timeOfTheDay!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              color: active != null && active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                              decorationThickness: 2.5,
                              decorationColor: appearance.elementsColor,
                              fontSize: 16),
                        )
                      : Icon(Icons.circle_outlined,
                          size: 25,
                          color: active != null && active
                              ? Colors.white
                              : Colors.white.withOpacity(0.45)),
                )
              ],
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                height: 48,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: appearance.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(habit.icon, color: appearance.elementsColor),
                      const SizedBox(
                        width: 16,
                      ),
                      Container(
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
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              if (streak != null)
                                Positioned(
                                  top: -6,
                                  right: 18,
                                  child: Text(
                                    streak,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              appearance.icon!,
                            ],
                          ),
                        ),
                    ]),
              ),
            ),
          ],
        ));

    return Dismissible(
        direction:
            !habitList ? DismissDirection.horizontal : DismissDirection.none,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _startToEndSwiping(habit, ref, context);
          } else if (direction == DismissDirection.endToStart) {
            _endToStartSwiping(trackedDay, habit, ref);
          }
          return false;
        },
        key: ObjectKey(habit),
        background: Container(
          color: Theme.of(context).colorScheme.secondary,
        ),
        secondaryBackground: Container(
          color: Colors.red,
        ),
        child: content);
  }
}
