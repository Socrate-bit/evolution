import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:flutter/material.dart';

class FrequencyNotifier extends StateNotifier<Schedule> {
  FrequencyNotifier()
      : super(Schedule(
          startDate: today,
        ));

  void setFrequencyType(FrequencyType frequencyType) {
    state = Schedule(
        startDate: state.startDate,
        endDate: state.endDate,
        endingDate: state.endingDate,
        habitId: state.habitId,
        daysOfTheWeek: frequencyType == FrequencyType.Weekly
            ? [DaysOfTheWeekUtility.numberToWeekDay[state.startDate!.weekday]!]
            : [...WeekDay.values],
        timesOfTheDay: [for (int x = 0; x < 7; x++) state.timesOfTheDay?[0]],
        type: frequencyType);
    state.copyWith(type: frequencyType);
  }

  void setStartDate(DateTime? startDate) {
    state = state.copyWith(
        startDate: startDate, startDateNullInput: startDate == null);
  }

  void setEndDate(DateTime? endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setEndingDate(DateTime? endingDate) {
    state = state.copyWith(
        endingDate: endingDate, endingNullDateInput: endingDate == null);
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
    state = setTimesOfDayStatic(timesOfTheDay, state);
  }

  static Schedule setTimesOfDayStatic(
      TimeOfDay? timesOfTheDay, Schedule state) {
    return state
        .copyWith(timesOfTheDay: [for (int x = 0; x < 7; x++) timesOfTheDay]);
  }

  void setTimesOfTheSpecificDay(WeekDay day, TimeOfDay? time) {
    state = setTimesOfSpecificDayStatic(day, time, state);
  }

  static Schedule setTimesOfSpecificDayStatic(
      WeekDay day, TimeOfDay? time, Schedule state) {
    int index = DaysOfTheWeekUtility.weekDayToNumber[day]!;
    return state.copyWith(timesOfTheDay: [
      for (int x = 0; x < 7; x++)
        if (x == index - 1) time else state.timesOfTheDay?[x]
    ]);
  }

  void setHabitId(String habitId) {
    state = state.copyWith(habitId: habitId);
  }

  void setState(Schedule newSchedule) {
    state = newSchedule.copyWith();
  }
}

final frequencyStateProvider =
    StateNotifierProvider.autoDispose<FrequencyNotifier, Schedule>((ref) {
  return FrequencyNotifier();
});
