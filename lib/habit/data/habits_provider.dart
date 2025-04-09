import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/global/logic/time_utility.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
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
    // newHabitList
    //     .sort((a, b) => compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));

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

    await _firestore
        .collection('habits')
        .doc(newHabit.habitId)
        .set(newHabit.toJson());
  }

  // Delete a Habit from state and Firestore
  Future<void> deleteHabit(Habit targetHabit) async {
    state =
        state.where((habit) => habit.habitId != targetHabit.habitId).toList();
    await _firestore.collection('habits').doc(targetHabit.habitId).delete();

    ref.read(habitRecapProvider.notifier).deleteHabitTrackedDays(targetHabit);

    if (targetHabit.validationType == HabitType.recapDay) {
      ref.read(dailyRecapProvider.notifier).deleteAllRecapDays();
    }

    ref
        .read(scheduledProvider.notifier)
        .deleteHabitSchedules(targetHabit.habitId);
  }

  // Update a Habit by deleting and re-adding it
  Future<void> updateHabit(Habit targetHabit, Habit newHabit) async {
    int index = state.indexOf(targetHabit);
    List<Habit> newState =
        state.where((habit) => habit.habitId != targetHabit.habitId).toList();
    newState.insert(index, newHabit);
    state = newState;

    await _firestore
        .collection('habits')
        .doc(newHabit.habitId)
        .set(newHabit.toJson());
  }

  Future<void> togglePause(Habit targetHabit, bool paused) async {
    if (paused) {
      ref.read(scheduledProvider.notifier).addSchedule(Schedule(
          startDate: today, habitId: targetHabit.habitId, paused: false));
    } else {
      ref.read(scheduledProvider.notifier).addSchedule(Schedule(
          startDate: today, habitId: targetHabit.habitId, paused: true));
    }
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
      return Habit.fromJson(doc.data(), habitId: doc.id);
    }).toList();

    state = loadedData;
  }

  void cleanState() {
    state = [];
  }

  bool isHabitListEmpty() {
    return state.isEmpty;
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

  bool isHabitCurrentlyPaused(Habit habit) {
    try {
      return ref
              .read(scheduledProvider.notifier)
              .getHabitAllSchedule(habit.habitId)
              .toList()
              .reversed
              .toList()[0]
              .paused ==
          true;
    } catch (e) {
      return false;
    }
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
