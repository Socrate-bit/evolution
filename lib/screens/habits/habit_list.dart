import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/appearance.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/screens/habits/habit_screen.dart';
import 'package:tracker_v1/widgets/daily/habit_item.dart';

class MyWidget extends ConsumerWidget {
  MyWidget({super.key});
  final defaultAppearance = StatusAppearance(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      elementsColor: Colors.white);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsList = ref.watch(habitProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: habitsList.length,
          itemBuilder: (ctx, item) => GestureDetector(
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
              )),
    );
  }
}
