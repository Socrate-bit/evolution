import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/screens/habits/habit_screen.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';

class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  late dynamic habitsNotifier;
  final defaultAppearance = StatusAppearance(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      elementsColor: Colors.white);

  @override
  void initState() {
    super.initState();
    // Store a reference to the notifier here
    habitsNotifier = ref.read(habitProvider.notifier);
  }

  Future<void> databaseOrderChange() async {
    await habitsNotifier.databaseOrderChange();
  }

  void onReorder(int oldIndex, int newIndex) {
    habitsNotifier.stateOrderChange(oldIndex, newIndex);
  }

  @override
  void dispose() {
    databaseOrderChange();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsList = ref.watch(habitProvider);
    Widget content = const Align(
      child: Text('No habits yet, create one!'),
    );

    if (habitsList.isNotEmpty) {
      content = ReorderableListView.builder(
        onReorder: (int oldIndex, int newIndex) {
          onReorder(oldIndex, newIndex);
        },
        itemCount: habitsList.length,
        itemBuilder: (ctx, item) => GestureDetector(
          key: ObjectKey(habitsList[item]),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => HabitScreen(habitsList[item]),
              ),
            );
          },
          child: HabitWidget(
              name: habitsList[item].name,
              icon: habitsList[item].icon,
              appearance: defaultAppearance),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Habits List'),
          centerTitle: true,
        ),
        body: content);
  }
}
