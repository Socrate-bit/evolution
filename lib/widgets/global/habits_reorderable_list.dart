import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/reordered_day.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';
import 'package:tracker_v1/models/utilities/time_of_day_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/reordered_day.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';

class HabitsReorderableList extends ConsumerStatefulWidget {
  HabitsReorderableList(
      {required this.habitsList,
      this.dailyHabits = false,
      this.date,
      this.habitOrder,
      super.key});

  final List<Habit> habitsList;
  final bool dailyHabits;
  final DateTime? date;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final Map<String, (TimeOfDay?, int)>? habitOrder;

  @override
  ConsumerState<HabitsReorderableList> createState() =>
      _HabitsReorderableListState();
}

class _HabitsReorderableListState extends ConsumerState<HabitsReorderableList> {
  late HabitNotifier habitsNotifier;
  // late List<Habit> habitListCopy;
  final ScrollController listViewScrollController = ScrollController();
  bool viewTimeCursor = false;
  int? cursorPosition;
  TimeOfDay? draggedTime;
  int? newIndex;
  int? draggedItemIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.dailyHabits) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _timer =
              Timer.periodic(const Duration(seconds: 10), (Timer timer) {});
        });
      });
    }
    // Store a reference to the notifier here
    habitsNotifier = ref.read(habitProvider.notifier);
  }

  @override
  void dispose() {
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

    if (cursorIndexPosition + 1 >= habitsList.length) {
      return endOfTheDay;
    }

    if (habitsList[cursorIndexPosition + 1].timeOfTheDay == null &&
        habitsList[cursorIndexPosition].timeOfTheDay == null) {
      draggedTime = null;
      return null;
    }

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
      widget.habitsList[draggedItemIndex!].timeOfTheDay = draggedTime;

      List<Habit> reorderedList = HabitNotifier.orderChange(
          widget.habitsList, draggedItemIndex!, newIndex!);

      Map<String, (TimeOfDay?, int)> habitOrder =
          Map.fromEntries(reorderedList.map(
        (e) => MapEntry(e.habitId, (e.timeOfTheDay, e.orderIndex)),
      ));

      ReorderedDay newReorder = ReorderedDay(
          userId: widget.userId, date: widget.date!, habitOrder: habitOrder);

      if (widget.habitOrder != null) {
        ref.read(ReorderedDayProvider.notifier).updateReorderedDay(newReorder);
      } else {ref.read(ReorderedDayProvider.notifier).addReorderedDay(newReorder);}
    } else {
      ref.read(habitProvider.notifier).updateHabit(
          widget.habitsList[draggedItemIndex!],
          widget.habitsList[draggedItemIndex!].copy()
            ..timeOfTheDay = draggedTime);
      habitsNotifier.databaseOrderChange(draggedItemIndex!, newIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Habit> habitList = widget.habitsList;

    habitList.sort((a, b) => (a.timeOfTheDay == null && b.timeOfTheDay == null)
        ? (a.orderIndex.compareTo(b.orderIndex))
        : compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

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
          physics: const AlwaysScrollableScrollPhysics(),
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
            return HabitWidget(
                key: ObjectKey(habitList[item]),
                date: widget.date,
                habitList: !widget.dailyHabits,
                habit: habitList[item],
                last: item == habitList.length - 1,
                cursor:
                    widget.dailyHabits ? getTimeCursor(habitList, item) : null);
          },
        ),
      ),
    );
  }
}
