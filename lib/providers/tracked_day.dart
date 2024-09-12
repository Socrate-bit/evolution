import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TrackedDayNotifier extends StateNotifier<Map<String, TrackedDay>> {
  TrackedDayNotifier(this.ref) : super({});
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTrackedDay(TrackedDay newTrackedDay) async {
    state = {...state, newTrackedDay.trackedDayId: newTrackedDay};

    await _firestore.collection('TrackedDay').doc(newTrackedDay.trackedDayId).set({
      'userId' : newTrackedDay.userId, 
      'habitId': newTrackedDay.habitId,
      'date': newTrackedDay.date.toIso8601String(),
      'done': newTrackedDay.done == Validated.yes ? true : false,
      'notation_showUp': newTrackedDay.notation?.showUp,
      'notation_investment': newTrackedDay.notation?.investment,
      'notation_method': newTrackedDay.notation?.method,
      'notation_result': newTrackedDay.notation?.result,
      'notation_goal': newTrackedDay.notation?.goal,
      'notation_extra': newTrackedDay.notation?.extra,
      'recap': newTrackedDay.recap,
      'improvements': newTrackedDay.improvements,
      'additionalMetrics': newTrackedDay.additionalMetrics != null
          ? jsonEncode(newTrackedDay.additionalMetrics)
          : null,
      'synced': newTrackedDay.synced ? true : false,
    });

    ref.read(habitProvider.notifier).addTrackedDay(newTrackedDay);
  }

  Future<void> deleteTrackedDay(TrackedDay targetTrackedDay) async {
    state = Map.from(state)..remove(targetTrackedDay.trackedDayId);

    await _firestore.collection('TrackedDay').doc(targetTrackedDay.trackedDayId).delete();

    ref.read(habitProvider.notifier).deleteTrackedDay(targetTrackedDay);
  }

  Future<void> updateTrackedDay(TrackedDay targetTrackedDay) async {
    deleteTrackedDay(targetTrackedDay);
    addTrackedDay(targetTrackedDay);
  }

  Future<void> deleteHabitTrackedDays(Habit habit) async {
    for (String trackedDay in habit.trackedDays.values) {
      deleteTrackedDay(state[trackedDay]!);
    }
  }

  Future<void> loadData() async {
    final snapshot = await _firestore.collection('TrackedDay').get();
    final data = snapshot.docs;

    if (data.isEmpty) return;

    final Map<String, TrackedDay> loadedData = {};
    for (final doc in data) {
      final row = doc.data();
      final trackedDay = TrackedDay(
        trackedDayId: doc.id,
        userId: row['userId'] as String,
        habitId: row['habitId'] as String,
        date: DateTime.parse(row['date'] as String),
        done: (row['done'] as bool) ? Validated.yes : Validated.no,
        notation: row['notation_showUp'] == null
            ? null
            : Rating(
                showUp: row['notation_showUp'] as double,
                investment: row['notation_investment'] as double,
                method: row['notation_method'] as double,
                result: row['notation_result'] as double,
                goal: row['notation_goal'] as double,
                extra: row['notation_extra'] as double,
              ),
        recap: row['recap'] as String?,
        improvements: row['improvements'] as String?,
        additionalMetrics: row['additionalMetrics'] != null
            ? jsonDecode(row['additionalMetrics'] as String)
            : null,
        synced: row['synced'] as bool,
      );
      loadedData[trackedDay.trackedDayId] = trackedDay;
    }

    state = loadedData;
  }
}

final trackedDayProvider =
    StateNotifierProvider<TrackedDayNotifier, Map<String, TrackedDay>>(
  (ref) {
    return TrackedDayNotifier(ref);
  },
);
