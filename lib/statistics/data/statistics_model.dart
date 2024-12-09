import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum StatType { habit, additionalMetrics, emotion, basic, custom }

enum AdditionalMetricsSubType { average, sum }

enum HabitVisualisationType {
  rating,
  percentCompletion,
  numberValidated,
  sumStreaks
}

enum BasicHabitSubtype {
  score,
  evaluation,
  completion,
  habitsValidated,
  bsumStreaks
}

enum CustomFormulaType { ratioBetweenTwo, additionBetweenTwo }

const Map<StatType, String> statTypeNames = {
  StatType.habit: 'Habit',
  StatType.additionalMetrics: 'Additional stats',
  StatType.emotion: 'Emotion',
  StatType.basic: 'Basic',
  StatType.custom: 'Custom',
};

const Map<AdditionalMetricsSubType, String> additionalMetricsSubTypeNames = {
  AdditionalMetricsSubType.average: 'Average',
  AdditionalMetricsSubType.sum: 'Sum',
};

const Map<HabitVisualisationType, String> habitVisualisationTypeNames = {
  HabitVisualisationType.rating: 'Rating',
  HabitVisualisationType.percentCompletion: 'Percent Completion',
  HabitVisualisationType.numberValidated: 'Number Validated',
  HabitVisualisationType.sumStreaks: 'Sum Streaks',
};

const Map<BasicHabitSubtype, String> basicHabitSubtypeNames = {
  BasicHabitSubtype.score: 'Score',
  BasicHabitSubtype.evaluation: 'Evaluation',
  BasicHabitSubtype.completion: 'Completion',
  BasicHabitSubtype.habitsValidated: 'Habits Validated',
  BasicHabitSubtype.bsumStreaks: 'Sum Streaks',
};

const Map<CustomFormulaType, String> customFormulaTypeNames = {
  CustomFormulaType.ratioBetweenTwo: 'Ratio Between Two',
  CustomFormulaType.additionBetweenTwo: 'Addition Between Two',
};

class Stat {
  final String statId;
  final String users;
  final dynamic ref;
  final StatType type;
  final dynamic formulaType;
  final double? maxY;
  final String name;
  final Color color;
  final int index;

  Stat({
    statId,
    required this.users,
    required this.type,
    this.ref,
    required this.name,
    required this.color,
    required this.index,
    this.formulaType,
    this.maxY,
  }) : statId = statId ?? idGenerator.v4();

  Map<String, dynamic> toJson() {
    StatType type = this.type;

    return {
      'id': statId,
      'users': users,
      'type': type.toString().split('.').last,
      'ref': this.type == StatType.additionalMetrics
          ? '${ref.$1}<.>${ref.$2}'
          : ref,
      'name': name,
      'color': color.value,
      'index': index,
      'formulaType': formulaType?.toString().split('.').last,
      'maxY': maxY,
    };
  }

  factory Stat.fromJson(Map<String, dynamic> json) {
    dynamic formulaType;
    dynamic finalRef;
    
    if (json['formulaType'] != null) {
      formulaType = _getFormulaType(json['formulaType']);
    }

    StatType type = StatType.values
        .firstWhere((e) => e.toString() == 'StatType.' + json['type']);

    if (type == StatType.additionalMetrics) {
      List<String> ref = json['ref'].split('<.>');
      finalRef = (ref[0], ref[1]);
    }

    return Stat(
      statId: json['id'],
      users: json['users'],
      type: type,
      ref: finalRef ?? json['ref'],
      name: json['name'],
      color: Color(json['color']),
      index: json['index'],
      formulaType: formulaType,
      maxY: json['maxY'],
    );
  }

  static dynamic _getFormulaType(String formulaType) {
    for (var enumType in [
      AdditionalMetricsSubType.values,
      HabitVisualisationType.values,
      BasicHabitSubtype.values,
      CustomFormulaType.values
    ]) {
      try {
        return enumType
            .firstWhere((e) => e.toString().split('.').last == formulaType);
      } catch (e) {
        // Continue searching in the next enum type
      }
    }
    return null; // or throw an exception if you prefer
  }

  Stat copyWith({
    String? statId,
    String? users,
    StatType? type,
    dynamic ref,
    String? name,
    Color? color,
    int? index,
    dynamic formulaType,
    double? maxY,
  }) {
    return Stat(
      statId: statId ?? this.statId,
      users: users ?? this.users,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      name: name ?? this.name,
      color: color ?? this.color,
      index: index ?? this.index,
      formulaType: formulaType ?? this.formulaType,
      maxY: maxY ?? this.maxY,
    );
  }
}
