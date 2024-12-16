import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/recap/data/daily_recap_repository.dart';
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
        .doc(
            newSchedule.scheduleId)
        .set(newSchedule.toJson());
  }

  // Delete a Schedule from state and Firestore
  Future<void> deleteSchedule(Schedule targetSchedule) async {
    state = state
        .where((schedule) => schedule.habitId != targetSchedule.habitId)
        .toList();

    await _firestore
        .collection('schedules')
        .doc(
            targetSchedule.scheduleId)
        .delete();
  }

  // Update a Schedule by deleting and re-adding it
  Future<void> updateSchedule(Schedule updatedSchedule) async {
    state = [
      ...state.where((schedule) => schedule.habitId != updatedSchedule.habitId),
      updatedSchedule
    ];

    await _firestore
        .collection('schedules')
        .doc(
            updatedSchedule.habitId)
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

  List<Schedule> getSchedulesForHabit(Habit habit) {
    return state
        .where((schedule) => schedule.habitId == habit.habitId)
        .toList();
  }

  Schedule getHabitDefaultSchedule(Habit habit) {
    List<Schedule> allHabitSchedules = getSchedulesForHabit(habit);
    List<Schedule> sortedSchedule = allHabitSchedules
        .where((schedule) =>
            schedule.endDate == null)
        .toList()
      ..sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });

    if (sortedSchedule.isEmpty) {
      return allHabitSchedules.last;
    }


    return sortedSchedule.last;
  }

  DateTime getHabitStartDateSchedule(Habit habit) {
    List<Schedule> sortedSchedule = getSchedulesForHabit(habit)
      ..sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });
    return sortedSchedule.first.startDate;
  }

  Schedule getHabitTargetDaySchedule(Habit habit, DateTime targetDate) {
    List<Schedule> sortedSchedule = getSchedulesForHabit(habit)
        .where((schedule) =>
            !schedule.startDate.isAfter(targetDate) &&
            (schedule.endDate == null ||
                (schedule.endDate != null &&
                    !schedule.endDate!.isBefore(targetDate))))
        .toList()
      ..sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });

    if (sortedSchedule.isEmpty) {
      return getHabitDefaultSchedule(habit);
    }
    return sortedSchedule.last;
  }

  bool getHabitTrackingStatus(Habit habit, DateTime date) {
    Schedule schedule = getHabitTargetDaySchedule(habit, date);

    // Common status logic
    bool paused = schedule.paused;
    final bool isStarted = !schedule.startDate.isAfter(date);
    final bool isEnded =
        schedule.endingDate != null && (!schedule.endingDate!.isAfter(date));

    if (isEnded || !isStarted || paused) {
      return false;
    }

    // Specific status logic
    switch (schedule.type) {
      case FrequencyType.Once:
        return schedule.startDate.isAtSameMomentAs(date);
      case FrequencyType.Daily:
        return schedule.startDate.difference(date).inDays % schedule.period1! ==
            0;
      case FrequencyType.Weekly:
        if ((schedule.startDate.difference(date).inDays ~/ 7) %
                schedule.period1 !=
            0) return false;
        if (schedule.whenever) {
          List<DateTime> weekDays =
              OffsetDays.getWeekDaysFromOffset(0, startDate: date);
          List<HabitRecap> trackedDays = ref
              .read(trackedDayProvider.notifier)
              .getHabitTrackedDaysInPeriod(
                  habit.habitId, weekDays.first, weekDays.last);
          int validatedNumber = trackedDays
              .length;
          bool isTrackedayForDate = trackedDays.map((e) => e.date).contains(date);
          return validatedNumber < schedule.period2 || isTrackedayForDate;
        } else {
          return schedule.daysOfTheWeek!
              .contains(WeekDay.values[date.weekday - 1]);
        }
      case FrequencyType.Monthly:
        int monthDifference = (schedule.startDate.year - date.year) * 12 +
            (schedule.startDate.month - date.month);
        if (monthDifference % schedule.period1 != 0) return false;

        if (schedule.whenever) {
          List<DateTime> weekDays =
              OffsetDays.getOffsetMonthDays(0, startDate: date);
                        List<HabitRecap> trackedDays = ref
              .read(trackedDayProvider.notifier)
              .getHabitTrackedDaysInPeriod(
                  habit.habitId, weekDays.first, weekDays.last);
          int validatedNumber = trackedDays
              .length;
          bool isTrackedayForDate = trackedDays.map((e) => e.date).contains(date);
          return validatedNumber < schedule.period2 || isTrackedayForDate;
        } else {
          return schedule.startDate.day == date.day;
        }

      default:
        return false;
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
        s.endDate == s.startDate);

    if (targetSchedule != null) {
      await deleteSchedule(targetSchedule);
    }
    await addSchedule(newSchedule);
  }

  Future<void> modifyAll(Schedule newSchedule) async {
    await deleteHabitSchedules(newSchedule.habitId!);
    await addSchedule(newSchedule);
  }

  Future<void> modifyFuture(Schedule newSchedule) async {
    final futureSchedules = state.where((s) =>
        s.habitId == newSchedule.habitId &&
        !s.startDate.isBefore(newSchedule.startDate));

    if (futureSchedules.isNotEmpty) {
      for (Schedule schedule in futureSchedules) {
        await deleteSchedule(schedule);
      }
    }

    Schedule modifiedSchedule = newSchedule.copyWith(endDate: null);
    await addSchedule(modifiedSchedule);
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
