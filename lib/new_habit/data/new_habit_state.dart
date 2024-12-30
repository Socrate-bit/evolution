import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
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
          frequency: 7,
          weekdays: [],
          validationType: HabitType.simple,
          startDate: today,
          endDate: null,
          timeOfTheDay: null,
          additionalMetrics: [],
          orderIndex: ref.read(habitProvider).length,
          ponderation: 3,
          color: const Color.fromARGB(255, 248, 189, 51),
          frequencyChanges: {},
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

  void setFrequency(int frequency) {
    state = state.copy(frequency: frequency);
  }

  void setWeekdays(List<WeekDay> weekdays) {
    state = state.copy(weekdays: weekdays);
  }

  void setValidationType(HabitType validationType) {
    state = state.copy(validationType: validationType);
  }

  void setStartDate(DateTime startDate) {
    state = state.copy(startDate: startDate);
  }

  void setEndDate(DateTime? endDate) {
    state = state.copy(endDate: endDate);
  }

  void setTimeOfTheDay(TimeOfDay? timeOfTheDay) {
    state = state.copy(timeOfTheDay: timeOfTheDay);
  }

  void setAdditionalMetrics(List<String> additionalMetrics) {
    state = state.copy(additionalMetrics: additionalMetrics);
  }

  void addAdditionalMetrics(String metric) {
    state =
        state.copy(additionalMetrics: [...state.additionalMetrics!, metric]);
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

  void setState(Habit habit) {
    state = habit;
  }
}

final newHabitStateProvider =
    StateNotifierProvider.autoDispose<NewHabitState, Habit>((ref) {
  return NewHabitState(ref);
});
