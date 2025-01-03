// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tracker_v1/daily/data/custom_day_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ReorderedDayNotifier extends StateNotifier<List<CustomDay>> {
//   ReorderedDayNotifier(this.ref) : super([]);
//   final Ref ref;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Add a new ReorderedDay to the state and Firestore
//   Future<void> addReorderedDay(CustomDay newReorder) async {
//     state = [...state, newReorder];

//     await _firestore
//         .collection('special_day_reorders')
//         .doc('${newReorder.userId}_${newReorder.date.toIso8601String()}')
//         .set(newReorder.toJson());
//   }

//   // Delete a ReorderedDay from state and Firestore
//   Future<void> deleteReorderedDay(CustomDay targetReorder) async {
//     await _firestore
//         .collection('special_day_reorders')
//         .doc('${targetReorder.userId}_${targetReorder.date.toIso8601String()}')
//         .delete();
//   }

//   // Update a ReorderedDay by deleting and re-adding it
//   Future<void> updateReorderedDay(CustomDay updatedReorder) async {
//     state = [
//       ...state.where((reorder) => reorder.date != updatedReorder.date),
//       updatedReorder
//     ];

//     await _firestore
//         .collection('special_day_reorders')
//         .doc(
//             '${updatedReorder.userId}_${updatedReorder.date.toIso8601String()}')
//         .set(updatedReorder.toJson());
//   }

//   // Load all special day reorders for the current user
//   Future<void> loadData() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;

//     if (userId == null) return;

//     final snapshot = await _firestore
//         .collection('special_day_reorders')
//         .where('userId', isEqualTo: userId)
//         .get();

//     if (snapshot.docs.isEmpty) return;

//     final List<CustomDay> loadedData = snapshot.docs.map((doc) {
//       final data = doc.data();
//       return CustomDay.fromJson(data);
//     }).toList();

//     state = loadedData;
//   }

//   // Clean the state (reset to an empty list)
//   void cleanState() {
//     state = [];
//   }
// }

// final reorderedDayProvider =
//     StateNotifierProvider<ReorderedDayNotifier, List<CustomDay>>(
//   (ref) => ReorderedDayNotifier(ref),
// );
