import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';

class DailyScreenState {
  final DateTime selectedDate;

  DailyScreenState({required this.selectedDate});
}

class DailyScreenStateNotifier extends StateNotifier<DailyScreenState> {
  DailyScreenStateNotifier()
      : super(
          DailyScreenState(
            selectedDate: DateTime.now().hour >= 2
                ? today
                : today.subtract(Duration(days: 1)),
          ),
        );

  String displayedDate() {
    if (today == state.selectedDate) {
      return 'Today';
    } else if (today.add(Duration(days: 1)) == state.selectedDate) {
      return 'Tomorrow';
    } else if (today.subtract(Duration(days: 1)) == state.selectedDate) {
      return 'Yesterday';
    } else {
      return formater1.format(state.selectedDate);
    }
  }

  void updateSelectedDate(DateTime newDate) {
    state = DailyScreenState(
      selectedDate: newDate,
    );
  }
}

final dailyScreenStateProvider =
    StateNotifierProvider.autoDispose<DailyScreenStateNotifier, DailyScreenState>((ref) {
  return DailyScreenStateNotifier();
});
