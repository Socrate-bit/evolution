import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/global/habits_reorderable_list.dart';

class AllHabitsPage extends ConsumerStatefulWidget {
  const AllHabitsPage({super.key});

  @override
  ConsumerState<AllHabitsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<AllHabitsPage> {
  @override
  Widget build(BuildContext context) {
    final habitsList = ref
        .watch(habitProvider)
        .where((habit) => habit.validationType != HabitType.unique)
        .toList();
    Widget content;

    if (habitsList.isNotEmpty) {
      content = HabitList(displayedHabitList: habitsList);
    } else {
      content = const Align(child: Text('No habits yet, create one!'));
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('All Routines'),
          centerTitle: true,
        ),
        body: content);
  }
}
