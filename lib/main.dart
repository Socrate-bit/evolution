import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return ColorsScreen();
    return MaterialApp(
      theme: themeData,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // FirebaseAuth.instance.signOut();
          UserData? userdata = ref.watch(userDataProvider);
          if (snapshot.hasError) {
            return const Center(
                child: Text('Something went wrong, try later...'));
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              userdata == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && userdata == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
