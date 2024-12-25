import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';

String getDisplayedScore(double? score, {bool elloge = false}) {
  String displayedScore = '-';

  if (score == null || score.isNaN) {
    return displayedScore;
  }

  if (score == score.toInt()) {
    displayedScore = score.toInt().toString();
  } else {
    displayedScore = score
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  if (elloge) {
    displayedScore += '/10';
  }
  if (score >= 10 && elloge) {
    displayedScore += ' 🥇';
  } else if (score >= 8 && elloge) {
    displayedScore += ' 🎉';
  }

  return displayedScore;
}

Color getScoreCardColor(WidgetRef ref, bool isFull, TimeOfDay? time,
    DateTime selectedDay, double? score) {
  // Compute the last habit time
  DateTime selectedDayNight = DateTime(
      today.year, today.month, today.day, time?.hour ?? 0, time?.minute ?? 0);

  bool habitListIsEmpty =
      ref.watch(scheduleCacheProvider(selectedDay)).isEmpty;
  bool todayAndNotEnded = DateTime.now().isBefore(selectedDayNight) &&
      selectedDay == today &&
      !isFull;

  if (habitListIsEmpty ||
      selectedDay.isAfter(today) ||
      todayAndNotEnded ||
      score == null) {
    return const Color.fromARGB(255, 51, 51, 51);
  } else {
    return RatingDisplayUtility.ratingToColor(score / 2).withOpacity(0.5);
  }
}

class ScoreCard extends ConsumerWidget {
  ScoreCard(this._selectedDay, this._score,
      {super.key, this.weekly = false, this.full = false, this.time});

  final DateTime _selectedDay;
  final DateTime _today = DateTime.now();
  final double? _score;
  final bool full;
  final bool weekly;
  final TimeOfDay? time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Center(
        child: Container(
          height: 32,
          width: 88,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: getScoreCardColor(ref, full, time, _selectedDay, _score)),
          alignment: Alignment.center,
          child: Text(
            !_selectedDay.isAfter(_today)
                ? getDisplayedScore(_score, elloge: true)
                : '-',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
