import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/screens/recaps/basic_recap.dart';
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
    final TrackedDay? trackedDay = trackedDays.firstWhereOrNull((td) {
      return td.habitId == habit.habitId && td.date == date;
    });
    if (trackingStatus.runtimeType == bool || trackedDay == null) {
      switch (habit.validationType) {
        case HabitType.recap:
          return ActionHandlers(
              HabitRecapScreen(habit, date, validated: Validated.yes), null);
        case HabitType.recapDay:
          return ActionHandlers(
              DailyRecapScreen(date, habit, validated: Validated.yes), null);
        case HabitType.simple || HabitType.unique:
          return ActionHandlers(
              BasicRecapScreen(
                habit,
                date,
                validated: Validated.yes,
              ),
              null);
      }
    } else {
      Future<void> onLongPress() async {
        await ref
            .read(trackedDayProvider.notifier)
            .deleteTrackedDay(trackedDay!);
      }

      switch (habit.validationType) {
        case HabitType.recap:
          return ActionHandlers(
              onLongPress,
              HabitRecapScreen(
                habit,
                date,
                validated: trackedDay.done != Validated.notYet
                    ? trackedDay.done
                    : Validated.yes,
                oldTrackedDay: trackedDay,
              ));
        case HabitType.recapDay:
          RecapDay recapDay = dailyRecaps.firstWhere((recapDay) {
            return recapDay.date == date;
          });
          return ActionHandlers(
            () async {
              await ref
                  .read(trackedDayProvider.notifier)
                  .deleteTrackedDay(trackedDay!);
              await ref
                  .read(recapDayProvider.notifier)
                  .deleteRecapDay(recapDay);
            },
            DailyRecapScreen(
              date,
              habit,
              oldDailyRecap: recapDay,
              oldTrackedDay: trackedDay,
              validated: trackedDay.done != Validated.notYet
                  ? trackedDay.done
                  : Validated.yes,
            ),
          );
        case HabitType.simple || HabitType.unique:
          return ActionHandlers(
              onLongPress,
              BasicRecapScreen(
                habit,
                date,
                oldTrackedDay: trackedDay,
                validated: trackedDay.done != Validated.notYet
                    ? trackedDay.done
                    : Validated.yes,
              ));
      }
    }
  }

  // Determines the color based on the tracking status
  (Color, IconData?, double?) getFillColor() {
    if (trackingStatus == false) {
      return (colorScheme.surface, null, null);
    } else if (trackingStatus == true) {
      return (const Color.fromARGB(255, 52, 52, 52), null, null);
    } else {
      final TrackedDay trackedDay = trackedDays.firstWhere((td) {
        return td.habitId == habit.habitId && td.date == date;
      });
      return (
        trackedDay.getStatusAppearance(colorScheme).backgroundColor,
        trackedDay.done == Validated.no ? Icons.close : null,
        trackedDay.totalRating()
      );
    }
  }

  // Initializer function that setups up the fill color and action
  List<dynamic> initController(WidgetRef ref) {
    final (Color, IconData?, double?) fillColor = getFillColor();
    final ActionHandlers actions = getAction(ref);
    return [fillColor, actions];
  }
}

class ActionHandlers {
  final dynamic onTap;
  final dynamic onLongPress;

  ActionHandlers(this.onLongPress, this.onTap);
}
