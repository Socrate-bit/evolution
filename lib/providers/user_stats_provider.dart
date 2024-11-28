import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/statistic_screen/logics/service_score_computing.dart';
import 'package:tracker_v1/models/utilities/offset_days.dart';

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
    // Compute the score
    List<DateTime> weekDays = OffsetDays.getWeekDaysFromOffset(0);
    int scoreWeek =
        productivityScoreComputing(weekDays, ref, endDate: weekDays.first) ?? 0;

    List<DateTime> monthDays = OffsetDays.getOffsetMonthDays(0);
    int scoreMonth =
        productivityScoreComputing(monthDays, ref, endDate: monthDays.first) ??
            0;

    List<TrackedDay> trackedDays = ref.watch(trackedDayProvider)
      ..sort((TrackedDay a, TrackedDay b) => a.date.compareTo(b.date));
    DateTime startDate = trackedDays.first.date;

    List<DateTime> allTimeDays = OffsetDays.getOffsetDays(startDate, today);
    int scoreAllTime = productivityScoreComputing(allTimeDays, ref,
            endDate: allTimeDays.first) ??
        0;

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
    final docSnapshot =
        await _firestore.collection('user_stats').doc(state.userId).get();
    if (docSnapshot.exists) {
      state = UserStats.fromJson(docSnapshot.data()!);
    } else {
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
