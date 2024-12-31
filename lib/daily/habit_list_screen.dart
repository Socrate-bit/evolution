import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';

class AllHabitsPage extends ConsumerStatefulWidget {
  const AllHabitsPage({super.key});

  @override
  ConsumerState<AllHabitsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<AllHabitsPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  static const List<String> _pageNames1 = ['Routines', 'Once', 'To Do'];
  static const List<String> _noItemText = [
    'No habits yet, create one!',
    'No unique tasks yet, create one!',
    'No unique things to plan yet, create one!'
  ];
  int _selectedPage1 = 0;

  LinkedHashMap<Habit, Schedule> filterList(
      LinkedHashMap<Habit, Schedule> allHabitsList) {
    if (_selectedPage1 == 0) {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) =>
            value.startDate == null || value.type == FrequencyType.Once);
    } else if (_selectedPage1 == 2) {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) => value.startDate != null);
    } else {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) =>
            value.startDate == null || value.type != FrequencyType.Once);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        _selectedPage1 = tabController.index;
      });
    });
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
      content = Align(child: Text(_noItemText[_selectedPage1]));
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('All Items'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            TabBar(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: (value) => HapticFeedback.selectionClick(),
              tabs: <Widget>[..._pageNames1.map((e) => Text(e))],
              controller: tabController,
            ),
            Expanded(child: content),
          ],
        ));
  }
}
