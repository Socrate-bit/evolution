import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/models/habit.dart';
import 'package:tracker_v1/models/daily_recap.dart';
import 'package:tracker_v1/screens/habit_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/screens/daily_recap.dart';
import 'package:collection/collection.dart';

class DayContainer extends ConsumerStatefulWidget {
  const DayContainer(this.habit, this.date, this.trackingStatus, {super.key});

  final Habit habit;
  final DateTime date;
  final dynamic trackingStatus;

  @override
  ConsumerState<DayContainer> createState() => _DayOfTheWeekState();
}

class _DayOfTheWeekState extends ConsumerState<DayContainer> {
  Color? fillColor;
  dynamic onTap = () {};
  TrackedDay? trackedDay;

  void _initContainer(context, trackedDays, List<RecapDay> recapList) {
    if (widget.trackingStatus == false) {
      fillColor = Theme.of(context).colorScheme.surfaceBright;
    } else if (widget.trackingStatus == true) {
      fillColor = const Color.fromARGB(255, 52, 52, 52);

      if (widget.habit.validationType == ValidationType.evaluation) {
        onTap = () {
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (ctx) => HabitRecapScreen(
              widget.habit.id,
              widget.date,
            ),
          );
        };
      } else if (widget.habit.validationType == ValidationType.recapDay) {
        onTap = () {
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (ctx) => DailyRecapScreen(
              widget.date,
              widget.habit.id,
              oldTrackedDay: recapList.firstWhereOrNull(
                (recap) {
                  return recap.date == widget.date;
                },
              ),
            ),
          );
        };
      } else {
        TrackedDay newTrackedDay = TrackedDay(
          habitId: widget.habit.id,
          date: widget.date,
          done: Validated.yes,
        );
        onTap = () {
          ref.read(trackedDayProvider.notifier).updateTrackedDay(newTrackedDay);
        };
      }
    } else {
      trackedDay = trackedDays[widget.trackingStatus];
      if (trackedDay == null) {
        fillColor = const Color.fromARGB(255, 52, 52, 52);
        return;
      }
      fillColor = trackedDay!.getStatusAppearance(context).backgroundColor;
      onTap = () {
        ref.read(trackedDayProvider.notifier).deleteTrackedDay(trackedDay!);
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackedDays = ref.watch(trackedDayProvider);

    List<RecapDay> recapList = ref.watch(recapDayProvider);

    _initContainer(context, trackedDays, recapList);

    return InkWell(
      onLongPress: onTap,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: fillColor, borderRadius: BorderRadius.circular(6)),
        child: trackedDay != null && trackedDay!.done == Validated.no
            ? Icon(
                Icons.close,
                color: Colors.redAccent.withOpacity(0.5),
              )
            : null,
      ),
    );
  }
}
