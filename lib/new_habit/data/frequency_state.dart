import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:flutter/material.dart';

class FrequencyState {
  final FrequencyType frequencyType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? period1;
  final bool whenever;
  final int? period2;
  final List<WeekDay> daysOfTheWeek;
  final List<TimeOfDay>? timesOfTheDay;

  FrequencyState({
    this.frequencyType = FrequencyType.Once,
    startDate,
    this.endDate,
    this.period1,
    this.whenever = false,
    this.period2,
    this.daysOfTheWeek = const [],
    this.timesOfTheDay,
  }) : startDate = startDate ?? today;

  FrequencyState copyWith({
    FrequencyType? frequencyType,
    DateTime? startDate,
    DateTime? endDate,
    int? period1,
    bool? whenever,
    int? period2,
    List<WeekDay>? daysOfTheWeek,
    List<TimeOfDay>? timesOfTheDay,
  }) {
    return FrequencyState(
      frequencyType: frequencyType ?? this.frequencyType,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      period1: period1,
      whenever: whenever ?? this.whenever,
      period2: period2,
      daysOfTheWeek: daysOfTheWeek ?? this.daysOfTheWeek,
      timesOfTheDay: timesOfTheDay ?? this.timesOfTheDay,
    );
  }
}

class FrequencyNotifier extends StateNotifier<Schedule> {
  FrequencyNotifier()
      : super(Schedule(
          startDate: today,
          daysOfTheWeek: [
            DaysOfTheWeekUtility.NumberToWeekDay[DateTime.now().weekday]!
          ],
        ));

  void setFrequencyType(FrequencyType frequencyType) {
    state = state.copyWith(type: frequencyType);
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setPeriod1(int period1) {
    state = state.copyWith(period1: period1);
  }

  void setWhenever(bool whenever) {
    state = state.copyWith(whenever: whenever);
  }

  void setPeriod2(int period2) {
    state = state.copyWith(period2: period2);
  }

  void setDaysOfTheWeek(List<WeekDay> daysOfTheWeek) {
    state = state.copyWith(daysOfTheWeek: daysOfTheWeek);
  }

  void setTimesOfTheDay(TimeOfDay? timesOfTheDay) {
    if (timesOfTheDay == null) return;
    state = state
        .copyWith(timesOfTheDay: [for (int x = 0; x < 7; x++) timesOfTheDay]);
  }

  void setHabitId(String habitId) {
    state = state.copyWith(habitId: habitId);
  }

  void setState(Schedule newSchedule) {
    state = newSchedule;
  }
}

final frequencyProvider =
    StateNotifierProvider.autoDispose<FrequencyNotifier, Schedule>((ref) {
  return FrequencyNotifier();
});
