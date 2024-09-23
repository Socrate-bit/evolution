import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

class RecapDay {
  RecapDay({
    recapId,
    required this.userId,
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
    required this.newHabit,
    this.gratefulness,
    this.proudness,
    this.altruism,
    this.additionalMetrics,
    this.synced = false,
  }) : recapId = recapId ?? idGenerator.v4();

  String recapId;
  String userId;
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
  bool newHabit;
  String? gratefulness;
  String? proudness;
  String? altruism;
  Map<String, dynamic>? additionalMetrics;
  bool synced;
}
