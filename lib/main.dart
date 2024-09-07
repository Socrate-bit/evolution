import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/screens/navigation.dart';
// import 'package:tracker_v1/colors.dart';

final kcolorTheme = const ColorScheme.dark().copyWith(
    primary: const Color.fromARGB(255, 248, 189, 51),
    secondary: Colors.blue,
    tertiary: Colors.green,
    surfaceBright: const Color.fromARGB(255, 37, 37, 38),
    primaryContainer: Colors.blue,
    surface: const Color.fromARGB(255, 20, 20, 20));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return ColorsScreen();
    return MaterialApp(
      theme: ThemeData().copyWith(
          colorScheme: kcolorTheme,
          iconTheme: const IconThemeData().copyWith(color: Colors.grey),
          inputDecorationTheme:
              const InputDecorationTheme().copyWith(fillColor: Colors.grey)),
      home: const MainScreen(),
    );
  }
}
