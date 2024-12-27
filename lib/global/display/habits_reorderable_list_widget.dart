import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/modify_habit_dialog.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/time_utility.dart';
import 'package:tracker_v1/global/logic/time_of_day_extent.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/daily/display/habit_item_widget.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';

class HabitReorderableList extends ConsumerStatefulWidget {
  const HabitReorderableList(
      {required this.habitScheduleMap, this.selectedDate, super.key});

  final LinkedHashMap<Habit, Schedule> habitScheduleMap;
  final DateTime? selectedDate;

  @override
  ConsumerState<HabitReorderableList> createState() =>
      _HabitsReorderableListState();
}

class _HabitsReorderableListState extends ConsumerState<HabitReorderableList> {
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

  double? _getTimeCursor(List<Habit> todayHabit, int index) {
    TimeOfDay clockNow = TimeOfDay.now();
    TimeOfDay? currentItemTime = widget
        .habitScheduleMap[_sortedHabitList[index]]!
        .getTimeOfTargetDay(widget.selectedDate);

    if (todayHabit.length == index + 1) {
      return null;
    }

    TimeOfDay? nextItemTime = widget
        .habitScheduleMap[_sortedHabitList[index + 1]]!
        .getTimeOfTargetDay(widget.selectedDate);

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
    TimeOfDay? timeIndexPlusOne;
    TimeOfDay? timeIndex;

    int cursorIndexPosition = _calculateDraggedItemPosition();

    if (cursorIndexPosition + 1 < sortedHabitList.length &&
        cursorIndexPosition >= -1) {
      timeIndexPlusOne = widget
          .habitScheduleMap[_sortedHabitList[cursorIndexPosition + 1]]
          ?.getTimeOfTargetDay(widget.selectedDate);
    }

    if (cursorIndexPosition > -1 &&
        cursorIndexPosition < sortedHabitList.length) {
      timeIndex = widget.habitScheduleMap[_sortedHabitList[cursorIndexPosition]]
          ?.getTimeOfTargetDay(widget.selectedDate);
    }

    if (_draggedItemPosition == null) {
      return timeIndex;
    }

    // Outside the list
    if (cursorIndexPosition < -1) return startOfTheDay;
    if (cursorIndexPosition + 1 > sortedHabitList.length) {
      return null;
    }

    // Inside the list
    if (cursorIndexPosition == -1) {
      rangeInBound = startOfTheDay.toMinutes();
      rangeOutBound = timeIndexPlusOne == null
          ? endOfTheDay.toMinutes()
          : timeIndexPlusOne.toMinutes();
    } else if (cursorIndexPosition + 1 == sortedHabitList.length) {
      if (timeIndex == null) {
        return null;
      }
      rangeInBound = timeIndex.toMinutes();
      rangeOutBound = endOfTheDay.toMinutes();
    } else if (timeIndex != null && timeIndexPlusOne == null) {
      rangeInBound = timeIndex.toMinutes();
      rangeOutBound = endOfTheDay.toMinutes();
    } else if (timeIndexPlusOne == null && timeIndex == null) {
      return null;
    } else {
      rangeInBound = timeIndex!.toMinutes();
      rangeOutBound = timeIndexPlusOne!.toMinutes();
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
    Schedule? oldSchedule =
        ref.read(scheduleCacheProvider(widget.selectedDate))[
            _sortedHabitList[_draggedInitialIndex!]];

    if (oldSchedule == null) {
      return;
    }

    Schedule newSchedule = oldSchedule.copyWith();
    newSchedule.startDate = widget.selectedDate ?? today;

    showModifyHabitDialog(context, ref, newSchedule,
        drag: true,
        isHabitListPage: widget.selectedDate == null,
        newTime: _computedDraggedTime);
  }

  @override
  Widget build(BuildContext context) {
    _sortedHabitList = widget.habitScheduleMap.keys.toList();

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
            TimeOfDay? initialTime = widget
                .habitScheduleMap[_sortedHabitList[_draggedInitialIndex!]]!
                .timesOfTheDay?[(widget.selectedDate?.weekday ?? 1) - 1];
            _inDragging = false;
            if (_computedDraggedTime != initialTime &&
                _cursorPosition != null) {
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
