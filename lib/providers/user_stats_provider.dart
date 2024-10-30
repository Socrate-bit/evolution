import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';
import 'package:tracker_v1/models/utilities/Scores/score_computing.dart';

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

  // Update the user's total gems (totGems)
  Future<void> updateStreaks() async {
    int newSreaks = sumStreaksComputing(ref) ?? 0;

    state = state.copyWith(streaks: newSreaks);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'streaks': newSreaks, 'dateSync': today.toIso8601String()});
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
