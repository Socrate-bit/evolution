import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/daily_recap.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'dart:convert';

class RecapDayNotifier extends StateNotifier<List<RecapDay>> {
  RecapDayNotifier(this.ref) : super([]);
  final Ref ref;

  // Get the database instance
  Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(
      '$dbPath/daily_recap.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE RecapDay (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            sleepQuality REAL,
            wellBeing REAL,
            energy REAL,
            driveMotivation REAL,
            stress REAL,
            focusMentalClarity REAL,
            intelligenceMentalPower REAL,
            frustrations REAL,
            satisfaction REAL,
            selfEsteemProudness REAL,
            lookingForwardToWakeUpTomorrow REAL,
            recap TEXT,
            improvements TEXT,
            gratefulness TEXT,
            proudness TEXT,
            additionalMetrics TEXT
          )
        ''');
      },
    );
  }

  // Add a new RecapDay to the state and database
  Future<void> addRecapDay(RecapDay newRecapDay) async {
    state = [...state, newRecapDay];

    final db = await getDatabase();
    await db.insert(
      'RecapDay',
      {
        'id': newRecapDay.id,
        'date': newRecapDay.date.toIso8601String(),
        'sleepQuality': newRecapDay.sleepQuality,
        'wellBeing': newRecapDay.wellBeing,
        'energy': newRecapDay.energy,
        'driveMotivation': newRecapDay.driveMotivation,
        'stress': newRecapDay.stress,
        'focusMentalClarity': newRecapDay.focusMentalClarity,
        'intelligenceMentalPower': newRecapDay.intelligenceMentalPower,
        'frustrations': newRecapDay.frustrations,
        'satisfaction': newRecapDay.satisfaction,
        'selfEsteemProudness': newRecapDay.selfEsteemProudness,
        'lookingForwardToWakeUpTomorrow': newRecapDay.lookingForwardToWakeUpTomorrow,
        'recap': newRecapDay.recap,
        'improvements': newRecapDay.improvements,
        'gratefulness': newRecapDay.gratefulness,
        'proudness': newRecapDay.proudness,
        'additionalMetrics': newRecapDay.additionalMetrics != null
            ? jsonEncode(newRecapDay.additionalMetrics)
            : null,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  // Delete a RecapDay from state and database
  Future<void> deleteRecapDay(RecapDay targetRecapDay) async {
    state = state.where((day) => day.id != targetRecapDay.id).toList();

    final db = await getDatabase();
    await db.delete(
      'RecapDay',
      where: 'id = ?',
      whereArgs: [targetRecapDay.id],
    );
  }

  // Update a RecapDay by deleting and re-adding it
  Future<void> updateRecapDay(RecapDay updatedRecapDay) async {
    await deleteRecapDay(updatedRecapDay);
    await addRecapDay(updatedRecapDay);
  }

  // Load data from the database into the state
  Future<void> loadRecapDays() async {
    final db = await getDatabase();
    final data = await db.query('RecapDay');

    if (data.isEmpty) return;

    final List<RecapDay> loadedData = data.map((row) {
      return RecapDay(
        id: row['id'] as String,
        date: DateTime.parse(row['date'] as String),
        sleepQuality: row['sleepQuality'] as double? ?? 0,
        wellBeing: row['wellBeing'] as double? ?? 0,
        energy: row['energy'] as double? ?? 0,
        driveMotivation: row['driveMotivation'] as double? ?? 0,
        stress: row['stress'] as double? ?? 0,
        focusMentalClarity: row['focusMentalClarity'] as double? ?? 0,
        intelligenceMentalPower: row['intelligenceMentalPower'] as double? ?? 0,
        frustrations: row['frustrations'] as double? ?? 0,
        satisfaction: row['satisfaction'] as double? ?? 0,
        selfEsteemProudness: row['selfEsteemProudness'] as double? ?? 0,
        lookingForwardToWakeUpTomorrow: row['lookingForwardToWakeUpTomorrow'] as double? ?? 0,
        recap: row['recap'] as String?,
        improvements: row['improvements'] as String?,
        additionalMetrics: row['additionalMetrics'] != null
            ? jsonDecode(row['additionalMetrics'] as String)
            : null,
      );
    }).toList();

    state = loadedData;
  }
}

// Riverpod provider for RecapDayNotifier
final recapDayProvider =
    StateNotifierProvider<RecapDayNotifier, List<RecapDay>>((ref) {
  return RecapDayNotifier(ref);
});
