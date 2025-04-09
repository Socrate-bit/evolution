import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';

class SharedHabitsNotifier extends StateNotifier<List<(Habit, Schedule)>> {
  SharedHabitsNotifier(this.ref) : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;

  // Load shared habits from Firestore into the state
  Future<void> loadSharedHabits() async {
    final habitSnapshot = await _firestore
        .collection('sharedHabits')
        .get();

    final scheduleSnapshot =
        await _firestore.collection('sharedSchedules').get();

    if (habitSnapshot.docs.isEmpty || scheduleSnapshot.docs.isEmpty) return;

    final List<(Habit, Schedule)> loadedSharedHabits =
        habitSnapshot.docs.map((habitDoc) {
      final scheduleDoc = scheduleSnapshot.docs.firstWhere(
        (scheduleDoc) => scheduleDoc.id == habitDoc.id,
        orElse: () => throw Exception(
            'No matching schedule found for habit ${habitDoc.id}'),
      );
      return (
        Habit.fromJson(habitDoc.data(), habitId: habitDoc.id),
        Schedule.fromJson(scheduleDoc.data()),
      );
    }).toList();

    state = loadedSharedHabits;
  }

  // Add a new shared habit and schedule to the state and Firestore
  Future<void> addSharedHabitSchedule(
    Habit newSharedHabit,
    Schedule schedule,
  ) async {
    state = [...state, (newSharedHabit, schedule)];

    await _firestore
        .collection('sharedHabits')
        .doc(newSharedHabit.habitId)
        .set(newSharedHabit.toJson());

    await _firestore
        .collection('sharedSchedules')
        .doc(schedule.habitId)
        .set(schedule.toJson());
  }

  // Delete a shared habit and schedule from state and Firestore
  Future<void> deleteSharedHabit(Habit targetSharedHabit) async {
    state = state
        .where((tuple) => tuple.$1.habitId != targetSharedHabit.habitId)
        .toList();

    await _firestore
        .collection('sharedSchedules')
        .doc(targetSharedHabit.habitId)
        .delete();

    await _firestore
        .collection('sharedHabits')
        .doc(targetSharedHabit.habitId)
        .delete();
  }

  (Habit, Schedule)? getSharedHabitById(String habitId) {
    return state.firstWhereOrNull((tuple) => tuple.$1.habitId == habitId);
  }

  void cleanState() {
    state = [];
  }
}

final sharedHabitsProvider =
    StateNotifierProvider<SharedHabitsNotifier, List<(Habit, Schedule)>>((ref) {
  return SharedHabitsNotifier(ref);
});
