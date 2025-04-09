import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/habit_bank/data/habit_category_model.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_model.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_provider.dart';
import 'package:tracker_v1/habit_bank/data/shared_habits_provider.dart';
import 'package:tracker_v1/habit_bank/habit_bank_screen.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';

class CategoryHabitScreen extends ConsumerWidget {
  const CategoryHabitScreen(this.category, {super.key});
  final HabitCategory category;

  List<Habit?> getHabit(WidgetRef ref) {
    List<SharedHabitStats> allHabits = ref.read(sharedHabitStatsProvider);
    List<SharedHabitStats> categoryHabits = allHabits
        .where((element) => element.categoriesRating.keys
            .map((e) => e)
            .contains(category.categoryId))
        .toList();

    return categoryHabits
        .map((stat) => ref
            .read(sharedHabitsProvider.notifier)
            .getSharedHabitById(stat.habitId)
            ?.$1)
        .toList()
      ..removeWhere((habit) => habit == null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style =
        Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(category.name.capitalizeString()),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(
                width: double.infinity,
                height: 30,
                child: ListTile(
                    title: Text('NAME', style: style),
                    trailing: Text('IMPACT', style: style))),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(color: Colors.grey),
              height: 1,
              width: double.infinity,
            ),
            Expanded(child: CustomCardList(getHabit(ref) as List<Habit>)),
          ],
        ));
  }
}
