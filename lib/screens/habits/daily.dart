import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/habit_recap.dart';
import 'package:tracker_v1/widgets/daily/day_switch.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen(this.dateDisplay, {super.key});
  final Function dateDisplay;

  @override
  ConsumerState<DailyScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<DailyScreen> {
  late DateTime date;
  DateTime now = DateTime.now();
  final _formater = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    if (now.hour >= 2) {
      date = DateTime(now.year, now.month, now.day);
    } else {
      date = DateTime(now.year, now.month, now.day - 1);
    }
  }

  String _displayedDate(DateTime value) {
    if (DateTime(now.year, now.month, now.day) == value) {
      return 'Today';
    } else if (DateTime(now.year, now.month, now.day + 1) == value) {
      return 'Tomorrow';
    } else if (DateTime(now.year, now.month, now.day - 1) == value) {
      return 'Yesterday';
    } else {
      return _formater.format(value);
    }
  }

  void _startToEndSwiping(Habit habit) {
    if (habit.validationType == ValidationType.binary) {
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
        date: date,
        done: Validated.yes,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(newTrackedDay);
    } else if (habit.validationType == ValidationType.evaluation) {
      TrackedDay? oldTrackedDay =
          ref.read(trackedDayProvider).firstWhereOrNull((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) =>
            HabitRecapScreen(habit, date, oldTrackedDay: oldTrackedDay),
      );
    } else if (habit.validationType == ValidationType.recapDay) {
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
        builder: (ctx) => DailyRecapScreen(date, habit,
            oldDailyRecap: oldRecapDay, oldTrackedDay: trackedDay),
      );
    }
  }

  void _endToStartSwiping(TrackedDay? trackedDay, Habit habit) {
    if (trackedDay == null) return;
    ref.read(trackedDayProvider.notifier).deleteTrackedDay(trackedDay);
    if (habit.validationType == ValidationType.recapDay) {
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
            (trackedDay.date.isBefore(date) ||
                trackedDay.date.isAtSameMomentAs(date)))
        .toList();
    habitTrackedDays.sort((a, b) {
      return a.date.isAfter(b.date) ? -1 : 1;
    });

    DateTime start = date;

    for (TrackedDay trackeDay in habitTrackedDays) {
      if (!habitTrackedDays.map((e) => e.date).contains(start)) break;
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
  Widget build(BuildContext context) {
    final habitsList = ref.watch(habitProvider);
    final todayHabitsList =
        ref.watch(habitProvider.notifier).getTodayHabit(date);
    final trackedDays = ref.watch(trackedDayProvider);

    Widget content = const Align(
      child: Text('No habits yet, create one!'),
    );

    if (habitsList.isNotEmpty) {
      content = const Align(child: Text('No habits today 💤'));
    }

    if (todayHabitsList.isNotEmpty) {
      content = ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: todayHabitsList.length,
        itemBuilder: (context, index) {
          TrackedDay? trackedDay = trackedDays.firstWhereOrNull((trackedDay) {
            return trackedDay.habitId == todayHabitsList[index].habitId &&
                trackedDay.date == date;
          });

          StatusAppearance? appearance = trackedDay != null
              ? trackedDay.getStatusAppearance(Theme.of(context).colorScheme)
              : StatusAppearance(
                  backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                  elementsColor: Colors.white);

          return Dismissible(
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _startToEndSwiping(todayHabitsList[index]);
              } else if (direction == DismissDirection.endToStart) {
                _endToStartSwiping(trackedDay, todayHabitsList[index]);
              }
              return false;
            },
            key: ObjectKey(todayHabitsList[index]),
            background: Container(
              color: Theme.of(context).colorScheme.secondary,
            ),
            secondaryBackground: Container(
              color: Colors.red,
            ),
            child: HabitWidget(
              name: todayHabitsList[index].name,
              icon: todayHabitsList[index].icon,
              appearance: appearance,
              streak: getCurrentStreak(trackedDays, todayHabitsList[index]),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        DaySwitch((value) {
          setState(
            () {
              date = value;
              widget.dateDisplay(_displayedDate(value));
            },
          );
        }, date),
        Expanded(child: content),
      ],
    );
  }
}
