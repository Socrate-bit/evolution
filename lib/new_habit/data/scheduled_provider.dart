import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/offset_days.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class ScheduledNotifier extends StateNotifier<List<Schedule>> {
  ScheduledNotifier(this.ref) : super([]);
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new Schedule to the state and Firestore
  Future<void> addSchedule(Schedule newSchedule) async {
    state = [...state, newSchedule];

    await _firestore
        .collection('schedules')
        .doc(newSchedule.scheduleId)
        .set(newSchedule.toJson());
  }

  // Delete a Schedule from state and Firestore
  Future<void> deleteSchedule(Schedule targetSchedule) async {
    state = state
        .where((schedule) => schedule.scheduleId != targetSchedule.scheduleId)
        .toList();

    await _firestore
        .collection('schedules')
        .doc(targetSchedule.scheduleId)
        .delete();
  }

  // Update a Schedule by deleting and re-adding it
  Future<void> updateSchedule(Schedule updatedSchedule) async {
    state = [
      ...state.where(
          (schedule) => schedule.scheduleId != updatedSchedule.scheduleId),
      updatedSchedule
    ];

    await _firestore
        .collection('schedules')
        .doc(updatedSchedule.scheduleId)
        .set(updatedSchedule.toJson());
  }

  // Load all schedules for the current user
  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final snapshot = await _firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final List<Schedule> loadedData = snapshot.docs.map((doc) {
      final data = doc.data();
      return Schedule.fromJson(data);
    }).toList();

    state = loadedData;
  }

  List<Schedule> getHabitAllSchedule(String habitId) {
    return state.where((schedule) => schedule.habitId == habitId).toList();
  }

  List<Schedule> sortSchedules(List<Schedule> schedules) {
    return schedules
      ..sort((a, b) {
        if (a.startDate == null && b.startDate == null) {
          return 0;
        } else if (a.startDate == null) {
          return -1;
        } else if (b.startDate == null) {
          return 1;
        } else if (a.startDate == b.startDate &&
            (a.type == FrequencyType.Once || b.type == FrequencyType.Once)) {
          return a.type == FrequencyType.Once ? 1 : -1;
        } else {
          return a.startDate!.compareTo(b.startDate!);
        }
      });
  }

  DateTime? getHabitStartDate(String habitId) {
    List<Schedule> sortedSchedule = sortSchedules(getHabitAllSchedule(habitId));

    if (sortedSchedule.isEmpty) {
      return null;
    }
    
    return sortedSchedule.elementAt(0).startDate;
  }

  Schedule? getHabitDefaultSchedule(String habitId, {DateTime? date}) {
    List<Schedule> allHabitSchedules = getHabitAllSchedule(habitId)
        .where((schedule) =>
            date != null ? !schedule.startDate!.isAfter(date) : true)
        .toList();

    if (allHabitSchedules.isEmpty) {
      return null;
    }

    // Default level 1
    List<Schedule> sortedSchedule = sortSchedules(allHabitSchedules);
    List<Schedule> filteredSchedules = sortedSchedule
        .where((schedule) => schedule.endDate == null &&
                schedule.startDate != null &&
                schedule.type != FrequencyType.Once &&
                (date != null
            ? !schedule.startDate!.isAfter(date)
            : true))
        .toList();

    if (filteredSchedules.isNotEmpty) {
      return filteredSchedules.last;
    }

    // Default level 2
    List<Schedule> filteredSchedules2 = sortedSchedule
        .where((schedule) => schedule.startDate != null &&
                schedule.type != FrequencyType.Once &&
                (date != null
            ? !schedule.startDate!.isAfter(date)
            : true))
        .toList();

    if (filteredSchedules2.isNotEmpty) {
      return filteredSchedules2.last;
    }

    return sortedSchedule.last;
  }

  Schedule? getHabitTargetDaySchedule(String habitId, DateTime targetDate) {
    List<Schedule> filteredSchedules = getHabitAllSchedule(habitId)
        .where((schedule) =>
            schedule.startDate != null &&
            !schedule.startDate!.isAfter(targetDate) &&
            (schedule.endDate == null ||
                (schedule.endDate != null &&
                    !schedule.endDate!.isBefore(targetDate))))
        .toList();

    List<Schedule> sortedSchedule = sortSchedules(filteredSchedules);

    if (sortedSchedule.isEmpty) {
      return null;
    }

    return sortedSchedule.last;
  }

  (bool, Schedule?) getHabitTrackingStatusWithSchedule(
      String habitId, DateTime date) {
    Schedule? schedule = getHabitTargetDaySchedule(habitId, date);

    // No schedule case
    if (schedule == null) {
      return (false, null);
    }

    // Common status logic
    if (schedule.startDate == null) {
      return (false, schedule);
    }

    bool paused = schedule.paused;
    final bool isStarted = !schedule.startDate!.isAfter(date);
    final bool isEnded =
        schedule.endingDate != null && (schedule.endingDate!.isBefore(date));

    if (isEnded || !isStarted || paused) {
      return (false, schedule);
    }

    // Specific status logic
    switch (schedule.type) {
      case FrequencyType.Once:
        return (schedule.startDate!.isAtSameMomentAs(date), schedule);
      case FrequencyType.Daily:
        return (
          schedule.startDate!.difference(date).inDays % schedule.period1! == 0,
          schedule
        );
      case FrequencyType.Weekly:
        if ((schedule.startDate!.difference(date).inDays ~/ 7) %
                schedule.period1 !=
            0) return (false, schedule);
        if (schedule.whenever) {
          List<DateTime> weekDays =
              OffsetDays.getWeekDaysFromOffset(0, startDate: date);
          List<HabitRecap> trackedDays = ref
              .read(trackedDayProvider.notifier)
              .getHabitTrackedDaysInPeriod(
                  habitId, weekDays.first, weekDays.last);
          int validatedNumber = trackedDays.length;
          bool isTrackedayForDate =
              trackedDays.map((e) => e.date).contains(date);
          return (
            validatedNumber < schedule.period2 || isTrackedayForDate,
            schedule
          );
        } else {
          return (
            schedule.daysOfTheWeek!.contains(WeekDay.values[date.weekday - 1]),
            schedule
          );
        }
      case FrequencyType.Monthly:
        int monthDifference = (schedule.startDate!.year - date.year) * 12 +
            (schedule.startDate!.month - date.month);
        if (monthDifference % schedule.period1 != 0) return (false, schedule);

        if (schedule.whenever) {
          List<DateTime> weekDays =
              OffsetDays.getOffsetMonthDays(0, startDate: date);
          List<HabitRecap> trackedDays = ref
              .read(trackedDayProvider.notifier)
              .getHabitTrackedDaysInPeriod(
                  habitId, weekDays.first, weekDays.last);
          int validatedNumber = trackedDays.length;
          bool isTrackedayForDate =
              trackedDays.map((e) => e.date).contains(date);
          return (
            validatedNumber < schedule.period2 || isTrackedayForDate,
            schedule
          );
        } else {
          return (schedule.startDate!.day == date.day, schedule);
        }

      default:
        return (false, schedule);
    }
  }

  // Delete all schedules linked to a specific habit
  Future<void> deleteHabitSchedules(String habitId) async {
    // Filter the schedules by the habitId
    final schedulesToDelete =
        state.where((schedule) => schedule.habitId == habitId).toList();

    for (Schedule schedule in schedulesToDelete) {
      deleteSchedule(schedule);
    }
  }

  Future<void> modifyTodayOnly(Schedule newSchedule) async {
    final targetSchedule = state.firstWhereOrNull((s) =>
        s.habitId == newSchedule.habitId &&
        s.startDate == newSchedule.startDate &&
        (s.type == FrequencyType.Once || s.startDate == s.endDate));

    if (targetSchedule != null) {
      await deleteSchedule(targetSchedule);
    }
    await addSchedule(newSchedule);
  }

  Future<void> modifyAll(Schedule newSchedule) async {
    await deleteHabitSchedules(newSchedule.habitId!);
    await addSchedule(newSchedule);
  }

  List<Schedule> _getFutureSchedules(Schedule newSchedule) {
    return state
        .where((s) =>
            s.habitId == newSchedule.habitId &&
            !s.startDate!.isBefore(newSchedule.startDate!))
        .toList();
  }

  Future<void> modifyFuture(Schedule newSchedule) async {
    final futureSchedules = _getFutureSchedules(newSchedule);

    if (futureSchedules.isNotEmpty) {
      for (Schedule schedule in futureSchedules) {
        await deleteSchedule(schedule);
      }
    }

    Schedule modifiedSchedule = newSchedule.copyWith(endDate: null);
    await addSchedule(modifiedSchedule);
    state;
  }

  Future<void> modifyFutureTimeOfDay(TimeOfDay? newTimeOfDay, Schedule schedule,
      {bool isHabitListPage = false}) async {
    final futureSchedules = _getFutureSchedules(schedule);

    List<Schedule> todaySchedule = futureSchedules
        .where((s) =>
            s.startDate!.isAtSameMomentAs(schedule.startDate!) &&
            s.type != FrequencyType.Once && s.startDate != s.endDate)
        .toList();

    // Case no default schedule starting today 
    if (todaySchedule.isEmpty) {
      Schedule? currentDefaultSchedule =
          getHabitDefaultSchedule(schedule.habitId!, date: schedule.startDate);
      Schedule newCurrentDefaultSchedule =
          currentDefaultSchedule!.copyWith(startDate: schedule.startDate, scheduleId: null)..resetScheduleId();
      addSchedule(newCurrentDefaultSchedule);
      futureSchedules.add(newCurrentDefaultSchedule);
    }

    if (futureSchedules.isNotEmpty) {
      _modifyBatchScheduleTimeOfDay(newTimeOfDay, futureSchedules, schedule,
          isHabitListPage: isHabitListPage);
    }
  }

  Future<void> modifyAllTimeOfDay(TimeOfDay? newTimeOfDay, String habitId, Schedule schedule,
      {bool isHabitListPage = false}) async {
    final allHabitSchedules = getHabitAllSchedule(habitId);

    if (allHabitSchedules.isNotEmpty) {
      _modifyBatchScheduleTimeOfDay(newTimeOfDay, allHabitSchedules, schedule,
          isHabitListPage: isHabitListPage);
    }
  }

  Future<void> _modifyBatchScheduleTimeOfDay(
      TimeOfDay? newTimeOfDay, List<Schedule> schedules, Schedule oldSchedule,
      {bool isHabitListPage = false}) async {
    for (Schedule schedule in schedules) {
      Schedule newSchedule;
      if (!isHabitListPage && oldSchedule.isMixedhour()) {
        WeekDay day = DaysOfTheWeekUtility
            .numberToWeekDay[(oldSchedule.startDate?.weekday ?? 1)]!;
        newSchedule = FrequencyNotifier.setTimesOfSpecificDayStatic(
            day, newTimeOfDay, schedule);
      } else {
        newSchedule =
            FrequencyNotifier.setTimesOfDayStatic(newTimeOfDay, schedule);
        schedule.startDate = schedule.startDate ?? today;
      }
      await updateSchedule(newSchedule);
    }
  }

  // Clean the state (reset to an empty list)
  void cleanState() {
    state = [];
  }
}

final scheduledProvider =
    StateNotifierProvider<ScheduledNotifier, List<Schedule>>(
  (ref) => ScheduledNotifier(ref),
);
