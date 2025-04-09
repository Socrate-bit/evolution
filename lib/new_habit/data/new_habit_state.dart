import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';

class NewHabitState extends StateNotifier<Habit> {
  NewHabitState(this.ref)
      : super(Habit(
          userId: FirebaseAuth.instance.currentUser!.uid,
          icon: Icons.self_improvement,
          name: '',
          description: '',
          newHabit: '',
          validationType: HabitType.simple,
          duration: Duration(minutes: 1),
          additionalMetrics: [],
          orderIndex: ref.read(habitProvider).length,
          ponderation: 3,
          color: const Color.fromARGB(255, 248, 189, 51),
        ));

  final Ref ref;

  void setIcon(IconData icon) {
    state = state.copy(icon: icon);
  }

  void setName(String name) {
    state = state.copy(name: name);
  }

  void setDescription(String description) {
    state = state.copy(description: description);
  }

  void setMainImprovement(String mainImprovement) {
    state = state.copy(newHabit: mainImprovement);
  }

  void setValidationType(HabitType validationType) {
    state = state.copy(validationType: validationType);
  }

  void setAdditionalMetrics(List<String> additionalMetrics) {
    state = state.copy(additionalMetrics: additionalMetrics);
  }

  void addAdditionalMetrics(String metric) {
    state =
        state.copy(additionalMetrics: [...state.additionalMetrics!, metric]);
  }

  void setShared() {
    state = state.copy(shared: true);
  }

  void removeAdditionalMetrics(int index) {
    state = state.copy(
      additionalMetrics: [
        ...List.from(state.additionalMetrics!)..removeAt(index)
      ],
    );
  }

  void setPonderation(int ponderation) {
    state = state.copy(ponderation: ponderation);
  }

  void setColor(Color color) {
    state = state.copy(color: color);
  }

  void setDuration(Duration duration) {
    state = state.copy(duration: duration);
  }

  static const List<Duration> preMadeDuration = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2)
  ];

  bool isCustomDuration() {
    return preMadeDuration.contains(state.duration);
  }

  void setState(Habit habit) {
    state = habit;
  }
}

final newHabitStateProvider =
    StateNotifierProvider.autoDispose<NewHabitState, Habit>((ref) {
  return NewHabitState(ref);
});
