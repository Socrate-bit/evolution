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
  titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  titleMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), 
  titleSmall: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
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

final themeData = ThemeData().copyWith(
  colorScheme: kcolorTheme,
  textTheme: kTextTheme,
  iconTheme: const IconThemeData().copyWith(color: Colors.grey),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: kcolorTheme.primary),
  ),
  inputDecorationTheme: const InputDecorationTheme().copyWith(fillColor: Colors.grey),
);
