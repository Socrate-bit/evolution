import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/habit.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'dart:convert';
import 'package:tracker_v1/models/utilities/days_utility.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]);

  Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      '$dbPath/habits.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Habits (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            icon TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            frequency INTEGER NOT NULL,
            weekdays TEXT,
            validationType TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT,
            additionalMetrics TEXT,
            trackedDays TEXT
          )
        ''');
      },
    );
    return db;
  }

  Future<void> addHabit(Habit newHabit) async {
    state = [...state, newHabit];

    final db = await getDatabase();
    await db.insert(
      'Habits',
      {
        'id': newHabit.id,
        'userId': newHabit.userId,
        'icon': newHabit.icon.codePoint.toString(),
        'name': newHabit.name,
        'description': newHabit.description,
        'frequency': newHabit.frequency,
        'weekdays': jsonEncode(
            newHabit.weekdays.map((day) => day.toString()).toList()),
        'validationType': newHabit.validationType.toString(),
        'startDate': newHabit.startDate.toIso8601String(),
        'endDate': newHabit.endDate?.toIso8601String(),
        'additionalMetrics': newHabit.additionalMetrics != null
            ? jsonEncode(newHabit.additionalMetrics)
            : null,
        'trackedDays': jsonEncode(newHabit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(Habit targetHabit) async {
    state = state.where((habit) => habit.id != targetHabit.id).toList();

    final db = await getDatabase();
    await db.delete(
      'Habits',
      where: 'id = ?',
      whereArgs: [targetHabit.id],
    );
  }

  Future<void> updateHabit(Habit targetHabit) async {
    state = [
      ...state.where((habit) => habit.id != targetHabit.id),
      targetHabit
    ];

    // Update in SQLite database
    final db = await getDatabase();
    await db.update(
      'Habits',
      {
        'userId': targetHabit.userId,
        'icon': targetHabit.icon.codePoint.toString(),
        'name': targetHabit.name,
        'description': targetHabit.description,
        'frequency': targetHabit.frequency,
        'weekdays': jsonEncode(
            targetHabit.weekdays.map((day) => day.toString()).toList()),
        'validationType': targetHabit.validationType.toString(),
        'startDate': targetHabit.startDate.toIso8601String(),
        'endDate': targetHabit.endDate?.toIso8601String(),
        'additionalMetrics': targetHabit.additionalMetrics != null
            ? jsonEncode(targetHabit.additionalMetrics)
            : null,
        'trackedDays': jsonEncode(targetHabit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
      },
      where: 'id = ?',
      whereArgs: [targetHabit.id],
    );
  }

  Future<void> addTrackedDay(TrackedDay trackedDay) async {
    state = state.map((habit) {
      if (habit.id == trackedDay.habitId) {
        Habit newHabit = habit.copy();
        DateTime date = DateTime(
          trackedDay.date.year,
          trackedDay.date.month,
          trackedDay.date.day,
        );
        newHabit.trackedDays[date] = trackedDay.id;
        return newHabit;
      }
      return habit;
    }).toList();

    final db = await getDatabase();
    Habit habit = state.firstWhere((habit) => habit.id == trackedDay.habitId);
    await db.update(
      'Habits',
      {
        'trackedDays': jsonEncode(habit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteTrackedDay(TrackedDay trackedDay) async {
    state = state.map((habit) {
      if (habit.id == trackedDay.habitId) {
        Habit newHabit = habit.copy();
        newHabit.trackedDays.remove(trackedDay.date);
        return newHabit;
      }
      return habit;
    }).toList();

    final db = await getDatabase();
    Habit habit = state.firstWhere((habit) => habit.id == trackedDay.habitId);
    await db.update(
      'Habits',
      {
        'trackedDays': jsonEncode(habit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteDatabase(String name) async {
    var databasesPath = await sql.getDatabasesPath();
    String path = '$databasesPath/$name';

    // Delete the database
    await sql.deleteDatabase(path);
    }

  Future<void> loadData() async {
    final db = await getDatabase();
    final data = await db.query('Habits');

    if (data.isEmpty) {
      return;
    }

    final List<Habit> loadedData = data.map((row) {
      return Habit(
        id: row['id'] as String,
        userId: row['userId'] as String,
        icon: IconData(int.parse(row['icon'] as String),
            fontFamily: 'MaterialIcons'),
        name: row['name'] as String,
        description: row['description'] as String?,
        frequency: row['frequency'] as int,
        weekdays: (jsonDecode(row['weekdays'] as String) as List)
            .map(
                (day) => WeekDay.values.firstWhere((e) => e.toString() == day))
            .toList(),
        validationType: ValidationType.values
            .firstWhere((e) => e.toString() == row['validationType']),
        startDate: DateTime.parse(row['startDate'] as String),
        endDate: row['endDate'] != null
            ? DateTime.parse(row['endDate'] as String)
            : null,
        additionalMetrics: row['additionalMetrics'] != null
            ? List<String>.from(jsonDecode(row['additionalMetrics'] as String))
            : null,
        trackedDays: row['trackedDays'] != null
            ? (jsonDecode(row['trackedDays'] as String) as Map<String, dynamic>)
                .map((key, value) =>
                    MapEntry(DateTime.parse(key), value as String))
            : {},
      );
    }).toList();

    state = loadedData;
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) {
    return HabitNotifier();
  },
);
