import 'package:background_fetch/background_fetch.dart';
import 'package:tracker_v1/notifications/data/scheduled_notifications_state.dart';

Future<void> initializeBackgroundFetch(ref) async {
// Step 1:  Configure BackgroundFetch as usual.
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 1000,
          stopOnTerminate: false,
          enableHeadless: true,
          forceAlarmManager: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE), (String taskId) async {
    // <-- Event callback.
    // This is the fetch-event callback.
    await ref.read(notificationsProvider.notifier).fullCycle();

    // Use a switch statement to route task-handling.
    switch (taskId) {
      case 'com.transistorsoft.customtask':
        print("Received custom task");
        break;
      default:
        print("Default fetch task");
    }
    // Finish, providing received taskId.
    BackgroundFetch.finish(taskId);
  }, (String taskId) async {
    // <-- Event timeout callback
    // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  });
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task, ref) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  await ref.read(notificationsProvider.notifier).fullCycle();
  BackgroundFetch.finish(taskId);
}

Future<void> printStatus() async {
  int status = await BackgroundFetch.status;
  print('[BackgroundFetch] status: $status');
}
