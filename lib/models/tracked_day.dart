import 'package:flutter/material.dart';
import 'package:tracker_v1/models/appearance.dart';
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
  }) : id = id ?? idGenerator.v4();

  String id;
  String habitId;
  DateTime date;
  Validated done;
  Rating? notation;
  String? recap;
  String? improvements;
  Map<String, dynamic>? additionalMetrics;

  double? totalRating() {
    if (notation == null) return null;
    return (notation!.showUp! * 1 / 2) +
        (notation!.investment * 1 / 2) +
        (notation!.method * 1 / 2) +
        (notation!.result * 1 / 2) +
        (notation!.extra);
  }

  StatusAppearance getStatusAppearance(context) {
    switch (done) {
      case Validated.notYet:
        return StatusAppearance(
            backgroundColor: const Color.fromARGB(255, 51, 51, 51),
            elementsColor: Colors.white,
            lineThroughCond: false);

      case Validated.yes:
        if (totalRating() == null) {
          return StatusAppearance(
            backgroundColor:
                Theme.of(context).colorScheme.secondary,
            elementsColor: Colors.white.withOpacity(0.45),
            lineThroughCond: true,
            icon: Icon(Icons.check,
                size: 30, weight: 200, color: Colors.white.withOpacity(0.45)),
          );
        } else {
          Color? statusColor;
          if (totalRating()! < 2.5) {
            statusColor = Colors.redAccent.withOpacity(0.6);
          } else if (totalRating()! < 5) {
            statusColor =
                Theme.of(context).colorScheme.primary;
          } else if (totalRating()! < 7.5) {
            statusColor =
                Theme.of(context).colorScheme.tertiary;
          } else if (totalRating()! >= 7.5) {
            statusColor =
                Theme.of(context).colorScheme.secondary;
          }
          return StatusAppearance(
            backgroundColor: statusColor!,
            lineThroughCond: true,
            elementsColor: Colors.white.withOpacity(0.45),
            icon: Icon(Icons.check,
                size: 30, color: Colors.white.withOpacity(0.45)),
          );
        }

      // case Validated.no:
      //   return StatusAppearance(
      //       backgroundColor: Colors.black,
      //       elementsColor: Colors.redAccent.withOpacity(0.5),
      //       lineThroughCond: true,
      //       icon: Icon(
      //         Icons.close,
      //         size: 30,
      //         color: Colors.redAccent.withOpacity(0.5),
      //       ));

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
    this.extra = 0,
  });

  double? showUp;
  double investment;
  double method;
  double result;
  double extra;
}
