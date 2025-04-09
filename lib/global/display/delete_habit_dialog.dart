import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';

void showDeleteHabitDialog(
    BuildContext context, WidgetRef ref, Schedule oldSchedule,
    {bool drag = false, bool isHabitListPage = false, TimeOfDay? newTime}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext ctx) => CupertinoAlertDialog(
      title: Text(
        'This is a repeating task',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
            child: Text('Delete for this day only'),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _modifyTodaySchedule(oldSchedule, context, ref, isDragging: drag);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
        CupertinoDialogAction(
          child: Text('Delete all future tasks'),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _modifyFutureSchedule(oldSchedule, context, ref);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('Delete all'),
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
                        _modifyAllSchedule(oldSchedule, context, ref, drag);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
             
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text('No'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
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
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

void _modifyTodaySchedule(
    Schedule oldSchedule, BuildContext context, WidgetRef ref,
    {bool isDragging = false}) {
  Schedule newSchedule =
      oldSchedule.copyWith(active: false, endDate: oldSchedule.startDate);
  newSchedule.resetScheduleId();
  ref.read(scheduledProvider.notifier).modifyTodayOnly(newSchedule);
}

void _modifyFutureSchedule(
  Schedule oldSchedule,
  BuildContext context,
  WidgetRef ref,
) {
  Schedule newSchedule = oldSchedule.copyWith(active: false, endDate: null);
  newSchedule.resetScheduleId();
  ref.read(scheduledProvider.notifier).modifyFuture(newSchedule);
}

void _modifyAllSchedule(
  Schedule oldSchedule,
  BuildContext context,
  WidgetRef ref,
  bool drag,
) {
  ref.read(scheduledProvider.notifier).deleteHabitSchedules(oldSchedule.habitId!);
}
