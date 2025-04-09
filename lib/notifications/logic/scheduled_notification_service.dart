import 'dart:collection';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/notifications/data/basic_notification_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';

class ScheduledHabitNotificationService {
  Future<List<BasicNotification>> getNextScheduledNotifications(ref) async {
    List<BasicNotification> allScheduledNotification = [];

    // Get habit schedule 2 days ahead
    LinkedHashMap<Habit, (Schedule?, HabitRecap?)> todayHabitScheduleMap =
        ref.read(scheduleCacheProvider(today));
    LinkedHashMap<Habit, (Schedule?, HabitRecap?)> tomorrowHabitScheduleMap =
        ref.read(scheduleCacheProvider(tomorrow));

    // Get today and tomorrow notifications
    List<BasicNotification> todayNotifications =
        _getNotificationFromSchedules(todayHabitScheduleMap, today);
    List<BasicNotification> tomorrowNotifications =
        _getNotificationFromSchedules(tomorrowHabitScheduleMap, tomorrow);
    List<BasicNotification> inTwoDaysNotifications =
        _getNotificationFromSchedules(tomorrowHabitScheduleMap, inTwoDays);

    allScheduledNotification.addAll(todayNotifications);
    allScheduledNotification.addAll(tomorrowNotifications);
    allScheduledNotification.addAll(inTwoDaysNotifications);

    if (Platform.isIOS && allScheduledNotification.length > 64) {
      allScheduledNotification = allScheduledNotification.sublist(0, 64);
    }

    return allScheduledNotification;
  }

  List<BasicNotification> _getNotificationFromSchedules(
      LinkedHashMap<Habit, (Schedule?, HabitRecap?)> schedules, DateTime date) {
    List<BasicNotification> notifications = [];

    // Loop through each schedule
    for (MapEntry<Habit, (Schedule?, HabitRecap?)> schedule
        in schedules.entries) {
      if (schedule.value.$1 == null) {
        continue;
      }

      Habit habit = schedule.key;
      Schedule todaySchedule = schedule.value.$1!;
      TimeOfDay? todayHabitTime =
          schedule.value.$1!.timesOfTheDay?[date.weekday - 1];
      List<int>? habitNotification = todaySchedule.notification;

      if (habitNotification == null ||
          todayHabitTime == null ||
          habitNotification.isEmpty) {
        continue;
      }

      // Convert notification time to notification date
      for (int notificationTime in habitNotification) {
        TimeOfDay notificationShift = TimeOfDay(
          hour: notificationTime ~/ 60,
          minute: notificationTime % 60,
        );

        DateTime notificationDailyTime = DateTime(
            date.year,
            date.month,
            date.day,
            todayHabitTime.hour - notificationShift.hour,
            todayHabitTime.minute - notificationShift.minute);

        if (notificationDailyTime.isBefore(DateTime.now())) {
          continue;
        }

        notifications.add(BasicNotification(notificationDailyTime, habit.name,
            _getNotificationText(notificationShift, habit)));
      }
    }

    return notifications;
  }
}

String _getNotificationText(TimeOfDay notificationShift, Habit habit) {
  String duration = notificationShift == TimeOfDay(hour: 0, minute: 0)
      ? 'Is starting now'
      : 'Start in ${_formatDuration(notificationShift.hour, notificationShift.minute)}';

  return '$duration';
}

String _formatDuration(int hour, int minute) {
  String hourText = hour > 0 ? '$hour hour${hour > 1 ? 's' : ''}' : '';
  String minuteText =
      minute > 0 ? '$minute minute${minute > 1 ? 's' : ''}' : '';
  String and = hourText.isNotEmpty && minuteText.isNotEmpty ? ' and ' : '';

  return '$hourText$and$minuteText';
}
