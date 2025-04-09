import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class HabitCategory {
  HabitCategory({
    required this.name,
    required this.color,
    categoryId,
  }) : categoryId = categoryId ?? idGenerator.v4();

  String name;
  Color color;
  String categoryId;

  factory HabitCategory.fromJson(Map<String, dynamic> json, {String? categoryId}) {
    return HabitCategory(
      name: json['name'] as String,
      color: Color(json['color'] as int),
      categoryId: json['categoryId'] ?? categoryId as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'categoryId': categoryId,
    };
  }

  HabitCategory copy({
    String? name,
    Color? color,
    String? categoryId,
  }) {
    return HabitCategory(
      name: name ?? this.name,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}