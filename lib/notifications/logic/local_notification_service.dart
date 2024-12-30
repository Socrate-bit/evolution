import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timeZone;
import 'package:timezone/timezone.dart' as timeZone;
import 'package:tracker_v1/notifications/data/basic_notification_model.dart';

class LocalNotificationService {
  LocalNotificationService._privateConstructor();

  static final LocalNotificationService _instance =
      LocalNotificationService._privateConstructor();

  factory LocalNotificationService() {
    return _instance;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> askPermissions() async {
    final bool? resultMac = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final bool? resultIos = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static _notificationDetails() async {
    return NotificationDetails(
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails('channel name', 'channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
            enableVibration: true,
            playSound: true,
            styleInformation: BigTextStyleInformation('')));
  }

  static Future<void> instantNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    await flutterLocalNotificationsPlugin
        .show(0, title, body, await _notificationDetails(), payload: payload);
  }

  static Future<void> scheduleNotification(
      {int? id,
      String? title,
      String? body,
      required DateTime scheduledDate,
      String? payload}) async {
    id ??= (scheduledDate.millisecondsSinceEpoch / 1000).toInt();

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    timeZone.initializeTimeZones();
    timeZone.setLocalLocation(timeZone.getLocation(currentTimeZone));

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        timeZone.TZDateTime.from(scheduledDate, timeZone.local),
        await _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  static Future<void> scheduleBasicNotificationList(
      List<BasicNotification> allScheduledNotification) async {
    for (BasicNotification notification in allScheduledNotification) {
      await LocalNotificationService.scheduleNotification(
          id: (notification.schedule.millisecondsSinceEpoch / 1000).toInt(),
          title: notification.title,
          body: notification.body,
          scheduledDate: notification.schedule);
    }
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> retrieveNotificationList() async {
    List notificationRequest =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    List notification =
        await flutterLocalNotificationsPlugin.getActiveNotifications();

    print('###############################################');
    print('Pending notification: $notificationRequest');
    print('Active notification: $notification');
    print('###############################################');
  }
}
