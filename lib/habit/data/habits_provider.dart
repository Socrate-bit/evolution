import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/global/logic/compare_time.dart';
import 'dart:convert';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier(this.ref) : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;

  void updateStateOrder(int oldIndex, int newIndex) async {
    // 1. Update the state
    List<Habit> newState = orderChange(state, oldIndex, newIndex);

    // 2. Update Firebase
    try {
      await _updateFirebaseOrder(newState);
    } catch (e) {
      print('Failed to update Firebase: $e');
      return;
    }
    state = newState;
  }

  static List<Habit> orderChange(
      List<Habit> oldHabitList, int oldIndex, int newIndex,
      {update = false}) {
    // 1. Change the item index
    List<Habit> newHabitList = List.from(oldHabitList);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    Habit removedItem = newHabitList.removeAt(oldIndex);
    newHabitList.insert(newIndex, removedItem);

    // 2. Sort in the right order (In case time of the day doesn't match the drag index)
    newHabitList
        .sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

    // 3. Update all the index properties with new list order
    newHabitList.asMap().forEach((int index, Habit habit) {
      habit.orderIndex = index;
    });

    return newHabitList;
  }

  Future<void> _updateFirebaseOrder(List<Habit> habits) async {
    WriteBatch batch = _firestore.batch();
    habits.asMap().forEach((int index, Habit habit) {
      batch.update(
        _firestore.collection('habits').doc(habit.habitId),
        {'orderIndex': index},
      );
    });
    await batch.commit();
  }

  // Add a new Habit to the state and Firestore
  Future<void> addHabit(Habit newHabit) async {
    state = [...state, newHabit];

    await _firestore.collection('habits').doc(newHabit.habitId).set({
      'userId': newHabit.userId,
      'icon': newHabit.icon.codePoint.toString(),
      'name': newHabit.name,
      'description': newHabit.description,
      'newHabit': newHabit.newHabit,
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'timeOfTheDay': newHabit.timeOfTheDay != null
          ? '${newHabit.timeOfTheDay!.hour.toString()}:${newHabit.timeOfTheDay!.minute.toString()}'
          : null,
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'orderIndex': newHabit.orderIndex,
      'ponderation': newHabit.ponderation,
      'color': newHabit.color.value,
      'frequencyChanges': jsonEncode(newHabit.frequencyChanges
          .map((date, freq) => MapEntry(date.toIso8601String(), freq))),
      'synced': newHabit.synced ? true : false,
    });
  }

  // Delete a Habit from state and Firestore
  Future<void> deleteHabit(Habit targetHabit) async {
    state =
        state.where((habit) => habit.habitId != targetHabit.habitId).toList();
    await _firestore.collection('habits').doc(targetHabit.habitId).delete();

    ref.read(trackedDayProvider.notifier).deleteHabitTrackedDays(targetHabit);
  }

  // Update a Habit by deleting and re-adding it
  Future<void> updateHabit(Habit targetHabit, Habit newHabit) async {
    int index = state.indexOf(targetHabit);
    List<Habit> newState =
        state.where((habit) => habit.habitId != targetHabit.habitId).toList();
    newState.insert(index, newHabit);
    state = newState;

    await _firestore.collection('habits').doc(newHabit.habitId).set({
      'userId': newHabit.userId,
      'icon': newHabit.icon.codePoint.toString(),
      'name': newHabit.name,
      'description': newHabit.description,
      'newHabit': newHabit.newHabit,
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'timeOfTheDay': newHabit.timeOfTheDay != null
          ? '${newHabit.timeOfTheDay!.hour.toString()}:${newHabit.timeOfTheDay!.minute.toString()}'
          : null,
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'ponderation': newHabit.ponderation,
      'color': newHabit.color.value,
      'orderIndex': newHabit.orderIndex,
      'frequencyChanges': jsonEncode(newHabit.frequencyChanges
          .map((date, freq) => MapEntry(date.toIso8601String(), freq))),
      'synced': false,
    });
  }

  Future<void> pauseHabit(Habit targetHabit, bool paused) async {
    int index = state.indexOf(targetHabit);
    Habit newHabit;

    if (paused) {
      int frequency = targetHabit.weekdays.length;
      newHabit = targetHabit..frequency = frequency;
      newHabit.frequencyChanges.addAll({today: frequency});
    } else {
      newHabit = targetHabit..frequency = 0;
      newHabit.frequencyChanges.addAll({today: 0});
    }

    List<Habit> newState =
        state.where((habit) => habit.habitId != targetHabit.habitId).toList();
    newState.insert(index, newHabit);
    state = newState;

    await _firestore.collection('habits').doc(newHabit.habitId).set({
      'userId': newHabit.userId,
      'icon': newHabit.icon.codePoint.toString(),
      'name': newHabit.name,
      'description': newHabit.description,
      'newHabit': newHabit.newHabit,
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'timeOfTheDay': newHabit.timeOfTheDay != null
          ? '${newHabit.timeOfTheDay!.hour.toString()}:${newHabit.timeOfTheDay!.minute.toString()}'
          : null,
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'ponderation': newHabit.ponderation,
      'color': newHabit.color.value,
      'orderIndex': newHabit.orderIndex,
      'frequencyChanges': jsonEncode(newHabit.frequencyChanges
          .map((date, freq) => MapEntry(date.toIso8601String(), freq))),
      'synced': false,
    });
  }

  // Load data from Firestore into the state
  Future<void> loadData() async {
    final snapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('orderIndex')
        .get();

    if (snapshot.docs.isEmpty) return;

    final List<Habit> loadedData = snapshot.docs.map((doc) {
      final data = doc.data();

      return Habit(
        habitId: doc.id,
        userId: data['userId'] as String,
        icon: IconData(int.parse(data['icon'] as String),
            fontFamily: 'MaterialIcons'),
        name: data['name'] as String,
        description: data['description'] as String?,
        newHabit: data['newHabit'] as String?,
        frequency: data['frequency'] as int,
        weekdays: (jsonDecode(data['weekdays'] as String) as List)
            .map((day) => WeekDay.values.firstWhere((e) => e.toString() == day))
            .toList(),
        validationType: HabitType.values
            .firstWhere((e) => e.toString() == data['validationType']),
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'] as String)
            : null,
        timeOfTheDay: data['timeOfTheDay'] != null
            ? stringToTimeOfDay(data['timeOfTheDay'] as String)
            : null,
        additionalMetrics: data['additionalMetrics'] != null
            ? List<String>.from(jsonDecode(data['additionalMetrics'] as String))
            : null,
        ponderation: data['ponderation'] as int,
        color: Color(data['color'] as int? ?? 4281611316),
        orderIndex: data['orderIndex'] as int,
        frequencyChanges: data['frequencyChanges'] != null
            ? (jsonDecode(data['frequencyChanges'] as String)
                    as Map<String, dynamic>)
                .map(
                    (key, value) => MapEntry(DateTime.parse(key), value as int))
            : {},
        synced: data['synced'] == true,
      );
    }).toList();

    state = loadedData;
  }

  void cleanState() {
    state = [];
  }

  // Get a list of the habits that are tracked on the target day
  List<Habit> getTodayHabit(DateTime date) {
    return state.where((habit) => getHabitTrackingStatus(habit, date)).toList();
  }

  // Helper function to check if the habit is tracked on the target day
  static bool isPaused(Habit habit, DateTime date1, [DateTime? date2]) {
    bool paused = false;
    List<int> values = habit.frequencyChanges.values.toList();
    List<DateTime> keys = habit.frequencyChanges.keys.toList();

    for (int i = habit.frequencyChanges.length; i > 0; i--) {
      int index = i - 1;

      if (values[index] == 0) {
        if ((keys[index].isBefore(date1) ||
                keys[index].isAtSameMomentAs(date1) ||
                keys[index] == habit.startDate) &&
            (habit.frequencyChanges.length <= index + 1
                ? true
                : keys[index + 1].isAfter(date2 ?? date1))) {
          paused = true;
        }
      }
    }

    return paused;
  }

  // Helper function to check if the habit is tracked on the target day
  static bool getHabitTrackingStatus(Habit habit, DateTime date) {
    bool paused = isPaused(habit, date);

    final bool isStarted = habit.startDate.isBefore(date) ||
        habit.startDate.isAtSameMomentAs(date);
    final bool isEnded = habit.endDate != null &&
        (habit.endDate!.isBefore(date) ||
            habit.endDate!.isAtSameMomentAs(date));
    final bool isTracked =
        habit.weekdays.contains(WeekDay.values[date.weekday - 1]);
    return isStarted && !isEnded && isTracked && !paused;
  }

  TimeOfDay? getLastTimeOfTheDay(DateTime date) {
    List<Habit> todayHabit =
        getTodayHabit(date).where((h) => h.timeOfTheDay != null).toList();
    List<TimeOfDay?> timeOfDay = todayHabit.map((h) => h.timeOfTheDay).toList()
      ..sort((a, b) => compareTimeOfDay(a, b));
    if (todayHabit.isNotEmpty) {
      return timeOfDay.last!;
    }
    return null;
  }

  // Helper function to get the additional metrics of a set of habits
  static List<(Habit, String)> getAdditionalMetrics(List<Habit> targetHabits) {
    final List<(Habit, String)> additionalMetrics = [];
    for (Habit habit in targetHabits) {
      if (habit.additionalMetrics == null) continue;
      for (String metric in habit.additionalMetrics!) {
        additionalMetrics.add((habit, metric));
      }
    }
    return additionalMetrics;
  }

  // Helper function to get the additional metrics of all habit
  List<(Habit, String)> getAllAdditionalMetrics() {
    return getAdditionalMetrics(state);
  }

  Habit? getHabitById(String habitId) {
    return state.firstWhereOrNull((habit) => habit.habitId == habitId);
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) {
    return HabitNotifier(ref);
  },
);

TimeOfDay stringToTimeOfDay(String timeString) {
  final format = timeString.split(":");
  int hour = int.parse(format[0]);
  int minute = int.parse(format[1]);

  return TimeOfDay(hour: hour, minute: minute);
}
