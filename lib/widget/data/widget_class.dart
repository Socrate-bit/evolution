import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final String icon; // SF Symbol name
  final Color color;
  final Duration? duration; // In seconds

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.duration,
  });

  // Conformance to Hashable
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          color == other.color &&
          duration == other.duration;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      duration.hashCode;
}

class Schedule {
  final Map<int, DateTime> timesOfTheDay; // Map weekday to time

  Schedule({required this.timesOfTheDay});
}