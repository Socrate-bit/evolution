import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';

class EmotionTable extends ConsumerWidget {
  const EmotionTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

  bool _isInTheWeek(DateTime date1, {DateTime? date2}) {
    final startBeforeEndOfWeek = date1.isBefore(offsetWeekDays.last) ||
        date1.isAtSameMomentAs(offsetWeekDays.last);
    final endAfterStartOfWeek = date2 == null ||
        date2.isAfter(offsetWeekDays.first) ||
        date2.isAtSameMomentAs(offsetWeekDays.first);

    return startBeforeEndOfWeek && endAfterStartOfWeek;
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        TableCell(
            child: Container(
          alignment: Alignment.center,
          width: 220,
        )),
        ...range.map(
          (item) => Column(
            children: [
              Text(
                DaysOfTheWeekUtility.weekDayToSign[WeekDay.values[item]]!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<bool> _gethabitTrackingStatus(Habit habitRecap, WidgetRef ref) {
    List<bool> isTrackedFilter = range.map((index) {
      return ref
          .read(scheduledProvider.notifier)
          .getHabitTrackingStatusWithSchedule(habitRecap.habitId, offsetWeekDays[index]).$1;
    }).toList();

    return isTrackedFilter;
  }

  List<Color> _getStatusColor(String emotion, List<DailyRecap> recapDays,
      List<bool> recapTrackingStatus, context) {
    List<Color> statusColors = offsetWeekDays.asMap().entries.map((e) {
      double? emotionMark = recapDays
          .firstWhereOrNull((recap) => e.value == recap.date)
          ?.getProperty(emotion);

      return recapTrackingStatus[e.key]
          ? emotionMark == null
              ? Theme.of(context).colorScheme.surface
              : RatingDisplayUtility.ratingToColor(emotionMark)
          : const Color.fromARGB(255, 62, 62, 62);
    }).toList();

    return statusColors;
  }

  TableRow _buildHabitRow(String emotion, context, List<Color> emotionStatus) {
    return TableRow(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(width: 8),
              // Icon(habit.icon),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  emotion,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ...range.map((index) {
          return TableCell(
              child: Container(
            color: emotionStatus[index],
            height: 30,
            width: double.infinity,
          ));
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DailyRecap> recapDays = [];
    List<bool> recapTrackingStatus = [];
    Habit? habitRecap = ref
        .watch(habitProvider)
        .firstWhereOrNull((h) => h.validationType == HabitType.recapDay);

    if (habitRecap != null) {
      recapDays = ref
          .watch(dailyRecapProvider)
          .where((r) =>
              r.userId == FirebaseAuth.instance.currentUser!.uid &&
              _isInTheWeek(r.date))
          .toList();
      recapTrackingStatus = _gethabitTrackingStatus(habitRecap, ref);
    }

    bool trackedThisWeek =
        habitRecap != null && !recapTrackingStatus.every((statut) => !statut);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        children: [
          Table(
            key: ObjectKey(offsetWeekDays.first),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {0: FixedColumnWidth(100)},
            border: TableBorder.all(
                color: const Color.fromARGB(255, 62, 62, 62),
                width: 2,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            children: [
              _buildTableHeader(),
              if (trackedThisWeek && habitRecap != null)
                ...Emotion.values.map((element) => _buildHabitRow(
                    emotionDescriptions[element]!,
                    context,
                    _getStatusColor(element.name, recapDays,
                        recapTrackingStatus, context))),
            ],
          ),
          if (!trackedThisWeek)
            Container(
              alignment: Alignment.center,
              height: 400,
              child: const Center(
                child: Text('You don\'t track your emotions yet !'),
              ),
            ),
        ],
      ),
    );
  }
}
