import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/recaps/daily_recap.dart';
import 'package:tracker_v1/screens/recaps/habit_recap.dart';

class ContainerController {
  final Habit habit;
  final DateTime date;
  final dynamic trackingStatus;
  final List<TrackedDay> trackedDays;
  final ColorScheme colorScheme;
  final List<RecapDay> dailyRecaps;

  ContainerController({
    required this.habit,
    required this.date,
    required this.trackingStatus,
    required this.trackedDays,
    required this.dailyRecaps,
    required this.colorScheme,
  });

  // Returns the appropriate action based on the habit's validation type
  ActionHandlers getAction(WidgetRef ref) {
    if (trackingStatus == false) {
      return ActionHandlers(null, null);
    } else if (trackingStatus == true) {
      switch (habit.validationType) {
        case ValidationType.evaluation:
          return ActionHandlers(HabitRecapScreen(habit, date), null);
        case ValidationType.recapDay:
          return ActionHandlers(DailyRecapScreen(date, habit.habitId), null);
        case ValidationType.binary:
          final TrackedDay newTrackedDay = TrackedDay(
              userId: FirebaseAuth.instance.currentUser!.uid,
              habitId: habit.habitId,
              date: date,
              done: Validated.yes);
          return ActionHandlers(() async {
            await ref
                .read(trackedDayProvider.notifier)
                .updateTrackedDay(newTrackedDay);
          }, null);
      }
    } else {
      final TrackedDay trackedDay = trackedDays.firstWhere((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      Future<void> onLongPress() async {
        await ref
            .read(trackedDayProvider.notifier)
            .deleteTrackedDay(trackedDay);
      }

      switch (habit.validationType) {
        case ValidationType.evaluation:
          return ActionHandlers(
              onLongPress,
              HabitRecapScreen(
                habit,
                date,
                oldTrackedDay: trackedDay,
              ));
        case ValidationType.recapDay:
          RecapDay recapDay = dailyRecaps.firstWhere((recapDay) {
            return recapDay.date == date;
          });
          return ActionHandlers(
            () async {
              await ref
                  .read(trackedDayProvider.notifier)
                  .deleteTrackedDay(trackedDay);
              await ref
                  .read(recapDayProvider.notifier)
                  .deleteRecapDay(recapDay);
            },
            DailyRecapScreen(date, habit.habitId, oldDailyRecap: recapDay),
          );
        case ValidationType.binary:
          return ActionHandlers(onLongPress, null);
      }
    }
  }

  // Determines the color based on the tracking status
  Color getFillColor() {
    if (trackingStatus == false) {
      return colorScheme.surfaceBright;
    } else if (trackingStatus == true) {
      return const Color.fromARGB(255, 52, 52, 52);
    } else {
      final TrackedDay trackedDay = trackedDays.firstWhere((td) {
        return td.habitId == habit.habitId && td.date == date ;
      });
      return trackedDay
          .getStatusAppearance(colorScheme)
          .backgroundColor; // Assuming this returns a Color
    }
  }

  // Initializer function that setups up the fill color and action
  List<dynamic> initController(WidgetRef ref) {
    final Color fillColor = getFillColor();
    final ActionHandlers actions = getAction(ref);
    return [fillColor, actions];
  }
}

class ActionHandlers {
  final dynamic onTap;
  final dynamic onLongPress;

  ActionHandlers(this.onLongPress, this.onTap);
}
