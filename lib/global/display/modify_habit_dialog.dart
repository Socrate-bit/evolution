import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';

void showModifyHabitDialog(
    BuildContext context, WidgetRef ref, Schedule newSchedule,
    {bool drag = false, bool isHabitListPage = false, TimeOfDay? newTime}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext ctx) => CupertinoAlertDialog(
      content: newSchedule.isMixedhour() && drag
          ? Text('! Mixed times !',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold))
          : null,
      title: Text(
        'This is a repeating task',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
            child: Text(!isHabitListPage &&
                    !newSchedule.startDate!.isAtSameMomentAs(today)
                ? 'Update for this date only'
                : 'Update for today only'),
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (drag) {
                _modifyTodayTimeOfDay(
                    isHabitListPage, newTime, newSchedule, context, ref);
              } else {
                _modifyTodaySchedule(newSchedule, context, ref,
                    isDragging: drag);
              }
            }),
        CupertinoDialogAction(
          child: Text('Update for all future days'),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (drag) {
              _modifyFutureTimeOfDay(
                  isHabitListPage, newTime, newSchedule, context, ref);
            } else {
              _modifyFutureSchedule(newSchedule, context, ref);
            }
          },
        ),
        CupertinoDialogAction(
          child: Text('Update for all'),
          onPressed: () {
            HapticFeedback.heavyImpact();
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text(
                    'It will affect past data, are you sure?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('Yes'),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (drag) {
                          _modifyAllTimeOfDay(isHabitListPage, newTime,
                              newSchedule, context, ref);
                        } else {
                          _modifyAllSchedule(newSchedule, context, ref, drag);
                        }
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text('No'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        CupertinoDialogAction(
          child: Text('Cancel'),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

void popUntilDailyScreen(context) {
  Navigator.of(context).popUntil((route) {
    return route.isFirst;
  });
}

void _modifyTodaySchedule(
    Schedule newSchedule, BuildContext context, WidgetRef ref,
    {bool isDragging = false}) {
  newSchedule.resetScheduleId();
  newSchedule.endDate = newSchedule.startDate;
  ref.read(scheduledProvider.notifier).modifyTodayOnly(newSchedule);

  popUntilDailyScreen(context);
}

void _modifyFutureSchedule(
  Schedule newSchedule,
  BuildContext context,
  WidgetRef ref,
) {
  newSchedule.resetScheduleId();
  newSchedule.endDate = null;
  ref.read(scheduledProvider.notifier).modifyFuture(newSchedule);
  popUntilDailyScreen(context);
}

void _modifyAllSchedule(
  Schedule newSchedule,
  BuildContext context,
  WidgetRef ref,
  bool drag,
) {
  newSchedule.resetScheduleId();
  newSchedule.endDate = null;
  ref.read(scheduledProvider.notifier).modifyAll(newSchedule);
  popUntilDailyScreen(context);
}

void _modifyTodayTimeOfDay(
  bool isHabitListPage,
  TimeOfDay? newTime,
  Schedule newSchedule,
  BuildContext context,
  WidgetRef ref,
) {
  newSchedule.resetScheduleId();
  newSchedule.endDate = newSchedule.startDate;
  newSchedule = FrequencyNotifier.setTimesOfDayStatic(newTime, newSchedule);
  ref.read(scheduledProvider.notifier).modifyTodayOnly(newSchedule);
  popUntilDailyScreen(context);
}

void _modifyFutureTimeOfDay(
  bool isHabitListPage,
  TimeOfDay? newTime,
  Schedule newSchedule,
  BuildContext context,
  WidgetRef ref,
) {
  newSchedule.resetScheduleId();
  ref.read(scheduledProvider.notifier).modifyFutureTimeOfDay(
      newTime, newSchedule,
      isHabitListPage: isHabitListPage);
  popUntilDailyScreen(context);
}

void _modifyAllTimeOfDay(
  bool isHabitListPage,
  TimeOfDay? newTime,
  Schedule newSchedule,
  BuildContext context,
  WidgetRef ref,
) {
  ref.read(scheduledProvider.notifier).modifyAllTimeOfDay(
      newTime, newSchedule.habitId!, newSchedule,
      isHabitListPage: isHabitListPage);
  popUntilDailyScreen(context);
}
