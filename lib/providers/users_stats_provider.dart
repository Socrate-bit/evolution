import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';

final allUserStatsProvider = FutureProvider<(List<UserStats>, List<UserData>)>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('user_stats').get();
  final snapshot2 = await firestore.collection('user_data').get();

  final List<UserStats> userStats = snapshot.docs.map((doc) {
    final data = doc.data();
    return UserStats.fromJson(data);
  }).toList();

  final List<UserData> userDatas = snapshot2.docs.map((doc) {
    final data = doc.data();
    return UserData.fromJson(data);
  }).toList();

  // Sort the users by total gems
  userStats.sort((a, b) => b.streaks.compareTo(a.streaks));

  return (userStats, userDatas);
});
