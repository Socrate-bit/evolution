import 'package:flutter/material.dart';

class ReorderedDay {
  final String userId;
  final DateTime date;
  final Map<String, (TimeOfDay?, int)> habitOrder;

  ReorderedDay({
    required this.userId,
    required this.date,
    required this.habitOrder,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'habitOrder': habitOrder.map((key, value) {
        return MapEntry(
          key,
          {
            'timeOfDay': value.$1 != null
                ? '${value.$1!.hour}:${value.$1!.minute}'
                : null,
            'order': value.$2,
          },
        );
      }),
    };
  }

  // Create from JSON
  factory ReorderedDay.fromJson(Map<String, dynamic> json) {
    return ReorderedDay(
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      habitOrder: (json['habitOrder'] as Map<String, dynamic>).map((key, value) {
        return MapEntry(
          key,
          (
            value['timeOfDay'] != null
                ? stringToTimeOfDay(value['timeOfDay'])
                : null,
            value['order'] as int,
          ),
        );
      }),
    );
  }
}

// Helper function to convert time string back to TimeOfDay
TimeOfDay stringToTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  return TimeOfDay(hour: hour, minute: minute);
}
