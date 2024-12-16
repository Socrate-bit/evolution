import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';

void showModifyHabitDialog(
    BuildContext context, WidgetRef ref, Schedule newSchedule) {
  showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) => CupertinoAlertDialog(
            title: Text(
              'This is a repeating task',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Update for this day only'),
                onPressed: () {
                  newSchedule.resetScheduleId();
                  newSchedule.endDate = newSchedule.startDate;
                  ref
                      .read(scheduledProvider.notifier)
                      .modifyTodayOnly(newSchedule);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Add your button 1 action here
                },
              ),
              CupertinoDialogAction(
                child: Text('Update for all future days'),
                onPressed: () {
                  newSchedule.resetScheduleId();
                  ref
                      .read(scheduledProvider.notifier)
                      .modifyFuture(newSchedule);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Add your button 2 action here
                },
              ),
              CupertinoDialogAction(
                child: Text('Update for all'),
                onPressed: () {
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
                              newSchedule.resetScheduleId();

                              ref
                                  .read(scheduledProvider.notifier)
                                  .modifyAll(newSchedule);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              // Add your confirmation action here
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  // Add your button 3 action here
                },
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
}
