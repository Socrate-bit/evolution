import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';

String displayedScore(double? score, {bool elloge = false}) {
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
    DateTime selectedDayNight = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, time?.hour ?? 20, time?.minute ?? 0);

    return Expanded(
      child: Center(
        child: Container(
          height: 32,
          width: 88,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _selectedDay.isAfter(_today) || (!full && now.isBefore(selectedDayNight)) ||
                      (!weekly &&
                          ref
                              .watch(habitProvider.notifier)
                              .getTodayHabit(_selectedDay)
                              .isEmpty)
                  ? const Color.fromARGB(255, 51, 51, 51)
                  : _score == null
                      ? const Color.fromARGB(255, 51, 51, 51)
                      : RatingUtility.getRatingColor(_score / 2)
                          .withOpacity(0.5)),
          alignment: Alignment.center,
          child: Text(
            !_selectedDay.isAfter(_today)
                ? displayedScore(_score, elloge: true)
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

