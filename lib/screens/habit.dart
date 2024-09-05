import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/habit.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen(this.habit, {super.key});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(habit.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
            Text(habit.description!.isEmpty ? 'No description': habit.description!, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),),             const SizedBox(
              height: 32,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {ref.read(trackedDayProvider.notifier).deleteHabitTrackedDays(habit);},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Reset data',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {ref.read(habitProvider.notifier).deleteHabit(habit);},
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Theme.of(context).colorScheme.primary),
                child: Text('Delete habit',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent.withOpacity(0.5))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
