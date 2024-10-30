import 'package:flutter/material.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';
import 'package:tracker_v1/widgets/daily/score.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum Validated { notYet, yes, no }

class TrackedDay {
  TrackedDay({
    trackedDayId,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.done,
    this.notation,
    this.recap,
    this.improvements,
    this.additionalMetrics,
    this.synced = false,
  }) : trackedDayId = trackedDayId ?? idGenerator.v4();

  String trackedDayId;
  String userId;
  String habitId;
  DateTime date;
  Validated done;
  Rating? notation;
  String? recap;
  String? improvements;
  Map<String, dynamic>? additionalMetrics;
  bool synced;

  double? totalRating() {
    if (notation == null) return null;
    return (notation!.quantity! * 2 / 5) +
        (notation!.quality * 2 / 5) +
        (notation!.result * 2 / 5) +
        (notation!.weeklyFocus == 0 ? 0 : notation!.weeklyFocus * 2) +
        (notation!.dailyGoal == 0 ? 0 : notation!.dailyGoal * 2);
  }

  StatusAppearance getStatusAppearance(colorScheme) {
    double? rating = totalRating();

    switch (done) {
      case Validated.notYet:
        return StatusAppearance(
            backgroundColor: const Color.fromARGB(255, 51, 51, 51),
            elementsColor: Colors.white,
            lineThroughCond: false);

      case Validated.yes:
        if (rating == null) {
          return StatusAppearance(
            backgroundColor: colorScheme.secondary,
            elementsColor: Colors.white.withOpacity(0.45),
            lineThroughCond: true,
            icon: Icon(Icons.check,
                size: 30, weight: 200, color: Colors.white.withOpacity(0.45)),
          );
        } else {
          Color? statusColor;

          statusColor = RatingUtility.getRatingColor(rating / 2);

          return StatusAppearance(
            backgroundColor: statusColor,
            lineThroughCond: true,
            elementsColor: Colors.white.withOpacity(0.45),
            icon: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 30), // Set minimum width
              child: Text(
                displayedScore(totalRating()),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          );
        }

      default:
        return StatusAppearance(
            backgroundColor: const Color.fromARGB(255, 51, 51, 51),
            elementsColor: Colors.white);
    }
  }
}

class Rating {
  Rating({
    required this.quantity,
    required this.quality,
    required this.result,
    required this.weeklyFocus,
    required this.dailyGoal,
  });

  double? quantity;
  double quality;
  double result;
  double weeklyFocus;
  double dailyGoal;
}
