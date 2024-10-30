import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/weekly/day_container.dart';

class EmotionTable extends ConsumerWidget {
  const EmotionTable({required this.offsetWeekDays, super.key});

  static const List range = [0, 1, 2, 3, 4, 5, 6];
  final List<DateTime> offsetWeekDays;

  static const List<String> emotions = [
    'Well-being',
    'Sleep',
    'Energy',
    'Motivation',
    'Stress',
    'Focus & Clarity',
    'Mental performance',
    'Frustrations',
    'Satisfaction',
    'Self-Esteem',
    'Looking forward tomorrow',
  ];

  static const List<String> dailyRecapKeys = [
    'wellBeing',
    'sleepQuality',
    'energy',
    'driveMotivation',
    'stress',
    'focusMentalClarity',
    'intelligenceMentalPower',
    'frustrations',
    'satisfaction',
    'selfEsteemProudness',
    'lookingForwardToWakeUpTomorrow',
  ];

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
          width: 200,
        )),
        ...range.map(
          (item) => Column(
            children: [
              Text(
                DaysUtility.weekDayToSign[WeekDay.values[item]]!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<bool> _gethabitTrackingStatus(Habit habitRecap) {
    List<bool> isTrackedFilter = range.map((index) {
      return HabitNotifier.getHabitTrackingStatus(
          habitRecap, offsetWeekDays[index]);
    }).toList();

    return isTrackedFilter;
  }

  List<Color> _getStatusColor(String emotion, List<RecapDay> recapDays,
      List<bool> recapTrackingStatus) {
    List<Color> statusColors = offsetWeekDays.asMap().entries.map((e) {
      double? emotionMark = recapDays
          .firstWhereOrNull((recap) => e.value == recap.date)
          ?.getProperty(emotion);

      return recapTrackingStatus[e.key]
          ? emotionMark == null
              ? const Color.fromARGB(255, 52, 52, 52)
              : RatingUtility.getRatingColor(emotionMark)
          : const Color.fromARGB(255, 37, 37, 38);
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
          return Center(
            child: DayContainer(
                fillColor: (emotionStatus[index], null),
                onLongPress: null,
                onTap: null),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<RecapDay> recapDays = [];
    List<bool> recapTrackingStatus = [];
    Habit? habitRecap = ref
        .watch(habitProvider)
        .firstWhereOrNull((h) => h.validationType == HabitType.recapDay);

    if (habitRecap != null) {
      recapDays = ref
          .watch(recapDayProvider)
          .where((r) =>
              r.userId == FirebaseAuth.instance.currentUser!.uid &&
              _isInTheWeek(r.date))
          .toList();
      recapTrackingStatus = _gethabitTrackingStatus(habitRecap);
    }

    bool trackedThisWeek = habitRecap != null &&
        !recapTrackingStatus.every((statut) => !statut);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                ...emotions.asMap().entries.map((entry) => _buildHabitRow(
                    emotions[entry.key],
                    context,
                    _getStatusColor(dailyRecapKeys[entry.key], recapDays,
                        recapTrackingStatus))),
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
