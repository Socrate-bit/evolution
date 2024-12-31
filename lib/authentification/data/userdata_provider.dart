import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:tracker_v1/notifications/data/scheduled_notifications_state.dart';
import 'package:tracker_v1/statistics/data/user_stats.dart';
import 'package:tracker_v1/friends/data/user_stats_provider.dart';

class AuthNotifier extends StateNotifier<UserData?> {
  AuthNotifier(this.ref) : super(null);

  final Ref ref;
  final firestore = FirebaseFirestore.instance;

  // Add or update UserData in Firestore
  Future<void> addUserData(UserData userdata) async {
    File pickedProfilPicture = File(userdata.profilPicture);

    // Upload profile picture to Firebase Storage
    final storage = firebase_storage.FirebaseStorage.instance;
    final fileName = pickedProfilPicture.uri.pathSegments.last;
    final storageRef = storage.ref().child('profile_pictures/$fileName');
    await storageRef.putFile(pickedProfilPicture);
    final downloadUrl = await storageRef.getDownloadURL();

    // Update UserData object with the new profile picture URL
    userdata = userdata.copy()..profilPicture = downloadUrl;

    // Save user data to Firestore using the toJson method
    await firestore
        .collection('user_data')
        .doc(userdata.userId)
        .set(userdata.toJson());

    // Update local state
    state = userdata;

    // Add user stats (assuming userStatsProvider handles user stats)
    ref
        .read(userStatsProvider.notifier)
        .addUserStats(UserStats(userId: userdata.userId!, dateSync: today));
  }

  // Load user data from Firestore and set local state
  Future<void> loadData() async {
    final docSnapshot = await firestore
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (!docSnapshot.exists) {
      return;
    }

    // Use the fromJson method to create UserData from Firestore document data
    final userData = UserData.fromJson(docSnapshot.data()!);

    // Update local state
    state = userData;
  }

  Future<UserData?> loadTargetUserData(String uuid) async {
    final docSnapshot = await firestore.collection('user_data').doc(uuid).get();

    if (!docSnapshot.exists) {
      return null;
    }

    // Use the fromJson method to create UserData from Firestore document data
    final userData = UserData.fromJson(docSnapshot.data()!);

    return userData;
  }

  // Clear the state when needed
  void cleanState() {
    state = null;
  }

  // Update user data
  Future<void> changeNotificationSettings(bool notificationActivated) async {
    if (!notificationActivated) {
      ref.read(notificationsProvider.notifier).cancelNotifications();
    } else {
      ref.read(notificationsProvider.notifier).cancelNotifications();
      ref.read(notificationsProvider.notifier).scheduleNotifications();
    }

    // Update the user data in Firestore using the toJson method
    await firestore
        .collection('user_data')
        .doc(state!.userId)
        .update({'notificationActivated': notificationActivated});

    // Update local state with the new notificationActivated value
    state = state!.copy()..notificationActivated = notificationActivated;
  }

  Future<void> changePriorityDisplaySettings(bool priorityDisplayActivated) async {
    // Update the user data in Firestore using the toJson method
    await firestore
        .collection('user_data')
        .doc(state!.userId)
        .update({'priorityDisplayActivated': priorityDisplayActivated});

    // Update local state with the new priorityDisplayActivated value
    state = state!.copy()..priorityDisplay = priorityDisplayActivated;
  }

  // Method to update existing user data in Firestore
  Future<void> updateUserData(UserData updatedUserData) async {
    File? pickedProfilPicture;

    // Check if a new profile picture is provided
    if (updatedUserData.profilPicture.isNotEmpty &&
        updatedUserData.profilPicture.startsWith('/')) {
      pickedProfilPicture = File(updatedUserData.profilPicture);

      // Upload the new profile picture to Firebase Storage
      final storage = firebase_storage.FirebaseStorage.instance;
      final fileName = pickedProfilPicture.uri.pathSegments.last;
      final storageRef = storage.ref().child('profile_pictures/$fileName');
      await storageRef.putFile(pickedProfilPicture);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the UserData object with the new profile picture URL
      updatedUserData = updatedUserData.copy()..profilPicture = downloadUrl;
    }

    // Update the user data in Firestore using the toJson method
    await firestore
        .collection('user_data')
        .doc(updatedUserData.userId)
        .update(updatedUserData.toJson());

    // Update local state with the updated user data
    state = updatedUserData;
  }
}

// Provider for user data
final userDataProvider = StateNotifierProvider<AuthNotifier, UserData?>(
  (ref) {
    return AuthNotifier(ref);
  },
);
