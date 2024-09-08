import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class RecapDay {
  RecapDay({
    id,
    required this.sleepQuality,
    required this.wellBeing,
    required this.energy,
    required this.driveMotivation,
    required this.stress,
    required this.focusMentalClarity,
    required this.intelligenceMentalPower,
    required this.frustrations,
    required this.satisfaction,
    required this.selfEsteemProudness,
    required this.lookingForwardToWakeUpTomorrow,
    required this.date,
    this.recap,
    this.improvements,
    this.gratefulness,
    this.proudness,
    this.additionalMetrics,
  }) : id = id ?? idGenerator.v4();

  String id;
  double sleepQuality;
  double wellBeing;
  double energy;
  double driveMotivation;
  double stress;
  double focusMentalClarity;
  double intelligenceMentalPower;
  double frustrations;
  double satisfaction;
  double selfEsteemProudness;
  double lookingForwardToWakeUpTomorrow;
  DateTime date;
  String? recap;
  String? improvements;
  String? gratefulness;
  String? proudness;
  Map<String, dynamic>? additionalMetrics;
}
