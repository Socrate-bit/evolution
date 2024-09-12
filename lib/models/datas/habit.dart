import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';

const idGenerator = Uuid();

enum ValidationType { binary, evaluation, recapDay }

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);

class Habit {
  Habit(
      {required this.userId,
      habitId,
      required this.icon,
      required this.name,
      this.description,
      required this.frequency,
      required this.weekdays,
      required this.validationType,
      required this.startDate,
      this.endDate,
      this.additionalMetrics,
      required this.orderIndex,
      this.synced = false,
      trackedDays,
      frequencyChanges})
      : habitId = habitId ?? idGenerator.v4(),
        trackedDays = trackedDays ?? {},
        frequencyChanges = frequencyChanges ?? {today: frequency};

  String userId;
  String habitId;
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
  int orderIndex;
  Map<DateTime, int> frequencyChanges;
  bool synced;

  Habit copy() {
    return Habit(
        userId: userId,
        habitId: habitId,
        icon: icon,
        name: name,
        description: description,
        frequency: frequency,
        weekdays: weekdays,
        validationType: validationType,
        startDate: startDate,
        endDate: endDate,
        additionalMetrics: additionalMetrics,
        trackedDays: trackedDays,
        orderIndex: orderIndex);
  }
}
