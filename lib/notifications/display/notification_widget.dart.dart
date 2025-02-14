import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class NotificationField extends ConsumerWidget {
  const NotificationField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule scheduleState = ref.watch(frequencyStateProvider);
    int notificationLength = (scheduleState.notification?.length ?? 0) + 1;

    return SizedBox(
      child: Column(
        children: [
          CustomToolTipTitle(title: 'Notifications:', content: 'Notification'),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            itemCount: notificationLength,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, item) {
              if (item == notificationLength - 1) {
                return _NewNotificationCard();
              }
              return _NotificationCard(
                item: item,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final int item;

  const _NotificationCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule scheduleState = ref.watch(frequencyStateProvider);
    Habit habitState = ref.watch(newHabitStateProvider);
    List<int>? notifications = scheduleState.notification;
    int hour = notifications![item] ~/ 60;
    int minute = notifications[item] % 60;
    String time = hour == 0 && minute == 0
        ? 'At start of habit'
        : '${(hour == 0 ? '' : '${hour}h ')}${(minute == 0 ? '' : '${minute}min ')}before start';

    return BasicCard(
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: habitState.color,
        ),
        title: Text(
          time,
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref
                  .read(frequencyStateProvider.notifier)
                  .deleteNotification(item);
            },
            icon: const Icon(
              Icons.delete,
              size: 20,
              color: Colors.grey,
            )),
      ),
    );
  }
}

class _NewNotificationCard extends ConsumerWidget {
  const _NewNotificationCard();

  void _addNotification(context, WidgetRef ref) {
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
    Habit habitState = ref.watch(newHabitStateProvider);
    Schedule scheduleState = ref.watch(frequencyStateProvider);

    if (scheduleState.notification != null &&
        scheduleState.notification!.length >= 5) {
      return BasicCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              'Max notifications reached',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _addNotification(context, ref);
      },
      child: BasicCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_rounded,
              size: 20,
              color: habitState.color,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Notification',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: habitState.color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class BasicCard extends StatelessWidget {
  final Widget child;

  const BasicCard({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(10)),
          child: child),
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
    setMiddleIndex(currentTime?.minute ??0);
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
