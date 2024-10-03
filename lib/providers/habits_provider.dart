import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier(this.ref) : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;

  // Change the order of the habits in the state
  void stateOrderChange(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    List<Habit> newState = List.from(state);
    Habit removedItem = newState.removeAt(oldIndex);
    newState.insert(newIndex, removedItem);
    state = newState;
  }

  // Update the order of habits in Firestore
  Future<void> databaseOrderChange() async {
    WriteBatch batch = _firestore.batch();

    List<Habit> newState = List.from(state);
    newState.asMap().forEach((int index, Habit habit) {
      habit.orderIndex = index;
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
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'orderIndex': newHabit.orderIndex,
      'ponderation': newHabit.ponderation,
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
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'ponderation': newHabit.ponderation,
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
      'frequency': newHabit.frequency,
      'weekdays':
          jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
      'validationType': newHabit.validationType.toString(),
      'startDate': newHabit.startDate.toIso8601String(),
      'endDate': newHabit.endDate?.toIso8601String(),
      'additionalMetrics': newHabit.additionalMetrics != null
          ? jsonEncode(newHabit.additionalMetrics)
          : null,
      'ponderation': newHabit.ponderation,
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
        frequency: data['frequency'] as int,
        weekdays: (jsonDecode(data['weekdays'] as String) as List)
            .map((day) => WeekDay.values.firstWhere((e) => e.toString() == day))
            .toList(),
        validationType: ValidationType.values
            .firstWhere((e) => e.toString() == data['validationType']),
        startDate: DateTime.parse(data['startDate'] as String),
        endDate: data['endDate'] != null
            ? DateTime.parse(data['endDate'] as String)
            : null,
        additionalMetrics: data['additionalMetrics'] != null
            ? List<String>.from(jsonDecode(data['additionalMetrics'] as String))
            : null,
        ponderation: data['ponderation'] as int,
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
  static bool getHabitTrackingStatus(Habit habit, DateTime date) {
    final bool paused =
        habit.frequencyChanges.values.toList().reversed.toList()[0] == 0 &&
            !habit.frequencyChanges.keys
                .toList()
                .reversed
                .toList()[0]
                .isAfter(date);
    final bool isStarted = habit.startDate.isBefore(date) ||
        habit.startDate.isAtSameMomentAs(date);
    final bool isEnded = habit.endDate != null &&
        (habit.endDate!.isBefore(date) ||
            habit.endDate!.isAtSameMomentAs(date));
    final bool isTracked =
        habit.weekdays.contains(WeekDay.values[date.weekday - 1]);
    return isStarted && !isEnded && isTracked && !paused;
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) {
    return HabitNotifier(ref);
  },
);
