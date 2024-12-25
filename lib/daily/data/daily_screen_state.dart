import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';

class DailyScreenState {
  final DateTime selectedDate;
  final PageController pageIndex;
  double? previousComputingRatio;

  DailyScreenState(
      {required this.selectedDate,
      required this.pageIndex,
      this.previousComputingRatio});
}

class DailyScreenStateNotifier extends StateNotifier<DailyScreenState> {
  DailyScreenStateNotifier(
    this.ref,
  ) : super(
          DailyScreenState(
            selectedDate: DateTime.now().hour >= 2
                ? today
                : today.subtract(Duration(days: 1)),
            pageIndex: PageController(initialPage: 52),
          ),
        );

  Ref ref;

  void updatePreviousRatio() {
    double? newNumber = completionComputing([state.selectedDate], ref);
    state = DailyScreenState(
      selectedDate: state.selectedDate,
      pageIndex: state.pageIndex,
      previousComputingRatio: newNumber,
    );
  }

  void updateSelectedDate(DateTime newDate) {
    state = DailyScreenState(
      selectedDate: newDate,
      pageIndex: state.pageIndex,
    );
  }

  void jumpToTodayPage() {
    state.pageIndex
        .animateToPage(52, duration: Durations.medium1, curve: Curves.ease);
  }
}

final dailyScreenStateProvider = StateNotifierProvider.autoDispose<
    DailyScreenStateNotifier, DailyScreenState>((ref) {
  return DailyScreenStateNotifier(ref);
});
