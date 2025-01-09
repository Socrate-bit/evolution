import 'package:flutter/material.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';

Habit habit1 = Habit(
    userId: '00001',
    habitId: '00002',
    icon: Icons.self_improvement,
    name: 'Habit test 1',
    frequency: 5,
    weekdays: [],
    validationType: HabitType.recap,
    startDate: now,
    orderIndex: 1,
    color: Colors.green,
    duration: Duration(minutes: 1));

Habit habit2 = Habit(
    userId: '00001',
    habitId: '00002',
    icon: Icons.self_improvement,
    name: 'Habit test 2',
    frequency: 5,
    weekdays: [],
    validationType: HabitType.recap,
    startDate: now,
    orderIndex: 1,
    color: Colors.blue,
    duration: Duration(minutes: 1));

