import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';

const idGenerator = Uuid();

enum HabitType { simple, recap, unique, recapDay }

const Map<HabitType, String> habitTypeDescriptions = {
  HabitType.simple: 'Simple task',
  HabitType.recap: 'Evaluation',
  HabitType.unique: 'Unique task',
  HabitType.recapDay: 'Journaling',
};

enum Ponderation { negligible, low, normal, high, critical }

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
      this.frequencyChanges = const {}})
      : habitId = habitId ?? idGenerator.v4();

  String userId;
  String habitId;
  IconData icon;
  String name;
  String? description;
  String? newHabit;
  HabitType validationType;
  List<String>? additionalMetrics;
  int ponderation;
  int orderIndex;
  Color color;
  bool? synced;
  Map<DateTime, dynamic>? frequencyChanges;
  List<WeekDay>? weekdays;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? timeOfTheDay;
  int? frequency;

  static bool compare(Habit habit1, Habit habit2) {
    return habit1.userId == habit2.userId &&
        habit1.habitId == habit2.habitId &&
        habit1.icon == habit2.icon &&
        habit1.name == habit2.name &&
        habit1.description == habit2.description &&
        habit1.newHabit == habit2.newHabit &&
        habit1.frequency == habit2.frequency &&
        habit1.validationType == habit2.validationType &&
        habit1.additionalMetrics == habit2.additionalMetrics &&
        habit1.ponderation == habit2.ponderation &&
        habit1.orderIndex == habit2.orderIndex &&
        habit1.color == habit2.color;
  }

  Habit copy({
    String? userId,
    String? habitId,
    IconData? icon,
    String? name,
    String? description,
    String? newHabit,
    int? frequency,
    List<WeekDay>? weekdays,
    HabitType? validationType,
    DateTime? startDate,
    TimeOfDay? timeOfTheDay,
    DateTime? endDate,
    List<String>? additionalMetrics,
    int? ponderation,
    int? orderIndex,
    Color? color,
    Map<DateTime, dynamic>? frequencyChanges,
    bool? synced,
  }) {
    return Habit(
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      description: description ?? this.description,
      newHabit: newHabit ?? this.newHabit,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      validationType: validationType ?? this.validationType,
      startDate: startDate ?? this.startDate,
      timeOfTheDay: timeOfTheDay ?? this.timeOfTheDay,
      endDate: endDate ?? this.endDate,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
      ponderation: ponderation ?? this.ponderation,
      orderIndex: orderIndex ?? this.orderIndex,
      frequencyChanges: frequencyChanges ?? this.frequencyChanges,
      color: color ?? this.color,
      synced: synced ?? this.synced,
    );
  }
}
