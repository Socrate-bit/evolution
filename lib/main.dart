import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/theme.dart';
import 'package:tracker_v1/screens/others/auth.dart';
import 'package:tracker_v1/screens/others/main_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:tracker_v1/colors.dart';

void main() async {
  WidgetsBinding widgetbinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetbinding);
  runApp(const ProviderScope(child: MyApp()));
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<void> loadData(ref) async {
    await ref.read(userDataProvider.notifier).loadData();
    await ref.read(habitProvider.notifier).loadData();
    await ref.read(trackedDayProvider.notifier).loadData();
    await ref.read(recapDayProvider.notifier).loadData();
  }

  void cleanData(ref) {
    ref.read(habitProvider.notifier).cleanState();
    ref.read(trackedDayProvider.notifier).cleanState();
    ref.read(recapDayProvider.notifier).cleanState();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return ColorsScreen();
    return MaterialApp(
      theme: themeData,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          dynamic state = snapshot.connectionState;
          // FirebaseAuth.instance.signOut();
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData) {
            Future.delayed(const Duration(seconds: 10)).then((_) {
              if (snapshot.hasData && ref.read(userDataProvider) == null) {
                cleanData(ref);
                FirebaseAuth.instance.signOut();
              }
            });

            {
              // Use FutureBuilder to wait for loadData to finish before rendering the MainScreen
              return FutureBuilder<void>(
                future: loadData(ref), // Load data here
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading spinner while data is loading
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    // Data is loaded, show MainScreen
                    return const MainScreen();
                  }
                },
              );
            }
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
