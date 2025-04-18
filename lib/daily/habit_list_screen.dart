import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';

class AllHabitsPage extends ConsumerStatefulWidget {
  const AllHabitsPage({super.key, this.dateOpened, this.habitListNavigation});
  final DateTime? dateOpened;
  final HabitListNavigation? habitListNavigation; 

  @override
  ConsumerState<AllHabitsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<AllHabitsPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  static const List<String> _pageNames1 = ['Routines', 'Once', 'To Do'];
  static const List<String> _noItemText = [
    'No habits yet, create one!',
    'No unique tasks yet!',
    'Nothing to plan yet!'
  ];
  int _selectedPage1 = 0;

  LinkedHashMap<Habit, (Schedule?, HabitRecap?)> filterList(
      LinkedHashMap<Habit, (Schedule?, HabitRecap?)> allHabitsList) {
    if (_selectedPage1 == 0) {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) =>
            value.$1?.startDate == null || value.$1?.type == FrequencyType.Once);
    } else if (_selectedPage1 == 2) {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) => value.$1?.startDate != null);
    } else {
      return LinkedHashMap.from(allHabitsList)
        ..removeWhere((key, value) =>
            value.$1?.startDate == null || value.$1?.type != FrequencyType.Once);
    }
  }

  @override
  void initState() {
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
    final LinkedHashMap<Habit, (Schedule?, HabitRecap?)> filteredHabitsList =
        filterList(allHabitsList);

    Widget content;

    if (filteredHabitsList.isNotEmpty) {
      content = HabitReorderableList(
        habitScheduleMap: filteredHabitsList,
        navigation: widget.habitListNavigation,
        selectedDate: widget.dateOpened,
      );
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
