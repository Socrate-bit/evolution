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
  int sleepQuality;
  int wellBeing;
  int energy;
  int driveMotivation;
  int stress;
  int focusMentalClarity;
  int intelligenceMentalPower;
  int frustrations;
  int satisfaction;
  int selfEsteemProudness;
  int lookingForwardToWakeUpTomorrow;
  DateTime date;
  String? recap;
  String? improvements;
  String? gratefulness;
  String? proudness;
  Map<String, dynamic>? additionalMetrics;
}
