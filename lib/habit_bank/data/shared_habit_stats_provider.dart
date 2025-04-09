import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_habit_stats_model.dart';

class SharedHabitStatsNotifier extends StateNotifier<List<SharedHabitStats>> {
  SharedHabitStatsNotifier(this.ref) : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;

  // Load data from Firestore into the state
  Future<void> loadData() async {
    final snapshot = await _firestore.collection('sharedHabitStats').get();

    if (snapshot.docs.isEmpty) return;

    final List<SharedHabitStats> loadedData = snapshot.docs.map((doc) {
      return SharedHabitStats.fromJson(doc.data(), statId: doc.id);
    }).toList();

    state = loadedData;
  }

  // Add a new SharedHabitStats to the state and Firestore
  Future<void> addSharedHabitStats(SharedHabitStats newSharedHabitStats) async {
    state = [...state, newSharedHabitStats];

    await _firestore
        .collection('sharedHabitStats')
        .doc(newSharedHabitStats.habitId)
        .set(newSharedHabitStats.toJson());
  }

  // Delete a SharedHabitStats from state and Firestore
  Future<void> deleteSharedHabitStats(SharedHabitStats targetSharedHabitStats) async {
    state = state
        .where((sharedHabitStats) =>
            sharedHabitStats.statId != targetSharedHabitStats.statId)
        .toList();
    await _firestore
        .collection('sharedHabitStats')
        .doc(targetSharedHabitStats.habitId)
        .delete();
  }

  // Update a SharedHabitStats by deleting and re-adding it
  Future<void> updateSharedHabitStats(
      SharedHabitStats targetSharedHabitStats, SharedHabitStats newSharedHabitStats) async {
    int index = state.indexOf(targetSharedHabitStats);

    List<SharedHabitStats> newState = state
        .where((sharedHabitStats) =>
            sharedHabitStats.statId != targetSharedHabitStats.statId)
        .toList();
    newState.insert(index, newSharedHabitStats);
    state = newState;

    await _firestore
        .collection('sharedHabitStats')
        .doc(newSharedHabitStats.habitId)
        .set(newSharedHabitStats.toJson());
  }

  // Update only the number of users in a SharedHabitStats
  Future<void> updateNumberOfUsers(String statId, int newNumberOfUsers) async {
    SharedHabitStats? targetSharedHabitStats = getSharedHabitStatsById(statId);
    if (targetSharedHabitStats == null) return;

    SharedHabitStats updatedSharedHabitStats = targetSharedHabitStats.copy(
      numberOfUsers: newNumberOfUsers,
    );

    await updateSharedHabitStats(targetSharedHabitStats, updatedSharedHabitStats);
  }
  // Add a new category rating to a SharedHabitStats
  Future<void> addCategoryRating(String statId, String category, double rating) async {
    SharedHabitStats? targetSharedHabitStats = getSharedHabitStatsById(statId);
    if (targetSharedHabitStats == null) return;

    Map<String, double> updatedCategoriesRating = {
      ...targetSharedHabitStats.categoriesRating,
      category: rating,
    };

    SharedHabitStats updatedSharedHabitStats = targetSharedHabitStats.copy(
      categoriesRating: updatedCategoriesRating,
    );

    await updateSharedHabitStats(targetSharedHabitStats, updatedSharedHabitStats);
  }

  // Update a specific category rating in a SharedHabitStats
  Future<void> updateCategoryRating(String statId, String category, double newRating) async {
    SharedHabitStats? targetSharedHabitStats = getSharedHabitStatsById(statId);
    if (targetSharedHabitStats == null) return;

    Map<String, double> updatedCategoriesRating = {
      ...targetSharedHabitStats.categoriesRating,
      category: newRating,
    };

    SharedHabitStats updatedSharedHabitStats = targetSharedHabitStats.copy(
      categoriesRating: updatedCategoriesRating,
    );

    await updateSharedHabitStats(targetSharedHabitStats, updatedSharedHabitStats);
  }

  // Delete a specific category rating from a SharedHabitStats
  Future<void> deleteCategoryRating(String statId, String category) async {
    SharedHabitStats? targetSharedHabitStats = getSharedHabitStatsById(statId);
    if (targetSharedHabitStats == null) return;

    Map<String, double> updatedCategoriesRating = Map.from(targetSharedHabitStats.categoriesRating)
      ..remove(category);

    SharedHabitStats updatedSharedHabitStats = targetSharedHabitStats.copy(
      categoriesRating: updatedCategoriesRating,
    );

    await updateSharedHabitStats(targetSharedHabitStats, updatedSharedHabitStats);
  }

  bool isSharedHabitStatsListEmpty() {
    return state.isEmpty;
  }

  SharedHabitStats? getSharedHabitStatsById(String statId) {
    return state.firstWhereOrNull(
        (sharedHabitStats) => sharedHabitStats.statId == statId);
  }

  void cleanState() {
    state = [];
  }
}

final sharedHabitStatsProvider =
    StateNotifierProvider<SharedHabitStatsNotifier, List<SharedHabitStats>>((ref) {
  return SharedHabitStatsNotifier(ref);
});