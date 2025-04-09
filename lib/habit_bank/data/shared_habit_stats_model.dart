import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class SharedHabitStats {
  SharedHabitStats({
    required this.numberOfUsers,
    required this.categoriesRating,
    required this.globalRating,
    required this.habitId,
    statId,
  }) : statId = statId ?? idGenerator.v4();

  int numberOfUsers;
  Map<String, double> categoriesRating;
  double globalRating;
  String habitId;
  String statId;

  factory SharedHabitStats.fromJson(Map<String, dynamic> json, {String? statId}) {
    return SharedHabitStats(
      numberOfUsers: json['numberOfUsers'] as int,
      categoriesRating: (json['categoriesRating'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          value as double,
        ),
      ),
      globalRating: json['globalRating'] as double,
      habitId: json['habitId'] as String,
      statId: json['statId'] ?? statId as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numberOfUsers': numberOfUsers,
      'categoriesRating': categoriesRating.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      ),
      'globalRating': globalRating,
      'habitId': habitId,
      'statId': statId,
    };
  }

  SharedHabitStats copy({
    int? numberOfUsers,
    Map<String, double>? categoriesRating,
    double? globalRating,
    String? habitId,
    String? statId,
  }) {
    return SharedHabitStats(
      numberOfUsers: numberOfUsers ?? this.numberOfUsers,
      categoriesRating: categoriesRating ?? this.categoriesRating,
      globalRating: globalRating ?? this.globalRating,
      habitId: habitId ?? this.habitId,
      statId: statId ?? this.statId,
    );
  }
}