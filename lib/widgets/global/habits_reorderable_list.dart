import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/reordered_day.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/models/utilities/time_of_day_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/reordered_day.dart';
import 'package:tracker_v1/screens/habits/habit_screen.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';

class HabitsReorderableList extends ConsumerStatefulWidget {
  HabitsReorderableList(
      {required this.habitsList,
      this.dailyHabits = false,
      this.date,
      super.key});

  final List<Habit> habitsList;
  final bool dailyHabits;
  final DateTime? date;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  ConsumerState<HabitsReorderableList> createState() =>
      _HabitsReorderableListState();
}

class _HabitsReorderableListState extends ConsumerState<HabitsReorderableList> {
  late dynamic habitsNotifier;
  final ScrollController listViewScrollController = ScrollController();
  bool viewTimeCursor = false;
  int? cursorPosition;
  TimeOfDay? draggedTime;
  int? newIndex;
  int? draggedItemIndex;
  Timer? _timer;
  late Map<String, (TimeOfDay?, int)> habitOrder;

  @override
  void initState() {
    super.initState();

    if (widget.dailyHabits) {
      _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
        setState(() {
          // Refresh the widget every minute
        });
      });
    }
    // Store a reference to the notifier here
    habitsNotifier = ref.read(habitProvider.notifier);
  }

  Future<void> databaseOrderChange() async {
    await habitsNotifier.databaseOrderChange();
  }

  @override
  void dispose() {
    databaseOrderChange();
    listViewScrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  double? getTimeCursor(List<Habit> todayHabit, int index) {
    TimeOfDay clockNow = TimeOfDay.now();
    TimeOfDay? currentItemTime = todayHabit[index].timeOfTheDay;

    if (todayHabit.length == index + 1) {
      return null;
    }

    TimeOfDay? nextItemTime = todayHabit[index + 1].timeOfTheDay;

    if (currentItemTime == null || nextItemTime == null) {
      return null;
    } else if (widget.date!.isAtSameMomentAs(today) &&
        compareTimeOfDay(currentItemTime, clockNow) < 0 &&
        compareTimeOfDay(nextItemTime, clockNow) > 0) {
      double ratio = ((clockNow.hour * 60 + clockNow.minute) -
              (currentItemTime.hour * 60 + currentItemTime.minute)) /
          ((nextItemTime.hour * 60 + nextItemTime.minute) -
              (currentItemTime.hour * 60 + currentItemTime.minute));
      return ratio;
    } else {
      return null;
    }
  }

  TimeOfDay? dragToTime(
      List<Habit> habitsList, int draggedItemIndex, int? cursorPosition) {
    const TimeOfDay startOfTheDay = TimeOfDay(hour: 0, minute: 0);
    const TimeOfDay endOfTheDay = TimeOfDay(hour: 23, minute: 59);
    int rangeInBound;
    int rangeOutBound;
    int itemHeight = 56;

    if (cursorPosition == null) {
      if (habitsList[draggedItemIndex].timeOfTheDay == null) {
        return null;
      }
      return habitsList[draggedItemIndex].timeOfTheDay!;
    }

    int cursorIndexPosition = cursorPosition ~/ itemHeight;

    if (cursorIndexPosition < 0) return startOfTheDay;
    if (cursorIndexPosition >= habitsList.length) return endOfTheDay;

    if (cursorPosition < 0) {
      rangeInBound = startOfTheDay.toMinutes();
    } else if (habitsList[cursorIndexPosition].timeOfTheDay == null) {
      return null;
    } else {
      rangeInBound = habitsList[cursorIndexPosition].timeOfTheDay!.toMinutes();
    }

    if (cursorIndexPosition + 1 == habitsList.length ||
        habitsList[cursorIndexPosition + 1].timeOfTheDay == null) {
      rangeOutBound = endOfTheDay.toMinutes();
    } else {
      rangeOutBound =
          habitsList[cursorIndexPosition + 1].timeOfTheDay!.toMinutes();
    }

    int range = rangeOutBound - rangeInBound;
    int pointedTimeInMinutes =
        (range * (cursorPosition % itemHeight) / itemHeight).toInt() +
            rangeInBound;

    pointedTimeInMinutes = (pointedTimeInMinutes / 5).round() * 5;
    draggedTime = timeOfDayFromMinutes(pointedTimeInMinutes);

    return draggedTime;
  }

  void onReorderEnd() {
    if (widget.dailyHabits) {
      habitOrder[widget.habitsList[draggedItemIndex!].habitId] =
          (draggedTime, newIndex!);
      ReorderedDay newReorder = ReorderedDay(
          userId: widget.userId, date: widget.date!, habitOrder: habitOrder);
      ref.read(ReorderedDayProvider.notifier).addReorderedDay(newReorder);
    } else {
      habitsNotifier.stateOrderChange(draggedItemIndex!, newIndex);
      ref.read(habitProvider.notifier).updateHabit(
          widget.habitsList[draggedItemIndex!],
          widget.habitsList[draggedItemIndex!].copy()
            ..timeOfTheDay = draggedTime);
      setState(() {
        cursorPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Habit> habitList = widget.habitsList
      ..sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    if (widget.dailyHabits) {
      final ReorderedDay? loadedHabitOrder = ref
          .watch(ReorderedDayProvider)
          .firstWhereOrNull(
              (e) => e.userId == widget.userId && e.date == widget.date);

      habitOrder = loadedHabitOrder != null
          ? loadedHabitOrder.habitOrder
          : Map.fromEntries(habitList
              .map((e) => MapEntry(e.habitId, (e.timeOfTheDay, e.orderIndex)))
              .toList());

      if (loadedHabitOrder != null) {
        habitList = habitList
            .map((e) => (habitOrder[e.habitId] != null
                ? (e.copy()
                  ..timeOfTheDay = habitOrder[e.habitId]!.$1
                  ..orderIndex = habitOrder[e.habitId]!.$2)
                : e.copy()))
            .toList();
      }
    }

    habitList.sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    return Container(
      margin: const EdgeInsets.all(8),
      child: Listener(
        onPointerMove: (event) {
          setState(() {
            cursorPosition = event.localPosition.dy.toInt() +
                listViewScrollController.offset.toInt();
          });
        },
        child: ReorderableListView.builder(
          scrollController: listViewScrollController,
          proxyDecorator: (child, index, animation) {
            return Material(
              type: MaterialType.canvas,
              color: Colors.black,
              elevation: 5,
              child: Stack(
                children: [
                  Positioned(
                      child: Text(dragToTime(
                                  habitList, draggedItemIndex!, cursorPosition)
                              ?.format(context) ??
                          '')),
                  child
                ],
              ),
            );
          },
          onReorderStart: (index) {
            setState(() {
              draggedItemIndex = index;
            });
          },
          onReorderEnd: (index) {
            newIndex = index;
            onReorderEnd();
          },
          onReorder: (int oldIndex, int newIndex) {
            newIndex == newIndex;
          },
          itemCount: habitList.length,
          itemBuilder: (ctx, item) {
            return GestureDetector(
              key: ObjectKey(habitList[item]),
              onTap: () {
                if (widget.dailyHabits &&
                    habitList[item].validationType != HabitType.unique) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => HabitScreen(habitList[item]),
                  ),
                );
              },
              child: HabitWidget(
                  date: widget.date,
                  habitList: !widget.dailyHabits,
                  habit: habitList[item],
                  last: item == habitList.length - 1,
                  cursor: widget.dailyHabits
                      ? getTimeCursor(habitList, item)
                      : null),
            );
          },
        ),
      ),
    );
  }
}
