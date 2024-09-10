import 'package:flutter/material.dart';
import 'package:tracker_v1/models/utilities/appearance.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum Validated { notYet, yes, no }

class TrackedDay {
  TrackedDay({
    id,
    required this.habitId,
    required this.date,
    required this.done,
    this.notation,
    this.recap,
    this.improvements,
    this.additionalMetrics,
    this.synced = false,
  }) : id = id ?? idGenerator.v4();

  String id;
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
    return (notation!.showUp! * 2 / 5) +
        (notation!.investment * 2 / 5) +
        (notation!.method * 2 / 5) +
        (notation!.result * 2 / 5) +
        (notation!.goal == 0 ? 0 : notation!.goal * 2) +
        (notation!.extra);
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

          if (rating < 2.5) {
            statusColor = Colors.redAccent.withOpacity(0.6);
          } else if (rating < 5) {
            statusColor = colorScheme.primary;
          } else if (rating < 7.5) {
            statusColor = colorScheme.tertiary;
          } else if (rating < 10) {
            statusColor = colorScheme.secondary;
          } else if (rating >= 10) {
            statusColor = Colors.deepPurple;
          }
          return StatusAppearance(
            backgroundColor: statusColor!,
            lineThroughCond: true,
            elementsColor: Colors.white.withOpacity(0.45),
            icon: Icon(Icons.check,
                size: 30, color: Colors.white.withOpacity(0.45)),
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
    required this.showUp,
    required this.investment,
    required this.method,
    required this.result,
    required this.goal,
    this.extra = 0,
  });

  double? showUp;
  double investment;
  double method;
  double result;
  double goal;
  double extra;
}
