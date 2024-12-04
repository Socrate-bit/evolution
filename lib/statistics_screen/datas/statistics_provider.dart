import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/statistics_screen/datas/statistics_model.dart';

class StatNotifier extends StateNotifier<List<Stat>> {
  StatNotifier(this.ref) : super([]);
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new Stat to the state and Firestore
  Future<void> addStat(Stat newStat) async {
    state = [...state, newStat];

    await _firestore
        .collection('stats')
        .doc(newStat.statId)
        .set(newStat.toJson());
  }

  Future<void> reorderStats(int oldIndex, int newIndex) async {
    List<Stat> newState = List.from(state);

    final stat = newState.removeAt(oldIndex);
    newState.insert(newIndex, stat);

    for (int i = 0; i < newState.length; i++) {
      newState[i] = newState[i].copyWith(index: i);
    }

        state = newState;
    WriteBatch batch = _firestore.batch();
    newState.forEach((Stat stat) {
      batch.update(
        _firestore.collection('stats').doc(stat.statId),
        {'index': stat.index},
      );
    });
    await batch.commit();

  }

  // Delete a Stat from state and Firestore
  Future<void> deleteStat(Stat targetStat) async {
    state = state.where((stat) => stat.statId != targetStat.statId).toList();

    await _firestore.collection('stats').doc(targetStat.statId).delete();
  }

  // Update a Stat by deleting and re-adding it
  Future<void> updateStat(Stat updatedStat) async {
    state = [
      ...state.where((stat) => stat.statId != updatedStat.statId),
      updatedStat
    ];

    await _firestore
        .collection('stats')
        .doc(updatedStat.statId)
        .set(updatedStat.toJson());
  }

  // Load all stats for the current user
  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final querySnapshot = await _firestore
        .collection('stats')
        .where('users', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      state = _basicStats;
      for (final stat in _basicStats) {
        await _firestore
            .collection('stats')
            .doc(stat.statId)
            .set(stat.toJson());
      }
    } else {
      state =
          querySnapshot.docs.map((doc) => Stat.fromJson(doc.data())).toList();
    }
  }

  void cleanState() {
    state = [];
  }
}

final statNotiferProvider = StateNotifierProvider<StatNotifier, List<Stat>>(
  (ref) => StatNotifier(ref),
);

String userId = FirebaseAuth.instance.currentUser!.uid;

final List<Stat> _basicStats = [
  Stat(
      index: 0,
      users: userId,
      type: StatType.basic,
      name: 'Score',
      formulaType: BasicHabitSubtype.score,
      color: Color.fromARGB(255, 20, 20, 20),
      maxY: null),
  Stat(
      index: 1,
      users: userId,
      type: StatType.basic,
      name: 'Evaluation',
      formulaType: BasicHabitSubtype.evaluation,
      color: Color.fromARGB(255, 20, 20, 20),
      maxY: 10),
  Stat(
      index: 2,
      users: userId,
      type: StatType.basic,
      name: 'Completion',
      formulaType: BasicHabitSubtype.completion,
      color: Color.fromARGB(255, 20, 20, 20),
      maxY: 100),
  Stat(
      index: 3,
      users: userId,
      type: StatType.basic,
      name: 'Habits validated',
      formulaType: BasicHabitSubtype.habitsValidated,
      color: Color.fromARGB(255, 20, 20, 20),
      maxY: null),
  Stat(
      index: 4,
      users: userId,
      type: StatType.basic,
      name: 'SumStreaks',
      formulaType: BasicHabitSubtype.bsumStreaks,
      color: Color.fromARGB(255, 20, 20, 20),
      maxY: null),
];
