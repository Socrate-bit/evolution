import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/notifications/data/basic_notification_model.dart';
import 'package:tracker_v1/notifications/logic/local_notification_service.dart';
import 'package:tracker_v1/notifications/logic/scheduled_notification_service.dart';

class NotificationsNotifier extends StateNotifier<List<BasicNotification>> {
  final Ref ref;
  final scheduledHabitNotificationService = ScheduledHabitNotificationService();
  final localNotificationService = LocalNotificationService;
  DateTime? lastGenerated;

  NotificationsNotifier(this.ref) : super([]);

  Future<void> fullCycle() async {
    if (ref.read(userDataProvider)?.notificationActivated != true) {
      await deleteNotifications();
      return;
    }

    await deleteNotifications();
    await generateNotifications();
    await scheduleNotifications();
  }

  Future<void> generateNotifications() async {
    final List<BasicNotification> notifications =
        await scheduledHabitNotificationService
            .getNextScheduledNotifications(ref);
    state = notifications;
    lastGenerated = DateTime.now();
  }

  Future<void> scheduleNotifications() async {
    await LocalNotificationService.scheduleBasicNotificationList(state);
  }

  Future<void> cancelNotifications() async {
    await LocalNotificationService.cancelAllNotifications();
  }

  Future<void> deleteNotifications() async {
    await LocalNotificationService.cancelAllNotifications();
    state = [];
  }

  Future<void> scheduleProviderListener() async {
    ref.listen<List<Schedule>>(scheduledProvider, (before, after) async {
      await fullCycle();
    });
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<BasicNotification>>(
        (ref) {
  NotificationsNotifier notifier = NotificationsNotifier(ref);
  notifier.scheduleProviderListener();
  return notifier;
});
