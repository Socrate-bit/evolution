import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
    habitId,
    required this.userId,
    required this.icon,
    required this.color,
    required this.name,
    this.description,
    required this.validationType,
    this.newHabit,
    this.additionalMetrics,
    this.ponderation = 3,
    this.orderIndex,
    required this.duration,
    this.shared = false,
    this.linked,
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
  int? orderIndex;
  Color color;
  Duration duration;
  bool shared;
  String? linked;

  static bool compare(Habit habit1, Habit habit2) {
    return habit1.userId == habit2.userId &&
        habit1.habitId == habit2.habitId &&
        habit1.icon == habit2.icon &&
        habit1.name == habit2.name &&
        habit1.description == habit2.description &&
        habit1.newHabit == habit2.newHabit &&
        habit1.validationType == habit2.validationType &&
        habit1.additionalMetrics == habit2.additionalMetrics &&
        habit1.ponderation == habit2.ponderation &&
        habit1.orderIndex == habit2.orderIndex &&
        habit1.color == habit2.color &&
        habit1.duration == habit2.duration &&
        habit1.shared == habit2.shared &&
        habit1.linked == habit2.linked;
  }

  Habit copy({
    String? userId,
    String? habitId,
    IconData? icon,
    String? name,
    String? description,
    String? newHabit,
    HabitType? validationType,
    List<String>? additionalMetrics,
    int? ponderation,
    int? orderIndex,
    Color? color,
    Duration? duration,
    bool? shared,
    String? linked,
  }) {
    return Habit(
        userId: userId ?? this.userId,
        habitId: habitId ?? this.habitId,
        icon: icon ?? this.icon,
        name: name ?? this.name,
        description: description ?? this.description,
        newHabit: newHabit ?? this.newHabit,
        validationType: validationType ?? this.validationType,
        additionalMetrics: additionalMetrics ?? this.additionalMetrics,
        ponderation: ponderation ?? this.ponderation,
        orderIndex: orderIndex ?? this.orderIndex,
        color: color ?? this.color,
        duration: duration ?? this.duration,
        shared: shared ?? this.shared,
        linked: linked ?? this.linked);
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
        validationType: HabitType.values
            .firstWhere((e) => e.toString() == json['validationType']),
        additionalMetrics: json['additionalMetrics'] != null
            ? List<String>.from(jsonDecode(json['additionalMetrics'] as String))
            : null,
        ponderation: json['ponderation'] as int,
        orderIndex: json['orderIndex'] as int,
        color: Color(json['color'] as int? ?? 4281611316),
        duration: (json['duration'] as int?) != null
            ? Duration(seconds: json['duration'] as int)
            : Duration(minutes: 1),
        shared: json['shared'] as bool? ?? false,
        linked: json['linked'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'habitId': habitId,
      'icon': icon.codePoint.toString(),
      'name': name,
      'description': description,
      'newHabit': newHabit,
      'validationType': validationType.toString(),
      'additionalMetrics':
          additionalMetrics != null ? jsonEncode(additionalMetrics) : null,
      'ponderation': ponderation,
      'orderIndex': orderIndex,
      'color': color.value,
      'duration': duration.inSeconds,
      'shared': shared,
      'linked': linked,
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
      'validationType': validationType.toString(),
      'additionalMetrics': additionalMetrics,
      'ponderation': ponderation,
      'orderIndex': orderIndex,
      'color': color.value,
      'duration': duration.inSeconds,
      'shared': shared,
      'linked': linked,
    };
  }
}
