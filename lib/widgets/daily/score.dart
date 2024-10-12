import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/utilities/rating_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';

class ScoreCard extends ConsumerWidget {
  ScoreCard(this._selectedDay, this._score, {super.key, this.weekly=false});

  final DateTime _selectedDay;
  final DateTime _today = DateTime.now();
  final _score;
  final bool weekly;

  String _displayedScore(double? score) {
    String displayedScore = '-';

    if (score == null || score.isNaN) {
      return displayedScore;
    }

    if (score == score.toInt()) {
      displayedScore = score.toInt().toString();
    } else {
      displayedScore = score.toStringAsFixed(2);
    }

    if (score > 10) {
      displayedScore += ' 🥇';
    } else if (score >= 7.5) {
      displayedScore += ' 🎉';
    }

    return displayedScore;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Center(
        child: Container(
          height: 32,
          width: 88,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _selectedDay.isAfter(_today) || (!weekly &&
                      ref
                          .watch(habitProvider.notifier)
                          .getTodayHabit(_selectedDay)
                          .isEmpty) 
                  ? const Color.fromARGB(255, 51, 51, 51)
                  : RatingUtility.getRatingColor(_score[0] / 2)
                      .withOpacity(0.75)),
          alignment: Alignment.center,
          child: Text(
            _displayedScore(_score[0]),
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
