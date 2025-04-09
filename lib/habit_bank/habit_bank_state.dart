import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitBankState {
  final int currentIndex;
  final String researchQuery;
  final String? selectedCategory;

  HabitBankState(this.currentIndex, this.researchQuery, this.selectedCategory);
}

class NavigationStateNotifier extends StateNotifier<HabitBankState> {
  NavigationStateNotifier() : super(HabitBankState(0, '', ''));

  void setIndex(int index) {
    state = HabitBankState(index, '', null);
  }

  void setResearchQuery(String query) {
    state = HabitBankState(state.currentIndex, query, state.selectedCategory);
  }

  void setSelectedCategory(String? category) {
    state = HabitBankState(state.currentIndex, state.researchQuery, category);
  }

  void cleanState() {
    state = HabitBankState(0, '', null);
  }
}

final habitBankStateProvider = StateNotifierProvider<NavigationStateNotifier, HabitBankState>((ref) {
  return NavigationStateNotifier();
});