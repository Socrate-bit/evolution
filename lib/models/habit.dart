import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum ValidationType { binary, evaluation, recapDay }

const Map<WeekDay, int> weekDayToNumber = {
  WeekDay.monday: 1,
  WeekDay.tuesday: 2,
  WeekDay.wednesday: 3,
  WeekDay.thursday: 4,
  WeekDay.friday: 5,
  WeekDay.saturday: 6,
  WeekDay.sunday: 7,
};

const Map<WeekDay, String> weekDayToSign = {
  WeekDay.monday: "M",
  WeekDay.tuesday: "T",
  WeekDay.wednesday: "W",
  WeekDay.thursday: "Th",
  WeekDay.friday: "F",
  WeekDay.saturday: "S",
  WeekDay.sunday: "Su",
};

class Habit {
  Habit(
      {required this.userId,
      id,
      required this.icon,
      required this.name,
      this.description,
      required this.frequency,
      required this.weekdays,
      required this.validationType,
      required this.startDate,
      this.endDate,
      this.additionalMetrics,
      trackedDays})
      : id = id ?? idGenerator.v4(),
        trackedDays = trackedDays ?? {};

  String userId;
  String id;
  IconData icon;
  String name;
  String? description;
  int frequency;
  List<WeekDay> weekdays;
  ValidationType validationType;
  DateTime startDate;
  DateTime? endDate;
  List<String>? additionalMetrics;
  Map<DateTime, String> trackedDays;

  Habit copy() {
    return Habit(
        userId: userId,
        id: id,
        icon: icon,
        name: name,
        description: description,
        frequency: frequency,
        weekdays: weekdays,
        validationType: validationType,
        startDate: startDate,
        endDate: endDate,
        additionalMetrics: additionalMetrics,
        trackedDays: trackedDays);
  }
}
