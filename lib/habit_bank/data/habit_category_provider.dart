import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_category_model.dart';

class HabitCategoryNotifier extends StateNotifier<List<HabitCategory>> {
  HabitCategoryNotifier(this.ref) : super([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;

  // Load data from Firestore into the state
  Future<void> loadData() async {
    final snapshot = await _firestore.collection('habitCategories').get();

    if (snapshot.docs.isEmpty) return;

    final List<HabitCategory> loadedData = snapshot.docs.map((doc) {
      return HabitCategory.fromJson(doc.data(), categoryId: doc.id);
    }).toList();

    state = loadedData;
  }

  // Add a new HabitCategory to the state and Firestore
  Future<void> addCategory(HabitCategory newCategory) async {
    state = [...state, newCategory];

    await _firestore
        .collection('habitCategories')
        .doc(newCategory.categoryId)
        .set(newCategory.toJson());
  }

  // Delete a HabitCategory from state and Firestore
  Future<void> deleteCategory(HabitCategory targetCategory) async {
    state = state
        .where((category) => category.categoryId != targetCategory.categoryId)
        .toList();
    await _firestore
        .collection('habitCategories')
        .doc(targetCategory.categoryId)
        .delete();
  }

  // Update a HabitCategory by deleting and re-adding it
  Future<void> updateCategory(
      HabitCategory targetCategory, HabitCategory newCategory) async {
    int index = state.indexOf(targetCategory);
    
    List<HabitCategory> newState = state
        .where((category) => category.categoryId != targetCategory.categoryId)
        .toList();
    newState.insert(index, newCategory);
    state = newState;

    await _firestore
        .collection('habitCategories')
        .doc(newCategory.categoryId)
        .set(newCategory.toJson());
  }

  void loadDummies() {
    state = dummyCategories;
  }

  void cleanState() {
    state = [];
  }

  bool isCategoryListEmpty() {
    return state.isEmpty;
  }

  HabitCategory? getCategoryById(String? categoryId) {
    return state.firstWhereOrNull((category) => category.categoryId == categoryId);
  }
}

final habitCategoryProvider =
    StateNotifierProvider<HabitCategoryNotifier, List<HabitCategory>>((ref) {
  return HabitCategoryNotifier(ref);
});


final List<HabitCategory> dummyCategories = [
  HabitCategory(name: 'Well-Being', color: Colors.blue),
  HabitCategory(name: 'Find Love', color: Colors.pink),
  HabitCategory(name: 'Self-Esteem', color: Colors.purple),
  HabitCategory(name: 'Happy Relationship', color: Colors.blueAccent),
  HabitCategory(name: 'Wealth', color: Colors.yellow),
  HabitCategory(name: 'Passion', color: Colors.orange),
  HabitCategory(name: 'Ikigai', color: Colors.deepPurple),
  HabitCategory(name: 'Happiness', color: Colors.yellow),
  HabitCategory(name: 'Dream Body', color: Colors.blue),
];