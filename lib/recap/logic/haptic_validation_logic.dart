import 'package:flutter/services.dart';
import 'package:tracker_v1/effects/effects_service.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';

void validationHaptic(HabitRecap newTrackedDay, HabitRecap? oldTrackedDay) {
  if (newTrackedDay.done == Validated.yes &&
      oldTrackedDay?.done != Validated.yes) {
    EffectsService().playValidated();
    HapticFeedback.heavyImpact();
  } else if (newTrackedDay.done == Validated.no &&
      oldTrackedDay?.done != Validated.no) {
    EffectsService().playFaillure();
    HapticFeedback.lightImpact();
  }
}
