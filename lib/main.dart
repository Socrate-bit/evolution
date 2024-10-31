import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/data_manager.dart';
import 'package:tracker_v1/theme.dart';
import 'package:tracker_v1/screens/others/auth.dart';
import 'package:tracker_v1/screens/others/main_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetbinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    bool uploadingFlag = ref.watch(firestoreUploadProvider);

    return MaterialApp(
      theme: themeData,
      home: StreamBuilder<User?>(
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
      ),
    );
  }
}
