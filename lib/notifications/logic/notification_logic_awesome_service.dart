// import 'dart:collection';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tracker_v1/global/data/schedule_cache.dart';
// import 'package:tracker_v1/global/logic/date_utility.dart';
// import 'package:tracker_v1/new_habit/data/habit_model.dart';
// import 'package:tracker_v1/new_habit/data/schedule_model.dart';

// Future<void> initializeNotifications() async {
//   // Request permission
//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   String? token = await FirebaseMessaging.instance.getToken();
//   print('#############################');
//   print('token: $token');

//   AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'basic_channel',
//         channelName: 'Push Notifications',
//         channelDescription: 'Channel for push notifications',
//         defaultColor: Color(0xFF9D50DD),
//         playSound: true,
//         defaultRingtoneType: DefaultRingtoneType.Alarm,
//         enableLights: true,
//         enableVibration: true,
//         ledColor: Colors.white,
//         importance: NotificationImportance.High,
//       ),
//     ],
//   );

//   // Handle background message
//   FirebaseMessaging.onBackgroundMessage(firebasePushHandler);
// }

// Future<void> firebasePushHandler(RemoteMessage message) async {
//   AwesomeNotifications().createNotificationFromJsonData(message.data);
// }

// Future<List<(String, NotificationSchedule)>> getTodayScheduledNotification(
//     WidgetRef ref) async {
//   List<(String, NotificationSchedule)> todayScheduledNotification = [];

//   // Get habit schedule 2 days ahead
//   LinkedHashMap<Habit, Schedule> todayHabitScheduleMap =
//       ref.read(scheduleCacheProvider(today));
//   LinkedHashMap<Habit, Schedule> tomorrowHabitScheduleMap =
//       ref.read(scheduleCacheProvider(tomorrow));

//   // Loop through each schedule
//   for (MapEntry<Habit, Schedule> schedule in todayHabitScheduleMap.entries) {
//     // Get habit
//     Habit habit = schedule.key;

//     // Get schedule & notification
//     Schedule todaySchedule = schedule.value;
//     TimeOfDay? todayHabitTime =
//         schedule.value.timesOfTheDay?[today.weekday - 1];
//     List<int>? habitNotification = todaySchedule.notification;

//     if (habitNotification == null || todayHabitTime == null) {
//       continue;
//     }

//     // Convert int to notification
//     for (int notificationTime in habitNotification) {
//       // Get notification time

//       TimeOfDay notificationShift = TimeOfDay(
//         hour: notificationTime ~/ 60,
//         minute: notificationTime % 60,
//       );

//       TimeOfDay notificationDailyTime = TimeOfDay(
//         hour: todayHabitTime.hour - notificationShift.hour,
//         minute: todayHabitTime.minute + notificationShift.minute,
//       );

//       // Get the actual system time zone
//       String timeZone =
//           await AwesomeNotifications().getLocalTimeZoneIdentifier();

//       // Get notification schedule
//       NotificationSchedule notificationSchedule = NotificationCalendar(
//         allowWhileIdle: true,
//         repeats: false,
//         hour: notificationDailyTime.hour,
//         minute: notificationDailyTime.minute,
//         second: 0,
//         timeZone: timeZone,
//       );

//       // Get notification text
//       String duration = notificationShift == TimeOfDay(hour: 0, minute: 0)
//           ? 'now'
//           : 'in ${notificationShift.hour} hours and ${notificationShift.minute} minutes';
//       String text = 'The habit ${habit.name} start $duration';

//       // Add to list
//       todayScheduledNotification.add((text, notificationSchedule));
//     }
//   }

//   return todayScheduledNotification;
// }

// void notifyTest() {
//   AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 10,
//       channelKey: 'basic_channel',
//       title: 'Simple Notification',
//       body: 'Simple body',
//       locked: true,
//     ),
//   );
// }
