import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class UserData {
  UserData({
    String? userId,
    required this.inscriptionDate,
    required this.name,
    required this.profilPicture,
    this.synced = false,
    this.notificationActivated = true,
    this.priorityDisplay = false,
  }) {
    this.userId = userId ?? idGenerator.v4();
  }

  String? userId;
  DateTime inscriptionDate;
  String name;
  String profilPicture;
  bool synced;
  bool notificationActivated;
  bool priorityDisplay;

  // Copy method to return a new instance of UserData with the same properties
  UserData copy() {
    return UserData(
      userId: userId,
      inscriptionDate: inscriptionDate,
      name: name,
      profilPicture: profilPicture,
      synced: synced,
      notificationActivated: notificationActivated,
      priorityDisplay: priorityDisplay,
    );
  }

  // fromJson method to convert a JSON map into a UserData instance
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] as String?,
      inscriptionDate: DateTime.parse(json['inscriptionDate'] as String),
      name: json['name'] as String,
      profilPicture: json['profilPicture'] as String,
      synced: json['synced'] as bool? ?? false, // Handle possible null for synced
      notificationActivated: json['notificationActivated'] as bool? ?? true, // Handle possible null for notificationActivated
      priorityDisplay: json['priorityDisplayActivated'] as bool? ?? false, // Handle possible null for priorityDisplay
    );
  }

  // toJson method to convert a UserData instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'inscriptionDate': inscriptionDate.toIso8601String(),
      'name': name,
      'profilPicture': profilPicture,
      'synced': synced,
      'notificationActivated': notificationActivated,
      'priorityDisplay': priorityDisplay,
    };
  }
}
