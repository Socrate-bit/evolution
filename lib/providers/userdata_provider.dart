import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:tracker_v1/models/datas/user_stats.dart';
import 'package:tracker_v1/providers/user_stats_provider.dart';

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
    await firestore.collection('user_data').doc(userdata.userId).set(userdata.toJson());

    // Update local state
    state = userdata;

    // Add user stats (assuming userStatsProvider handles user stats)
    ref.read(userStatsProvider.notifier).addUserStats(UserStats(userId: userdata.userId!));
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

  // Clear the state when needed
  void cleanState() {
    state = null;
  }
}

// Provider for user data
final userDataProvider = StateNotifierProvider<AuthNotifier, UserData?>(
  (ref) {
    return AuthNotifier(ref);
  },
);
