import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';

class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier(this.ref)
      : super(UserStats(userId: FirebaseAuth.instance.currentUser!.uid));
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
  Future<void> updateTotGems(int newTotGems) async {
    state = state.copyWith(totGems: newTotGems);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'totGems': newTotGems});
  }

  // Update the available gems
  Future<void> updateAvailableGems(int newAvailableGems) async {
    state = state.copyWith(availableGems: newAvailableGems);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'availableGems': newAvailableGems});
  }

  // Update the weekly average score
  Future<void> updateWeeklyAverage(double newAverage) async {
    state = state.copyWith(averageWeek: newAverage);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'averageWeek': newAverage});
  }

  // Update the 3-month average score
  Future<void> update3MonthAverage(double newAverage) async {
    state = state.copyWith(average3Months: newAverage);
    await _firestore
        .collection('user_stats')
        .doc(state.userId)
        .update({'average3Months': newAverage});
  }

  // Delete UserStats
  Future<void> deleteUserStats() async {
    await _firestore.collection('user_stats').doc(state.userId).delete();
    state = UserStats(
        userId: FirebaseAuth.instance.currentUser!.uid); // Reset the state
  }

  // Load UserStats data from Firestore
  Future<void> loadUserStats() async {
    final docSnapshot =
        await _firestore.collection('user_stats').doc(state.userId).get();
    if (docSnapshot.exists) {
      state = UserStats.fromJson(docSnapshot.data()!);
    } else {
      addUserStats(UserStats(userId: FirebaseAuth.instance.currentUser!.uid));
    }
  }
}

// Provider for managing UserStats
final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier(ref);
});

// Extension to easily update UserStats state
extension on UserStats {
  UserStats copyWith({
    String? userId,
    int? totGems,
    int? availableGems,
    double? averageWeek,
    double? average3Months,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totGems: totGems ?? this.totGems,
      availableGems: availableGems ?? this.availableGems,
      averageWeek: averageWeek ?? this.averageWeek,
      average3Months: average3Months ?? this.average3Months,
    );
  }
}
