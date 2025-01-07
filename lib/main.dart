import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/alldata_manager.dart';
import 'package:tracker_v1/notifications/logic/local_notification_service.dart';
import 'package:tracker_v1/theme.dart';
import 'package:tracker_v1/authentification/auth_screen.dart';
import 'package:tracker_v1/naviguation/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsBinding widgetbinding = WidgetsFlutterBinding.ensureInitialized();
  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification
  await LocalNotificationService.initializeNotifications();
  await LocalNotificationService.askPermissions();

  // Initialize splash screen
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
      home: Platform.isIOS || Platform.isAndroid
          ? UpgradeAlert(
              dialogStyle: UpgradeDialogStyle.cupertino,
              child: MyHomeWidget())
          : MyStreamBuilder(),
    );
  }
}

class MyHomeWidget extends ConsumerStatefulWidget {
  const MyHomeWidget({super.key});

  @override
  ConsumerState<MyHomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends ConsumerState<MyHomeWidget> {
  static const String appGroupId = 'group.productive'; // Add from here
  // static const String androidWidgetName = 'test_homeExtension';

  @override
  void initState() {
    HomeWidget.setAppGroupId(appGroupId);
    super.initState();
  }

  void updateTitleWidget() {
    HomeWidget.saveWidgetData('title_test', 'I m a wonderful widget');
    HomeWidget.updateWidget(
      name: 'home_widget_test',
      iOSName: 'home_widget_test',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyStreamBuilder();
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
          final future = ref.read(dataManagerProvider).loadData();

          return FutureBuilder(
              future: future,
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
