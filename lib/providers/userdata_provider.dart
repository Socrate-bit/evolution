import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthNotifier extends StateNotifier<UserData?> {
  AuthNotifier() : super(null);

  final firestore = FirebaseFirestore.instance;

  Future<void> addUserData(UserData userdata) async {
    state = userdata;

    // Save user data to Firestore
    await firestore.collection('user_data').doc(userdata.userId).set({
      'userId': userdata.userId,
      'inscriptionDate': userdata.inscriptionDate.toIso8601String(),
      'name': userdata.name,
      'profilPicture': userdata.profilPicture,
      'synced': userdata.synced ? true : false,
    });
  }

  Future<void> loadData() async {
    final docSnapshot = await firestore
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (!docSnapshot.exists) return;

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
}

final userDataProvider = StateNotifierProvider<AuthNotifier, UserData?>(
  (ref) {
    return AuthNotifier();
  },
);
