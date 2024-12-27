import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/alldata_manager.dart';
import 'package:tracker_v1/theme.dart';
import 'package:tracker_v1/authentification/auth_screen.dart';
import 'package:tracker_v1/naviguation/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetbinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  AwesomeNotifications().initialize(
    null, // App icon for notifications
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Push Notifications',
        channelDescription: 'Channel for push notifications',
        defaultColor: Color(0xFF9D50DD),
        playSound: true,
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        enableLights: true,
        enableVibration: true,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
  );

  FirebaseMessaging.onBackgroundMessage(_firebasePushHandler);
  FlutterNativeSplash.preserve(widgetsBinding: widgetbinding);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      darkTheme: darkThemeData,
      themeMode: ThemeMode.dark,
      theme: lightThemeData,
      home: UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino, child: MyStreamBuilder()),
    );
  }
}

class MyStreamBuilder extends ConsumerWidget {
  const MyStreamBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool uploadingFlag = ref.watch(firestoreUploadProvider);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.hasData && !uploadingFlag) {
          return FutureBuilder(
              future: ref.read(dataManagerProvider).loadData(),
              builder: (ctx, loadSnapshot) {
                if (loadSnapshot.connectionState == ConnectionState.done) {
                  return const MainScreen();
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            uploadingFlag) {
          return const AuthScreen();
        } else {
          Future.microtask(() => ref.read(dataManagerProvider).cleanData());
          return const AuthScreen();
        }
      },
    );
  }
}

Future<void> _firebasePushHandler(RemoteMessage message) async {
  print('Message from Firebase: ${message.messageId}');

  AwesomeNotifications().createNotificationFromJsonData(message.data, );
}

void notifyTest() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Simple Notification',
      body: 'Simple body',
      locked: true,
    ),
  );
}
