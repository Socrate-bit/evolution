import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/screens/recaps/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/habit_recap.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<DailyScreen> {
  late DateTime date;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    date = DateTime(now.year, now.month, now.day);
  }

  void _startToEndSwiping(Habit habit) {
    if (habit.validationType == ValidationType.binary) {
      TrackedDay trackedDay = TrackedDay(
        userId: FirebaseAuth.instance.currentUser!.uid,
        habitId: habit.habitId,
        date: date,
        done: Validated.yes,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(trackedDay);
    } else if (habit.validationType == ValidationType.evaluation) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => HabitRecapScreen(
          habit,
          date,
        ),
      );
    } else if (habit.validationType == ValidationType.recapDay) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => DailyRecapScreen(date, habit.habitId),
      );
    }
  }

  void _endToStartSwiping(trackedDay, habitId) {
    if (trackedDay == null) return;
    ref.read(trackedDayProvider.notifier).deleteTrackedDay(trackedDay);
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
          TrackedDay? trackedDay =
              trackedDays[todayHabitsList[index].trackedDays[date]];

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
                _endToStartSwiping(trackedDay, todayHabitsList[index].habitId);
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
            ),
          );
        },
      );
    }

    return content;
  }
}
