import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/user.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'dart:io';

class AuthNotifier extends StateNotifier<UserData?> {
  AuthNotifier() : super(null);

  Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      '$dbPath/user_data',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE user_data(id TEXT PRIMARY KEY, inscriptionDate TEXT, name TEXT, profilPicture TEXT)');
      },
    );

    return db;
  }

  Future<void> addUserData(UserData userdata) async {
    state = userdata;
    File? copiedImage = null;

    final documentPath = await syspath.getApplicationDocumentsDirectory();

    final filename = path.basename(userdata.profilPicture!.path);
    copiedImage = await userdata.profilPicture!.copy('${documentPath.path}/$filename'); 
    final db = await getDatabase();

    await db.insert('user_data', {
      'id': userdata.userId,
      'inscriptionDate': userdata.inscriptionDate.toIso8601String(),
      'name': userdata.name,
      'profilPicture': copiedImage?.path
    });
  }

  Future<void> loadData() async {
    final db = await getDatabase();
    final data = await db.query('user_data');

    if (data.isEmpty) {
      return;
    }

    final userData = data.map((row) {
      return UserData(
        userId: row['id'] as String,
        inscriptionDate: DateTime.parse(row['inscriptionDate'] as String),
        name: row['name'] as String,
        profilPicture: File(row['profilPicture'] as String),
      );
    }).toList()[0];
    state = userData;
  }
}

final userDataProvider = StateNotifierProvider<AuthNotifier, UserData?>(
  (ref) {
    return AuthNotifier();
  },
);
