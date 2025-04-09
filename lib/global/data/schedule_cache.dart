import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:tracker_v1/global/logic/time_utility.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class ScheduleCacheNotifier
    extends StateNotifier<LinkedHashMap<Habit, (Schedule?, HabitRecap?)>> {
  ScheduleCacheNotifier(this.ref, {this.date}) : super(LinkedHashMap()) {
    initCache();
    _instances.add(this);
  }

  static final List<ScheduleCacheNotifier> _instances = [];
  Ref ref;
  DateTime? date;

  void cacheSchedule(
      LinkedHashMap<Habit, (Schedule?, HabitRecap?)> todayHabits) {
    state = todayHabits;
  }

  void initCache() {
    List<Habit> habits = ref.read(habitProvider);
    List<(Habit, Schedule?)> habitsWithSchedule = [];
    LinkedHashMap<Habit, (Schedule?, HabitRecap?)> habitWithScheduleSortedMap =
        LinkedHashMap();

    for (Habit habit in habits) {
      // Conditional logic for habit list or daily screen
      if (date == null) {
        Schedule? defaultSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitDefaultSchedule(habit.habitId);

        habitsWithSchedule.add((habit, defaultSchedule));
      } else {
        (bool, Schedule?) isTrackedWithSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitTrackingStatusWithSchedule(habit.habitId, date!);
        if (isTrackedWithSchedule.$1 && isTrackedWithSchedule.$2 != null) {
          habitsWithSchedule.add((habit, isTrackedWithSchedule.$2!));
        }
      }
    }

    //Sort the list
    habitsWithSchedule.sort((a, b) => compareTimeOfDay(
        a.$2?.timesOfTheDay?[(date?.weekday ?? 1) - 1],
        b.$2?.timesOfTheDay?[(date?.weekday ?? 1) - 1]));

    for (var habitWithSchedule in habitsWithSchedule) {
      List<HabitRecap> recapDayList = ref
          .read(habitRecapProvider.notifier)
          .getHabitTrackedDaysInPeriod(
              habitWithSchedule.$1.habitId, date, date);
      HabitRecap? recapDay =
          recapDayList.isNotEmpty ? recapDayList.first : null;
      habitWithScheduleSortedMap[habitWithSchedule.$1] =
          (habitWithSchedule.$2, recapDay);
    }

    state = habitWithScheduleSortedMap;
  }

  TimeOfDay? getLastTimeOfTheDay(DateTime date) {
    LinkedHashMap<Habit, (Schedule?, HabitRecap?)> todayHabit = state;
    List<TimeOfDay?> timeOfDayList = todayHabit.entries
        .map((e) => e.value.$1?.timesOfTheDay?[date.weekday - 1])
        .whereNotNull()
        .toList();

    if (timeOfDayList.isNotEmpty) {
      return timeOfDayList.last;
    }

    return null;
  }

  void scheduleCacheResetListener() {
    ref.listen(
      habitProvider,
      (oldHabits, newHabits) {
        initCache();
      },
    );

    ref.listen(
      habitRecapProvider,
      (oldHabits, newHabits) {
        initCache();
      },
    );

    ref.listen(
      scheduledProvider,
      (oldSchedules, newSchedules) {
        initCache();
      },
    );
  }

  String toJson() {
    return jsonEncode(state.entries
        .map((e) => {
              'habit': e.key.toJson2(),
              'schedule': e.value.$1?.toJson(),
              'validated': e.value.$2?.done == null
                  ? null
                  : e.value.$2?.done != Validated.notYet
                      ? true
                      : null,
            })
        .toList());
  }

  static void cleanAll() {
    for (var instance in _instances) {
      instance.state = LinkedHashMap();
    }
  }
}

final scheduleCacheProvider = StateNotifierProvider.family<
    ScheduleCacheNotifier,
    LinkedHashMap<Habit, (Schedule?, HabitRecap?)>,
    DateTime?>((ref, date) {
  ScheduleCacheNotifier notifier = ScheduleCacheNotifier(ref, date: date);
  notifier.scheduleCacheResetListener();
  return notifier;
});
