import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class RecapDayNotifier extends StateNotifier<List<RecapDay>> {
  RecapDayNotifier(this.ref) : super([]);
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new RecapDay to the state and Firestore
  Future<void> addRecapDay(RecapDay newRecapDay) async {
    state = [...state, newRecapDay];

    await _firestore.collection('RecapDay').doc(newRecapDay.recapId).set({
      'userId': newRecapDay.userId,
      'date': newRecapDay.date.toIso8601String(),
      'sleepQuality': newRecapDay.sleepQuality,
      'wellBeing': newRecapDay.wellBeing,
      'energy': newRecapDay.energy,
      'driveMotivation': newRecapDay.driveMotivation,
      'stress': newRecapDay.stress,
      'focusMentalClarity': newRecapDay.focusMentalClarity,
      'intelligenceMentalPower': newRecapDay.intelligenceMentalPower,
      'frustrations': newRecapDay.frustrations,
      'satisfaction': newRecapDay.satisfaction,
      'selfEsteemProudness': newRecapDay.selfEsteemProudness,
      'lookingForwardToWakeUpTomorrow':
          newRecapDay.lookingForwardToWakeUpTomorrow,
      'recap': newRecapDay.recap,
      'improvements': newRecapDay.improvements,
      'gratefulness': newRecapDay.gratefulness,
      'emotionalRecap': newRecapDay.emotionalRecap,
      'proudness': newRecapDay.proudness,
      'altruism': newRecapDay.altruism,
      'additionalMetrics': newRecapDay.additionalMetrics != null
          ? jsonEncode(newRecapDay.additionalMetrics)
          : null,
      'synced': newRecapDay.synced,
    });
  }

  // Delete a RecapDay from state and Firestore
  Future<void> deleteRecapDay(RecapDay targetRecapDay) async {
    state =
        state.where((day) => day.recapId != targetRecapDay.recapId).toList();

    await _firestore
        .collection('RecapDay')
        .doc(targetRecapDay.recapId)
        .delete();
  }

  // Update a RecapDay by deleting and re-adding it
  Future<void> updateRecapDay(RecapDay updatedRecapDay) async {
    await deleteRecapDay(updatedRecapDay);
    await addRecapDay(updatedRecapDay);
  }

  Future<void> deleteAllRecapDays() async {
    state = [];
   await _deleteAllRecapDaysFirebase();
  }

  Future<void> _deleteAllRecapDaysFirebase() async {
    final querySnapshot = await _firestore
        .collection('RecapDay')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    WriteBatch batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Load data from Firestore into the state
  Future<void> loadData() async {
    final snapshot = await _firestore
        .collection('RecapDay')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.docs.isEmpty) return;

    final List<RecapDay> loadedData = snapshot.docs.map((doc) {
      final data = doc.data();
      return RecapDay(
        recapId: doc.id,
        userId: data['userId'] as String,
        date: DateTime.parse(data['date'] as String),
        sleepQuality: data['sleepQuality'] as double? ?? 0,
        wellBeing: data['wellBeing'] as double? ?? 0,
        energy: data['energy'] as double? ?? 0,
        driveMotivation: data['driveMotivation'] as double? ?? 0,
        stress: data['stress'] as double? ?? 0,
        focusMentalClarity: data['focusMentalClarity'] as double? ?? 0,
        intelligenceMentalPower:
            data['intelligenceMentalPower'] as double? ?? 0,
        frustrations: data['frustrations'] as double? ?? 0,
        satisfaction: data['satisfaction'] as double? ?? 0,
        selfEsteemProudness: data['selfEsteemProudness'] as double? ?? 0,
        lookingForwardToWakeUpTomorrow:
            data['lookingForwardToWakeUpTomorrow'] as double? ?? 0,
        recap: data['recap'] as String?,
        improvements: data['improvements'] as String?,
        additionalMetrics: data['additionalMetrics'] != null
            ? jsonDecode(data['additionalMetrics'] as String)
            : null,
        gratefulness: data['gratefulness'] as String?,
        emotionalRecap: data['gratefulness'] as String?,
        proudness: data['proudness'] as String?,
        altruism: data['altruism'] as String?,
        synced: data['synced'] == true,
      );
    }).toList();

    state = loadedData;
  }

  void cleanState() {
    state = [];
  }
}

// Riverpod provider for RecapDayNotifier
final recapDayProvider =
    StateNotifierProvider<RecapDayNotifier, List<RecapDay>>(
  (ref) => RecapDayNotifier(ref),
);
