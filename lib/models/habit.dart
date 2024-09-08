import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';

const idGenerator = Uuid();
enum ValidationType { binary, evaluation, recapDay }

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
