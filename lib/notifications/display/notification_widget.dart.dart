import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:tracker_v1/new_habit/display/card_list_widget.dart';

class NotificationField extends ConsumerWidget {
  const NotificationField({super.key});

  List<TitledCardItem> _getTitlesCardItems(Schedule scheduleState,
      Habit habitState, BuildContext context, WidgetRef ref) {
    String getNotificationString(int hour, int minute) {
      return hour == 0 && minute == 0
          ? 'At start of habit'
          : '${(hour == 0 ? '' : '${hour}h ')}${(minute == 0 ? '' : '${minute}min ')}before start';
    }

    if (scheduleState.notification == null) {
      return [];
    }

    return scheduleState.notification!.map((notification) {
      int hour = notification ~/ 60;
      int minute = notification % 60;

      Icon icon = Icon(
        Icons.notifications,
        color: habitState.color,
      );

      Text text = Text(
        getNotificationString(hour, minute),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      );

      IconButton iconButton = IconButton(
          onPressed: () {
            int index = scheduleState.notification!.indexOf(notification);
            HapticFeedback.selectionClick();
            ref.read(frequencyStateProvider.notifier).deleteNotification(index);
          },
          icon: const Icon(
            Icons.delete,
            size: 20,
            color: Colors.grey,
          ));

      return TitledCardItem(leading: icon, title: text, trailing: iconButton);
    }).toList();
  }

  void _addNotification(BuildContext context, WidgetRef ref) {
    picker.DatePicker.showPicker(
      context,
      theme: picker.DatePickerTheme(
        containerHeight: 150,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        itemStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        cancelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        doneStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
      showTitleActions: true,
      pickerModel: CustomPicker(),
      onConfirm: (date) {
        ref
            .read(frequencyStateProvider.notifier)
            .addNotification(date.hour * 60 + date.minute);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule scheduleState = ref.watch(frequencyStateProvider);
    Habit habitState = ref.watch(newHabitStateProvider);

    return TitledCardList(
      title: 'Notifications:',
      items: _getTitlesCardItems(scheduleState, habitState, context, ref),
      addTap: () {
        _addNotification(context, ref);
      },
      addColor: habitState.color,
      addTitle: 'Add Notification',
    );
  }
}

class CustomPicker extends picker.CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, '0');
  }

  CustomPicker({DateTime? currentTime, super.locale}) {
    this.currentTime = currentTime ?? DateTime.now();
    setLeftIndex(currentTime?.hour ?? 0);
    setMiddleIndex(currentTime?.minute ?? 0);
    setRightIndex(0);
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return ':';
  }

  @override
  String rightDivider() {
    return '';
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
            currentLeftIndex(), currentMiddleIndex(), 0)
        : DateTime(currentTime.year, currentTime.month, currentTime.day,
            currentLeftIndex(), currentMiddleIndex(), 0);
  }
}
