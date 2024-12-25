import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum FrequencyType { Once, Daily, Weekly, Monthly }

class Schedule {
  String? scheduleId;
  final String userId;
  final String? habitId;
  DateTime? startDate;
  DateTime? endDate;
  final DateTime? endingDate;
  final bool paused;
  final FrequencyType type;
  final int period1;
  final bool whenever;
  final int period2;
  final List<WeekDay>? daysOfTheWeek;
  final List<TimeOfDay?>? timesOfTheDay;

  Schedule({
    scheduleId,
    this.habitId,
    userId,
    this.startDate,
    this.endDate,
    this.endingDate,
    this.paused = false,
    this.type = FrequencyType.Once,
    this.period1 = 1,
    this.whenever = false,
    this.period2 = 1,
    this.daysOfTheWeek = const [...WeekDay.values],
    this.timesOfTheDay,
  })  : scheduleId = scheduleId ?? idGenerator.v4(),
        userId = FirebaseAuth.instance.currentUser!.uid;

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'userId': userId,
      'habitId': habitId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'endingDate': endingDate?.toIso8601String(),
      'paused': paused,
      'type': type.toString().split('.').last,
      'period1': period1,
      'whenever': whenever,
      'period2': period2,
      'daysOfTheWeek':
          daysOfTheWeek?.map((day) => day.toString().split('.').last).toList(),
      'timesOfTheDay':
          timesOfTheDay?.map((time) => time != null ? '${time!.hour}:${time.minute}' : null).toList(),
    };
  }

  // Create from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'],
      habitId: json['habitId'],
      userId: json['userId'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      endingDate: json['endingDate'] != null
          ? DateTime.parse(json['endingDate'])
          : null,
      paused: json['paused'],
      type: FrequencyType.values
          .firstWhere((e) => e.name.toString() == json['type'] as String),
      period1: json['period1'],
      whenever: json['whenever'],
      period2: json['period2'],
      daysOfTheWeek: (json['daysOfTheWeek'] as List<dynamic>?)
          ?.map((day) =>
              WeekDay.values.firstWhere((e) => e.name.toString() == day))
          .toList(),
      timesOfTheDay: (json['timesOfTheDay'] as List<dynamic>?)
          ?.map((time) => stringToTimeOfDay(time.toString()))
          .toList(),
    );
  }

  static bool compareSchedules(Schedule schedule1, Schedule schedule2) {
    return schedule1.scheduleId == schedule2.scheduleId &&
        schedule1.userId == schedule2.userId &&
        schedule1.habitId == schedule2.habitId &&
        schedule1.startDate == schedule2.startDate &&
        schedule1.endDate == schedule2.endDate &&
        schedule1.endingDate == schedule2.endingDate &&
        schedule1.paused == schedule2.paused &&
        schedule1.type == schedule2.type &&
        schedule1.period1 == schedule2.period1 &&
        schedule1.whenever == schedule2.whenever &&
        schedule1.period2 == schedule2.period2 &&
        schedule1.daysOfTheWeek?.toString() ==
            schedule2.daysOfTheWeek?.toString() &&
        schedule1.timesOfTheDay?.toString() ==
            schedule2.timesOfTheDay?.toString();
  }

  bool isMixedhour() {
    if (timesOfTheDay == null) return false;
    return timesOfTheDay!.toSet().length > 1;
  }

  void resetScheduleId() {
    scheduleId = idGenerator.v4();
  }

  TimeOfDay? getTimeOfTargetDay(DateTime? date) {
    return timesOfTheDay?[(date?.weekday ?? 1) - 1];
  }

  Schedule copyWith({
    String? scheduleId,
    String? habitId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? endingDate,
    bool? paused,
    FrequencyType? type,
    int? period1,
    bool? whenever,
    int? period2,
    List<WeekDay>? daysOfTheWeek,
    List<TimeOfDay?>? timesOfTheDay,
    bool startDateNullInput = false,
    bool enDateNullInput = false,
    bool endingNullDateInput = false,
  }) {
    return Schedule(
      scheduleId: scheduleId ?? this.scheduleId,
      habitId: habitId ?? this.habitId,
      userId: userId,
      startDate: startDateNullInput ? null : startDate ?? this.startDate,
      endDate: enDateNullInput ? null : endDate ?? this.endDate,
      endingDate: endingNullDateInput ? null : endingDate ?? this.endingDate,
      paused: paused ?? this.paused,
      type: type ?? this.type,
      period1: period1 ?? this.period1,
      whenever: whenever ?? this.whenever,
      period2: period2 ?? this.period2,
      daysOfTheWeek: daysOfTheWeek ?? this.daysOfTheWeek,
      timesOfTheDay: timesOfTheDay ?? this.timesOfTheDay,
    );
  }

  static TimeOfDay? stringToTimeOfDay(String tod) {
    if (tod == 'null') return null;
    final parts = tod.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
