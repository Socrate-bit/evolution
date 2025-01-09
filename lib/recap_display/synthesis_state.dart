import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';

class SynthesisState {
  DateTime? date;
  Habit? habit;
  SynthesisState(this.date, this.habit);
}

class SynthesisStateNotifier extends StateNotifier<SynthesisState> {
  SynthesisStateNotifier() : super(SynthesisState(DateTime.now(), null));

  void setDate(DateTime? date) {
    state = SynthesisState(date, state.habit);
  }

  void setHabit(Habit? habit) {
    state = SynthesisState(state.date, habit);
  }
}

final synthesisStateProvider =
    StateNotifierProvider<SynthesisStateNotifier, SynthesisState>((ref) {
  return SynthesisStateNotifier();
});
