class UserStats {
  UserStats({
    required this.userId,
    this.totGems = 0, // Default total gems is 0
    this.availableGems = 0, // Default available gems is 0
    this.averageWeek = 0.0,
    this.average3Months = 0.0,
  });

  String userId;
  int totGems; // Total gems earned by the user
  int availableGems; // Gems that are currently available to spend
  double averageWeek;
  double average3Months;

  // Convert UserStats to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totGems': totGems,
      'availableGems': availableGems,
      'averageWeek': averageWeek,
      'average3Months': average3Months,
    };
  }

  // Create UserStats from Firestore document snapshot
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      totGems: json['totGems'],
      availableGems: json['availableGems'],
      averageWeek: (json['averageWeek'] as num).toDouble(),
      average3Months: (json['average3Months'] as num).toDouble(),
    );
  }
}
