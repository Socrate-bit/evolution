import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';

const idGenerator = Uuid();

enum HabitType { simple, recap, unique, recapDay }
const Map<HabitType, String> habitTypeDescriptions = {
  HabitType.simple: 'Simple habit',
  HabitType.recap: 'Activity evaluation',
  HabitType.unique: 'Unique task',
  HabitType.recapDay: 'Journaling & Emotions',
};


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
      this.timeOfTheDay,
      this.endDate,
      this.additionalMetrics,
      this.ponderation = 3,
      required this.orderIndex,
      this.synced = false,
      required this.color, 
      frequencyChanges})
      : habitId = habitId ?? idGenerator.v4(),
        frequencyChanges = frequencyChanges ?? {today: frequency} {
    validationType == HabitType.unique
        ? endDate = DateTime(startDate.year, startDate.month, startDate.day + 1)
        : endDate = endDate;
  }



  String userId;
  String habitId;
  IconData icon;
  String name;
  String? description;
  String? newHabit;
  int frequency;
  List<WeekDay> weekdays;
  HabitType validationType;
  DateTime startDate;
  TimeOfDay? timeOfTheDay;
  DateTime? endDate;
  List<String>? additionalMetrics;
  int ponderation;
  int orderIndex;
  Color color;
  Map<DateTime, int> frequencyChanges;
  bool synced;

  Habit copy() {
    return Habit(
        userId: userId,
        habitId: habitId,
        icon: icon,
        name: name,
        description: description,
        newHabit : newHabit,
        frequency: frequency,
        weekdays: weekdays,
        validationType: validationType,
        startDate: startDate,
        timeOfTheDay: timeOfTheDay,
        endDate: endDate,
        additionalMetrics: additionalMetrics,
        ponderation: ponderation,
        orderIndex: orderIndex,
        frequencyChanges: frequencyChanges,
        color: color,
        synced: synced);
  }
}
