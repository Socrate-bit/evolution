import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class UserData {
  UserData({
    String? userId,
    required this.inscriptionDate,
    required this.name,
    required this.profilPicture,
    this.synced = false,
  }) {
    this.userId = userId ?? idGenerator.v4();
  }

  String? userId;
  DateTime inscriptionDate;
  String name;
  String profilPicture;
  bool synced;

  // Copy method to return a new instance of UserData with the same properties
  UserData copy() {
    return UserData(
      userId: userId,
      inscriptionDate: inscriptionDate,
      name: name,
      profilPicture: profilPicture,
      synced: synced,
    );
  }
}
