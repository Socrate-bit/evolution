import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';

class ToPlanScreen extends ConsumerStatefulWidget {
  const ToPlanScreen({super.key});

  @override
  ConsumerState<ToPlanScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<ToPlanScreen> {
  LinkedHashMap<Habit, Schedule> filterList(
      LinkedHashMap<Habit, Schedule> allHabitsList) {
    return LinkedHashMap.from(allHabitsList)
      ..removeWhere((key, value) =>
          value.startDate != null);
  }

  @override
  Widget build(BuildContext context) {
    final allHabitsList = ref.watch(scheduleCacheProvider(null));
    final LinkedHashMap<Habit, Schedule> filteredHabitsList =
        filterList(allHabitsList);

    Widget content;

    if (filteredHabitsList.isNotEmpty) {
      content = HabitReorderableList(habitScheduleMap: filteredHabitsList);
    } else {
      content = const Align(child: Text('No items create one!'));
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('To Plan'),
          centerTitle: true,
        ),
        body: content);
  }
}
