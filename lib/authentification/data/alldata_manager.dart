import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/logic/convert_habitV1.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/naviguation/naviguation_state.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/notifications/data/scheduled_notifications_state.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/statistics/data/statistics_model.dart';
import 'package:tracker_v1/statistics/data/statistics_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/friends/data/user_stats_provider.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/friends/data/alluserstats_provider.dart';
import 'package:tracker_v1/statistics/logic/statistics_service.dart';

final dataManagerProvider = Provider((ref) => DataManager(ref));

class DataManager {
  final ProviderRef ref;

  DataManager(this.ref);

  Future<void> cleanData() async {
    ref.read(userDataProvider.notifier).cleanState();
    ref.read(habitProvider.notifier).cleanState();
    ref.read(trackedDayProvider.notifier).cleanState();
    ref.read(recapDayProvider.notifier).cleanState();
    ref.read(scheduledProvider.notifier).cleanState();
    ref.read(navigationStateProvider.notifier).cleanState();
    ref.read(notificationsProvider.notifier).deleteNotifications();
    ScheduleCacheNotifier.cleanAll();
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

    // Delete user data from 'user_data' collection
    final scheduleQuery = await firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in scheduleQuery.docs) {
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

      ref.read(notificationsProvider);
      listenToScheduleProvider(ref);
      listenToStatsProvider(ref);

      await Future.wait([
        ref.read(habitProvider.notifier).loadData(),
        ref.read(trackedDayProvider.notifier).loadData(),
        ref.read(recapDayProvider.notifier).loadData(),
        ref.read(userStatsProvider.notifier).loadUserStats(),
        ref.read(statNotiferProvider.notifier).loadData(),
        ref.read(habitProvider.notifier).loadData(),
        ref.read(scheduledProvider.notifier).loadData(),
      ]);

      await v1Converter(ref.read(habitProvider), ref);

      ref.read(allUserStatsProvider);
    } catch (error) {
      signOut();
    }
  }
}

void updateTitleWidget(ref) async {
  String todayHabitJson =
      ref.read(scheduleCacheProvider(today).notifier).toJson();
  HomeWidget.saveWidgetData('todayHabitJson', todayHabitJson);
  HomeWidget.updateWidget(
    name: 'home_widget_test',
    iOSName: 'home_widget_test',
  );
}

void updatePerformanceWidget(ref) async {
  String jsonStats = ref.read(statNotiferProvider.notifier).toJson();
  if (jsonStats.isEmpty || jsonStats == '[]') return;

  HomeWidget.saveWidgetData('available_stats', jsonStats);
  updatePerformanceDataWidget(ref);

  HomeWidget.updateWidget(
    name: 'performance_widget',
    iOSName: 'performance_widget',
  );
}

void updatePerformanceDataWidget(ref) async {
  List<Stat> statsList = ref.read(statNotiferProvider);
  List<String> statsDataList = getContainerStats(ref, statsList, 0, 0, null, null);
  List<String> statsDataListLastWeek = getContainerStats(ref, statsList, 1, 0, null, null);

  for (int index in List.generate(statsList.length, (index) => index)) {
    Map<String, String> jsonStatsData = {
      'actualValue': statsDataList[index],
      'maxValue': statsDataListLastWeek[index],
      'color': statsList.elementAt(index).color.value.toString(),
    };

    HomeWidget.saveWidgetData(statsList[index].statId, jsonEncode(jsonStatsData));
  }

  HomeWidget.updateWidget(
    name: 'performance_data_widget',
    iOSName: 'performance_data_widget',
  );
}

void listenToStatsProvider(ref) {
  ref.listen(statNotiferProvider, (previous, next) {
    updatePerformanceWidget(ref);
  });
}

void listenToScheduleProvider(ref) {
  ref.listen(scheduleCacheProvider(today), (previous, next) {
    updateTitleWidget(ref);
    updatePerformanceWidget(ref);
  });
}

final firestoreUploadProvider = StateProvider<bool>((ref) => false);
