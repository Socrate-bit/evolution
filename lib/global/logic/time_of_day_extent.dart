import 'package:flutter/material.dart';

extension TimeOfDayExtensions on TimeOfDay {
  int toMinutes() {
    return hour * 60 + minute;
  }
}

TimeOfDay timeOfDayFromMinutes(int minutes) {
  return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
}