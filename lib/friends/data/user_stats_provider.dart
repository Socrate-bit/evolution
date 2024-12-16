import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/statistics/data/user_stats.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/global/logic/offset_days.dart';

class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier(this.ref)
      : super(UserStats(
            userId: FirebaseAuth.instance.currentUser!.uid, dateSync: today));
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new UserStats entry
  Future<void> addUserStats(UserStats newUserStats) async {
    await _firestore
        .collection('user_stats')
        .doc(newUserStats.userId)
        .set(newUserStats.toJson());
    state = newUserStats;
  }

  Future<void> updateStreaks() async {
    DateTime startDate;
    double scoreAllTime = 0;
    // Compute the score
    List<DateTime> weekDays = OffsetDays.getWeekDaysFromOffset(0);
    double scoreWeek =
        productivityScoreComputing(weekDays, ref, endDate: weekDays.first) ?? 0;

    List<DateTime> monthDays = OffsetDays.getOffsetMonthDays(0);
    double scoreMonth =
        productivityScoreComputing(monthDays, ref, endDate: monthDays.first) ??
            0;

    List<HabitRecap> trackedDays = ref.watch(trackedDayProvider);
    if (trackedDays.isNotEmpty) {
      trackedDays
          .sort((HabitRecap a, HabitRecap b) => a.date.compareTo(b.date));
      startDate = trackedDays.first.date;
      if (!startDate.isAfter(today)) {
        List<DateTime> allTimeDays = OffsetDays.getOffsetDays(startDate, today);
        scoreAllTime = productivityScoreComputing(allTimeDays, ref,
                endDate: allTimeDays.first) ??
            0;
      }
    }

    // Update the score
    state = state.copyWith(
        scoreWeek: scoreWeek,
        scoreMonth: scoreMonth,
        scoreAllTime: scoreAllTime);

    await _firestore.collection('user_stats').doc(state.userId).update({
      'scoreWeek': scoreWeek,
      'scoreMonth': scoreMonth,
      'scoreAllTime': scoreAllTime,
      'dateSync': today.toIso8601String()
    });
  }

  // Update the user's message
  Future<void> updateMessage(String message) async {
    state = state.copyWith(message: message);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'message': message});
  }

  // Delete UserStats
  Future<void> deleteUserStats() async {
    await _firestore.collection('user_stats').doc(state.userId).delete();
    state = UserStats(
        userId: FirebaseAuth.instance.currentUser!.uid,
        dateSync: today); // Reset the state
  }

  // Load UserStats data from Firestore
  Future<void> loadUserStats() async {
    try {
      final docSnapshot =
          await _firestore.collection('user_stats').doc(state.userId).get();
      if (docSnapshot.exists) {
        state = UserStats.fromJson(docSnapshot.data()!);
      } else {
        addUserStats(UserStats(
            userId: FirebaseAuth.instance.currentUser!.uid, dateSync: today));
      }
    } catch (e) {
      deleteUserStats();
      addUserStats(UserStats(
          userId: FirebaseAuth.instance.currentUser!.uid, dateSync: today));
    }
  }
}

// Provider for managing UserStats
final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier(ref);
});
