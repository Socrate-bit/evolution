import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tracker_v1/daily/data/custom_day_model.dart';
import 'package:uuid/uuid.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';

const idGenerator = Uuid();

enum HabitType { simple, recap, unique, recapDay }

const Map<HabitType, String> habitTypeDescriptions = {
  HabitType.simple: 'Simple Task',
  HabitType.recap: 'Intentional',
  HabitType.unique: 'Unique task',
  HabitType.recapDay: 'Journaling',
};

enum Ponderation { negligible, low, normal, high, critical }

class Habit {
  Habit({
    required this.userId,
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
    this.frequencyChanges = const {},
    required this.duration,
  }) : habitId = habitId ?? idGenerator.v4();

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
  Duration duration;

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
        habit1.color == habit2.color &&
        habit1.duration == habit2.duration;
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
    Duration? duration,
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
        duration: duration ?? this.duration);
  }

  factory Habit.fromJson(Map<String, dynamic> json, {String? habitId}) {
    return Habit(
        userId: json['userId'] as String,
        habitId: json['habitId'] ?? habitId as String,
        icon: IconData(int.parse(json['icon'] as String),
            fontFamily: 'MaterialIcons'),
        name: json['name'] as String,
        description: json['description'] as String?,
        newHabit: json['newHabit'] as String?,
        frequency: json['frequency'] as int,
        weekdays: (jsonDecode(json['weekdays'] as String) as List)
            .map((day) => WeekDay.values.firstWhere((e) => e.toString() == day))
            .toList(),
        validationType: HabitType.values
            .firstWhere((e) => e.toString() == json['validationType']),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        timeOfTheDay: json['timeOfTheDay'] != null
            ? stringToTimeOfDay(json['timeOfTheDay'] as String)
            : null,
        additionalMetrics: json['additionalMetrics'] != null
            ? List<String>.from(jsonDecode(json['additionalMetrics'] as String))
            : null,
        ponderation: json['ponderation'] as int,
        orderIndex: json['orderIndex'] as int,
        color: Color(json['color'] as int? ?? 4281611316),
        frequencyChanges: json['frequencyChanges'] != null
            ? (jsonDecode(json['frequencyChanges'] as String)
                    as Map<String, dynamic>)
                .map(
                    (key, value) => MapEntry(DateTime.parse(key), value as int))
            : {},
        synced: json['synced'] == true,
        duration: (json['duration'] as int?) != null
            ? Duration(seconds: json['duration'] as int)
            : Duration(minutes: 1));
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'habitId': habitId,
      'icon': icon.codePoint.toString(),
      'name': name,
      'description': description,
      'newHabit': newHabit,
      'frequency': frequency,
      'weekdays': jsonEncode(weekdays?.map((day) => day.toString()).toList()),
      'validationType': validationType.toString(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'timeOfTheDay': timeOfTheDay != null
          ? '${timeOfTheDay!.hour.toString()}:${timeOfTheDay!.minute.toString()}'
          : null,
      'additionalMetrics':
          additionalMetrics != null ? jsonEncode(additionalMetrics) : null,
      'ponderation': ponderation,
      'orderIndex': orderIndex,
      'color': color.value,
      'frequencyChanges': jsonEncode(frequencyChanges
          ?.map((date, freq) => MapEntry(date.toIso8601String(), freq))),
      'synced': synced ?? false,
      'duration': duration.inSeconds
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      'userId': userId,
      'habitId': habitId,
      'icon': icon.codePoint.toString(),
      'name': name,
      'description': description,
      'newHabit': newHabit,
      'frequency': frequency,
      'weekdays': weekdays?.map((day) => day.toString()).toList(),
      'validationType': validationType.toString(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'timeOfTheDay': timeOfTheDay != null
          ? '${timeOfTheDay!.hour.toString()}:${timeOfTheDay!.minute.toString()}'
          : null,
      'additionalMetrics':
          additionalMetrics,
      'ponderation': ponderation,
      'orderIndex': orderIndex,
      'color': color.value,
      'frequencyChanges': frequencyChanges
          ?.map((date, freq) => MapEntry(date.toIso8601String(), freq)),
      'synced': synced ?? false,
      'duration': duration.inSeconds
    };
  }

}
