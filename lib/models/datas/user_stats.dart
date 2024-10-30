class UserStats {
  UserStats({
    required this.userId,
    required this.dateSync,
    this.streaks = 0, // Default total gems is 0
  });

  String userId;
  DateTime dateSync;
  int streaks; // Total gems earned by the user

  // Convert UserStats to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dateSync': dateSync.toIso8601String(),
      'streaks': streaks,
    };
  }

  // Create UserStats from Firestore document snapshot
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      dateSync: DateTime.parse(json['dateSync']),
      streaks: json['streaks'] as int,
    );
  }

  UserStats copyWith({
    String? userId,
    int? streaks,
    DateTime? dateSync
    
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      streaks: streaks ?? this.streaks,
      dateSync: dateSync ?? this.dateSync,
    );
  }
}
