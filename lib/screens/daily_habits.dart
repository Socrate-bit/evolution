import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/appearance.dart';
import 'package:tracker_v1/models/habit.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/screens/daily_recap.dart';
import 'package:tracker_v1/screens/habit_recap.dart';
import 'package:tracker_v1/widgets/habit_item.dart';
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
        habitId: habit.id,
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
          habit.id,
          date,
        ),
      );
    } else if (habit.validationType == ValidationType.recapDay) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => DailyRecapScreen(
          date, habit.id
        ),
      );
    }
  }

  void _endToStartSwiping(trackedDay, habitId) {
    if (trackedDay == null) return;
    //   TrackedDay trackedDay = TrackedDay(
    //     habitId: habitId,
    //     date: date,
    //     done: Validated.no,
    //   );

    //   ref.read(trackedDayProvider.notifier).addTrackedDay(trackedDay);
    // } else {
    ref.read(trackedDayProvider.notifier).deleteTrackedDay(trackedDay);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final habitsList = ref.watch(habitProvider).where((item) {
      List<int?> weekDaysNumberList = item.weekdays
          .map((day) => weekDayToNumber[day])
          .toList(); //! Caching OR Database?
      return weekDaysNumberList.contains(DateTime.now().weekday);
    }).toList();
    final trackedDays = ref.watch(trackedDayProvider);

    Widget content = const Align(
      child: Text('No habits yet, create one!'),
    );

    if (habitsList.isNotEmpty) {
      content = ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: habitsList.length,
        itemBuilder: (context, index) {
          TrackedDay? trackedDay =
              trackedDays[habitsList[index].trackedDays[date]];

          StatusAppearance? appearance = trackedDay != null
              ? trackedDay.getStatusAppearance(context)
              : StatusAppearance(
                  backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                  elementsColor: Colors.white);

          return Dismissible(
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _startToEndSwiping(habitsList[index]);
              } else if (direction == DismissDirection.endToStart) {
                _endToStartSwiping(trackedDay, habitsList[index].id);
              }
              return false;
            },
            key: ObjectKey(habitsList[index]),
            background: Container(
              color: Theme.of(context).colorScheme.secondary,
            ),
            secondaryBackground: Container(
              color: Colors.red,
            ),
            child: HabitWidget(
              name: habitsList[index].name,
              icon: habitsList[index].icon,
              appearance: appearance,
            ),
          );
        },
      );
    }

    return content;
  }
}
