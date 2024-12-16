import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/daily/data/custom_day_model.dart';
import 'package:tracker_v1/global/logic/compare_time.dart';
import 'package:tracker_v1/daily/logic/sort_habits_utility.dart';
import 'package:tracker_v1/global/logic/time_of_day_extent.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/daily/data/reorderedday_provider.dart';
import 'package:tracker_v1/daily/display/habit_item_widget.dart';

class HabitList extends ConsumerStatefulWidget {
  const HabitList(
      {required this.displayedHabitList,
      this.selectedDate,
      this.habitsPersonalisedOrder,
      super.key});

  final List<Habit> displayedHabitList;
  final DateTime? selectedDate;
  final Map<String, (TimeOfDay?, int)>? habitsPersonalisedOrder;

  @override
  ConsumerState<HabitList> createState() => _HabitsReorderableListState();
}

class _HabitsReorderableListState extends ConsumerState<HabitList> {
  final ScrollController _listViewScrollController = ScrollController();
  Timer? _timer;
  static const int _itemHeight = 56;
  late List<Habit> _sortedHabitList;

  // Dragging variables
  bool _inDragging = false;
  int? _draggedInitialIndex;
  double? _cursorPosition;
  double? _cursorPositionCorection;
  int? _draggedItemPosition;
  TimeOfDay? _computedDraggedTime;
  int? _draggedNewIndex;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {});
        });
      });
    }
  }

  @override
  void dispose() {
    _listViewScrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _sortedHabitList = sortHabits(widget.displayedHabitList, widget.selectedDate, ref);

    return Container(
      margin: const EdgeInsets.all(8),
      child: Listener(
        onPointerDown: (event) {
          _updatePointerCorrection(event);
        },
        onPointerMove: (event) {
          _updateDraggingVariables(event);
        },
        child: ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollController: _listViewScrollController,
          proxyDecorator: (child, index, animation) {
            return ProxyDecoratorWidget(
                timeText: _computedDraggedTime?.format(context) ?? '',
                child: child);
          },
          onReorderStart: (initialIndex) {
            _inDragging = true;
            _draggedInitialIndex = initialIndex;
          },
          onReorderEnd: (newIndex) {
            _inDragging = false;
            _draggedNewIndex = newIndex;
            if (_computedDraggedTime != _sortedHabitList[_draggedInitialIndex!].timeOfTheDay && _cursorPosition != null) {
              _onReorderEnd(ref.read(habitProvider.notifier));
            }
          },
          onReorder: (oldIndex, newIndex) {},
          itemCount: _sortedHabitList.length,
          itemBuilder: (ctx, item) {
            return HabitWidget(
                key: ObjectKey(_sortedHabitList[item]),
                date: widget.selectedDate,
                habitList: !(widget.selectedDate != null),
                habit: _sortedHabitList[item],
                isLastItem: item == _sortedHabitList.length - 1,
                timeMarker: widget.selectedDate != null
                    ? _getTimeCursor(_sortedHabitList, item)
                    : null);
          },
        ),
      ),
    );
  }

  double? _getTimeCursor(List<Habit> todayHabit, int index) {
    TimeOfDay clockNow = TimeOfDay.now();
    TimeOfDay? currentItemTime = todayHabit[index].timeOfTheDay;

    if (todayHabit.length == index + 1) {
      return null;
    }

    TimeOfDay? nextItemTime = todayHabit[index + 1].timeOfTheDay;

    if (currentItemTime == null || nextItemTime == null) {
      return null;
    } else if (widget.selectedDate!.isAtSameMomentAs(today) &&
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

// Update dragging variables functions
  void _updatePointerCorrection(PointerDownEvent event) {
    double cursorPosition =
        event.localPosition.dy + _listViewScrollController.offset;
    _cursorPositionCorection = cursorPosition >= 0
        ? (cursorPosition % _itemHeight) - (_itemHeight / 2)
        : (0 - (_itemHeight / 2));
  }

  void _updateDraggingVariables(PointerMoveEvent event) {
    _cursorPosition = event.localPosition.dy;
    _draggedItemPosition = (_cursorPosition! +
            _listViewScrollController.offset -
            _cursorPositionCorection!)
        .toInt();
    if (_inDragging) {
      setState(() {
        _computedDraggedTime = _dragToTime(_sortedHabitList);
      });
    } else {
      return;
    }
  }

  TimeOfDay? _dragToTime(List<Habit> sortedHabitList) {
    const TimeOfDay startOfTheDay = TimeOfDay(hour: 0, minute: 0);
    const TimeOfDay endOfTheDay = TimeOfDay(hour: 23, minute: 59);
    int rangeInBound;
    int rangeOutBound;

    if (_draggedItemPosition == null) {
      return sortedHabitList[_draggedInitialIndex!].timeOfTheDay!;
    }

    int cursorIndexPosition = _calculateDraggedItemPosition();

    // Outside the list
    if (cursorIndexPosition < -1) return startOfTheDay;
    if (cursorIndexPosition + 1 > sortedHabitList.length) {
      return null;
    }

    // Inside the list
    if (cursorIndexPosition == -1) {
      rangeInBound = startOfTheDay.toMinutes();
      rangeOutBound = sortedHabitList[cursorIndexPosition + 1].timeOfTheDay ==
              null
          ? endOfTheDay.toMinutes()
          : sortedHabitList[cursorIndexPosition + 1].timeOfTheDay!.toMinutes();
    } else if (cursorIndexPosition + 1 == sortedHabitList.length) {
      if (sortedHabitList[cursorIndexPosition].timeOfTheDay == null) {
        return null;
      }
      rangeInBound =
          sortedHabitList[cursorIndexPosition].timeOfTheDay!.toMinutes();
      rangeOutBound = endOfTheDay.toMinutes();
    } else if (sortedHabitList[cursorIndexPosition].timeOfTheDay != null &&
        sortedHabitList[cursorIndexPosition + 1].timeOfTheDay == null) {
      rangeInBound =
          sortedHabitList[cursorIndexPosition].timeOfTheDay!.toMinutes();
      rangeOutBound = endOfTheDay.toMinutes();
    } else if (sortedHabitList[cursorIndexPosition + 1].timeOfTheDay == null &&
        sortedHabitList[cursorIndexPosition].timeOfTheDay == null) {
      return null;
    } else {
      rangeInBound =
          sortedHabitList[cursorIndexPosition].timeOfTheDay!.toMinutes();
      rangeOutBound =
          sortedHabitList[cursorIndexPosition + 1].timeOfTheDay!.toMinutes();
    }

    return _calculateDraggedTime(rangeInBound, rangeOutBound);
  }

  int _calculateDraggedItemPosition() {
    double draggedItemPositionRelativeFirstItem =
        _draggedItemPosition! - (_itemHeight / 2);
    int cursorIndexPosition =
        (draggedItemPositionRelativeFirstItem) ~/ _itemHeight -
            (draggedItemPositionRelativeFirstItem < 0 ? 1 : 0);
    return cursorIndexPosition;
  }

  TimeOfDay _calculateDraggedTime(int rangeInBound, int rangeOutBound) {
    double draggedItemPositionRelativeFirstItem =
        _draggedItemPosition! - (_itemHeight / 2);
    int range = rangeOutBound - rangeInBound;
    int pointedTimeInMinutes = (rangeInBound +
            (draggedItemPositionRelativeFirstItem % _itemHeight) /
                _itemHeight *
                range)
        .toInt();

    // Round to the nearest 5 minutes
    int pointedTimeInMinutesRounded = (pointedTimeInMinutes / 5).round() * 5;

    return timeOfDayFromMinutes(pointedTimeInMinutesRounded);
  }

// On reorder end function
  void _onReorderEnd(HabitNotifier habitsNotifier) {
    if (widget.selectedDate != null) {
      _updateReorderState();
    } else {
      _updateHabitState(habitsNotifier);
    }
  }

  void _updateReorderState() {
    _updateSortedList();
    CustomDay newReorder = _createReorderedDay();
    if (widget.habitsPersonalisedOrder != null) {
      ref.read(reorderedDayProvider.notifier).updateReorderedDay(newReorder);
    } else {
      ref.read(reorderedDayProvider.notifier).addReorderedDay(newReorder);
    }
  }

  void _updateSortedList() {
    _sortedHabitList[_draggedInitialIndex!].timeOfTheDay = _computedDraggedTime;
    _sortedHabitList = HabitNotifier.orderChange(
        _sortedHabitList, _draggedInitialIndex!, _draggedNewIndex!);
  }

  CustomDay _createReorderedDay() {
    Map<String, (TimeOfDay?, int)> habitOrder =
        Map.fromEntries(_sortedHabitList.map(
      (e) => MapEntry(e.habitId, (e.timeOfTheDay, e.orderIndex)),
    ));

    return CustomDay(
        userId: FirebaseAuth.instance.currentUser!.uid,
        date: widget.selectedDate!,
        habitOrder: habitOrder);
  }

  void _updateHabitState(HabitNotifier habitsNotifier) {
    ref.read(habitProvider.notifier).updateHabit(
        _sortedHabitList[_draggedInitialIndex!],
        _sortedHabitList[_draggedInitialIndex!].copy()
          ..timeOfTheDay = _computedDraggedTime);
    habitsNotifier.updateStateOrder(_draggedInitialIndex!, _draggedNewIndex!);
  }
}

class ProxyDecoratorWidget extends StatelessWidget {
  final Widget child;
  final String timeText;

  const ProxyDecoratorWidget(
      {required this.child, required this.timeText, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      type: MaterialType.card,
      color: Colors.black.withOpacity(0.5),
      elevation: 5,
      child: Stack(
        children: [
          Positioned(
            child: Text(timeText),
          ),
          child,
        ],
      ),
    );
  }
}
