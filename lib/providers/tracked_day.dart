import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TrackedDayNotifier extends StateNotifier<List<TrackedDay>> {
  TrackedDayNotifier(this.ref) : super([]);
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTrackedDay(TrackedDay newTrackedDay) async {
    state = [...state, newTrackedDay];
    await _firestore
        .collection('TrackedDay')
        .doc(newTrackedDay.trackedDayId)
        .set({
      'userId': newTrackedDay.userId,
      'habitId': newTrackedDay.habitId,
      'date': newTrackedDay.date.toIso8601String(),
      'done': newTrackedDay.done == Validated.yes ? true : false,
      'notation_showUp': newTrackedDay.notation?.quantity,
      'notation_investment': newTrackedDay.notation?.quality,
      'notation_result': newTrackedDay.notation?.result,
      'notation_goal': newTrackedDay.notation?.weeklyFocus,
      'notation_extra': newTrackedDay.notation?.dailyGoal,
      'recap': newTrackedDay.recap,
      'improvements': newTrackedDay.improvements,
      'additionalMetrics': newTrackedDay.additionalMetrics != null
          ? jsonEncode(newTrackedDay.additionalMetrics)
          : null,
      'synced': newTrackedDay.synced ? true : false,
      'dateOnValidation': newTrackedDay.dateOnValidation?.toIso8601String(),
    });
  }
  
  Future<void> deleteTrackedDay(TrackedDay targetTrackedDay) async {
    state = state
        .where((td) => td.trackedDayId != targetTrackedDay.trackedDayId)
        .toList();

    await _firestore
        .collection('TrackedDay')
        .doc(targetTrackedDay.trackedDayId)
        .delete();
  }

  Future<void> deleteHabitTrackedDays(Habit habit) async {
    // Filter the tracked days by the habitId
    final trackedDaysToDelete =
        state.where((td) => td.habitId == habit.habitId).toList();

    for (TrackedDay trackedDay in trackedDaysToDelete) {
      // Remove the tracked day from state
      deleteTrackedDay(trackedDay);

      // Delete the corresponding document from Firestore
      await _firestore
          .collection('TrackedDay')
          .doc(trackedDay.trackedDayId)
          .delete();
    }
  }

  Future<void> updateTrackedDay(TrackedDay targetTrackedDay) async {
    deleteTrackedDay(targetTrackedDay);
    addTrackedDay(targetTrackedDay);
  }

  Future<void> loadData() async {
    final snapshot = await _firestore
        .collection('TrackedDay')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = snapshot.docs;

    if (data.isEmpty) return;

    final List<TrackedDay> loadedData = [];
    for (final doc in data) {
      final row = doc.data();
      final trackedDay = TrackedDay(
        trackedDayId: doc.id,
        userId: row['userId'] as String,
        habitId: row['habitId'] as String,
        date: DateTime.parse(row['date'] as String),
        done: (row['done'] as bool) ? Validated.yes : Validated.no,
        notation: row['notation_showUp'] == null
            ? null
            : Rating(
                quantity: row['notation_showUp'] as double,
                quality: row['notation_investment'] as double,
                result: row['notation_result'] as double,
                weeklyFocus: row['notation_goal'] as double,
                dailyGoal: row['notation_extra'] as double,
              ),
        recap: row['recap'] as String?,
        improvements: row['improvements'] as String?,
        additionalMetrics: row['additionalMetrics'] != null
            ? jsonDecode(row['additionalMetrics'] as String)
            : null,
        synced: row['synced'] as bool,
        dateOnValidation: row['dateOnValidation'] != null
            ? DateTime.parse(row['dateOnValidation'] as String)
            : DateTime.parse(row['date'] as String),
      );
      loadedData.add(trackedDay);
    }

    state = loadedData;
  }

  void cleanState() {
    state = [];
  }
}

final trackedDayProvider =
    StateNotifierProvider<TrackedDayNotifier, List<TrackedDay>>(
  (ref) {
    return TrackedDayNotifier(ref);
  },
);
