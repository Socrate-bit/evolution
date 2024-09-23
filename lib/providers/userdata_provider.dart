import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AuthNotifier extends StateNotifier<UserData?> {
  AuthNotifier() : super(null);

  final firestore = FirebaseFirestore.instance;

  Future<void> addUserData(UserData userdata) async {
    File pickedProfilPicture = File(userdata.profilPicture);

    final storage = firebase_storage.FirebaseStorage.instance;
    final fileName = pickedProfilPicture.uri.pathSegments.last;
    final storageRef = storage.ref().child('profile_pictures/$fileName');
    await storageRef.putFile(pickedProfilPicture);
    final downloadUrl = await storageRef.getDownloadURL();

    // Save user data to Firestore
    await firestore.collection('user_data').doc(userdata.userId).set({
      'userId': userdata.userId,
      'inscriptionDate': userdata.inscriptionDate.toIso8601String(),
      'name': userdata.name,
      'profilPicture': downloadUrl,
      'synced': userdata.synced ? true : false,
    });

    state = userdata..profilPicture = downloadUrl;
  }

  Future<void> loadData() async {
    final docSnapshot = await firestore
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (!docSnapshot.exists) {
      return;
    }

    final data = docSnapshot.data()!;
    final userData = UserData(
      userId: data['userId'] as String,
      inscriptionDate: DateTime.parse(data['inscriptionDate'] as String),
      name: data['name'] as String,
      profilPicture: data['profilPicture'] as String,
      synced: data['synced'] as bool,
    );

    state = userData;
  }

  void cleanState() {
    state = null;
  }
}

final userDataProvider = StateNotifierProvider<AuthNotifier, UserData?>(
  (ref) {
    return AuthNotifier();
  },
);
