import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';

class AllHabitsPage extends ConsumerStatefulWidget {
  const AllHabitsPage({super.key});

  @override
  ConsumerState<AllHabitsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<AllHabitsPage> {
  @override
  Widget build(BuildContext context) {
    final habitsList = ref.watch(scheduleCacheProvider(null));

    Widget content;

    if (habitsList.isNotEmpty) {
      content = HabitReorderableList(habitScheduleMap: habitsList);
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
