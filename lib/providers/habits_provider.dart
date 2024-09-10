import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
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
          CREATE TABLE habits (
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
            trackedDays TEXT,
            orderIndex INTEGER NOT NULL,
            frequencyChanges TEXT,
            synced INTEGER
          )
        ''');
      },
    );
    return db;
  }

  void stateOrderChange(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    List<Habit> newState = List.from(state);
    Habit removedItem = newState.removeAt(oldIndex);
    newState.insert(newIndex, removedItem);
    state = newState;
  }

  Future<void> databaseOrderChange() async {
    final db = await getDatabase();
    Batch batch = db.batch();

    List<Habit> newState = List.from(state);
    newState.asMap().forEach((int index, Habit habit) {
      habit.orderIndex = index;
      batch.update(
        'habits',
        {'orderIndex': index}, // Set the new orderIndex
        where: 'id = ?', // Update the row where the id matches
        whereArgs: [habit.id],
      );
    });

    state = newState;
    // Commit the batch to execute all updates
    await batch.commit();
  }

  Future<void> addHabit(Habit newHabit) async {
    state = [...state, newHabit];

    final db = await getDatabase();
    await db.insert(
      'habits',
      {
        'id': newHabit.id,
        'userId': newHabit.userId,
        'icon': newHabit.icon.codePoint.toString(),
        'name': newHabit.name,
        'description': newHabit.description,
        'frequency': newHabit.frequency,
        'weekdays':
            jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
        'validationType': newHabit.validationType.toString(),
        'startDate': newHabit.startDate.toIso8601String(),
        'endDate': newHabit.endDate?.toIso8601String(),
        'additionalMetrics': newHabit.additionalMetrics != null
            ? jsonEncode(newHabit.additionalMetrics)
            : null,
        'trackedDays': jsonEncode(newHabit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
        'orderIndex': newHabit.orderIndex,
        'frequencyChanges': jsonEncode(newHabit.frequencyChanges
            .map((date, freq) => MapEntry(date.toIso8601String(), freq))),
        'synced': newHabit.synced ? 1 : 0,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(Habit targetHabit) async {
    state = state.where((habit) => habit.id != targetHabit.id).toList();

    final db = await getDatabase();
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [targetHabit.id],
    );
  }

  Future<void> updateHabit(Habit targetHabit, Habit newHabit) async {
    int index = state.indexOf(targetHabit);
    List<Habit> newState =
        state.where((habit) => habit.id != targetHabit.id).toList();
    newState.insert(index, newHabit);
    state = newState;

    // Update in SQLite database
    final db = await getDatabase();
    await db.update(
      'habits',
      {
        'id': newHabit.id,
        'userId': newHabit.userId,
        'icon': newHabit.icon.codePoint.toString(),
        'name': newHabit.name,
        'description': newHabit.description,
        'frequency': newHabit.frequency,
        'weekdays':
            jsonEncode(newHabit.weekdays.map((day) => day.toString()).toList()),
        'validationType': newHabit.validationType.toString(),
        'startDate': newHabit.startDate.toIso8601String(),
        'endDate': newHabit.endDate?.toIso8601String(),
        'additionalMetrics': newHabit.additionalMetrics != null
            ? jsonEncode(newHabit.additionalMetrics)
            : null,
        'trackedDays': jsonEncode(newHabit.trackedDays
            .map((date, id) => MapEntry(date.toIso8601String(), id))),
        'orderIndex': newHabit.orderIndex,
        'frequencyChanges': jsonEncode(newHabit.frequencyChanges
            .map((date, freq) => MapEntry(date.toIso8601String(), freq))),
        'synced': 0,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
      where: 'id = ?',
      whereArgs: [newHabit.id],
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
      'habits',
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
      'habits',
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
    // deleteDatabase('daily_recap.db');
    final db = await getDatabase();
    final data = await db.query('habits', orderBy: 'orderIndex ASC');

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
            .map((day) => WeekDay.values.firstWhere((e) => e.toString() == day))
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
        orderIndex: row['orderIndex'] as int,
        frequencyChanges: row['frequencyChanges'] != null
            ? (jsonDecode(row['frequencyChanges'] as String)
                    as Map<String, dynamic>)
                .map(
                    (key, value) => MapEntry(DateTime.parse(key), value as int))
            : {},
        synced: row['synced'] == 1,
      );
    }).toList();

    state = loadedData;
  }

  /// Get a list of the habit that are tracked at the target day 
  List<Habit> getTodayHabit(date) {
    return state.where((habit) => getHabitTrackingStatus(habit, date)).toList();
  }

  /// Helper function, check if the habit is tracked at the target day
  static bool getHabitTrackingStatus(Habit habit, DateTime date) {
      final bool isStarted = habit.startDate.isBefore(date) ||
          habit.startDate.isAtSameMomentAs(date);
      final bool isEnded = habit.endDate != null &&
          (habit.endDate!.isBefore(date) || habit.endDate!.isAtSameMomentAs(date));
      final bool isTracked =
          habit.weekdays.contains(WeekDay.values[date.weekday - 1]);
      return isStarted && !isEnded && isTracked;
  }

}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>(
  (ref) {
    return HabitNotifier();
  },
);
