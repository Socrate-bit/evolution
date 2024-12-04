class UserStats {
  UserStats({
    required this.userId,
    required this.dateSync,
    this.streaks = 0,
    this.scoreWeek = 0,
    this.scoreMonth = 0,
    this.scoreAllTime = 0,
    this.completion = 0.0,
    this.evaluation = 0.0, // Changed to double for numeric evaluation
    this.validated = 0, // Changed to int
    this.message = '',
  });

  String userId;
  DateTime dateSync;
  int streaks;
  double scoreWeek;
  double scoreMonth;
  double scoreAllTime;
  double completion;
  double evaluation;
  int validated;
  String message;

  // Convert UserStats to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dateSync': dateSync.toIso8601String(),
      'streaks': streaks,
      'scoreWeek': scoreWeek,
      'scoreMonth': scoreMonth,
      'scoreAllTime': scoreAllTime,
      'completion': completion,
      'evaluation': evaluation,
      'validated': validated,
      'message': message,
    };
  }

  // Create UserStats from Firestore document snapshot
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      dateSync: DateTime.parse(json['dateSync']),
      streaks: json['streaks'] as int? ?? 0,
      scoreWeek: json['scoreWeek'] as double? ?? 0,
      scoreMonth: json['scoreMonth'] as double? ?? 0,
      scoreAllTime: json['scoreAllTime'] as double? ?? 0,
      completion: (json['completion'] as num?)?.toDouble() ?? 0.0,
      evaluation:
          (json['evaluation'] as num?)?.toDouble() ?? 0.0, // Parsing as double
      validated: json['validated'] as int? ?? 0, // Parsing as int
      message: json['message'] as String? ?? '',
    );
  }

  UserStats copyWith({
    String? userId,
    int? streaks,
    DateTime? dateSync,
    double? scoreWeek,
    double? scoreMonth,
    double? scoreAllTime,
    double? completion,
    double? evaluation,
    int? validated,
    String? message,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      streaks: streaks ?? this.streaks,
      dateSync: dateSync ?? this.dateSync,
      scoreWeek: scoreWeek ?? this.scoreWeek,
      scoreMonth: scoreMonth ?? this.scoreMonth,
      scoreAllTime: scoreAllTime ?? this.scoreAllTime,
      completion: completion ?? this.completion,
      evaluation: evaluation ?? this.evaluation,
      validated: validated ?? this.validated,
      message: message ?? this.message,
    );
  }
}
