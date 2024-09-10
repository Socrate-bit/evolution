import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'dart:convert';

class TrackedDayNotifier extends StateNotifier<Map<String, TrackedDay>> {
  TrackedDayNotifier(this.ref) : super({});
  final Ref ref;

  Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      '$dbPath/tracked_day.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE TrackedDay (
            id TEXT PRIMARY KEY,             
            habitId TEXT NOT NULL,           
            date TEXT NOT NULL,              
            done INTEGER NOT NULL,           
            notation_showUp REAL,            
            notation_investment REAL,        
            notation_method REAL,            
            notation_result REAL, 
            notation_goal REAL,           
            notation_extra REAL,             
            recap TEXT,                     
            improvements TEXT,               
            additionalMetrics TEXT,
            synced INTEGER          
          )
        ''');
      },
    );
    return db;
  }

  Future<void> addTrackedDay(TrackedDay newTrackedDay) async {
    state = {...state, newTrackedDay.id: newTrackedDay};

    final db = await getDatabase();
    await db.insert(
      'TrackedDay',
      {
        'id': newTrackedDay.id,
        'habitId': newTrackedDay.habitId,
        'date': newTrackedDay.date.toIso8601String(),
        'done': newTrackedDay.done == Validated.yes ? 1 : 0,
        'notation_showUp': newTrackedDay.notation?.showUp,
        'notation_investment': newTrackedDay.notation?.investment,
        'notation_method': newTrackedDay.notation?.method,
        'notation_result': newTrackedDay.notation?.result,
        'notation_goal': newTrackedDay.notation?.goal,
        'notation_extra': newTrackedDay.notation?.extra,
        'recap': newTrackedDay.recap,
        'improvements': newTrackedDay.improvements,
        'additionalMetrics': newTrackedDay.additionalMetrics != null
            ? jsonEncode(newTrackedDay.additionalMetrics)
            : null,
        'synced': newTrackedDay.synced ? 1 : 0,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    ref.read(habitProvider.notifier).addTrackedDay(newTrackedDay);
  }

  Future<void> deleteTrackedDay(TrackedDay targetTrackedDay) async {
    state = Map.from(state)..remove(targetTrackedDay.id);

    final db = await getDatabase();
    await db.delete(
      'TrackedDay',
      where: 'id = ?',
      whereArgs: [targetTrackedDay.id],
    );

    ref.read(habitProvider.notifier).deleteTrackedDay(targetTrackedDay);
  }

  Future<void> updateTrackedDay(TrackedDay targetTrackedDay) async {
    deleteTrackedDay(targetTrackedDay);
    addTrackedDay(targetTrackedDay);
  }

  Future<void> deleteHabitTrackedDays(Habit habit) async {
    for (String trackedDay in habit.trackedDays.values) {
      deleteTrackedDay(state[trackedDay]!);
    }
  }

  Future<void> loadData() async {
    final db = await getDatabase();
    final data = await db.query('TrackedDay');

    if (data.isEmpty) return;

    final Map<String, TrackedDay> loadedData = {};
    for (final row in data) {
      final trackedDay = TrackedDay(
        id: row['id'] as String,
        habitId: row['habitId'] as String,
        date: DateTime.parse(row['date'] as String),
        done: (row['done'] as int) == 1 ? Validated.yes : Validated.no,
        notation: row['notation_showUp'] == null
            ? null
            : Rating(
                showUp: row['notation_showUp'] as double,
                investment: row['notation_investment'] as double,
                method: row['notation_method'] as double,
                result: row['notation_result'] as double,
                goal: row['notation_goal'] as double,
                extra: row['notation_extra'] as double,
              ),
        recap: row['recap'] as String?,
        improvements: row['improvements'] as String?,
        additionalMetrics: row['additionalMetrics'] != null
            ? jsonDecode(row['additionalMetrics'] as String)
            : null,
        synced: row['synced'] == 1,
      );
      loadedData[trackedDay.id] = trackedDay;
    }

    state = loadedData;
  }
}

final trackedDayProvider =
    StateNotifierProvider<TrackedDayNotifier, Map<String, TrackedDay>>(
  (ref) {
    return TrackedDayNotifier(ref);
  },
);
