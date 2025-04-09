import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_habit_stats_model.dart';

class SharedHabitCategoriesState extends StateNotifier<SharedHabitStats> {
  SharedHabitCategoriesState(this.ref)
      : super(SharedHabitStats(
          numberOfUsers: 0,
          categoriesRating: {},
          globalRating: 0.0,
          habitId: '',
        ));

  final Ref ref;

  void setNumberOfUsers(int numberOfUsers) {
    state = state.copy(numberOfUsers: numberOfUsers);
  }

  void setCategoriesRating(Map<String, double> categoriesRating) {
    state = state.copy(categoriesRating: categoriesRating);
  }

  void addCategoryRating(String category, double rating) {
    final updatedCategoriesRating = Map<String, double>.from(state.categoriesRating)
      ..[category] = rating;
    state = state.copy(categoriesRating: updatedCategoriesRating);
  }

  void deleteCategoryRating(String category) {
    final updatedCategoriesRating = Map<String, double>.from(state.categoriesRating)
      ..remove(category);
    state = state.copy(categoriesRating: updatedCategoriesRating);
  }
  

  void setGlobalRating(double globalRating) {
    state = state.copy(globalRating: globalRating);
  }

  void setHabitId(String habitId) {
    state = state.copy(habitId: habitId);
  }

  void setStatId(String statId) {
    state = state.copy(statId: statId);
  }

  void setState(SharedHabitStats sharedHabitStats) {
    state = sharedHabitStats;
  }
}

final sharedHabitStateProvider =
    StateNotifierProvider.autoDispose<SharedHabitCategoriesState, SharedHabitStats>(
        (ref) {
  return SharedHabitCategoriesState(ref);
});
