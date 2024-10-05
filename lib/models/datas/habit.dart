import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';

const idGenerator = Uuid();

enum ValidationType { binary, evaluation, recapDay }

enum Ponderation { negligible, additional, valuable, significant, critical }

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);

class Habit {
  Habit(
      {required this.userId,
      habitId,
      required this.icon,
      required this.name,
      this.description,
      this.newHabit,
      required this.frequency,
      required this.weekdays,
      required this.validationType,
      required this.startDate,
      this.endDate,
      this.additionalMetrics,
      this.ponderation = 3,
      required this.orderIndex,
      this.synced = false,
      frequencyChanges})
      : habitId = habitId ?? idGenerator.v4(),
        frequencyChanges = frequencyChanges ?? {today: frequency};

  String userId;
  String habitId;
  IconData icon;
  String name;
  String? description;
  String? newHabit;
  int frequency;
  List<WeekDay> weekdays;
  ValidationType validationType;
  DateTime startDate;
  DateTime? endDate;
  List<String>? additionalMetrics;
  int ponderation;
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
        orderIndex: orderIndex);
  }
}
