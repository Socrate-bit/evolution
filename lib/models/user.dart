import 'dart:io';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class UserData {
  UserData({
    String? userId,
    required this.inscriptionDate,
    required this.name,
    // required this.profilPicture,
  }) {
    this.userId = userId ?? idGenerator.v4();
  }

  String? userId;
  DateTime inscriptionDate;
  String name;
  // File profilPicture;
}