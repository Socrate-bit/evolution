import 'package:uuid/uuid.dart';

const idGenerator = Uuid();

enum Emotion {
  wellBeing,
  sleepQuality,
  energy,
  driveMotivation,
  stress,
  focusMentalClarity,
  intelligenceMentalPower,
  frustrations,
  satisfaction,
  selfEsteemProudness,
  lookingForwardToWakeUpTomorrow,
}

const Map<Emotion, String> emotionDescriptions = {
  Emotion.wellBeing: 'Well-being',
  Emotion.sleepQuality: 'Sleep',
  Emotion.energy: 'Energy',
  Emotion.driveMotivation: 'Motivation',
  Emotion.stress: 'Stress',
  Emotion.focusMentalClarity: 'Focus & Clarity',
  Emotion.intelligenceMentalPower: 'Mental performance',
  Emotion.frustrations: 'Frustrations',
  Emotion.satisfaction: 'Satisfaction',
  Emotion.selfEsteemProudness: 'Self-Esteem',
  Emotion.lookingForwardToWakeUpTomorrow: 'Looking forward tomorrow',
};

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
    this.emotionalRecap,
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
  String? emotionalRecap;
  String? gratefulness;
  String? proudness;
  String? altruism;
  Map<String, dynamic>? additionalMetrics;
  bool synced;

  dynamic getProperty(String propertyName) {
    var properties = {
      'recapId': recapId,
      'userId': userId,
      'sleepQuality': sleepQuality,
      'wellBeing': wellBeing,
      'energy': energy,
      'driveMotivation': driveMotivation,
      'stress': stress,
      'focusMentalClarity': focusMentalClarity,
      'intelligenceMentalPower': intelligenceMentalPower,
      'frustrations': frustrations,
      'satisfaction': satisfaction,
      'selfEsteemProudness': selfEsteemProudness,
      'lookingForwardToWakeUpTomorrow': lookingForwardToWakeUpTomorrow,
      'date': date,
      'recap': recap,
      'improvements': improvements,
      'emotionalRecap': emotionalRecap,
      'gratefulness': gratefulness,
      'proudness': proudness,
      'altruism': altruism,
      'additionalMetrics': additionalMetrics,
      'synced': synced,
    };
    return properties[propertyName];
  }
}
