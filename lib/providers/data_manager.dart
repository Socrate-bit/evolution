import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/reordered_day.dart';
import 'package:tracker_v1/statistics_screen/datas/statistics_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/user_stats_provider.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/providers/users_stats_provider.dart';

final dataManagerProvider = Provider((ref) => DataManager(ref));

class DataManager {
  final ProviderRef ref;

  DataManager(this.ref);

  void cleanData() {
    ref.read(userDataProvider.notifier).cleanState();
    ref.read(habitProvider.notifier).cleanState();
    ref.read(trackedDayProvider.notifier).cleanState();
    ref.read(recapDayProvider.notifier).cleanState();
    ref.read(ReorderedDayProvider.notifier).cleanState();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    final userData = ref.read(userDataProvider);
    final firestore = FirebaseFirestore.instance;
    final fireStorage = FirebaseStorage.instance;
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    // Initialize Firestore batch
    final batch = firestore.batch();

    // Delete documents from 'habits' collection
    final habitsQuery = await firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in habitsQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete documents from 'TrackedDay' collection
    final trackedDaysQuery = await firestore
        .collection('TrackedDay')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in trackedDaysQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete documents from 'TrackedDay' collection
    final reordersDaysQuery = await firestore
        .collection('special_day_reorders')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in reordersDaysQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete documents from 'RecapDay' collection
    final recapDaysQuery = await firestore
        .collection('RecapDay')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in recapDaysQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user data from 'user_data' collection
    final userDataQuery = await firestore
        .collection('user_data')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in userDataQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user data from 'user_data' collection
    final userStatsQuery = await firestore
        .collection('user_stats')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in userStatsQuery.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch deletion
    await batch.commit();

    // Delete profile picture from Firebase Storage
    if (userData?.profilPicture != null && userData!.profilPicture.isNotEmpty) {
      try {
        final storageRef = fireStorage.refFromURL(userData.profilPicture);
        await storageRef.delete();
      } catch (e) {
        print('Error deleting profile picture: $e');
      }
    }

    // Delete FirebaseAuth account
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> loadData() async {
    try {
      await ref.read(userDataProvider.notifier).loadData();
      if (ref.read(userDataProvider) == null) {
        signOut();
        return;
      }

      await Future.wait([
        ref.read(habitProvider.notifier).loadData(),
        ref.read(trackedDayProvider.notifier).loadData(),
        ref.read(recapDayProvider.notifier).loadData(),
        ref.read(ReorderedDayProvider.notifier).loadData(),
        ref.read(userStatsProvider.notifier).loadUserStats(),
        ref.read(statNotiferProvider.notifier).loadData(),  
      ]);

      ref.read(allUserStatsProvider);
    } catch (error) {
      print(error);
      signOut();
    }
  }
}

final firestoreUploadProvider = StateProvider<bool>((ref) => false);
