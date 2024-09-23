import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';

final dataManagerProvider = Provider((ref) => DataManager(ref));

class DataManager {
  final ProviderRef ref;

  DataManager(this.ref);

  void cleanData() {
    ref.read(userDataProvider.notifier).cleanState();
    ref.read(habitProvider.notifier).cleanState();
    ref.read(trackedDayProvider.notifier).cleanState();
    ref.read(recapDayProvider.notifier).cleanState();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.currentUser!.delete();
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
        ref.read(recapDayProvider.notifier).loadData()
      ]);
    } catch (error) {
      signOut();
    }
  }
}

final firestoreUploadProvider = StateProvider<bool>((ref) => false);
