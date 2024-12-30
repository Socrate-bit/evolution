import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:tracker_v1/global/logic/time_utility.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class ScheduleCacheNotifier
    extends StateNotifier<LinkedHashMap<Habit, Schedule>> {
  ScheduleCacheNotifier(this.ref, {this.date}) : super(LinkedHashMap()) {
    initCache();
    _instances.add(this);
  }

  static final List<ScheduleCacheNotifier> _instances = [];
  Ref ref;
  DateTime? date;

  void cacheSchedule(LinkedHashMap<Habit, Schedule> todayHabits) {
    state = todayHabits;
  }

  void initCache() {
    List<Habit> habits = ref.read(habitProvider);
    List<(Habit, Schedule)> habitsWithSchedule = [];
    LinkedHashMap<Habit, Schedule> habitWithScheduleSortedMap = LinkedHashMap();

    for (Habit habit in habits) {
      // Conditional logic for habit list or daily screen
      if (date == null) {
        Schedule? defaultSchedule = ref
            .read(scheduledProvider.notifier)
            .getHabitDefaultSchedule(habit.habitId);

        if (defaultSchedule != null &&
            defaultSchedule.type != FrequencyType.Once) {
          habitsWithSchedule.add((habit, defaultSchedule));
        }
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
        a.$2.timesOfTheDay?[(date?.weekday ?? 1) - 1],
        b.$2.timesOfTheDay?[(date?.weekday ?? 1) - 1]));

    for (var habitWithSchedule in habitsWithSchedule) {
      habitWithScheduleSortedMap[habitWithSchedule.$1] = habitWithSchedule.$2;
    }

    state = habitWithScheduleSortedMap;
  }

  TimeOfDay? getLastTimeOfTheDay(DateTime date) {
    LinkedHashMap<Habit, Schedule> todayHabit = state;
    List<TimeOfDay?> timeOfDayList = todayHabit.entries
        .map((e) => e.value.timesOfTheDay?[date.weekday - 1])
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
      trackedDayProvider,
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

  static void cleanAll() {
    for (var instance in _instances) {
      instance.state = LinkedHashMap();
    }
  }
}

final scheduleCacheProvider = StateNotifierProvider.family<
    ScheduleCacheNotifier,
    LinkedHashMap<Habit, Schedule>,
    DateTime?>((ref, date) {
  ScheduleCacheNotifier notifier = ScheduleCacheNotifier(ref, date: date);
  notifier.scheduleCacheResetListener();
  return notifier;
});
