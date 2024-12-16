import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/statistics/data/user_stats.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';

List<UserStats> _correctedUserStats(List<UserStats> userStats) {
  DateTime startOfCurrentMonth = DateTime(today.year, today.month, 1);
  DateTime startOfCurrentWeek = today.subtract(Duration(days: now.weekday - 1));

  return userStats.map((userStat) {
    return userStat.copyWith(
        scoreWeek: userStat.dateSync.isBefore(startOfCurrentWeek)
            ? 0
            : userStat.scoreWeek,
        scoreMonth: userStat.dateSync.isBefore(startOfCurrentMonth)
            ? 0
            : userStat.scoreMonth);
  }).toList();
}

final allUserStatsProvider =
    FutureProvider<(List<UserStats>, List<UserData>)>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('user_stats').get();
  final snapshot2 = await firestore.collection('user_data').get();

  final List<UserStats> userStats = snapshot.docs.map((doc) {
    final data = doc.data();
    try {
      return UserStats.fromJson(data);
    } catch (e) {
      return UserStats(
          userId: data['userId'],
          scoreWeek: 0,
          scoreMonth: 0,
          scoreAllTime: 0,
          dateSync: today);
    }
  }).toList();

  final List<UserData> userDatas = snapshot2.docs.map((doc) {
    final data = doc.data();
    return UserData.fromJson(data);
  }).toList();

  final List<UserStats> correctedStats = _correctedUserStats(userStats);

  return (correctedStats, userDatas);
});
