import 'package:flutter/material.dart';

final kcolorTheme = const ColorScheme.dark().copyWith(
  primary: const Color.fromARGB(255, 248, 189, 51),
  secondary: Colors.blue,
  tertiary: Colors.green,
  surfaceBright: const Color.fromARGB(255, 37, 37, 38),
  primaryContainer: Colors.blue,
  surface: const Color.fromARGB(255, 20, 20, 20),
);

final kTextTheme = const TextTheme().copyWith(
  titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
  titleMedium: const TextStyle(color: Colors.white, fontSize: 20),
  titleSmall: const TextStyle(color: Colors.grey, fontSize: 16),
  bodyLarge: const TextStyle(color: Colors.white),
  bodyMedium: const TextStyle(color: Colors.white),
  bodySmall: const TextStyle(color: Colors.white),
  labelLarge: const TextStyle(color: Colors.white),
  labelMedium: const TextStyle(color: Colors.white),
  labelSmall: const TextStyle(color: Colors.white),
  headlineLarge: const TextStyle(color: Colors.white),
  headlineMedium: const TextStyle(color: Colors.white),
  headlineSmall: const TextStyle(color: Colors.white),
  displayLarge: const TextStyle(color: Colors.white),
  displayMedium: const TextStyle(color: Colors.white),
  displaySmall: const TextStyle(color: Colors.white),
);

final darkThemeData = ThemeData().copyWith(
  colorScheme: kcolorTheme,
  textTheme: kTextTheme,
  iconTheme: const IconThemeData().copyWith(color: Colors.grey),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: kcolorTheme.primary),
  ),
  inputDecorationTheme:
      const InputDecorationTheme().copyWith(fillColor: Colors.grey),
);

final klightColorTheme = const ColorScheme.dark().copyWith(
  primary: const Color.fromARGB(255, 248, 189, 51),
  secondary: Colors.blue,
  tertiary: Colors.green,
  surfaceBright: Colors.white,
  primaryContainer: Colors.blue,
  surface: const Color.fromARGB(202, 255, 255, 255),
);

final klightTextTheme = const TextTheme().copyWith(
  titleLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  titleMedium: const TextStyle(color: Colors.black, fontSize: 18),
  titleSmall: const TextStyle(color: Colors.grey, fontSize: 17),
  bodyLarge: const TextStyle(color: Colors.black),
  bodyMedium: const TextStyle(color: Colors.black),
  bodySmall: const TextStyle(color: Colors.black),
  labelLarge: const TextStyle(color: Colors.black),
  labelMedium: const TextStyle(color: Colors.black),
  labelSmall: const TextStyle(color: Colors.grey, fontSize: 14),
  headlineLarge: const TextStyle(color: Colors.black),
  headlineMedium: const TextStyle(color: Colors.black),
  headlineSmall: const TextStyle(color: Colors.black),
  displayLarge: const TextStyle(color: Colors.black),
  displayMedium: const TextStyle(color: Colors.black),
  displaySmall: const TextStyle(color: Colors.black),
);

final lightThemeData = ThemeData().copyWith(
  colorScheme: klightColorTheme,
  textTheme: klightTextTheme,
  iconTheme: const IconThemeData().copyWith(color: Colors.grey),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: kcolorTheme.primary),
  ),
  inputDecorationTheme:
      const InputDecorationTheme().copyWith(fillColor: Colors.grey),
);

BoxShadow basicShadow = BoxShadow(
  color: Colors.black.withOpacity(0.1), // Soft shadow
  blurRadius: 0,
  spreadRadius: -1,
  blurStyle: BlurStyle.normal,
  offset: Offset(4, 4), // Downward shadow
);

Color add100ToEachChannel(Color color, int x) {
  int r = (color.red + x).clamp(0, 255);
  int g = (color.green + x).clamp(0, 255);
  int b = (color.blue + x).clamp(0, 255);

  return Color.fromARGB(color.alpha, r, g, b);
}
